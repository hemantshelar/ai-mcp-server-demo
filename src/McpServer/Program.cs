using AiMcpServerDemo.Hosting;
using Microsoft.Extensions.Options;
using McpServer.Options;

var builder = WebApplication.CreateBuilder(args);
builder.Host.AddLayeredAppConfiguration();

builder.Services.Configure<McpOptions>(builder.Configuration.GetSection(McpOptions.SectionName));

var app = builder.Build();

app.MapGet("/health", () => Results.Ok(new { status = "Healthy" }))
    .WithName("GetHealth");

app.MapGet("/options", (IOptions<McpOptions> options) => Results.Ok(options.Value))
    .WithName("GetMcpOptions");

app.Run();
