using System.ComponentModel;
using System.Reflection;
using ModelContextProtocol.Server;

namespace McpServer.Tools;

/// <summary>
/// Sample MCP tools discoverable by clients (VS Code, Claude, etc.) via Streamable HTTP.
/// </summary>
[McpServerToolType]
public static class SampleMcpTools
{
    [McpServerTool, Description("Returns pong. Use to verify the server is reachable.")]
    public static string Ping() => "pong";

    [McpServerTool, Description("Echoes the message back to the client.")]
    public static string Echo(string message) => message;

    [McpServerTool, Description("Returns the sample MCP server name and assembly version.")]
    public static string GetServerInfo()
    {
        var asm = Assembly.GetExecutingAssembly();
        var name = asm.GetName().Name ?? "McpServer";
        var version = asm.GetName().Version?.ToString() ?? "unknown";
        return $"{name} v{version}";
    }
}
