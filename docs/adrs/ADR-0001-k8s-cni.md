---
status: Accepted
date: 08/15/2025
decision-makers: Ryan Seipp
---

# Kubernetes CNI

## Context and Problem Statement

Kubernetes requires a CNI plugin to control and configure networking between
pods, and to/from the cluster. The CNI must be "on-prem-like", and particularly
suited for driving massive amounts of data over the network. Additionally, it
should ideally have security and ingress built-in so other choices do not need
to be made.

## Decision Drivers

- On-prem-like: particularly suited for driving massive amounts of data over the
  network.
- Ideally has security and ingress (or Gateway API) support built-in.
- Straightforward to configure in a GitOps manner.
- Is not bloated with extra features we don't need

## Considered Options

- Cilium
- Calico
- Flannel

## Decision Outcome

Chosen option: Cilium, primarily due to its robust performance, and tight
integration with security tooling (CiliumNetworkPolicy) and Ingress/Gateway-API
support via Envoy.

### Consequences

- Robust CNI that delivers on performance
- Easiest to configure due to prior experience
- Integration with security and ingress or Gateway API

* Security at L7 due to Envoy integration

### Confirmation

The Kind Cluster will be configured declaratively with the Cilium CNI with
Gateway API support enabled.

## More Information

- [Cilium](https://cilium.io/)
- [Cilium Ingress](https://docs.cilium.io/en/stable/network/servicemesh/ingress/)
- [Cilium Gateway API](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/)
- [CiliumNetworkPolicy](https://docs.cilium.io/en/stable/network/kubernetes/policy/)
- [Calico](https://docs.tigera.io/calico/latest/about/)
- [Calico Gateway API](https://docs.tigera.io/calico/latest/networking/gateway-api)
- [Flannel](https://github.com/flannel-io/flannel)
