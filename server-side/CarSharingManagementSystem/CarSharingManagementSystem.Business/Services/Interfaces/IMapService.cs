using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Interfaces
{
    public interface IMapService : IService<Map> 
    {
        Task<int> PrivateAddAsync(Map map);
    }
}