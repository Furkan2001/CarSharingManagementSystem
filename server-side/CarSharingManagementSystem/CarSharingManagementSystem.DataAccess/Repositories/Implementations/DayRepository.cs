using CarSharingManagementSystem.Entities;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarSharingManagementSystem.DataAccess.Repositories.Implementations
{
    public class DayRepository : IDayRepository
    {
        private readonly AppDbContext _context;

        public DayRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Day>> GetAllAsync()
        {
            return await _context.Days.ToListAsync();
        }

        public async Task<Day> GetByIdAsync(int id)
        {
            return await _context.Days.FindAsync(id);
        }

        public async Task<int> AddAsync(Day day)
        {
            try
            {
                await _context.Days.AddAsync(day);
                await _context.SaveChangesAsync();
                return 0; // Success
            }
            catch
            {
                return -1; // Failure
            }
        }

        public async Task<int> UpdateAsync(Day day)
        {
            try
            {
                _context.Days.Update(day);
                await _context.SaveChangesAsync();
                return 0; // Success
            }
            catch
            {
                return -1; // Failure
            }
        }

        public async Task<int> DeleteAsync(int id)
        {
            try
            {
                var day = await _context.Days.FindAsync(id);
                if (day != null)
                {
                    _context.Days.Remove(day);
                    await _context.SaveChangesAsync();
                    return 0; // Success
                }
                return -1; // Day not found
            }
            catch
            {
                return -1; // Failure
            }
        }
    }
}