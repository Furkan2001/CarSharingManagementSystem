using CarSharingManagementSystem.DataAccess.DTOs;
using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Interfaces
{
    public interface IJourneyService : IService<Journey> 
    {
        Task<IEnumerable<Journey>> GetByUserIdAsync(int userId);
        Task<IEnumerable<Journey>> GetFilteredJourneysAsync(JourneyFilterModel filterModel);
        Task AutoDeleteAsync();
    }
}