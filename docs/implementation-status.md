# Implementation status

Tracks progress against [plan.md](../plan.md) (Option A: single in-repo tracker). Update this file in the same branch/PR that completes a step so history stays reviewable.

**Last synced:** 2026-04-18 — aligned with [plan.md](../plan.md) frontmatter and current codebase.

**How to use**

- Set **Status** to `Not started`, `In progress`, or `Done`.
- Fill **Branch** and **PR** when work begins / merges (links optional: `org/repo#123`).
- Use **Notes** for deviations from the plan, follow-ups, or ADR references (`docs/adr/…`).

| Step | Plan § | Todo id | Area | Status | Branch | PR | Notes |
|------|--------|---------|------|--------|--------|-----|-------|
| 1 | Implementation order §1 | `sln-projects` | Solution, projects, `Directory.Build.props`, `IOptions`, user secrets order | Done | | | `ai-mcp-server-demo.sln`, `src/Api`, `src/McpServer`, `src/AiMcpServerDemo.Hosting`, `AddLayeredAppConfiguration` (env → appsettings → user secrets in Development). Api: `/api/health`, `/api/options`. |
| 2 | §2 | `mcp-http` (done); `local-dev` (open) | MCP Streamable HTTP, tools, ops routes, `launchSettings` (McpServer) | Done | | | **`mcp-http` complete:** `ModelContextProtocol.AspNetCore` 1.2.0, `AddMcpServer` + `WithHttpTransport` (stateless) + **`WithToolsFromAssembly(typeof(SampleMcpTools).Assembly)`** (required—parameterless call scans wrong assembly). `MapMcp()`. Tools: `Ping`, `Echo`, `GetServerInfo` in [`Tools/SampleMcpTools.cs`](../src/McpServer/Tools/SampleMcpTools.cs). `/health` + `/options` (Development only). **Cursor:** use **`http://localhost:5136/`** in `mcp.json`—HTTPS often yields `fetch failed` (dev cert). **Still open (`local-dev`):** `.vscode` compound launch, README notes. |
| 3 | §3 | `local-dev` (partial) | API, `launchSettings` (Api), multi-start / `.vscode` | In progress | | | Api has [`launchSettings`](../src/Api/Properties/launchSettings.json), `/api/health`, `/api/options`, OpenAPI in dev. **Remaining:** multiple startup projects / `.vscode` compound for Api + McpServer, README. |
| 4 | §4 | `docker` | Dockerfiles, `.dockerignore`, `docker-compose.yml` | Not started | | | |
| 5 | §5 | `bicep-azure` | Bicep, RG, `australiaeast`, UAMI + FIC, params | Not started | | | |
| 6 | §6 | `github-actions` | CI + deploy workflows, OIDC | Not started | | | |
| 7 | §7 | `readme` | README: local dev, config, Azure, GHA | Not started | | | |

## Todo status (mirrors plan.md)

| Todo id | plan.md status | Notes |
|---------|------------------|--------|
| `sln-projects` | completed | |
| `mcp-http` | completed | |
| `docker` | pending | |
| `bicep-azure` | pending | |
| `github-actions` | pending | |
| `local-dev` | pending | Partly overlaps step 2–3 (launch compound, docs). |
| `readme` | pending | |

## Quick reference (from plan todos)

| Todo id | Description |
|---------|-------------|
| `sln-projects` | `ai-mcp-server-demo.sln`, Api + McpServer (.NET 9), `Directory.Build.props`, `IOptions`, samples |
| `mcp-http` | ModelContextProtocol.AspNetCore, Kestrel, health, sample MCP tools |
| `docker` | Multi-stage Dockerfiles, `.dockerignore`, `docker-compose.yml` |
| `bicep-azure` | Bicep, `rg-ai-mcp-server-demo-{env}`, `australiaeast`, UAMI + FIC, Dev/Prod params |
| `github-actions` | GHA CI + deploy, first-run Azure CLI doc, OIDC with UAMI |
| `local-dev` | `launchSettings`, optional VS Code compound, README prereqs / run / debug |
| `readme` | README covering local, compose, Azure, GHA |
