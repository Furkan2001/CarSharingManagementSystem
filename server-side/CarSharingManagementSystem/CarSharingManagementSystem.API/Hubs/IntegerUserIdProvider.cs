using Microsoft.AspNetCore.SignalR;

namespace CarSharingManagementSystem.API.Hubs
{
    /// <summary>
    /// SignalR için kullanıcı kimlik sağlayıcısı (integer kimliklerle çalışır).
    /// </summary>
    public class IntegerUserIdProvider : IUserIdProvider
    {
        /// <summary>
        /// SignalR bağlantısı sırasında kullanıcı kimliğini belirler.
        /// </summary>
        /// <param name="connection">SignalR bağlantı bilgisi.</param>
        /// <returns>Kullanıcı kimliği (string olarak döndürülür).</returns>
        public string GetUserId(HubConnectionContext connection)
        {
            var userId = connection.GetHttpContext()?.Request.Headers["user_id"].ToString();

            Console.WriteLine($"userı-Id: {userId}");

            if (string.IsNullOrEmpty(userId))
            {
                return null;
            }

            return userId;
        }
    }
}
