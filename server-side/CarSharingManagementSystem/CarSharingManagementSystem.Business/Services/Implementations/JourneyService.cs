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

        public async Task<IEnumerable<Journey>> GetAllJourneysAsync()
        {
            return await _journeyRepository.GetAllAsync();
        }

        public async Task<IEnumerable<Journey>> GetJourneysByUsernameAsync(string username)
        {
            return await _journeyRepository.GetByUsernameAsync(username);
        }

        public async Task<Journey?> GetJourneyByIdAsync(int id)
        {
            return await _journeyRepository.GetByIdAsync(id);
        }

        public async Task AddJourneyAsync(Journey journey)
        {
            await _journeyRepository.AddAsync(journey);
        }

        public async Task UpdateJourneyAsync(Journey journey)
        {
            await _journeyRepository.UpdateAsync(journey);
        }

        public async Task DeleteJourneyAsync(int id)
        {
            await _journeyRepository.DeleteAsync(id);
        }

        public async Task<IEnumerable<Journey>> FilterJourneysAsync(string origin, string destination)
        {
            return await _journeyRepository.FilterByLocationAsync(origin, destination);
        }
    }
}