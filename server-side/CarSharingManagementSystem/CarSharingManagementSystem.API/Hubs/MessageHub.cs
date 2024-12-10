using System.Collections.Concurrent;
using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.Entities;
using Microsoft.AspNetCore.SignalR;

namespace CarSharingManagementSystem.API.Hubs
{
    public class MessageHub : Hub
    {
        private readonly IMessageService _messageService;
        private static readonly ConcurrentDictionary<string, string> UserConnections = new();

        public MessageHub(IMessageService messageService)
        {
            _messageService = messageService;
        }

        public override async Task OnConnectedAsync()
        {
            var userId = Context.GetHttpContext()?.Request.Headers["user_id"].ToString();
            if (!string.IsNullOrEmpty(userId))
            {
                UserConnections[userId] = Context.ConnectionId;
                Console.WriteLine($"Kullanıcı {userId} bağlandı. ConnectionId: {Context.ConnectionId}");
            }
            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var userId = Context.GetHttpContext()?.Request.Headers["user_id"].ToString();
            if (!string.IsNullOrEmpty(userId) && UserConnections.ContainsKey(userId))
            {
                UserConnections.TryRemove(userId, out _);
                Console.WriteLine($"Kullanıcı {userId} bağlantısı kesildi.");
            }
            await base.OnDisconnectedAsync(exception);
        }

        public async Task SendMessage(int senderId, int receiverId, string message)
        {
            Console.WriteLine($"Mesaj gönderiliyor. Gönderen ID: {senderId}, Alıcı ID: {receiverId}, Mesaj: {message}");

            if (UserConnections.TryGetValue(receiverId.ToString(), out var connectionId))
            {
                Console.WriteLine($"Alıcı {receiverId} bağlı. Mesaj iletiliyor... connectionId: {connectionId}");
                await Clients.Client(connectionId).SendAsync("ReceiveMessage", senderId, message);
                Console.WriteLine("Clients.Client.SendAsync çağrısı tamamlandı.");
            }
            else
            {
                Console.WriteLine($"Alıcı {receiverId} bağlı değil. Mesaj veritabanına kaydediliyor...");
                await _messageService.AddAsync(new Message
                {
                    SenderId = senderId,
                    ReceiverId = receiverId,
                    MessageText = message,
                    IsRead = false,
                    Time = DateTime.UtcNow
                });
            }
        }
    }
}