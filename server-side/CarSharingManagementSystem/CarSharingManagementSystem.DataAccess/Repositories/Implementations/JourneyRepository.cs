using CarSharingManagementSystem.Entities;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarSharingManagementSystem.DataAccess.Repositories.Implementations
{
    public class JourneyRepository : IJourneyRepository
    {
        private readonly AppDbContext _context;

        public JourneyRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Journey>> GetAllAsync()
        {
            // User ve Map ilişkilerini dahil ederek tüm Journey kayıtlarını getiriyoruz
            return await _context.Journeys
                .Include(j => j.User)
                .Include(j => j.Map)
                .ToListAsync();
        }

        public async Task<Journey> GetByIdAsync(int id)
        {
            // Tek bir Journey kaydını ilişkili User ve Map ile birlikte getiriyoruz
            return await _context.Journeys
                .Include(j => j.User)
                .Include(j => j.Map)
                .FirstOrDefaultAsync(j => j.JourneyId == id);
        }

        public async Task<int> AddAsync(Journey journey)
        {
            try
            {
                await _context.Journeys.AddAsync(journey);
                await _context.SaveChangesAsync();
                return 0; // Success
            }
            catch
            {
                return -1; // Failure
            }
        }

        public async Task<int> UpdateAsync(Journey journey)
        {
            try
            {
                _context.Journeys.Update(journey);
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
                var journey = await _context.Journeys.FindAsync(id);
                if (journey != null)
                {
                    _context.Journeys.Remove(journey);
                    await _context.SaveChangesAsync();
                    return 0; // Success
                }
                return -1; // Journey not found
            }
            catch
            {
                return -1; // Failure
            }
        }
    }
}