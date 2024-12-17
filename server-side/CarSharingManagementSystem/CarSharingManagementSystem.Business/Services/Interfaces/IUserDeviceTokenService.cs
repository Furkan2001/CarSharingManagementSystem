using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Interfaces
{
    public interface IUserDeviceTokenService
    {
        Task AddDeviceTokenAsync(int userId, string token);
        Task<string> GetDeviceTokenAsync(int userId);
    }
}