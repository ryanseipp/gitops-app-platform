# Reuse manifests templated from helm charts so they're consistent when ArgoCD bootstraps.
# This also allows us to rerun TF as needed without worrying about breaking stuff in-cluster.
data "kubectl_kustomize_documents" "argocd_manifests" {
  target = "../gitops/infra/argocd"
}

data "kubectl_kustomize_documents" "cilium_manifests" {
  target = "../gitops/infra/cilium"
}

data "kubectl_kustomize_documents" "tailscale_manifests" {
  target = "../gitops/infra/tailscale"
}

# Create the cluster, with 1 control-plane node and 3 workers for HA
resource "kind_cluster" "default" {
  name = "test-cluster"

  kind_config {
    api_version = "kind.x-k8s.io/v1alpha4"
    kind        = "Cluster"

    node {
      role = "control-plane"
    }
    node {
      role = "worker"
      kubeadm_config_patches = [
        <<-EOT
        kind: JoinConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            register-with-taints: "node.cilium.io/agent-not-ready=true:NoExecute"
        EOT
      ]
    }
    node {
      role = "worker"
      kubeadm_config_patches = [
        <<-EOT
        kind: JoinConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            register-with-taints: "node.cilium.io/agent-not-ready=true:NoExecute"
        EOT
      ]
    }
    node {
      role = "worker"
      kubeadm_config_patches = [
        <<-EOT
        kind: JoinConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            register-with-taints: "node.cilium.io/agent-not-ready=true:NoExecute"
        EOT
      ]
    }

    networking {
      disable_default_cni = true
    }
  }
}

# Ensure we have a CNI installed so pods can run and access network resources
resource "kubectl_manifest" "cilium" {
  count     = length(data.kubectl_kustomize_documents.cilium_manifests.documents)
  yaml_body = element(data.kubectl_kustomize_documents.cilium_manifests.documents, count.index)
}

# Bootstrap ArgoCD
resource "kubectl_manifest" "argocd_namespace" {
  yaml_body = element(data.kubectl_kustomize_documents.argocd_manifests.documents, 0)
}
resource "kubectl_manifest" "argocd" {
  count     = length(data.kubectl_kustomize_documents.argocd_manifests.documents) - 1
  yaml_body = element(data.kubectl_kustomize_documents.argocd_manifests.documents, count.index + 1)

  depends_on = [kubectl_manifest.argocd_namespace]
}

# Only creating tailscale through TF so we can create the namespace & inject the oauth secret
resource "kubectl_manifest" "tailscale_namespace" {
  yaml_body = element(data.kubectl_kustomize_documents.tailscale_manifests.documents, 0)
}

# Create the OAuth client the operator needs
# https://tailscale.com/kb/1236/kubernetes-operator#prerequisites
resource "tailscale_oauth_client" "tailscale_operator" {
  description = "gitops-app-platform tailscale-operator"
  scopes      = ["devices:core", "auth_keys"]
  tags        = ["tag:k8s-operator"]
}

# Inject the secret into the tailscale namespace. Also lets us rotate secrets if compromised
resource "kubectl_manifest" "tailscale_operator_oauth" {
  yaml_body = <<-EOT
    apiVersion: v1
    kind: Secret
    metadata:
      name: operator-oauth
      namespace: tailscale
    stringData:
      client_id: ${tailscale_oauth_client.tailscale_operator.id}
      client_secret: ${tailscale_oauth_client.tailscale_operator.key}
    EOT

  depends_on = [kubectl_manifest.tailscale_namespace]
}

resource "kubectl_manifest" "tailscale" {
  count     = length(data.kubectl_kustomize_documents.tailscale_manifests.documents) - 1
  yaml_body = element(data.kubectl_kustomize_documents.tailscale_manifests.documents, count.index + 1)

  depends_on = [kubectl_manifest.tailscale_operator_oauth]
}

