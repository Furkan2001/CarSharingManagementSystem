using CarSharingManagementSystem.Entities;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarSharingManagementSystem.DataAccess.Repositories.Implementations
{
    public class MapRepository : IMapRepository
    {
        private readonly AppDbContext _context;

        public MapRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Map>> GetAllAsync()
        {
            return await _context.Maps.ToListAsync();
        }

        public async Task<Map> GetByIdAsync(int id)
        {
            return await _context.Maps.FindAsync(id);
        }

        public async Task<int> AddAsync(Map map)
        {
            try
            {
                await _context.Maps.AddAsync(map);
                await _context.SaveChangesAsync();
                return 0; // Success
            }
            catch
            {
                return -1; // Failure
            }
        }

        public async Task<int> UpdateAsync(Map map)
        {
            try
            {
                _context.Maps.Update(map);
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
                var map = await _context.Maps.FindAsync(id);
                if (map != null)
                {
                    _context.Maps.Remove(map);
                    await _context.SaveChangesAsync();
                    return 0; // Success
                }
                return -1; // Map not found
            }
            catch
            {
                return -1; // Failure
            }
        }
    }
}