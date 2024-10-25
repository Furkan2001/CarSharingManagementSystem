using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using CarSharingManagementSystem.Entities;
using Microsoft.EntityFrameworkCore;

namespace CarSharingManagementSystem.DataAccess.Repositories.Implementations
{
    public class CarRepository : ICarRepository
    {
        private readonly AppDbContext _context;

        public CarRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Car>> GetAllAsync()
        {
            return await _context.Cars.ToListAsync();
        }

        public async Task<Car?> GetByIdAsync(int id)
        {
            return await _context.Cars.FindAsync(id);
        }

        public async Task AddAsync(Car car)
        {
            await _context.Cars.AddAsync(car);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Car car)
        {
            _context.Cars.Update(car);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var car = await GetByIdAsync(id);
            if (car != null)
            {
                _context.Cars.Remove(car);
                await _context.SaveChangesAsync();
            }
        }
    }
}
