using System.Collections.Concurrent;
using CarSharingManagementSystem.Business.Services.Interfaces;
using Microsoft.AspNetCore.SignalR;
using CarSharingManagementSystem.HelperClasses;
using CarSharingManagementSystem.API.HelperClasses;

namespace CarSharingManagementSystem.API.Hubs
{
    public class MessageHub : Hub
    {
        private readonly IMessageService _messageService;
        private readonly IUserDeviceTokenService _userDeviceTokenService;
        private static readonly ConcurrentDictionary<string, string> UserConnections = new();

        public MessageHub(IMessageService messageService, IUserDeviceTokenService userDeviceTokenService)
        {
            _messageService = messageService;
            _userDeviceTokenService = userDeviceTokenService;
        }

        public override async Task OnConnectedAsync()
        {
            var httpContext = Context.GetHttpContext();
            var userId = httpContext?.Request.Query["user_id"];
            if (!string.IsNullOrEmpty(userId))
            {
                UserConnections[userId] = Context.ConnectionId;
                Console.WriteLine($"Kullanıcı {userId} bağlandı. ConnectionId: {Context.ConnectionId}");
            }
            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var httpContext = Context.GetHttpContext();
            var userId = httpContext?.Request.Query["user_id"];
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

                await _messageService.AddAsync(new Entities.Message
                {
                    SenderId = senderId,
                    ReceiverId = receiverId,
                    MessageText = message,
                    IsRead = true,
                    Time = DateTime.UtcNow
                });
            }
            else
            {
                Console.WriteLine($"Alıcı {receiverId} bağlı değil.");
                SendNotification sendNotificationService = new SendNotification(_userDeviceTokenService);
                await sendNotificationService.SendNotificationFromFirebase(receiverId, "Yeni Mesaj", message);

                await _messageService.AddAsync(new Entities.Message
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