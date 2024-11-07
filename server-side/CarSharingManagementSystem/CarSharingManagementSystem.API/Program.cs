using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.Business.Services.Implementations;
using CarSharingManagementSystem.DataAccess;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using CarSharingManagementSystem.DataAccess.Repositories.Implementations;
using Microsoft.EntityFrameworkCore;
using CarSharingManagementSystem.API.Middleware;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

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

// Service Depencies
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IJourneyDayService, JourneyDayService>();
builder.Services.AddScoped<IDayService, DayService>();
builder.Services.AddScoped<IMessageService, MessageService>();
builder.Services.AddScoped<IMapService, MapService>();
builder.Services.AddScoped<IJourneyService, JourneyService>();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
// builder.Services.AddSwaggerGen();

builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "CarSharingManagementSystem API", Version = "v1" });

    c.AddSecurityDefinition("ApiKey", new OpenApiSecurityScheme
    {
        Description = "API Key gerekli. Örneğin: \"x-api-key: {API_KEY}\"",
        In = ParameterLocation.Header,
        Name = "x-api-key",
        Type = SecuritySchemeType.ApiKey,
        Scheme = "ApiKeyScheme"
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
        }
    });
});

var app = builder.Build();

app.UseCors("AllowAllOrigins");

// Add API Key Middleware
app.UseMiddleware<ApiKeyMiddleware>();

// Add Swagger
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();
app.MapControllers();
app.Run();
