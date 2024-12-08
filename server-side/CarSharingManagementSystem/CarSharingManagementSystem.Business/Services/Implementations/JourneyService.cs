using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.DataAccess.DTOs;
using CarSharingManagementSystem.DataAccess.Repositories.Implementations;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Implementations
{
    public class JourneyService : IJourneyService
    {
        private readonly IJourneyRepository _journeyRepository;
        private readonly IRequestRepository _requestRepository; 

        public JourneyService(IJourneyRepository journeyRepository, IRequestRepository requestRepository)
        {
            _journeyRepository = journeyRepository;
            _requestRepository = requestRepository;
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

        public async Task<Journey> GetByIdAndUserIdAsync(int id, int userId)
        {
            await _requestRepository.CleanupDeletedRequestsAsync();
            return await _journeyRepository.GetByIdAndUserIdAsync(id, userId);
        }

        public async Task<int> AddAsync(Journey journey)
        {
            return await _journeyRepository.AddAsync(journey);
        }

        public async Task<IEnumerable<Journey>> GetFilteredJourneysAsync(JourneyFilterModel filterModel)
        {
            return await _journeyRepository.GetFilteredJourneysAsync(filterModel);
        }

        public async Task<int> UpdateAsync(Journey journey)
        {
            return await _journeyRepository.UpdateAsync(journey);
        }

        public async Task<int> DeleteAsync(int id)
        {
            return await _journeyRepository.DeleteAsync(id);
        }

        public async Task AutoDeleteAsync()
        {
            await _journeyRepository.AutoDeleteAsync();
        }
    }
}