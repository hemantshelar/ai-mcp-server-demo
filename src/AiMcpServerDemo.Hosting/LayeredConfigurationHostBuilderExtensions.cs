using System.Reflection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;

namespace AiMcpServerDemo.Hosting;

/// <summary>
/// Configuration precedence for duplicate keys (last wins): environment variables (lowest),
/// then appsettings.json / appsettings.{Environment}.json, then user secrets (highest, Development only).
/// </summary>
public static class LayeredConfigurationHostBuilderExtensions
{
    public static IHostBuilder AddLayeredAppConfiguration(this IHostBuilder host)
    {
        host.ConfigureAppConfiguration((context, config) =>
        {
            config.Sources.Clear();

            config.AddEnvironmentVariables();

            var env = context.HostingEnvironment;
            config.SetBasePath(env.ContentRootPath);
            config.AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);
            config.AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true, reloadOnChange: true);

            if (env.IsDevelopment())
            {
                var entry = Assembly.GetEntryAssembly();
                if (entry is not null)
                    config.AddUserSecrets(entry, optional: true);
            }
        });

        return host;
    }
}
