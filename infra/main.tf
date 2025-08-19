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
