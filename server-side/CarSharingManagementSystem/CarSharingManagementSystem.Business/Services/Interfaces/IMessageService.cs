using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Interfaces
{
    public interface IMessageService : IService<Message> 
    {
        Task<bool> MarkAsReadAsync(int messageId);
        Task<int> DeleteReadMessagesAsync();
        Task<IEnumerable<Message>>GetMessageHistoryAsync(int userId1, int userId2);
        Task<IEnumerable<Message>> GetEndUnreadedMessagesForAPerson(int userId);
        Task<int> DeleteMessagesBetweenTwoUsers(int userId1, int userId2);
    }
}