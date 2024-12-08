using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.DataAccess.Repositories.Interfaces
{
    public interface IRequestRepository : IRepository<Request> 
    {
        Task<IEnumerable<Request>> GetRequestsByUserId(int userId);
        Task CleanupDeletedRequestsAsync();
    }
}