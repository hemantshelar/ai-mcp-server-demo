# Azure Phase 1 bootstrap (GitHub Actions OIDC)

Creates **minimum** resources so GitHub Actions can sign in with **OIDC** (no client secret):

- Resource group **`rg-ai-mcp-server-demo-{env}`** in **Australia East**
- User-assigned managed identity **`MI_ai-mcp-server-demo-{env}`**
- **RBAC**: that identity can manage resources in the resource group (below uses **Contributor** on the RG)
- **Federated identity credential** linking **GitHub Actions** to the managed identity

Repeat the steps for **`dev`** and **`prod`** (separate resource groups and identities).

**Prerequisites:** [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (`az`), rights to create resource groups, managed identities, role assignments, and federated credentials in your subscription.

## Option A — Bicep (recommended)

Shared module (always used):

- [`infra/bicep/modules/managed-identity-github.bicep`](../infra/bicep/modules/managed-identity-github.bicep) — UAMI + FIC + **Contributor** on the resource group

### A1 — Subscription deployment (creates the resource group)

Use [`infra/bicep/subscription.bicep`](../infra/bicep/subscription.bicep) to create **`rg-ai-mcp-server-demo-{env}`** and deploy Phase 1 in one step. **`location`** defaults to **`australiaeast`**; override in parameters if needed.

- [`infra/bicep/parameters/subscription.dev.bicepparam`](../infra/bicep/parameters/subscription.dev.bicepparam) / [`subscription.prod.bicepparam`](../infra/bicep/parameters/subscription.prod.bicepparam)

**1.** Edit the `.bicepparam` file: set **`githubOrg`** and **`githubRepo`** (optional: add `param location = '...'` to override region).

**2.** Deploy at **subscription** scope (requires rights to deploy at subscription level, e.g. **Contributor** on the subscription or a custom role that can create resource groups):

```bash
az deployment sub create \
  --name demo-phase1-dev \
  --location australiaeast \
  --template-file infra/bicep/subscription.bicep \
  --parameters infra/bicep/parameters/subscription.dev.bicepparam
```

Use a unique `--name` per deployment. **`--location`** is the region Azure uses for deployment metadata (match **`australiaeast`**).

**3.** Read outputs (example):

```bash
az deployment sub show --name demo-phase1-dev --query properties.outputs -o json
```

Then set GitHub variables as in [§ 7](#7-github-configuration).

Validate locally:

```bash
az bicep build --file infra/bicep/subscription.bicep
```

### A2 — Resource group only (RG already exists)

If you created the RG with `az group create` (or the portal), deploy with:

- [`infra/bicep/main.bicep`](../infra/bicep/main.bicep) — resource group scope
- [`infra/bicep/parameters/main.dev.bicepparam`](../infra/bicep/parameters/main.dev.bicepparam) / [`main.prod.bicepparam`](../infra/bicep/parameters/main.prod.bicepparam)

```bash
az deployment group create \
  --resource-group rg-ai-mcp-server-demo-dev \
  --parameters infra/bicep/parameters/main.dev.bicepparam \
  --template-file infra/bicep/main.bicep
```

```bash
az bicep build --file infra/bicep/main.bicep
```

---

## Option B — Azure CLI (manual)

The following sections mirror the same resources without Bicep.

## 1. Sign in and select subscription

```bash
az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
```

Export subscription id for reuse:

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
```

## 2. Choose environment name

Use **`dev`** or **`prod`** for `{env}` in names below.

```bash
ENV=dev   # or prod
RG="rg-ai-mcp-server-demo-${ENV}"
LOCATION=australiaeast
MI_NAME="MI_ai-mcp-server-demo-${ENV}"
```

## 3. Resource group

```bash
az group create --name "$RG" --location "$LOCATION"
```

## 4. User-assigned managed identity

```bash
az identity create \
  --name "$MI_NAME" \
  --resource-group "$RG" \
  --location "$LOCATION"
```

Capture **client id** and **principal id**:

```bash
CLIENT_ID=$(az identity show --name "$MI_NAME" --resource-group "$RG" --query clientId -o tsv)
PRINCIPAL_ID=$(az identity show --name "$MI_NAME" --resource-group "$RG" --query principalId -o tsv)
echo "AZURE_CLIENT_ID (GitHub variable): $CLIENT_ID"
```

## 5. RBAC (Contributor on the resource group)

Phase 2 (ACR, Container Apps) expects this identity to deploy into the same resource group. Adjust to a narrower role later if required.

```bash
az role assignment create \
  --assignee-object-id "$PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --role Contributor \
  --scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG}"
```

## 6. Federated identity credential (GitHub OIDC)

Match **`subject`** to how workflows authenticate. This repo’s [`.github/workflows/deploy-azure.yml`](../.github/workflows/deploy-azure.yml) uses **`workflow_dispatch`** with a GitHub **Environment** (`dev` / `prod`), so the recommended subject is:

`repo:<GitHubOrg>/<repoName>:environment:<env>`

Replace **`YOUR_ORG`** and **`YOUR_REPO`**.

```bash
FIC_NAME="github-actions-${ENV}"

az identity federated-credential create \
  --name "$FIC_NAME" \
  --identity-name "$MI_NAME" \
  --resource-group "$RG" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:YOUR_ORG/YOUR_REPO:environment:${ENV}" \
  --audiences "api://AzureADTokenExchange"
```

If you use a different subject pattern (branch or tag), change **`--subject`** accordingly and keep it aligned with [Microsoft’s guidance on OIDC](https://learn.microsoft.com/azure/developer/github/connect-from-azure).

## 7. GitHub configuration

For each GitHub **Environment** (`dev`, `prod`) used by the deploy workflow:

| Variable | Value |
|----------|--------|
| **`AZURE_CLIENT_ID`** | **Client id** of **`MI_ai-mcp-server-demo-{env}`** (same env as the GitHub Environment) |
| **`AZURE_TENANT_ID`** | Entra tenant id: `az account show --query tenantId -o tsv` |
| **`AZURE_SUBSCRIPTION_ID`** | Subscription id |

Configure under **Repository → Settings → Environments → `dev` / `prod` → Environment variables**.

## 8. Validate

Run workflow **Deploy Azure (Phase 1 — OIDC)** from the Actions tab, choose **`dev`** or **`prod`**, and confirm **`azure/login`** and **`az account show`** succeed.

---

Phase 2 (ACR, Container Apps) will extend `infra/bicep` — see [plan.md](../plan.md).
