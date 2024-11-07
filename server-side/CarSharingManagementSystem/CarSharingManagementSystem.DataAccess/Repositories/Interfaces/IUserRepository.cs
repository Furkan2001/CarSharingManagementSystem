using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.DataAccess.Repositories.Interfaces
{
    public interface IUserRepository : IRepository<User> 
    {
        Task<User?> GetUserByEmailAsync(string email);

        Task<User?> GetUserByApiKeyAsync(string apiKey);
    }
}