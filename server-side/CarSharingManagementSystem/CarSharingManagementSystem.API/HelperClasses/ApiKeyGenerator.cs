using System.Security.Cryptography;

namespace CarSharingManagementSystem.HelperClasses
{
    public class ApiKeyGenerator
    {
        public static string GenerateApiKey()
        {
                byte[] secretKeyBytes = new byte[32]; // 256-bit
                RandomNumberGenerator.Fill(secretKeyBytes); // produce random bytes
                return Convert.ToBase64String(secretKeyBytes); // Base64 encoding
        }
    }
}
