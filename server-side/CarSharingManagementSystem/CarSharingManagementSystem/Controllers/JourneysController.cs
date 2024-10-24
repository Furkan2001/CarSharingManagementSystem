using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CarSharingManagementSystem.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class JourneysController : ControllerBase
    {
        // GET: api/Journey/all
        [HttpGet("all")]
        public IActionResult GetAllJourneys()
        {
            var journeys = new[]
            {
                new { Id = 1, UserName = "Esat", Beginning = "Gtü", Destination = "Kartal", Time = "15:00" },
                new { Id = 2, UserName = "Furkan", Beginning = "Gtü", Destination = "Kadıköy", Time = "17:30" },
                new { Id = 3, UserName = "Enes", Beginning = "Gtü", Destination = "Gebze", Time = "17:00" }
            };

            //Response.Headers.Add("Access-Control-Allow-Origin", "*");
            return Ok(journeys);
        }

        // GET: api/Journey/mine
        [HttpGet("mine")]
        public IActionResult GetMyJourneys()
        {
            var journeys = new[]
            {
                new { Id = 1, UserName = "Esat", Beginning = "Gtü", Destination = "Kartal", Time = "15:00" },
                new { Id = 2, UserName = "Esat", Beginning = "Gtü", Destination = "Kadıköy", Time = "17:30" }
            };

            //Response.Headers.Add("Access-Control-Allow-Origin", "*");
            return Ok(journeys);
        }

        // GET: api/Journey/5
        [HttpGet("{id}")]
        public IActionResult GetJourneyById(int id)
        {
            var journey = new
            {
                Id = 1,
                UserName = "Esat",
                Beginning = "Gtü",
                Destination = "Kartal",
                Time = "15:00",
            };

            //Response.Headers.Add("Access-Control-Allow-Origin", "*");
            return Ok(journey);
        }

        // POST: api/Journey
        [HttpPost]
        public IActionResult CreateJourney([FromBody] object journey)
        {
            var result = new[]
            {
                new {Bool = "True"}
            };
            return Ok(result);
        }

        // PUT: api/Journey/5
        [HttpPut("{id}")]
        public IActionResult UpdateJourney(int id, [FromBody] object journey)
        {
            var result = new[]
            {
                new {Bool = "True"}
            };
            return Ok(result);
        }

        // DELETE: api/Journey/5
        [HttpDelete("{id}")]
        public IActionResult DeleteJourney(int id)
        {
            var result = new[]
            {
                new {Bool = "True"}
            };

            return Ok(result);
        }

        // Custom Route: api/Journey/search?origin=Chicago&destination=Houston
        [HttpGet("filter")]
        public IActionResult FilterJourneys(string origin, string destination)
        {
            var journeys = new[]
            {
                new { Id = 2, UserName = "Furkan", Beginning = "Gtü", Destination = "Kadıköy", Time = "17:30" }
            };
            return Ok(journeys);
        }
    }
}
