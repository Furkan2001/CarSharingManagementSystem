using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Interfaces
{
    public interface IUserService : IService<User> 
    {
        Task<User?> GetUserByEmailAsync(string email);
    }
}