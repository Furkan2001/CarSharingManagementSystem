using CarSharingManagementSystem.DataAccess.DTOs;
using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.DataAccess.Repositories.Interfaces
{
    public interface IJourneyRepository : IRepository<Journey> 
    { 
        Task<IEnumerable<Journey>> GetByUserIdAsync(int userId);
        Task<IEnumerable<Journey>> GetAccordingToHasVehicle(bool hasVehicle);
        Task<IEnumerable<Journey>> GetAccordingToDestinationLocation(string destinationDistrict);
        Task<IEnumerable<Journey>> GetAccordingToStartLocation(string startDistrict);
        Task<IEnumerable<Journey>> GetAccordingToStartAndDestinationLocation(string startDistrict, string destinationDistrict);
        Task<IEnumerable<Journey>> GetAccordingToTime(DateTime start, DateTime end);
        Task<IEnumerable<Journey>> GetFilteredJourneysAsync(JourneyFilterModel filterModel);
        Task<Journey> GetReceiverByIdAndUserIdAsync(int id, int userId);
        Task<Journey> GetSenderByIdAndUserIdAsync(int id, int userId);
        Task AutoDeleteAsync();
    }
}
