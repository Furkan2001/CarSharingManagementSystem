using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using CarSharingManagementSystem.Entities;

namespace CarSharingManagementSystem.Business.Services.Implementations
{
    public class MessageService : IMessageService
    {
        private readonly IMessageRepository _messageRepository;

        public MessageService(IMessageRepository messageRepository)
        {
            _messageRepository = messageRepository;
        }

        public async Task<IEnumerable<Message>> GetAllAsync()
        {
            return await _messageRepository.GetAllAsync();
        }

        public async Task<Message> GetByIdAsync(int id)
        {
            return await _messageRepository.GetByIdAsync(id);
        }

        public async Task<IEnumerable<Message>>GetMessageHistoryAsync(int userId1, int userId2)
        {
            var messages = await _messageRepository.GetMessageHistoryAsync(userId1, userId2);

            if (messages != null)
            {
                foreach(var message in messages)
                {
                    if (message.ReceiverId == userId1)
                        await MarkAsReadAsync(message.MessageId);
                }
                //await DeleteReadMessagesAsync();
            }

            return messages;
        }

        public async Task<int> AddAsync(Message message)
        {
            return await _messageRepository.AddAsync(message);
        }

        public async Task<int> UpdateAsync(Message message)
        {
            return await _messageRepository.UpdateAsync(message);
        }

        public async Task<bool> MarkAsReadAsync(int messageId)
        {
            return await _messageRepository.MarkAsReadAsync(messageId);
        }

        public async Task<IEnumerable<Message>> GetEndUnreadedMessagesForAPerson(int userId)
        {
            return await _messageRepository.GetEndUnreadedMessagesForAPerson(userId);
        }

        public async Task<int> DeleteReadMessagesAsync()
        {
            return await _messageRepository.DeleteReadMessagesAsync();
        }

        public async Task<int> DeleteMessagesBetweenTwoUsers(int userId1, int userId2)
        {
            return await _messageRepository.DeleteMessagesBetweenTwoUsers(userId1, userId2);
        }

        public async Task<int> DeleteAsync(int id)
        {
            return await _messageRepository.DeleteAsync(id);
        }
    }
}