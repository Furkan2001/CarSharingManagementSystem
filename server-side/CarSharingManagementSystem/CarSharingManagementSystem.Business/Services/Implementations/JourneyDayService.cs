using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Implementations
{
    public class JourneyDayService : IJourneyDayService
    {
        private readonly IJourneyDayRepository _journeyDayRepository;

        public JourneyDayService(IJourneyDayRepository journeyDayRepository)
        {
            _journeyDayRepository = journeyDayRepository;
        }

        public async Task<IEnumerable<JourneyDay>> GetAllAsync()
        {
            return await _journeyDayRepository.GetAllAsync();
        }

        public async Task<JourneyDay> GetByIdAsync(int id)
        {
            return await _journeyDayRepository.GetByIdAsync(id);
        }

        public async Task<int> AddAsync(JourneyDay journeyDay)
        {
            return await _journeyDayRepository.AddAsync(journeyDay);
        }

        public async Task<int> UpdateAsync(JourneyDay journeyDay)
        {
            return await _journeyDayRepository.UpdateAsync(journeyDay);
        }

        public async Task<int> DeleteAsync(int id)
        {
            return await _journeyDayRepository.DeleteAsync(id);
        }
    }
}