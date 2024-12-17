using CarSharingManagementSystem.Entities;
using Microsoft.EntityFrameworkCore;

namespace CarSharingManagementSystem.DataAccess
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        // Veritabanı tablolarına karşılık gelen DbSet'ler
        public DbSet<User> Users { get; set; }
        public DbSet<Journey> Journeys { get; set; }
        public DbSet<Day> Days { get; set; }
        public DbSet<JourneyDay> JourneyDays { get; set; }
        public DbSet<Message> Messages { get; set; }
        public DbSet<Map> Maps { get; set; }
        public DbSet<Request> Requests { get; set; }
        public DbSet<Status> Statuses {get; set; }
        public DbSet<UserDeviceToken> UserDeviceTokens { get; set; }
    }
}