# Cross-Repo Compatibility Analysis Report

## Overall Status: ⚠️ 4 Issues Found

Most of the system is correctly wired together. However, there are 4 specific issues that will definitely cause failures.

---

## 🔴 Issue 1: CRITICAL — Missing IRSA Roles in Terraform

**Repos Affected:** `caresync-gitops` ↔ `caresync-infra`

**The Problem:**
Your Helm ServiceAccounts reference **8 IAM roles** that Terraform needs to create, but Terraform only creates **4 of them**. The following 4 roles exist in Helm but are MISSING from `caresync-infra/terraform/modules/iam-irsa/main.tf`:

| Role Name (Expected by Helm SA) | Status in Terraform |
|---|---|
| `caresync-dev-eso-role` | ✅ Created |
| `caresync-dev-ai-service-role` | ✅ Created |
| `caresync-dev-doc-service-role` | ✅ Created |
| `caresync-dev-albc-role` | ✅ Created |
| `caresync-dev-auth-service-role` | ❌ **MISSING** |
| `caresync-dev-user-service-role` | ❌ **MISSING** |
| `caresync-dev-appointment-service-role` | ❌ **MISSING** |
| `caresync-dev-notification-service-role` | ❌ **MISSING** |
| `caresync-dev-frontend-role` | ❌ **MISSING** |

**What will happen:** When ArgoCD deploys the Helm chart, the 5 ServiceAccounts will have an ARN pointing to a non-existent IAM role. This causes the IRSA token injection to silently fail, meaning your pods will run with NO AWS permissions and crash when trying to access the database.

**Fix needed:** Add 5 more `aws_iam_role` resources to `iam-irsa/main.tf`.

---

## 🔴 Issue 2: CRITICAL — `values.yaml` Has Hardcoded OLD ALB URL

**Repos Affected:** `caresync-gitops` ↔ `caresync-infra`

**The Problem:**
`caresync-gitops/helm/values.yaml` has this hardcoded:
```yaml
apiBaseUrl: "http://k8s-caresync-caresync-cfc825078f-579067473.us-east-1.elb.amazonaws.com"
```
And `caresync-infra/terraform/modules/secrets-manager/main.tf` also hardcodes the same URL:
```hcl
frontend_url = "http://k8s-caresync-caresync-cfc825078f-579067473.us-east-1.elb.amazonaws.com"
api_base_url = "http://k8s-caresync-caresync-cfc825078f-579067473.us-east-1.elb.amazonaws.com/api"
```

This was the URL from your **old, now-deleted cluster**. Every time the trainer wipes resources and you rebuild, the ALB will get a new random URL. The frontend will point to a dead address and fail to contact the backend APIs.

**Fix needed:** We will update this once the new cluster is live. We need a mechanism to pipe the new ALB URL from Terraform output into the `values.yaml` automatically.

---

## 🟡 Issue 3: WARNING — `values-dev.yaml` is Empty

**Repos Affected:** `caresync-gitops` ↔ `caresync-app` workflows

**The Problem:**
`caresync-gitops/helm/values-dev.yaml` is completely empty (just a comment):
```yaml
# Dev-specific overrides
# These would typically be populated by a CI/CD pipeline
```

Your CI/CD workflows write the new image tag to this file using `yq`. But because `values.yaml` already sets all tags to `latest`, the actual field paths your `yq` command writes to don't exist in `values-dev.yaml` yet. The `yq` command will simply **append** a new root-level key instead of overriding the nested `services.authService.tag`, which means ArgoCD will continue reading `latest` from `values.yaml` instead of the new tag.

**Fix needed:** Pre-populate `values-dev.yaml` with the proper structure so `yq` can correctly override the tags.

---

## 🟡 Issue 4: WARNING — `contents: read` Permission Blocks GitOps Push

**Repos Affected:** `caresync-app` workflows

**The Problem:**
All 7 workflow files have:
```yaml
permissions:
  id-token: write
  contents: read
```

The `contents: read` permission is fine for most things, but the `update-helm-values` job pushes to `caresync-gitops` using a `MANIFEST_REPO_PAT` secret. This is fine because it uses a PAT (personal access token), not the default `GITHUB_TOKEN`. However, if anyone ever tries to combine these repos or the PAT expires, the `contents: read` on the default GITHUB_TOKEN will silently block. This is low risk but worth noting.

---

## ✅ Everything Else is Correct

| Check | Status |
|---|---|
| ECR repo names (`caresync/auth-service` etc.) match between Terraform and workflows | ✅ |
| AWS Account ID `664685894054` is consistent in all workflows and Terraform | ✅ |
| Helm `secrets.name` matches `ExternalSecret` target name (`caresync-app-secrets`) | ✅ |
| ArgoCD `caresync-dev.yaml` points to correct repo URL and `helm/` path | ✅ |
| `ClusterSecretStore` references correct `external-secrets-sa` service account | ✅ |
| ESO role ARN in SA matches `caresync-dev-eso-role` created by Terraform | ✅ |
| All HTTPRoutes reference port `80` which matches all `service.yaml` definitions | ✅ |
| Frontend ConfigMap `frontend-config` is defined and mounted correctly | ✅ |
| All deployments have correct resource limits (cpu/memory) as required | ✅ |
| HPA `maxReplicas: 3` is set correctly on all services | ✅ |
| PDB `minAvailable: 1` is set correctly on all services | ✅ |
| S3 backend bucket name matches between `bootstrap/main.tf` and `versions.tf` | ✅ |
| All workflow `yq` keys match Helm `values.yaml` structure | ✅ |
| Docker Buildx `--platform linux/amd64` correctly targets EKS node architecture | ✅ |

---

## Summary: What Needs to Be Fixed

| Priority | Issue | Fix |
|---|---|---|
| 🔴 CRITICAL | 5 missing IRSA roles in Terraform | Add roles to `iam-irsa/main.tf` |
| 🔴 CRITICAL | Hardcoded dead ALB URL in `values.yaml` and Terraform | Fix after first cluster rebuild |
| 🟡 WARNING | `values-dev.yaml` is empty | Pre-populate with service tag structure |
| 🟡 WARNING | Workflow permission note | Low risk, informational only |
