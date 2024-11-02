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

        public async Task<int> AddAsync(Message message)
        {
            return await _messageRepository.AddAsync(message);
        }

        public async Task<int> UpdateAsync(Message message)
        {
            return await _messageRepository.UpdateAsync(message);
        }

        public async Task<int> DeleteAsync(int id)
        {
            return await _messageRepository.DeleteAsync(id);
        }
    }
}