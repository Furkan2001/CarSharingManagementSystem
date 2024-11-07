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

        public UsersController(IUserService userService)
        {
            _userService = userService;
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
            await _userService.AddAsync(_user);

            var tempUser = await _userService.GetUserByEmailAsync(_user.Email);

            if (tempUser != null)
                return Ok(tempUser);

            return Ok();
        }
    }
}
