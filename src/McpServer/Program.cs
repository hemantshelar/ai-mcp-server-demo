using AiMcpServerDemo.Hosting;
using Microsoft.Extensions.Options;
using ModelContextProtocol.Server;
using McpServer.Options;
using McpServer.Tools;

var builder = WebApplication.CreateBuilder(args);
builder.Host.AddLayeredAppConfiguration();

builder.Services.Configure<McpOptions>(builder.Configuration.GetSection(McpOptions.SectionName));

// WithToolsFromAssembly() with no args uses the *extension method's* assembly (the SDK), not this app—pass the tools assembly explicitly.
builder.Services
    .AddMcpServer()
    .WithHttpTransport(options =>
    {
        options.Stateless = true;
    })
    .WithToolsFromAssembly(typeof(SampleMcpTools).Assembly);

var app = builder.Build();

app.MapMcp();

app.MapGet("/health", () => Results.Ok(new { status = "Healthy" }))
    .WithName("McpHealth");

if (app.Environment.IsDevelopment())
{
    app.MapGet("/options", (IOptions<McpOptions> options) => Results.Ok(options.Value))
        .WithName("McpOptionsDebug");
}

app.Run();
