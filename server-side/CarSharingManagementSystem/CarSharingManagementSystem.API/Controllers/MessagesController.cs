using Microsoft.AspNetCore.Mvc;
using CarSharingManagementSystem.Entities;
using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.DataAccess.DTOs;
using Microsoft.AspNetCore.SignalR;
using CarSharingManagementSystem.API.Hubs;

namespace CarSharingManagementSystem.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MessagesController : ControllerBase
    {
        private readonly IMessageService _messageService;
        private readonly IHubContext<MessageHub> _hubContext;

        public MessagesController(IMessageService messageService, IHubContext<MessageHub> hubContext)
        {
            _messageService = messageService;
            _hubContext = hubContext;
        }

        /// <summary>
        /// Send a message
        /// </summary>
        [HttpPost("send")]
        public async Task<IActionResult> SendMessage([FromBody] MessageDto messageDto)
        {
            var message = new Message
            {
                SenderId = messageDto.SenderId,
                ReceiverId = messageDto.ReceiverId,
                MessageText = messageDto.Content,
                IsRead = false,
                Time = DateTime.UtcNow
            };

            await _messageService.AddAsync(message);

            var a = _hubContext.Clients;

            // SignalR ile alıcıya mesaj gönder
            await _hubContext.Clients.User(messageDto.ReceiverId.ToString())
                .SendAsync("ReceiveMessage", messageDto.SenderId, messageDto.Content);

            return Ok(new { Message = "Success" });
        }

        /// <summary>
        /// Get unreaded messages
        /// </summary>
        [HttpGet("unread/{userId}")]
        public async Task<IActionResult> GetUnreadMessages(int userId)
        {
            var unreadMessages = await _messageService.GetUnreadMessagesAsync(userId);
            return Ok(unreadMessages);
        }

        /// <summary>
        /// Point as readed to message
        /// </summary>
        [HttpPut("mark-as-read/{messageId}")]
        public async Task<IActionResult> MarkMessageAsRead(int messageId)
        {
            var result = await _messageService.MarkAsReadAsync(messageId);
            if (!result)
            {
                return NotFound(new { Message = "Not Found" });
            }

            return Ok(new { Message = "Success" });
        }

        /// <summary>
        /// Get messages history between two person
        /// </summary>
        [HttpGet("history/{userId1}/{userId2}")]
        public async Task<IActionResult> GetMessageHistory(int userId1, int userId2)
        {
            var messageHistory = await _messageService.GetMessageHistoryAsync(userId1, userId2);
            return Ok(messageHistory);
        }

        ///
        ///
        ///
        [HttpGet("endmessages/{userId}")]
        public async Task<IActionResult> GetEndUnreadedMessagesForAPerson(int userId)
        {
            var endMessagesForAPerson = await _messageService.GetEndUnreadedMessagesForAPerson(userId);
            if (endMessagesForAPerson == null)
                return NotFound(new { Message = "Not Found" });
            
            return Ok(endMessagesForAPerson);
        }

        /// <summary>
        /// Delete a message
        /// </summary>
        [HttpDelete("{messageId}")]
        public async Task<IActionResult> DeleteMessage(int messageId)
        {
            var result = await _messageService.DeleteAsync(messageId);
            if (result == -1)
            {
                return NotFound(new { Message = "Mesaj bulunamadı." });
            }

            return Ok(new { Message = "Mesaj silindi." });
        }

        /// <summary>
        /// Delete all readed messages
        /// </summary>
        [HttpDelete("delete-read")]
        public async Task<IActionResult> DeleteReadMessages()
        {
            var result = await _messageService.DeleteReadMessagesAsync();
            if (result == -1)
            {
                return BadRequest(new { Message = "Error in deleting all readed messages" });
            }

            return Ok(new { Message = "Success" });
        }
    }
}
