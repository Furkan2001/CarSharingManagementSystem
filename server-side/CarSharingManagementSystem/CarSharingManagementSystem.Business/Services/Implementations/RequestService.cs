using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Implementations
{
    public class RequestService : IRequestService
    {
        private readonly IRequestRepository _requestRepository;

        public RequestService(IRequestRepository requestRepository)
        {
            _requestRepository = requestRepository;
        }
        public async Task<IEnumerable<Request>> GetAllAsync()
        {
            return await _requestRepository.GetAllAsync();
        }

        public async Task<Request> GetByIdAsync(int id)
        {
            return await _requestRepository.GetByIdAsync(id);
        }

        public async Task<IEnumerable<Request>> GetRequestsByUserId(int userId)
        {
            await _requestRepository.CleanupDeletedRequestsAsync();
            return await _requestRepository.GetRequestsByUserId(userId);
        }

        public async Task<int> AddAsync(Request entity)
        {
            return await _requestRepository.AddAsync(entity);
        }

        public async Task<int> DeleteAsync(int id)
        {
            return await _requestRepository.DeleteAsync(id);
        }
        public async Task<int> UpdateAsync(Request entity)
        {
            return await _requestRepository.UpdateAsync(entity);
        }
    }
}