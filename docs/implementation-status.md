# Implementation status

Tracks progress against [plan.md](../plan.md) (Option A: single in-repo tracker). Update this file in the same branch/PR that completes a step so history stays reviewable.

**How to use**

- Set **Status** to `Not started`, `In progress`, or `Done`.
- Fill **Branch** and **PR** when work begins / merges (links optional: `org/repo#123`).
- Use **Notes** for deviations from the plan, follow-ups, or ADR references (`docs/adr/…`).

| Step | Plan § | Todo id | Area | Status | Branch | PR | Notes |
|------|--------|---------|------|--------|--------|-----|-------|
| 1 | Implementation order §1 | `sln-projects` | Solution, projects, `Directory.Build.props`, `IOptions`, user secrets order | Done | | | `ai-mcp-server-demo.sln` (classic `-f sln`), `src/Api`, `src/McpServer`, `src/AiMcpServerDemo.Hosting` with `AddLayeredAppConfiguration` (lowest: env vars, then appsettings, then user secrets in Development). Api samples: `/api/health`, `/api/options`. McpServer is MCP-only (no extra REST routes). |
| 2 | §2 | `mcp-http`, `local-dev` (partial) | MCP host, tools, `launchSettings` (McpServer), debug | In progress | | | **McpServer:** `ModelContextProtocol.AspNetCore` 1.2.0, `AddMcpServer` + `WithHttpTransport` (stateless) + `WithToolsFromAssembly`, `MapMcp()`. Tools: `Ping`, `Echo`, `GetServerInfo` in `Tools/SampleMcpTools.cs`. **Remaining for this row:** polish `launchSettings`, VS Code compound (`local-dev`). |
| 3 | §3 | `local-dev` (partial) | API endpoints, health, `launchSettings` (Api), multi-start / `.vscode` | Not started | | | |
| 4 | §4 | `docker` | Dockerfiles, `.dockerignore`, `docker-compose.yml` | Not started | | | |
| 5 | §5 | `bicep-azure` | Bicep, RG, `australiaeast`, UAMI + FIC, params | Not started | | | |
| 6 | §6 | `github-actions` | CI + deploy workflows, OIDC | Not started | | | |
| 7 | §7 | `readme` | README: local dev, config, Azure, GHA | Not started | | | |

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
