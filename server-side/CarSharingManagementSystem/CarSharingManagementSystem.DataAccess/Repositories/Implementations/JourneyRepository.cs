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
            return await _context.Journeys.ToListAsync();
        }

        public async Task<Journey?> GetByIdAsync(int id)
        {
            return await _context.Journeys.FindAsync(id);
        }

        public async Task AddAsync(Journey journey)
        {
            await _context.Journeys.AddAsync(journey);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Journey journey)
        {
            _context.Journeys.Update(journey);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var journey = await GetByIdAsync(id);
            if (journey != null)
            {
                _context.Journeys.Remove(journey);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<IEnumerable<Journey>> GetByUsernameAsync(string username)
        {
            return await _context.Journeys
                .Where(j => j.UserName == username)
                .ToListAsync();
        }

        public async Task<IEnumerable<Journey>> FilterByLocationAsync(string origin, string destination)
        {
            return await _context.Journeys
                .Where(j => j.Beginning == origin && j.Destination == destination)
                .ToListAsync();
        }
    }
}