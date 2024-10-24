using CarSharingManagementSystem.Entities;
using Microsoft.EntityFrameworkCore;

namespace CarSharingManagementSystem.DataAccess
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        // Veritabanı tablolarına karşılık gelen DbSet'ler
        public DbSet<Car> Cars { get; set; }
        public DbSet<Journey> Journeys { get; set; }
    }
}