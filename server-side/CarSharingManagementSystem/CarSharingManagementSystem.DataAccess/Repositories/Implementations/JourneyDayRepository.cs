using CarSharingManagementSystem.Entities;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarSharingManagementSystem.DataAccess.Repositories.Implementations
{
    public class JourneyDayRepository : IJourneyDayRepository
    {
        private readonly AppDbContext _context;

        public JourneyDayRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<JourneyDay>> GetAllAsync()
        {
            return await _context.JourneyDays.ToListAsync();
        }

        public async Task<JourneyDay?> GetByIdAsync(int id)
        {
            return await _context.JourneyDays.FindAsync(id);
        }

        public async Task<int> AddAsync(JourneyDay journeyDay)
        {
            try
            {
                await _context.JourneyDays.AddAsync(journeyDay);
                await _context.SaveChangesAsync();
                return 0; // Success
            }
            catch
            {
                return -1; // Failure
            }
        }

        public async Task<int> UpdateAsync(JourneyDay journeyDay)
        {
            try
            {
                _context.JourneyDays.Update(journeyDay);
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
                var journeyDay = await _context.JourneyDays.FindAsync(id);
                if (journeyDay != null)
                {
                    _context.JourneyDays.Remove(journeyDay);
                    await _context.SaveChangesAsync();
                    return 0; // Success
                }
                return -1; // JourneyDay not found
            }
            catch
            {
                return -1; // Failure
            }
        }
    }
}