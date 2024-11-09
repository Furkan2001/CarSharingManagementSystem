using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.DataAccess.Repositories.Interfaces
{
    public interface IMapRepository : IRepository<Map> 
    {
        Task<int> PrivateAddAsync(Map map);
    }
}