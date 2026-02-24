# Platform Lab — GitOps on GKE

This repository contains a platform engineering lab built on Google Kubernetes Engine using Terraform, Argo CD and Kustomize. The goal was to put together a realistic end‑to‑end setup that can be created, operated and destroyed entirely from code, without relying on manual cluster changes.

It’s intentionally simple in terms of workload, but the surrounding platform concerns are the focus: infrastructure definition, GitOps delivery, environment separation, validation and operational hygiene.

---

## Overview

The platform consists of:

- Terraform provisioning for GCP networking and a GKE cluster, with remote state stored in GCS
- Kubernetes manifests structured using Kustomize (base + environment overlays)
- Argo CD managing deployments using the Application‑of‑Applications pattern
- Argo CD Projects enforcing environment boundaries
- CI checks to validate Terraform and Kubernetes manifests before merge
- Namespace guardrails using ResourceQuota and LimitRange
- A defined teardown process to remove all resources cleanly

Everything is driven from Git so the cluster state is reproducible.

---

## Design choices

### Terraform with remote state

Infrastructure is defined entirely in Terraform with a remote backend. This keeps the environment reproducible and avoids local state drift.

### Kustomize overlays

Applications use a shared base with environment overlays (dev, preprod, prod). This keeps manifests consistent while allowing controlled differences per environment.

### Argo CD as the deployment mechanism

Argo CD handles reconciliation from Git. Application definitions are also stored in Git using the Application‑of‑Applications approach so bootstrapping a cluster only requires applying the root application.

### Limited exposure of Argo CD

Argo CD is kept internal (ClusterIP) and accessed via port‑forwarding rather than exposing it publicly. This keeps access simple while avoiding unnecessary external surface area.

### Environment isolation

Argo CD Projects restrict which namespaces applications can deploy to. This prevents accidental cross‑environment deployments.

### CI validation

GitHub Actions runs:

- terraform fmt and validate
- Kustomize render checks
- kubeconform schema validation

This ensures invalid configuration fails before reaching the cluster.

### Promotion approach

Container image versions are pinned per environment overlay. Promotion is handled by updating tags rather than rebuilding artefacts per environment.

### Namespace guardrails

ResourceQuota and LimitRange provide basic resource governance and defaults for workloads.

### Teardown

Terraform destroy removes infrastructure cleanly. The platform is designed so nothing persists outside Terraform or Git.

---

## Repository structure

```
infra/
  envs/
  modules/

apps/
  base/
  overlays/
  applications/
  projects/
  guardrails/
```

---

## Lifecycle

1. Terraform provisions networking and GKE.
2. Argo CD is installed.
3. The root Argo application is applied.
4. Argo creates applications, projects and guardrails from Git.
5. Changes are made via pull requests and validated in CI.
6. Argo reconciles automatically.
7. Terraform destroy removes infrastructure when finished.

---

## Possible extensions

Areas that would be added in a longer‑lived setup:

- Workload Identity and tighter IAM boundaries
- External Secrets integration
- Policy enforcement (Kyverno or Gatekeeper)
- Observability stack
- Additional services to demonstrate multi‑app operation

---

## Notes

This repo is intended as a working reference for how the pieces fit together rather than a production template. It focuses on structure, workflow and control rather than application complexity.
