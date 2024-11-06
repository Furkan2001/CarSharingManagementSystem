using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using System.Collections.Generic;
using CarSharingManagementSystem.Entities;
using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.DTOs;

namespace CarSharingManagementSystem.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class JourneysController : ControllerBase
    {
        private readonly IJourneyService _journeyService;

        public JourneysController(IJourneyService journeyService)
        {
            _journeyService = journeyService;
        }

        // GET: api/Journey/all
        [HttpGet("all")]
        public async Task<IActionResult> GetAllJourneys()
        {
            var journeys = await _journeyService.GetAllAsync();
            return Ok(journeys);
        }

        // GET: api/Journey/mine
        [HttpGet("mine/{id}")]
        public async Task<IActionResult> GetMyJourneys(int id)
        {
            var journeys = await _journeyService.GetByUserIdAsync(id);
            return Ok(journeys);
        }

        // GET: api/Journey/5
        [HttpGet("{id}")]
        public async Task<IActionResult> GetJourneyById(int id)
        {
            var journey = await _journeyService.GetByIdAsync(id);
            if (journey == null)
            {
                return NotFound();
            }
            return Ok(journey);
        }

        // Bu fonksiyon filtrelemelere göre düzenlenecek.
        [HttpPost("filter")]
        public async Task<IActionResult> FilterJourney([FromBody] JourneyFilterModel filterModel)
        {
            var journey = await _journeyService.GetAllAsync();
            return Ok(journey);
        }

        // POST: api/Journey
        [HttpPost]
        public async Task<IActionResult> CreateJourney([FromBody] Journey journey)
        {
            if (journey == null)
            {
                return BadRequest("Journey data is null.");
            }

            var result = await _journeyService.AddAsync(journey);
            if (result == -1)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, "Error creating journey.");
            }

            return CreatedAtAction(nameof(GetJourneyById), new { id = journey.JourneyId }, journey);
        }

        // PUT: api/Journey/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateJourney(int id, [FromBody] Journey journey)
        {
            if (journey == null || journey.JourneyId != id)
            {
                return BadRequest("Journey data is incorrect.");
            }

            var result = await _journeyService.UpdateAsync(journey);
            if (result == -1)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, "Error updating journey.");
            }

            return NoContent();
        }

        // DELETE: api/Journey/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteJourney(int id)
        {
            var result = await _journeyService.DeleteAsync(id);
            if (result == -1)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, "Error deleting journey.");
            }

            return NoContent();
        }


    }
}
