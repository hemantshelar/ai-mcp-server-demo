# ai-mcp-server-demo

Sample .NET 9 solution: **Streamable HTTP MCP server** (`src/McpServer`), standalone **Web API** (`src/Api`), shared layered configuration (`src/AiMcpServerDemo.Hosting`). See [plan.md](plan.md) for full scope (Docker, Azure Bicep, GitHub Actions).

## Prerequisites

- [.NET 9 SDK](https://dotnet.microsoft.com/download) (see [global.json](global.json) for SDK roll-forward)
- [Git](https://git-scm.com/)
- **IDE:** Visual Studio 2022, **VS Code** with [C# Dev Kit](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csdevkit) (or C# extension), or **JetBrains Rider**
- **Docker Desktop** — optional; only needed when you use Docker Compose (not required for `dotnet run`)

No Azure subscription or Azure CLI is required for everyday local development.

## Clone and restore

```bash
git clone <your-repo-url>
cd ai-mcp-server-demo
dotnet restore
```

## Configuration (quick reference)

Apps use typed options and layered configuration: **environment variables** (lowest precedence), then **appsettings.json**, then **user secrets** in Development (highest). See [plan.md](plan.md) § *Configuration and `IOptions<T>`*.

Per project (after clone):

```bash
dotnet user-secrets init --project src/Api
dotnet user-secrets init --project src/McpServer
```

Set overrides with `dotnet user-secrets set` as needed.

Optional HTTPS dev certificate:

```bash
dotnet dev-certs https --trust
```

## Local URLs (Development)

| App | HTTP | HTTPS |
|-----|------|--------|
| **Api** | http://localhost:5101 | https://localhost:7268 |
| **McpServer** | http://localhost:5136 | https://localhost:7137 |

Values match [src/Api/Properties/launchSettings.json](src/Api/Properties/launchSettings.json) and [src/McpServer/Properties/launchSettings.json](src/McpServer/Properties/launchSettings.json).

### Run without debugging (two terminals)

```bash
dotnet run --project src/Api --launch-profile http
dotnet run --project src/McpServer --launch-profile http
```

### Debug in VS Code

1. Open the repo folder in VS Code.
2. **Run and Debug** → choose **Api + McpServer (http)** (compound) or a single project.
3. Requires the **C#** / **C# Dev Kit** extension for `coreclr` debugging.

Configs live under [.vscode/launch.json](.vscode/launch.json).

### Debug in Visual Studio

**Solution** → right-click → **Configure Startup Projects** → **Multiple startup projects** → set **Api** and **McpServer** to **Start**.

### Api: OpenAPI (Development)

With the Api running in **Development**, OpenAPI is registered via `MapOpenApi()`. The OpenAPI document is typically available at:

- **HTTP:** http://localhost:5101/openapi/v1.json  
- **HTTPS:** https://localhost:7268/openapi/v1.json  

If the path differs for your SDK version, check the running app or ASP.NET Core 9 OpenAPI docs.

### Cursor: connect to the MCP server

Use the **HTTP** base URL for Streamable HTTP (avoids TLS `fetch failed` with local dev certs):

```json
"ai-mcp-server-demo": {
  "url": "http://localhost:5136/"
}
```

Place under `mcpServers` in [`.cursor/mcp.json`](https://cursor.com/docs/context/mcp) (user or project). Restart Cursor or reload MCP after changes.

## More documentation

- [plan.md](plan.md) — architecture, Azure, CI/CD
- [docs/implementation-status.md](docs/implementation-status.md) — delivery checklist
