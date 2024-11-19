using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.DataAccess.Repositories.Interfaces
{
    public interface IMessageRepository : IRepository<Message> 
    {
        Task<bool> MarkAsReadAsync(int messageId);
        Task<int> DeleteReadMessagesAsync();
        Task<IEnumerable<Message>>GetMessageHistoryAsync(int userId1, int userId2);
        Task<IEnumerable<Message>> GetUnreadMessagesAsync(int userId);
    }
}