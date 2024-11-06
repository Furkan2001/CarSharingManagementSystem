using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.Business.Services.Implementations;
using CarSharingManagementSystem.DataAccess;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using CarSharingManagementSystem.DataAccess.Repositories.Implementations;
using Microsoft.EntityFrameworkCore;
using System.Text.Json.Serialization;

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

// DbContext ekleme
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Repository bağımlılıklarını ekleme
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IJourneyRepository, JourneyRepository>();
builder.Services.AddScoped<IDayRepository, DayRepository>();
builder.Services.AddScoped<IJourneyDayRepository, JourneyDayRepository>();
builder.Services.AddScoped<IMessageRepository, MessageRepository>();
builder.Services.AddScoped<IMapRepository, MapRepository>();

// Service bağımlılıklarını ekleme
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IJourneyDayService, JourneyDayService>();
builder.Services.AddScoped<IDayService, DayService>();
builder.Services.AddScoped<IMessageService, MessageService>();
builder.Services.AddScoped<IMapService, MapService>();
builder.Services.AddScoped<IJourneyService, JourneyService>();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseCors("AllowAllOrigins");

// Swagger ekleme
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();
app.MapControllers();
app.Run();
