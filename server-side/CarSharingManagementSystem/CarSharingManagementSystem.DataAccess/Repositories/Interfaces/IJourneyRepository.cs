using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.DataAccess.Repositories.Interfaces
{
    public interface IJourneyRepository : IRepository<Journey> 
    { 
        Task<IEnumerable<Journey>> GetByUserIdAsync(int userId);
    }
}
