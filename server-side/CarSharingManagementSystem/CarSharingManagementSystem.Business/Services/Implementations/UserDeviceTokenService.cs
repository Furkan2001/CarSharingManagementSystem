using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Implementations
{
    public class UserDeviceTokenService : IUserDeviceTokenService
    {
        private readonly IUserDeviceTokenRepository _repository;

        public UserDeviceTokenService(IUserDeviceTokenRepository repository)
        {
            _repository = repository;
        }

        public async Task AddDeviceTokenAsync(int userId, string token)
        {
            await _repository.AddDeviceTokenAsync(userId, token);
        }

        public async Task<string> GetDeviceTokenAsync(int userId)
        {
            return await _repository.GetDeviceTokenAsync(userId);
        }
    }
}