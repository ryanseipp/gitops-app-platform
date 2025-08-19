# On-Prem GitOps App Platform (Mini)

## What you’ll build

Stand up a small, “on-prem-like” Kubernetes environment on your machine (or a
local VM), bootstrap GitOps with Argo CD (or equivalent), and deploy a sample
web app behind an Ingress with DNS. Automate as much as possible using Terraform
and/or a config-management tool (Ansible/Chef). Wire up CI (GitHub Actions) to
build/scan the image and push changes through GitOps.

## Constraints (simulate on-prem)

- Cluster: Use one of: k3s, k3d, kind, MicroK8s, or another local/on-prem-style
  K8s install.
- Ingress Controller: Any ingress controller you prefer (document your choice
  and why).
- DNS: Try to use a DNS / Magic DNS setup and not IP address to make the
  application externally accessible. (Tailscale k8s operator would be nice to
  see here)
- GitOps: Argo CD (preferred) or Flux (or other automated deployment
  controller).
- CI/CD: GitHub Actions.
- Automation: Use Terraform / config management for infra/bootstrap where
  sensible.
- Security: Include basic hardening (see “Security requirements”).

## Deliverables

- Public GitHub repo containing: Possible Structure:
  - docs/: architecture diagram + README
  - infra/: Terraform and/or config-management to stand up the cluster +
    bootstrap GitOps controller + install ingress controller of your choice
  - gitops/: manifests, Helm charts, or Kustomize configs for your app(s)
  - app/: small web app (or a known “hello world” container) with Dockerfile
  - .github/workflows/: CI pipelines
  - Makefile (or Taskfile) for common actions (make up, make destroy, etc.)

### Functional requirements (baseline)

1. Cluster bootstrap

- Infra automation brings up a local K8s cluster.
- Installs and configures an ingress controller (choice is yours, explain why
  you picked it).
- Installs and configures a GitOps deployment tool (Argo CD, Flux, etc.).

2. Application deployment via GitOps

- Deploy a simple web app serving JSON with:
  - app name
  - build SHA
  - current timestamp (from inside the pod)
- Accessible via Ingress at http://app.<LOCAL-IP>.sslip.io/,
  https://app<name>.<tailnet name>.net (or equivalent).
- Include readiness/liveness probes, resource requests/limits, and a safe update
  strategy.

3. CI/CD

- GitHub Actions workflow to:
  - build container image
  - run basic test(s)
  - scan image (e.g., Trivy)
  - push image to a registry (GHCR or local)
  - update GitOps layer by digest, not :latest

4. Security requirements (minimum)

- Pin container images by digest in manifests.
- RBAC: app runs under a dedicated ServiceAccount with least privilege.
- Secrets handled securely (no plaintext in repo).

5. SRE/operability (minimum)

- HPA with safe min/max.
- Basic observability (metrics, annotations, or alerts).

6. DNS/Ingress

- Functional hostname using magic DNS service (document exact URL).

### Stretch goals

- TLS with cert-manager (self-signed OK)
- Policy enforcement (OPA Gatekeeper, Kyverno)
- Progressive delivery (Argo Rollouts or similar)
- Self-hosted CI runner

## Evaluation criteria

- Reproducibility & Docs – one-command bootstrap, clear troubleshooting steps.
- GitOps & Deployment Quality – clean manifests, automated sync, healthy status.
- Ingress/DNS & SRE Basics – reachable app, proper probes, autoscaling, PDB.
- Security – digest pinning, RBAC, network policy, secret handling.
- CI/CD – build/test/scan/publish/update flow, IaC checks.
- Code Quality & Decisions – clear commits, rationale for choices.
