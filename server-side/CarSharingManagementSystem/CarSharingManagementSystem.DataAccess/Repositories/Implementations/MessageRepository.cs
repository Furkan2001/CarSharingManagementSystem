using CarSharingManagementSystem.Entities;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarSharingManagementSystem.DataAccess.Repositories.Implementations
{
    public class MessageRepository : IMessageRepository
    {
        private readonly AppDbContext _context;

        public MessageRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Message>> GetAllAsync()
        {
            return await _context.Messages
                .Include(m => m.Sender)
                .Include(m => m.Receiver)
                .ToListAsync();
        }

        public async Task<Message> GetByIdAsync(int id)
        {
            return await _context.Messages
                .Include(m => m.Sender)
                .Include(m => m.Receiver)
                .FirstOrDefaultAsync(m => m.MessageId == id);
        }

        public async Task<IEnumerable<Message>>GetMessageHistoryAsync(int userId1, int userId2)
        {
            return await _context.Messages
                .Where(m => m.SenderId == userId1 && m.ReceiverId == userId2)
                .Include(m => m.Sender)
                .Include(m => m.Receiver)
                .ToListAsync();
        }

        public async Task<IEnumerable<Message>> GetUnreadMessagesAsync(int userId)
        {
            return await _context.Messages
                .Where(m => m.ReceiverId == userId && m.IsRead == false)
                .Include(m => m.Sender)
                .Include(m => m.Receiver)
                .ToListAsync();
        }

        public async Task<int> AddAsync(Message message)
        {
            try
            {
                await _context.Messages.AddAsync(message);
                await _context.SaveChangesAsync();
                return 0;
            }
            catch
            {
                return -1;
            }
        }

        public async Task<int> UpdateAsync(Message message)
        {
            try
            {
                _context.Messages.Update(message);
                await _context.SaveChangesAsync();
                return 0;
            }
            catch
            {
                return -1;
            }
        }

        public async Task<bool> MarkAsReadAsync(int messageId)
        {
            var message = await _context.Messages.FindAsync(messageId);
            if (message != null)
            {
                message.IsRead = true;
                await _context.SaveChangesAsync();
                return true;
            }
            return false;
        }

        public async Task<int> DeleteReadMessagesAsync()
        {
            try
            {
                var readMessages = await _context.Messages
                    .Where(m => m.IsRead)
                    .ToListAsync();

                _context.Messages.RemoveRange(readMessages);
                await _context.SaveChangesAsync();
                return 0;
            }
            catch
            {
                return -1;
            }
        }

        public async Task<int> DeleteAsync(int id)
        {
            try
            {
                var message = await _context.Messages.FindAsync(id);
                if (message != null)
                {
                    _context.Messages.Remove(message);
                    await _context.SaveChangesAsync();
                    return 0;
                }
                return -1;
            }
            catch
            {
                return -1;
            }
        }
    }
}