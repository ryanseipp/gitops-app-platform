---
status: Accepted
date: 08/15/2025
decision-makers: Ryan Seipp
---

# Local, "On-Prem-Like" Kubernetes Environment

## Context and Problem Statement

We need to spin up "on-prem-like" Kubernetes environments such that we can
deploy resources and display knowledge and experience with tooling.
"On-prem-like" is defined to be a Kubernetes distribution where storage,
networking, and compute are not solved for you, such as by a cloud provider.

## Decision Drivers

- Runs locally, such as in Docker
- Supports later tooling choices we want
- Is not bloated with extra features we don't need

## Considered Options

- Kind
- k3s
- k3d
- MicroK8s

## Decision Outcome

Chosen option: Kind, primarily because it runs in Docker (as opposed to k3s and
MicroK8s), and has great support from the Cilium CNI (as opposed to k3d).

### Consequences

- Good tooling support as it is the standard tool used to test operators and
  Kubernetes itself.
- Extra effort as CNI is not chosen by default.

### Confirmation

A Kind cluster will be spun up from configuration locally, and in CI to test the
implementation.

## More Information

- [Cilium](https://cilium.io/)
- [Cilium Kind install](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/)
- [Kind](https://kind.sigs.k8s.io/)
- [K3d](https://k3d.io/stable/)
- [K3s](https://k3s.io/)
- [MicroK8s](https://microk8s.io/)
