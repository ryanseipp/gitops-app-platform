terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.9.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }
}

provider "kind" {}

provider "kubectl" {
  config_path       = kind_cluster.default.kubeconfig_path
  apply_retry_count = 3
}
