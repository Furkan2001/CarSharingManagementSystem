using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.Entities;
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
