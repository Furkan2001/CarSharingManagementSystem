using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.Business.Services.Implementations;
using CarSharingManagementSystem.DataAccess;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using CarSharingManagementSystem.DataAccess.Repositories.Implementations;
using Microsoft.EntityFrameworkCore;
using CarSharingManagementSystem.API.Middleware;
using Microsoft.OpenApi.Models;
using CarSharingManagementSystem.API.Hubs;
using Microsoft.AspNetCore.SignalR;
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;


var builder = WebApplication.CreateBuilder(args);

// Add session services
builder.Services.AddDistributedMemoryCache();  // Add in-memory caching for session
builder.Services.AddSession(options =>
{
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
    options.Cookie.SameSite = SameSiteMode.Lax;
    options.IdleTimeout = TimeSpan.FromMinutes(60); // Set session timeout
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAllOrigins", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// DbContext
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Repository Depencies
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IJourneyRepository, JourneyRepository>();
builder.Services.AddScoped<IDayRepository, DayRepository>();
builder.Services.AddScoped<IJourneyDayRepository, JourneyDayRepository>();
builder.Services.AddScoped<IMessageRepository, MessageRepository>();
builder.Services.AddScoped<IMapRepository, MapRepository>();
builder.Services.AddScoped<IRequestRepository, RequestRepository>();
builder.Services.AddScoped<IUserDeviceTokenRepository, UserDeviceTokenRepository>();

// Service Depencies
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IJourneyDayService, JourneyDayService>();
builder.Services.AddScoped<IDayService, DayService>();
builder.Services.AddScoped<IMessageService, MessageService>();
builder.Services.AddScoped<IMapService, MapService>();
builder.Services.AddScoped<IJourneyService, JourneyService>();
builder.Services.AddScoped<IRequestService, RequestService>();
builder.Services.AddScoped<IUserDeviceTokenService, UserDeviceTokenService>();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Firebase'i başlat
FirebaseApp.Create(new AppOptions()
{
    Credential = GoogleCredential.FromFile("Private/carsharing-961ea-firebase-adminsdk-im372-c79318efec.json")
});

builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "CarSharingManagementSystem API", Version = "v1" });

    // x-api-key başlığı
    c.AddSecurityDefinition("ApiKey", new OpenApiSecurityScheme
    {
        Description = "API Key gerekli. Örneğin: \"x-api-key: {API_KEY}\"",
        In = ParameterLocation.Header,
        Name = "x-api-key",
        Type = SecuritySchemeType.ApiKey,
        Scheme = "ApiKeyScheme"
    });

    // user_id başlığı
    c.AddSecurityDefinition("UserId", new OpenApiSecurityScheme
    {
        Description = "User ID gerekli. Örneğin: \"user_id: {USER_ID}\"",
        In = ParameterLocation.Header,
        Name = "user_id",
        Type = SecuritySchemeType.ApiKey,
        Scheme = "UserIdScheme"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "ApiKey"
                },
                Scheme = "ApiKeyScheme",
                Name = "x-api-key",
                In = ParameterLocation.Header,
            },
            new List<string>()
        },
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "UserId"
                },
                Scheme = "UserIdScheme",
                Name = "user_id",
                In = ParameterLocation.Header,
            },
            new List<string>()
        }
    });
});

builder.Services.AddSignalR();
//builder.WebHost.UseUrls("http://0.0.0.0:3000");

var app = builder.Build();

app.UseSession();

app.UseCors("AllowAllOrigins");

// Add API Key Middleware
app.UseMiddleware<ApiKeyMiddleware>();

// Add Swagger
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.MapHub<MessageHub>("/messageHub");

//app.Urls.Add("http://0.0.0.0:3000");

app.Run();
