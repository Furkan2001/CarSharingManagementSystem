using CarSharingManagementSystem.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarSharingManagementSystem.DataAccess.Repositories.Interfaces
{
    public interface IJourneyRepository
    {
        Task<IEnumerable<Journey>> GetAllAsync();
        Task<Journey?> GetByIdAsync(int id);
        Task AddAsync(Journey journey);
        Task UpdateAsync(Journey journey);
        Task DeleteAsync(int id);
        Task<IEnumerable<Journey>> GetByUsernameAsync(string username);
        Task<IEnumerable<Journey>> FilterByLocationAsync(string origin, string destination);
    }
}
