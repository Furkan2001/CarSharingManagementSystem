using CarSharingManagementSystem.Business.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;

namespace CarSharingManagementSystem.API.Middleware
{
    public class ApiKeyMiddleware
    {
        private readonly RequestDelegate _next;
        private const string ApiKeyHeaderName = "x-api-key";
        private const string UserIdHeaderName = "user_id";

        public ApiKeyMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context, IUserService userService)
        {
            if (context.Request.Path.StartsWithSegments("/swagger") || context.Request.Path.StartsWithSegments("/auth") || context.Request.Path.StartsWithSegments("/login") || context.Request.Path.StartsWithSegments("/api/Users/save-device-token") || context.Request.Path.StartsWithSegments("/messageHub"))
            {
                await _next(context);
                return;
            }

            // x-api-key kontrolü
            if (!context.Request.Headers.TryGetValue(ApiKeyHeaderName, out var extractedApiKey))
            {
                context.Response.StatusCode = 401; // Unauthorized
                await context.Response.WriteAsync("API Key is missing");
                return;
            }

            // user_id kontrolü
            if (!context.Request.Headers.TryGetValue(UserIdHeaderName, out var extractedUserId))
            {
                context.Response.StatusCode = 401; // Unauthorized
                await context.Response.WriteAsync("User ID is missing");
                return;
            }

            // API Key'e göre kullanıcıyı doğrula
            var user = await userService.GetUserByApiKeyAsync(extractedApiKey);
            if (user == null)
            {
                context.Response.StatusCode = 401; // Unauthorized
                await context.Response.WriteAsync("Invalid API Key");
                return;
            }

            // user_id eşleşmesini kontrol et
            if (user.UserId.ToString() != extractedUserId)
            {
                context.Response.StatusCode = 401; // Unauthorized
                await context.Response.WriteAsync("User ID and API Key do not match");
                return;
            }

            // Kullanıcı doğrulandı, isteği devam ettir
            await _next(context);
        }
    }
}
