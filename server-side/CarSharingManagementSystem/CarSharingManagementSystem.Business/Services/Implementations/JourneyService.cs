using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Implementations
{
    public class JourneyService : IJourneyService
    {
        private readonly IJourneyRepository _journeyRepository;

        public JourneyService(IJourneyRepository journeyRepository)
        {
            _journeyRepository = journeyRepository;
        }

        public async Task<IEnumerable<Journey>> GetAllAsync()
        {
            return await _journeyRepository.GetAllAsync();
        }

        public async Task<Journey> GetByIdAsync(int id)
        {
            return await _journeyRepository.GetByIdAsync(id);
        }

        public async Task<IEnumerable<Journey>> GetByUserIdAsync(int userId)
        {
            return await _journeyRepository.GetByUserIdAsync(userId);
        }

        public async Task<int> AddAsync(Journey journey)
        {
            return await _journeyRepository.AddAsync(journey);
        }

        public async Task<int> UpdateAsync(Journey journey)
        {
            return await _journeyRepository.UpdateAsync(journey);
        }

        public async Task<int> DeleteAsync(int id)
        {
            return await _journeyRepository.DeleteAsync(id);
        }
    }
}