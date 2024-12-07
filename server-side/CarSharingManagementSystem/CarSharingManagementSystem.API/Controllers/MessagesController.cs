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

        /// <summary>
        /// Get last messages related with that user
        /// <summary>
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
        [HttpDelete("delete/{userId1}/{userId2}")]
        public async Task<IActionResult> DeleteMessagesBetweenTwoUsers(int userId1, int userId2)
        {
            var result = await _messageService.DeleteMessagesBetweenTwoUsers(userId1, userId2);
            if (result == -1)
            {
                return NotFound(new { Message = "Not Found." });
            }

            return Ok(new { Message = "Mesaj silindi." });
        }
    }
}
