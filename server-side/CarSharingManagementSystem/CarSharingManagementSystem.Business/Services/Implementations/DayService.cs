using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Implementations
{
    public class DayService : IDayService
    {
        private readonly IDayRepository _dayRepository;

        public DayService(IDayRepository dayRepository)
        {
            _dayRepository = dayRepository;
        }

        public async Task<IEnumerable<Day>> GetAllAsync()
        {
            return await _dayRepository.GetAllAsync();
        }

        public async Task<Day> GetByIdAsync(int id)
        {
            return await _dayRepository.GetByIdAsync(id);
        }

        public async Task<int> AddAsync(Day day)
        {
            return await _dayRepository.AddAsync(day);
        }

        public async Task<int> UpdateAsync(Day day)
        {
            return await _dayRepository.UpdateAsync(day);
        }

        public async Task<int> DeleteAsync(int id)
        {
            return await _dayRepository.DeleteAsync(id);
        }
    }
}