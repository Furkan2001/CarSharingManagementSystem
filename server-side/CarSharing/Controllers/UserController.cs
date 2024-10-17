using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace MyApp.Namespace
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
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
