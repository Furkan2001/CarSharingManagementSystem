using CarSharingManagementSystem.Entities;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace CarSharingManagementSystem.DataAccess.Repositories.Implementations
{
    public class RequestRepository : IRequestRepository
    {
        private readonly AppDbContext _context;

        public RequestRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Request>> GetAllAsync()
        {
            // receiver_is_deleted veya sender_is_deleted olan request'leri hariç tut
            return await _context.Requests
                .Where(r => !(r.ReceiverIsDeleted && r.SenderIsDeleted)) // Her iki alan 1 ise hariç tut
                .Include(r => r.Sender)
                .Include(r => r.Receiver)
                .Include(r => r.Status)
                .ToListAsync();
        }

        public async Task<Request> GetByIdAsync(int id)
        {
            return await _context.Requests
                .Include(r => r.Sender)
                .Include(r => r.Receiver)
                .Include(r => r.Status)
                .FirstOrDefaultAsync(r => r.RequestId == id);
        }

        public async Task<IEnumerable<Request>> GetRequestsByUserId(int userId)
        {
            return await _context.Requests
                .Where(r => 
                    (r.ReceiverId == userId && !r.ReceiverIsDeleted) || // Kullanıcı alıcı ve silinmemişse
                    (r.SenderId == userId && !r.SenderIsDeleted)       // Kullanıcı gönderici ve silinmemişse
                )
                .Include(r => r.Sender)
                .Include(r => r.Receiver)
                .Include(r => r.Status)
                .ToListAsync();
        }

        public async Task<int> AddAsync(Request entity)
        {
            try
            {
                await _context.Requests.AddAsync(entity);
                await _context.SaveChangesAsync();
                return 0; // Success
            }
            catch
            {
                return -1; // Failure
            }
        }

        public async Task<int> DeleteAsync(int id)
        {
            try
            {
                var request = await _context.Requests.FindAsync(id);
                if (request != null)
                {
                    _context.Requests.Remove(request);
                    await _context.SaveChangesAsync();
                    return 0; // Success
                }
                return -1; // Not Found
            }
            catch
            {
                return -1; // Failure
            }
        }

        public async Task<int> UpdateAsync(Request entity)
        {
            try
            {
                // Eğer hem sender_is_deleted hem de receiver_is_deleted true ise request'i tamamen sil
                if (entity.SenderIsDeleted && entity.ReceiverIsDeleted)
                {
                    _context.Requests.Remove(entity);
                }
                else
                {
                    _context.Requests.Update(entity);
                }

                await _context.SaveChangesAsync();
                return 0; // Success
            }
            catch
            {
                return -1; // Failure
            }
        }

        public async Task CleanupDeletedRequestsAsync()
        {
            // receiver_is_deleted ve sender_is_deleted olan tüm request'leri sil
            var requestsToDelete = await _context.Requests
                .Where(r => r.ReceiverIsDeleted && r.SenderIsDeleted)
                .ToListAsync();

            if (requestsToDelete.Any())
            {
                _context.Requests.RemoveRange(requestsToDelete);
                await _context.SaveChangesAsync();
            }
        }
    }
}