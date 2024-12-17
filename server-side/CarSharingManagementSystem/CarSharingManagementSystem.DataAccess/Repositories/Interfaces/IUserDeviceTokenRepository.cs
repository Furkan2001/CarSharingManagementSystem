using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.DataAccess.Repositories.Interfaces
{
    public interface IUserDeviceTokenRepository
    {
        Task AddDeviceTokenAsync(int userId, string token);
        Task<string> GetDeviceTokenAsync(int userId);
    }
}