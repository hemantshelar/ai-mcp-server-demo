using Api.Options;
using AiMcpServerDemo.Hosting;
using Microsoft.Extensions.Options;

var builder = WebApplication.CreateBuilder(args);
builder.Host.AddLayeredAppConfiguration();

builder.Services.Configure<ApiOptions>(builder.Configuration.GetSection(ApiOptions.SectionName));
builder.Services.AddOpenApi();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.MapGet("/api/health", () => Results.Ok(new { status = "Healthy" }))
    .WithName("GetHealth");

app.MapGet("/api/options", (IOptions<ApiOptions> options) => Results.Ok(options.Value))
    .WithName("GetApiOptions");

app.Run();
