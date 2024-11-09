using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Implementations
{
    public class MapService : IMapService
    {
        private readonly IMapRepository _mapRepository;

        public MapService(IMapRepository mapRepository)
        {
            _mapRepository = mapRepository;
        }

        public async Task<IEnumerable<Map>> GetAllAsync()
        {
            return await _mapRepository.GetAllAsync();
        }

        public async Task<Map> GetByIdAsync(int id)
        {
            return await _mapRepository.GetByIdAsync(id);
        }

        public async Task<int> AddAsync(Map map)
        {
            return await _mapRepository.AddAsync(map);
        }

        public async Task<int> PrivateAddAsync(Map map)
        {
            return await _mapRepository.PrivateAddAsync(map);
        }

        public async Task<int> UpdateAsync(Map map)
        {
            return await _mapRepository.UpdateAsync(map);
        }

        public async Task<int> DeleteAsync(int id)
        {
            return await _mapRepository.DeleteAsync(id);
        }
    }
}