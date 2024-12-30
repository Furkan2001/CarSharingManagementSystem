using System.Collections.Concurrent;
using CarSharingManagementSystem.Business.Services.Interfaces;
using Microsoft.AspNetCore.SignalR;
using FirebaseAdmin.Messaging;

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
            }
            else
            {
                Console.WriteLine($"Alıcı {receiverId} bağlı değil. Mesaj veritabanına kaydediliyor...");
                await _messageService.AddAsync(new Entities.Message
                {
                    SenderId = senderId,
                    ReceiverId = receiverId,
                    MessageText = message,
                    IsRead = false,
                    Time = DateTime.UtcNow
                });

                await SendNotification(receiverId, "Yeni Mesaj", message);
            }
        }

        private async Task SendNotification(int receiverId, string title, string messageBody)
        {
            var deviceToken = await GetUserDeviceToken(receiverId);

            if (string.IsNullOrEmpty(deviceToken))
            {
                Console.WriteLine($"Kullanıcı {receiverId} için cihaz token bulunamadı.");
                return;
            }

            // Firebase mesajını oluştur
            var message = new FirebaseAdmin.Messaging.Message()
            {
                Token = deviceToken,
                Notification = new Notification()
                {
                    Title = title,
                    Body = messageBody
                },
                Data = new Dictionary<string, string>()
                {
                    { "receiverId", receiverId.ToString() },
                    { "message", messageBody }
                }
            };

            try
            {
                // Firebase ile bildirimi gönder
                var response = await FirebaseMessaging.DefaultInstance.SendAsync(message);
                Console.WriteLine($"Bildirim gönderildi. Yanıt: {response}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Bildirim gönderme hatası: {ex.Message}");
            }
        }

        private async Task<string> GetUserDeviceToken(int userId)
        {
            return await _userDeviceTokenService.GetDeviceTokenAsync(userId);
        }
    }
}