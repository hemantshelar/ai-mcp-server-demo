# GitHub Actions: end-to-end setup for Azure OIDC (deploy workflow)

Goal: run **[`.github/workflows/deploy-azure.yml`](../.github/workflows/deploy-azure.yml)** successfully — **Azure login (OIDC)** → **`az account show`** → **dotnet build/test**.

The workflow reads **GitHub Actions variables** (`vars.*`), **not** repository secrets, unless you change the YAML.

---

## Prerequisites (complete before GitHub steps)

1. **Azure Phase 1 is deployed** — resource group, user-assigned managed identity **`MI_ai-mcp-server-demo-{env}`**, federated credential (FIC) for GitHub. Use [azure-bootstrap.md](azure-bootstrap.md) (Bicep or CLI).
2. **FIC subject matches this repo** — must be exactly:
   - `repo:<YourGitHubOrgOrUser>/<YourRepoName>:environment:dev`
   - `repo:<YourGitHubOrgOrUser>/<YourRepoName>:environment:prod`  
   `<YourGitHubOrgOrUser>` and `<YourRepoName>` are **case-sensitive** and must match the repo GitHub shows in the URL bar.
3. **Workflow file is on the branch GitHub runs** — usually **`main`**. Merge your workflow so **Actions** can see **Deploy Azure (Phase 1 — OIDC)**.
4. **Collect three Azure values** (from `az` or portal):

   ```bash
   az account show --query tenantId -o tsv      # AZURE_TENANT_ID
   az account show --query id -o tsv            # AZURE_SUBSCRIPTION_ID
   ```

   For each managed identity (dev and prod):

   ```bash
   az identity show -g rg-ai-mcp-server-demo-dev -n MI_ai-mcp-server-demo-dev --query clientId -o tsv
   az identity show -g rg-ai-mcp-server-demo-prod -n MI_ai-mcp-server-demo-prod --query clientId -o tsv
   ```

---

## Step 1 — Enable Actions (if needed)

1. Open the repo on GitHub → **Settings**.
2. **Actions** → **General**.
3. Under **Actions permissions**, choose **Allow all actions and reusable workflows** (or your org’s approved policy).
4. **Save**.

---

## Step 2 — Create GitHub Environments `dev` and `prod`

Names must be exactly **`dev`** and **`prod`** (same as the workflow dropdown and FIC subject).

1. **Settings** → left sidebar **Environments** (under *Code and automation*).
2. **New environment** → name: **`dev`** → **Configure environment**.
3. **New environment** → name: **`prod`** → **Configure environment**.

**Optional:** On **`prod`**, under **Deployment protection rules**, add **Required reviewers** so production runs need approval.

---

## Step 3 — Add repository variables (tenant + subscription)

Use this when **tenant** and **subscription** are the **same** for both dev and prod (typical).

1. **Settings** → **Secrets and variables** → **Actions**.
2. Open the **Variables** tab (not *Secrets*).
3. **Repository variables** → **New repository variable**:
   - Name: **`AZURE_TENANT_ID`** → Value: output of `az account show --query tenantId -o tsv`
4. **New repository variable**:
   - Name: **`AZURE_SUBSCRIPTION_ID`** → Value: output of `az account show --query id -o tsv`

If dev and prod use **different** subscriptions or tenants, **skip** this step and put **`AZURE_TENANT_ID`** and **`AZURE_SUBSCRIPTION_ID`** in **Step 4** on each environment instead.

---

## Step 4 — Add `AZURE_CLIENT_ID` per environment

Each GitHub Environment uses the matching Azure managed identity’s **Application (client) ID**.

### For `dev`

1. **Settings** → **Environments** → **`dev`**.
2. **Environment variables** → **Add environment variable**.
3. Name: **`AZURE_CLIENT_ID`**
4. Value: client id of **`MI_ai-mcp-server-demo-dev`** (from prerequisites).

### For `prod`

1. **Settings** → **Environments** → **`prod`**.
2. **Environment variables** → **Add environment variable**.
3. Name: **`AZURE_CLIENT_ID`**
4. Value: client id of **`MI_ai-mcp-server-demo-prod`**.

At this point the job can resolve:

- `vars.AZURE_CLIENT_ID` → from the **selected** environment (`dev` or `prod`).
- `vars.AZURE_TENANT_ID` and `vars.AZURE_SUBSCRIPTION_ID` → from **repository** variables (Step 3), unless you set them per environment instead.

---

## Step 5 — Run the workflow

1. **Actions** tab.
2. Left sidebar → **Deploy Azure (Phase 1 — OIDC)**.
3. **Run workflow** (button on the right).
4. Branch: **`main`** (or your default branch that contains the workflow).
5. **Environment** dropdown: choose **`dev`** or **`prod`** (must match a GitHub Environment you created).
6. **Run workflow**.

### What “good” looks like

- **Azure login (OIDC)** — green.
- **Verify Azure session** — green; logs show subscription/tenant info from `az account show`.
- **Restore, build, test** — green.

---

## Step 6 — If something fails (quick checks)

| Symptom | What to verify |
|--------|-------------------|
| **Could not authenticate** / OIDC failed | FIC subject in Azure = `repo:ORG/REPO:environment:dev` (or `prod`) with exact ORG/REPO casing. |
| **Variable not found** / empty `vars` | Variables are under **Actions → Variables**, not only **Secrets**. Names must be exactly **`AZURE_CLIENT_ID`**, **`AZURE_TENANT_ID`**, **`AZURE_SUBSCRIPTION_ID`**. |
| **Wrong subscription** after login | **`AZURE_SUBSCRIPTION_ID`** repository variable wrong; or set per-environment subscription in Step 3 style on each env. |
| Workflow **not listed** | Workflow file not on default branch, or Actions disabled (Step 1). |
| **Environment** missing in Run workflow | Create **Step 2** environments with exact names **`dev`** / **`prod`**. |

---

## Optional: use GitHub Secrets instead of Variables

This repo’s YAML uses **`vars.*`**. To use **Secrets**:

1. Add **Repository secrets** or **Environment secrets** with the same three names.
2. Edit [`.github/workflows/deploy-azure.yml`](../.github/workflows/deploy-azure.yml): replace **`vars.AZURE_CLIENT_ID`** (and tenant, subscription) with **`secrets.AZURE_CLIENT_ID`** etc.
3. Re-run the workflow.

Until you change the YAML, **secrets are ignored** for these names.

---

## Reference: what the workflow expects

```yaml
client-id: ${{ vars.AZURE_CLIENT_ID }}
tenant-id: ${{ vars.AZURE_TENANT_ID }}
subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
```

The job sets **`environment: ${{ inputs.environment }}`**, so when you pick **`dev`**, GitHub merges **environment `dev` variables** with **repository variables** for `vars.*` resolution.
