using Microsoft.AspNetCore.Mvc;
using System;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;
using System.Net.Http;
using Newtonsoft.Json;
using System.Collections.Generic;  // Make sure to import this for Dictionary

namespace CarSharingManagementSystem.Controllers
{
    [Route("")]
    [ApiController]
    public class OAuthController : ControllerBase
    {
        private readonly string clientId = "FB387A2ABDDD423586FFB6ED157762BB";
        private readonly string clientSecret = "3FF64BC099174847A5FB2EF22E1D0930";  // Make sure to add the client secret
        private readonly string redirectUri = "http://localhost:3000/auth";
        private readonly string authorizationEndpoint = "https://kampus.gtu.edu.tr/oauth/yetki";
        private readonly string tokenEndpoint = "https://kampus.gtu.edu.tr/oauth/dogrulama";



        [HttpGet("login")]
        public IActionResult Login()
        {
            // Generate state and code_verifier
            var state = GenerateRandomState();
            var codeVerifier = GenerateCodeVerifier();
            var codeChallenge = GenerateCodeChallenge(codeVerifier);

            Console.WriteLine($"codeVerifier: {codeVerifier}");

            // Store values in cookies (client-side)
            Response.Cookies.Append("state", state, new CookieOptions { HttpOnly = true, Secure = true, SameSite = SameSiteMode.Lax });
            Response.Cookies.Append("codeVerifier", codeVerifier, new CookieOptions { HttpOnly = true, Secure = true, SameSite = SameSiteMode.Lax });

            // Construct authorization URL
            var authorizationUrl = $"{authorizationEndpoint}?response_type=code" +
                                $"&client_id={clientId}" +
                                $"&redirect_uri={Uri.EscapeDataString(redirectUri)}" +
                                $"&state={state}" +
                                $"&code_challenge_method=s256" +
                                $"&code_challenge={codeChallenge}";

            return Redirect(authorizationUrl);
        }

        [HttpGet("auth")]
        public async Task<IActionResult> OAuthRedirect(string state, string code)
        {
            // Retrieve values from cookies (client-side)
            var storedState = Request.Cookies["state"];
            var storedCodeVerifier = Request.Cookies["codeVerifier"];

            if (storedState == null || storedCodeVerifier == null)
            {
                return BadRequest("Missing state or codeVerifier.");
            }

            if (state != storedState)
            {
                return BadRequest("Invalid state.");
            }

            Console.WriteLine($"codeVerifier: {storedCodeVerifier}");

            // Exchange code for token using stored codeVerifier
            var token = await ExchangeCodeForToken(code, storedCodeVerifier);

            return Ok(token);
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

        // Generate a code verifier for PKCE
        private string GenerateCodeVerifier()
        {
            // var rng = new Random();
            // var codeVerifier = new byte[64];  // Code verifier length must be between 43 and 128 bytes
            // rng.NextBytes(codeVerifier);
            // return Convert.ToBase64String(codeVerifier)
            //               .TrimEnd('=')
            //               .Replace('+', '-')
            //               .Replace('/', '_');

            return "FNWNCOMVBMOSXJVVWOQECEMZHEAYQXYCDDOUXTPIZVWHOMPMZU";
        }

        // Generate a code challenge (SHA-256 of the code verifier)
        private string GenerateCodeChallenge(string codeVerifier)
        {
            // using (var sha256 = SHA256.Create())
            // {
            //     byte[] hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(codeVerifier));
            //     string base64Hash = Convert.ToBase64String(hashBytes);
            //     return Uri.EscapeDataString(base64Hash);
            // }

            return "SPWVMuTi7LDzOSSbVtRs3eD3mm4oGMeKXpq19kaBLqk%3D";
        }
    }
}
