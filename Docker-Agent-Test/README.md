# Docker Agent test (local LLM + MCP)

This folder contains a **Docker Agent** configuration that:

1. Runs a **local model** via **Docker Model Runner (DMR)** (models you see under Docker Desktop **Models**).
2. Connects to this repository’s **McpServer** over **Streamable HTTP** at `http://localhost:5136/` (same transport as `MapMcp()` in .NET).

Use it to verify that a **local** LLM can discover and call tools such as **`reverse_string`**.

## Prerequisites

- **Docker Desktop** with **Docker Model Runner** enabled: **Settings → AI → Enable Docker Model Runner** (see [DMR get started](https://docs.docker.com/ai/model-runner/get-started/)).
- **Docker Agent** CLI available (`docker agent version` or the installation path in [Docker Agent installation](https://docs.docker.com/ai/integrations/#installation)).
- The model referenced in [`agent.yaml`](agent.yaml) (`models.local_mcp_demo.model`) must exist locally. Check with:

  ```bash
  docker model list
  ```

  If the model is missing, pull it from the catalog or adjust `model:` to one you already have (for example `ai/qwen2:0.5B-Q4_K_M` or `ai/deepseek-r1-distill-llama:latest`).

## 1. Start McpServer (host port 5136)

From the **repository root**:

```bash
docker compose up --build -d mcp
```

Confirm:

```bash
curl -sS http://localhost:5136/health
```

You should see `{"status":"Healthy"}`.

## 2. Run the agent

From the **repository root** (so paths stay predictable):

```bash
docker agent run ./Docker-Agent-Test/agent.yaml
```

Or from this folder:

```bash
cd Docker-Agent-Test
docker agent run ./agent.yaml
```

Try a prompt such as: **“Use the reverse_string tool on the text Hemant.”**

### If MCP never connects

- Ensure nothing else is bound to **5136**.
- If **docker agent** runs in an environment where `localhost` is not the host (unusual on Windows/macOS for the default install), set the MCP URL to your host gateway, for example `http://host.docker.internal:5136/` in `agent.yaml` under `toolsets[0].remote.url`, and retry.

### If the model ignores tools

Very small models (for example **0.5B**) often **fail at tool calling**. Prefer **Gemma 2B**, **DeepSeek 8B**, or similar if available locally.

## References

- [Docker Agent local models](https://docs.docker.com/ai/docker-agent/local-models/)
- [Remote MCP (SSE / Streamable HTTP)](https://docker.github.io/docker-agent/features/remote-mcp/)
- [McpServer entrypoint](../src/McpServer/Program.cs) — `MapMcp()` at `/`
