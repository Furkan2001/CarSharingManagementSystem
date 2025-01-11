using Microsoft.AspNetCore.Mvc;
using System.Security.Cryptography;
using System.Text;
using Newtonsoft.Json;
using CarSharingManagementSystem.Business.Services.Interfaces;
using Newtonsoft.Json.Linq;
using CarSharingManagementSystem.Entities;
using CarSharingManagementSystem.HelperClasses;

namespace CarSharingManagementSystem.Controllers
{
    [Route("")]
    [ApiController]
    public class OAuthController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly string clientId = "FB387A2ABDDD423586FFB6ED157762BB";
        private readonly string clientSecret = "3FF64BC099174847A5FB2EF22E1D0930";
        private readonly string redirectUri = "http://localhost:3000/auth";
        private readonly string authorizationEndpoint = "https://kampus.gtu.edu.tr/oauth/yetki";
        private readonly string tokenEndpoint = "https://kampus.gtu.edu.tr/oauth/dogrulama";
        private readonly string queryServerAddress = "https://kampus.gtu.edu.tr/oauth/sorgulama";

        public OAuthController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpGet("login")]
        public IActionResult Login()
        {
            // Generate state and code_verifier
            var state = GenerateRandomState();
            var codeVerifier = GenerateCodeVerifier();
            var codeChallenge = GenerateCodeChallenge(codeVerifier);

            Console.WriteLine($"codeVerifier: {codeVerifier}");
            Console.WriteLine($"Received State: {state}");

            // Store values in cookies (client-side)
            Response.Cookies.Append("state", state, new CookieOptions { HttpOnly = true, Secure = false, SameSite = SameSiteMode.Lax });
            Response.Cookies.Append("codeVerifier", codeVerifier, new CookieOptions { HttpOnly = true, Secure = false, SameSite = SameSiteMode.Lax });

            // Construct authorization URL
            var authorizationUrl = $"{authorizationEndpoint}?response_type=code" +
                                $"&client_id={clientId}" +
                                $"&redirect_uri={Uri.EscapeDataString(redirectUri)}" +
                                $"&state={state}" +
                                $"&code_challenge_method=s256" +
                                $"&code_challenge={codeChallenge}";

            return Ok(authorizationUrl);
        }

        [HttpGet("auth")]
        public async Task<IActionResult> OAuthRedirect(string state, string code)
        {
            // Retrieve values from cookies (client-side)
            var storedState = Request.Cookies["state"];
            var storedCodeVerifier = Request.Cookies["codeVerifier"];

            Console.WriteLine($"Stored State: {storedState}");

            if (storedState == null || storedCodeVerifier == null)
            {
                return BadRequest("Missing state or codeVerifier.");
            }

            if (state != storedState)
            {
                return BadRequest("Invalid state.");
            }

            Console.WriteLine($"codeVerifier: {storedCodeVerifier}");

            try
            {
                // 1. Access token al
                var accessToken = await ExchangeCodeForToken(code, storedCodeVerifier);
                Console.WriteLine($"Access Token: {accessToken}");

                // 2. Access token ile kullanıcı bilgilerini al
                using (var httpClient = new HttpClient())
                {
                    var requestData = new Dictionary<string, string>
                    {
                        { "client_id", clientId },
                        { "access_token", accessToken },
                        { "kapsam", "GENEL" }
                    };

                    var jsonData = JsonConvert.SerializeObject(requestData);
                    var content = new StringContent(jsonData, Encoding.UTF8, "application/json");
                    //var content = new FormUrlEncodedContent(requestData);
                    var response = await httpClient.PostAsync(queryServerAddress, content);

                    if (!response.IsSuccessStatusCode)
                    {
                        var errorContent = await response.Content.ReadAsStringAsync();
                        Console.WriteLine($"Error response: {errorContent}");
                        Console.WriteLine($"Error code: {response.StatusCode}");
                        return StatusCode((int)response.StatusCode, $"Error fetching user info: {errorContent}");
                    }

                    var responseContent = await response.Content.ReadAsStringAsync();
                    var userInfo = JToken.Parse(responseContent);

                    if (userInfo == null)
                    {
                        return BadRequest("User info could not be parsed.");
                    }

                    User? newUser = await ControlUser(userInfo);

                    if (newUser == null)
                    {
                        Console.WriteLine("Error ControlUser funciton");
                        return BadRequest();
                    }

                    Console.WriteLine("User exists in the system.");
                    return Ok(newUser);
                }
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, $"An error occurred: {ex.Message}");
            }
        }

        private async Task<User?> ControlUser(JToken userInfo)
        {
            User _user = ConvertToUser(userInfo);

            var users = await _userService.GetAllAsync();

            foreach(User user in users)
            {
                if (user.Email == _user.Email)
                    return await _userService.GetUserByEmailAsync(_user.Email);
            }

            _user.apiKey = ApiKeyGenerator.GenerateApiKey();
            _user.SustainabilityPoint = 0;
            await _userService.AddAsync(_user);

            var tempUser = await _userService.GetUserByEmailAsync(_user.Email);

            if (tempUser != null)
                return tempUser;

            return null;
        }

        private User ConvertToUser(JToken userInfo)
        {
            return new User
            {
                Username = userInfo["kullanici_adi"]?.ToString(),
                Name = userInfo["ad"]?.ToString(),
                Surname = userInfo["soyad"]?.ToString(),
                Email = userInfo["kurumsal_email_adresi"]?.ToString(),
                Gender = userInfo["cinsiyet"]?.ToString(),
                IsInInstitution = userInfo["kurum_ici"]?.ToString() == "TRUE",
                IsStudent = userInfo["ogrenci"]?.ToString() == "TRUE",
                IsAcademicPersonal = userInfo["akademik_personel"]?.ToString() == "TRUE",
                IsAdministrativeStaff = userInfo["idari_personel"]?.ToString() == "TRUE",
                UniqueId = userInfo["kimlik_no_unique_id"]?.ToString(),
                SustainabilityPoint = null, // Eğer JSON'da sustainabilityPoint yoksa null bırakın
                apiKey = null // Eğer API key yoksa burada bir değer bırakabilirsiniz
            };
        }

        // Step 3: Exchange the authorization code for an access token
        private async Task<string> ExchangeCodeForToken(string code, string codeVerifier)
        {
            using (var httpClient = new HttpClient())
            {
                var requestData = new Dictionary<string, string>
                {
                    { "client_id", clientId },
                    { "client_secret", clientSecret },
                    { "code", code },
                    { "code_verifier", codeVerifier }
                };

                // Convert the request data to JSON
                var jsonData = JsonConvert.SerializeObject(requestData);

                // Prepare the content for the POST request (no need to manually add Content-Type header)
                var content = new StringContent(jsonData, Encoding.UTF8, "application/json");

                // Set the Content-Length header manually
                content.Headers.Add("Content-Length", jsonData.Length.ToString());

                // Send the POST request
                var response = await httpClient.PostAsync(tokenEndpoint, content);

                // Check if the response status is successful
                if (!response.IsSuccessStatusCode)
                {
                    // Log error and return failure message
                    var errorContent = await response.Content.ReadAsStringAsync();
                    Console.WriteLine($"Error response: {errorContent}");
                    throw new HttpRequestException($"Token request failed with status code {response.StatusCode}: {errorContent}");
                }

                // Parse the response
                var responseContent = await response.Content.ReadAsStringAsync();
                dynamic responseJson = JsonConvert.DeserializeObject(responseContent);

                Console.WriteLine($"Received Token Response: {responseJson}");

                // Return the access token
                return responseJson.access_token;
            }
        }

        // Generate random 'state' value
        private string GenerateRandomState()
        {
            var rng = new Random();
            var randomValue = new byte[32];
            rng.NextBytes(randomValue);
            return Convert.ToBase64String(randomValue)
                            .TrimEnd('=')
                          .Replace('+', '-')
                          .Replace('/', '_');
        }

        // Generate a random 'code_verifier' for PKCE
        public static string GenerateCodeVerifier()
        {
            const string chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~";
            var random = new Random();
            var codeVerifier = new char[64]; // Default length is 64, can be adjusted between 43-128

            for (int i = 0; i < codeVerifier.Length; i++)
            {
                codeVerifier[i] = chars[random.Next(chars.Length)];
            }

            return new string(codeVerifier);
        }

        // Generate a 'code_challenge' using SHA256 hash and Base64 encoding
        public static string GenerateCodeChallenge(string codeVerifier)
        {
            using (var sha256 = SHA256.Create())
            {
                // SHA256 hash hesaplama
                byte[] hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(codeVerifier));
                
                // Base64 kodlama (standard)
                string base64Hash = Convert.ToBase64String(hashBytes);

                // URI encoding (percent-encode)
                return Uri.EscapeDataString(base64Hash);
            }
        }
    }
}
