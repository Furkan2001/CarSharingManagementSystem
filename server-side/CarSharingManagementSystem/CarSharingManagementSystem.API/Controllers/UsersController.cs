using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CarSharingManagementSystem.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        [HttpGet]
        public IActionResult GetUsers()
        {
            var user = new[]
            {
                new { Id = 1, Name = "Furkan", Email = "furkan@example.com" }
            };
            return Ok(user);
        }
    }
}
