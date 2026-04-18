# Implementation status

Tracks progress against [plan.md](../plan.md) (Option A: single in-repo tracker). Update this file in the same branch/PR that completes a step so history stays reviewable.

**Last synced:** 2026-04-18 — **Phase 2** Bicep + **deploy-azure** RG deploy verified after provider registration, RG **UAA** on deployment MI, AcrPush GUID fix, ACR naming; troubleshooting captured in [plan.md](../plan.md) § Azure / GHA deployment fixes. Optional: **docker push** + revision updates.

**How to use**

- Set **Status** to `Not started`, `In progress`, or `Done`.
- Fill **Branch** and **PR** when work begins / merges (links optional: `org/repo#123`).
- Use **Notes** for deviations from the plan, follow-ups, or ADR references (`docs/adr/…`).

| Step | Plan § | Todo id | Area | Status | Branch | PR | Notes |
|------|--------|---------|------|--------|--------|-----|-------|
| 1 | Implementation order §1 | `sln-projects` | Solution, projects, `Directory.Build.props`, `IOptions`, user secrets order | Done | | | `ai-mcp-server-demo.sln`, `src/Api`, `src/McpServer`, `src/AiMcpServerDemo.Hosting`, `AddLayeredAppConfiguration` (env → appsettings → user secrets in Development). Api: `/api/health`, `/api/options`. |
| 2 | §2 | `mcp-http` | MCP Streamable HTTP, tools, ops routes, `launchSettings` (McpServer) | Done | | | `ModelContextProtocol.AspNetCore` 1.2.0, **`WithToolsFromAssembly(typeof(SampleMcpTools).Assembly)`**, `MapMcp()`, tools in [`SampleMcpTools.cs`](../src/McpServer/Tools/SampleMcpTools.cs), `/health` + `/options` (dev). Cursor MCP URL: **`http://localhost:5136/`**. |
| 3 | §3 | `local-dev` | API, `launchSettings`, `.vscode`, README local | Done | feature/003-local-dev | | [`.vscode/launch.json`](../.vscode/launch.json) compound **Api + McpServer (http)**; [tasks.json](../.vscode/tasks.json) `build-solution`. [README.md](../README.md): prerequisites, ports, `dotnet run`, VS / VS Code, OpenAPI `/openapi/v1.json`, Cursor snippet. |
| 4 | §4 | `docker` | Dockerfiles, `.dockerignore`, `docker-compose.yml` | Done | feature/004-docker | | Multi-stage [`docker/Api.Dockerfile`](../docker/Api.Dockerfile), [`docker/McpServer.Dockerfile`](../docker/McpServer.Dockerfile); root [`.dockerignore`](../.dockerignore); [`docker-compose.yml`](../docker-compose.yml). Containers listen on **8080**; host ports **5101** (Api), **5136** (McpServer). |
| 5 | §5 | `bicep-azure` | Bootstrap RG + UAMI + FIC + RBAC; Bicep Phase 1 + Phase 2 ACR + Container Apps | Done | feature/001-plan | | **Phase 1 + 2** deployed via GHA + `main.bicep`; see [plan.md](../plan.md) deployment fixes. **Follow-up:** push app images, point `apiImage`/`mcpImage` at ACR. |
| 6 | §6 | `github-actions` | `ci.yml` + `deploy-azure.yml`, OIDC | Done | feature/005-enable-github-actions | | [`.github/workflows/ci.yml`](../.github/workflows/ci.yml), [deploy-azure.yml](../.github/workflows/deploy-azure.yml); [github-actions-setup.md](github-actions-setup.md). Deploy workflow = **`azure/login`** + **`az deployment group create`** (`main.bicep`) + build/test. Default branch / CI branches per repo (`feature/001-plan`, etc.). |
| 7 | §7 | `readme` | README: local dev, config, Azure, GHA | Not started | | | Deep links in README to [azure-bootstrap.md](azure-bootstrap.md) + [github-actions-setup.md](github-actions-setup.md); optional single “Azure & CI/CD” section consolidating RG naming, default branch, and Phase 2 pointer. |

## Todo status (mirrors plan.md)

| Todo id | plan.md status | Notes |
|---------|------------------|-------|
| `sln-projects` | completed | |
| `mcp-http` | completed | |
| `docker` | completed | |
| `bicep-azure` | completed | RG-scoped deploy verified; plan § Azure / GHA deployment fixes |
| `github-actions` | completed | |
| `local-dev` | completed | |
| `readme` | pending | |

## Quick reference (from plan todos)

| Todo id | Description |
|---------|-------------|
| `sln-projects` | `ai-mcp-server-demo.sln`, Api + McpServer (.NET 9), `Directory.Build.props`, `IOptions`, samples |
| `mcp-http` | ModelContextProtocol.AspNetCore, Kestrel, health, sample MCP tools |
| `docker` | Multi-stage Dockerfiles, `.dockerignore`, `docker-compose.yml` |
| `bicep-azure` | Phase 1 CLI/Bicep bootstrap done in repo; Phase 2: ACR + Container Apps |
| `github-actions` | `ci.yml` + deploy with OIDC; Phase 1 deploy without ACR/ACA; bootstrap doc with `az` |
| `local-dev` | `launchSettings`, optional VS Code compound, README prereqs / run / debug |
| `readme` | README covering local, compose, Azure, GHA |

## Next step (recommended order)

1. **`readme` todo** — Add a short **Azure & GitHub Actions** subsection in [README.md](../README.md) pointing to [docs/azure-bootstrap.md](azure-bootstrap.md) and [docs/github-actions-setup.md](github-actions-setup.md) (default branch, environments, variables, deployment troubleshooting — see [plan.md](../plan.md) § Azure / GHA deployment fixes).

2. **App images in Azure** — **docker push** Api/McpServer to ACR; set **`apiImage`** / **`mcpImage`** in `.bicepparam` or **`az containerapp update`** (see [plan.md](../plan.md) next steps).
