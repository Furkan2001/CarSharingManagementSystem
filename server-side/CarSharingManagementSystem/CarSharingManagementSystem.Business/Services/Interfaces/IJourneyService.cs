using System.Collections.Generic;
using System.Threading.Tasks;
using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Interfaces
{
    public interface IJourneyService
    {
        Task<IEnumerable<Journey>> GetAllJourneysAsync();
        Task<IEnumerable<Journey>> GetJourneysByUsernameAsync(string username);
        Task<Journey?> GetJourneyByIdAsync(int id);
        Task AddJourneyAsync(Journey journey);
        Task UpdateJourneyAsync(Journey journey);
        Task DeleteJourneyAsync(int id);
        Task<IEnumerable<Journey>> FilterJourneysAsync(string origin, string destination);
    }
}
