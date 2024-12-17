using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using CarSharingManagementSystem.Entities;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarSharingManagementSystem.DataAccess.Repositories.Implementations
{

    public class UserDeviceTokenRepository : IUserDeviceTokenRepository
    {
        private readonly AppDbContext _context;

        public UserDeviceTokenRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task AddDeviceTokenAsync(int userId, string token)
        {
            // Kullanıcı için cihaz token var mı kontrol et
            var existingToken = await _context.UserDeviceTokens
                .FirstOrDefaultAsync(x => x.UserId == userId && x.Token == token);

            if (existingToken == null) // Eğer yoksa yeni bir token ekle
            {
                var deviceToken = new UserDeviceToken
                {
                    UserId = userId,
                    Token = token,
                    Time = DateTime.UtcNow
                };

                await _context.UserDeviceTokens.AddAsync(deviceToken);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<string> GetDeviceTokenAsync(int userId)
        {
            var token = await _context.UserDeviceTokens
                .Where(x => x.UserId == userId)
                .OrderByDescending(x => x.Time) // En son kaydedilen token'ı getir
                .Select(x => x.Token)
                .FirstOrDefaultAsync();

            return token;
        }
    }
}