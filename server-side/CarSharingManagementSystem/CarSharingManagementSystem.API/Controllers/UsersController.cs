using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.Entities;
using CarSharingManagementSystem.HelperClasses;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CarSharingManagementSystem.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IUserDeviceTokenService _userDeviceTokenService;

        public UsersController(IUserService userService, IUserDeviceTokenService userDeviceTokenService)
        {
            _userService = userService;
            _userDeviceTokenService = userDeviceTokenService;
        }

        [HttpGet]
        public async Task<IActionResult> GetUsers()
        {
            var user = await _userService.GetAllAsync();
            return Ok(user);
        }

        [HttpPost]
        public async Task<IActionResult> ControlUser(User _user)
        {
            var users = await _userService.GetAllAsync();

            foreach(User user in users)
            {
                if (user.Email == _user.Email)
                    return Ok(user);
            }

            _user.apiKey = ApiKeyGenerator.GenerateApiKey();
            _user.SustainabilityPoint = 0;
            await _userService.AddAsync(_user);

            var tempUser = await _userService.GetUserByEmailAsync(_user.Email);

            if (tempUser != null)
                return Ok(tempUser);

            return Ok();
        }

        [HttpPost("save-device-token")]
        public async Task<IActionResult> SaveDeviceToken(int userId, string deviceToken)
        {
            await _userDeviceTokenService.AddDeviceTokenAsync(userId, deviceToken);
            return Ok(new { message = "Cihaz token'ı kaydedildi." });
        }

        [HttpGet("get-user/{id}")]
        public async Task<IActionResult> GetAUser(int id)
        {
            User? user = await _userService.GetByIdAsync(id);
            return Ok(user);
        }
    }
}
