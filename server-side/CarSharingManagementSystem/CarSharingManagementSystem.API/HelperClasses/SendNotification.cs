using CarSharingManagementSystem.Business.Services.Interfaces;
using FirebaseAdmin.Messaging;

namespace CarSharingManagementSystem.API.HelperClasses
{
    public class SendNotification
    {
        private readonly IUserDeviceTokenService _userDeviceTokenService;

        public SendNotification(IUserDeviceTokenService userDeviceTokenService)
        {
            _userDeviceTokenService = userDeviceTokenService;
        }

        public async Task SendNotificationFromFirebase(int receiverId, string title, string messageBody)
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