# On-Prem GitOps App Platform

This is a small, "on-prem-like" Kubernetes environment which runs locally within
Kind. It's bootstrapped via GitOps with Terraform and Argo CD, and contains a
simple public web app.

## Setup

If you're running this locally, your tailnet name is different from mine. Find
all references to the tailnet using `task fd-tailnet`, then substitute your own
tailnet's name. You'll likely want to fork the repo and commit the changes too,
so they aren't overridden by ArgoCD.

### Install tools

- OpenTofu (can be substituted for terraform by updating Taskfile.yml)
- Kind
- Kubectl

### Dev tools

- helmfile
- kustomize

### Bootstrap

Afterwards, run `task up`, which runs OpenTofu to create a Kind cluster with
ArgoCD, Cilium (CNI) and Tailscale. Please note that you'll need a Tailscale
OAuth client to bootstrap the tailscale-operator with the right permissions. You
can create an OAuth client
[here](https://login.tailscale.com/admin/settings/oauth).

## CNI & Ingress Choice

Cilium was chosen to provide both the CNI & Ingress/Gateway API. This is due to
my previous experience with it, but also due to the robust performance,
flexibility in installed environment, and capabilities that are useful for
on-prem environments.

Cilium comes with support for Ingress & Gateway API via Envoy, and integrates
with it to provide a L7 security enforcement point. We can leverage
CiliumNetworkPolicy to filter on domain names, such as on egress to a
third-party API.

## TODO

If I had more time, I'd implement the following:

1. Policies via Kyverno

- Validate signed images w/ cosign
- Prevent unsafe defaults (argocd project, namespace, etc.)

2. Network microsegmentation

- Use CiliumNetworkPolicy to segment network & enforce traffic flows

3. Secure configuration

- Scan manifests using kubescape/trivy in CI
- Enforce pod security admission restricted standards

4. Full Observability Stack

- The setup here isn't worth the squeeze for such a small example project
- Grafana/Prometheus/Loki/Tempo

Things that didn't quite make sense to implement for this project:

1. Full TLS via LetsEncrypt - introduces network requirements
2. Progressive Delivery - not enough traffic to reliably catch bugs
3. Self-hosted CI runner - possible, but makes more sense on-prem, rather than
   when deploying Kind clusters. Tailscale arguably makes this easier
4. Secrets management - Only 1 secret to manage, created on the fly by TF

## Repo structure

```
.
├── app         # hello-world Rust app
├── docs
│   └── adrs    # Example ADRs that should be expanded upon
├── gitops
│   ├── apps    # Custom apps - main reason to deploy cluster
│   └── infra   # Third-party apps providing infra
├── infra       # TF to bootstrap cluster & infra
└── scripts     # Helper scripts in managing manifests
```
