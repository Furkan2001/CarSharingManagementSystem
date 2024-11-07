using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using CarSharingManagementSystem.Entities;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarSharingManagementSystem.DataAccess.Repositories.Implementations
{

    public class UserRepository : IUserRepository
    {
        private readonly AppDbContext _context;

        public UserRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<User>> GetAllAsync()
        {
            return await _context.Users.ToListAsync();
        }

        public async Task<User?> GetByIdAsync(int id)
        {
            return await _context.Users.FindAsync(id);
        }

        public async Task<User?> GetUserByEmailAsync(string email)
        {
            return await _context.Users
                .Where(u => u.Email == email)
                .FirstOrDefaultAsync();
        }

        public async Task<User?> GetUserByApiKeyAsync(string apiKey)
        {
            return await _context.Users
                .Where(u => u.apiKey == apiKey)
                .FirstOrDefaultAsync();
        }

        public async Task<int> AddAsync(User user)
        {
            try
            {
                await _context.Users.AddAsync(user);
                await _context.SaveChangesAsync();
                return 0; // Success
            }
            catch
            {
                return -1; // Failure
            }
        }

        public async Task<int> UpdateAsync(User user)
        {
            try
            {
                _context.Users.Update(user);
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
                var user = await _context.Users.FindAsync(id);
                if (user != null)
                {
                    _context.Users.Remove(user);
                    await _context.SaveChangesAsync();
                    return 0; // Success
                }
                return -1; // User not found
            }
            catch
            {
                return -1; // Failure
            }
        }
    }
}