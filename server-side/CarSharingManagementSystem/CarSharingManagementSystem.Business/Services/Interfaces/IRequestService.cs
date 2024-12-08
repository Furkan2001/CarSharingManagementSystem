using CarSharingManagementSystem.DataAccess.DTOs;
using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Interfaces
{
    public interface IRequestService : IService<Request> 
    {
        Task<IEnumerable<Request>> GetRequestsByUserId(int userId);
    }
}