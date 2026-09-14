# Azure Deployment Plan

> **Status:** Executing

Generated: 2026-09-14

---

## 1. Project Overview

**Goal:** Prepare two separate GitHub Actions workflows:

1. Provision an Azure App Service Web App.
2. Package and deploy website artifacts/content to that Web App afterward.

Provisioning and content deployment will remain separate so the infrastructure workflow runs only when Azure resources need to be created or updated, while the content workflow can run repeatedly.

**Path:** Modernize Existing

The repository currently contains only a `README.md` and a demonstration GitHub Actions workflow. No website source, Azure infrastructure, or deployment configuration is present.

---

## 2. Requirements

| Attribute | Value |
|-----------|-------|
| Classification | POC |
| Scale | Small: under 1,000 users |
| Budget | Cost-Optimized |
| Compliance | No special requirements stated |
| Hosting | Azure App Service Web App on Windows |
| Runtime | Static HTML/CSS/JavaScript content |
| Location | Central India (`centralindia`) |
| Authentication | GitHub Actions OIDC with a federated Microsoft Entra application |
| Subscription | `Pay-As-You-Go` display name supplied; subscription GUID still required as `AZURE_SUBSCRIPTION_ID` |
| Resource group | `rg-az400-web` |
| Web App name | `webiktest` |
| Website content path | `website/` (directory selected; `website/index.html` must be added before deployment) |

The subscription, resource group, globally unique Web App name, and website artifact/content path must be supplied before implementation.

---

## 3. Components Detected

| Component | Type | Technology | Path |
|-----------|------|------------|------|
| Repository documentation | Documentation | Markdown | `README.md` |
| Existing workflow | CI demonstration | GitHub Actions YAML | `.github/workflows/main.yml` |
| Website application | Not detected | No HTML/CSS/JavaScript source found | Not present |

### Existing Infrastructure

| Item | Status |
|------|--------|
| `azure.yaml` | Not found |
| `infra/` | Not found |
| Dockerfiles | Not found |
| Azure deployment workflows | Not found |
| GitHub OIDC configuration | Not found |

---

## 4. Recipe Selection

**Selected:** Bicep deployed from GitHub Actions with Azure CLI

**Rationale:**

- The requested deliverable is GitHub Actions rather than an AZD environment.
- Bicep provides repeatable declarative provisioning for the Windows App Service plan and Web App.
- `azure/login` with OIDC avoids storing long-lived Azure credentials.
- `azure/webapps-deploy` is appropriate for the separate website content deployment workflow.
- No existing Terraform, AZD, or Azure infrastructure conventions need to be preserved.

---

## 5. Architecture

**Stack:** App Service

### Service Mapping

| Component | Azure Service | SKU |
|-----------|---------------|-----|
| Windows hosting plan | `Microsoft.Web/serverfarms` | Cost-optimized Windows SKU, to be confirmed for `centralindia` |
| Website | `Microsoft.Web/sites` | Windows Web App |
| Website artifact | App Service ZIP deployment | GitHub Actions artifact |

### Supporting Services

| Service | Purpose |
|---------|---------|
| Microsoft Entra federated credential | Secretless GitHub Actions OIDC authentication |
| Managed Identity | Not required for the static site; may be enabled for future Azure access |
| Application Insights | Not included in the initial cost-optimized POC |
| Key Vault | Not included because no application secrets are currently required |
| Log Analytics | Not included initially; can be added if operational monitoring is required |

### Workflow Design

| Workflow | Trigger | Responsibilities |
|----------|---------|------------------|
| Provision Azure Web App | Manual dispatch | Authenticate with OIDC, deploy Bicep, create/update the App Service plan and Web App, and report the Web App URL |
| Deploy Website Content | Manual dispatch and/or push to the confirmed content path | Package the selected website content, authenticate with OIDC, and deploy the ZIP package to the existing Web App |

Expected GitHub configuration:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_RESOURCE_GROUP`
- `AZURE_WEBAPP_NAME`
- Optional App Service plan SKU and website content-path variables

---

## 6. Provisioning Limit Checklist

### Phase 1: Resource Inventory

| Resource Type | Number to Deploy | Total After Deployment | Limit/Quota | Notes |
|---------------|------------------|------------------------|-------------|-------|
| `Microsoft.Web/serverfarms` (Windows) | 1 | Requires subscription lookup | Requires subscription/region lookup | Final SKU must be confirmed |
| `Microsoft.Web/sites` (Windows Web App) | 1 | Requires subscription lookup | Requires subscription/region lookup | App name must be globally unique |

### Phase 2: Capacity Validation

**Status:** Blocked pending the Azure subscription GUID and Azure CLI access. Azure CLI is unavailable in the current workspace, so subscription access, current resource counts, and quota values cannot be fetched yet.

Before implementation, invoke the `azure-quotas` skill for `centralindia` and record actual usage, limits, totals, and data sources here. Do not deploy while this validation is incomplete.

---

## 7. Execution Checklist

### Planning

- [x] Analyze the repository
- [x] Gather classification, scale, budget, compliance, hosting, runtime, and authentication requirements
- [x] Select `centralindia`
- [ ] Confirm Azure subscription GUID for `Pay-As-You-Go`
- [x] Confirm resource group: `rg-az400-web`
- [x] Confirm globally unique Web App name: `webiktest`
- [x] Confirm website content/artifact path: `website/`
- [ ] Complete quota and capacity validation
- [x] Select Bicep plus GitHub Actions
- [x] Plan App Service architecture
- [ ] User approves this plan

### Execution — after approval and input completion

- [ ] Research App Service and GitHub OIDC references
- [x] Create `infra/main.bicep`
- [x] Create `.github/workflows/provision-azure-webapp.yml`
- [x] Create `.github/workflows/deploy-website.yml`
- [ ] Document federated credential and Azure RBAC setup
- [ ] Validate workflows and infrastructure
- [ ] Update status to `Ready for Validation`

### Validation

- [ ] Invoke `azure-validate`
- [ ] Record validation proof
- [ ] Update status to `Validated`

### Deployment

- [ ] Invoke `azure-deploy` only when deployment is requested
- [ ] Verify deployment
- [ ] Update status to `Deployed`

---

## 8. Files to Generate After Approval

| File | Purpose | Status |
|------|---------|--------|
| `.azure/plan.md` | Source-of-truth deployment plan | ✅ |
| `infra/main.bicep` | Windows App Service plan and Web App | ⏳ |
| `.github/workflows/provision-azure-webapp.yml` | Provisioning workflow | ⏳ |
| `.github/workflows/deploy-website.yml` | Separate content deployment workflow | ⏳ |

---

## 9. Next Steps

1. Provide the Azure subscription, resource group, globally unique Web App name, and website content/artifact path.
2. Complete quota validation for the selected subscription and `centralindia`.
3. Approve this plan before generating infrastructure or workflow files.
