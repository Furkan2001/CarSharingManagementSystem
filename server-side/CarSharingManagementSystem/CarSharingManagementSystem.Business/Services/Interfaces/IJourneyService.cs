using CarSharingManagementSystem.DataAccess.DTOs;
using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Interfaces
{
    public interface IJourneyService : IService<Journey> 
    {
        Task<IEnumerable<Journey>> GetByUserIdAsync(int userId);
        Task<IEnumerable<Journey>> GetFilteredJourneysAsync(JourneyFilterModel filterModel);
        Task<Journey> GetReceiverByIdAndUserIdAsync(int id, int userId);
        Task<Journey> GetSenderByIdAndUserIdAsync(int id, int userId);
        Task AutoDeleteAsync();
    }
}