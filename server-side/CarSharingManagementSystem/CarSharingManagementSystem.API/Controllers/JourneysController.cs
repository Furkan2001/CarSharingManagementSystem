using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using System.Collections.Generic;
using CarSharingManagementSystem.Entities;
using CarSharingManagementSystem.Business.Services.Interfaces;
using CarSharingManagementSystem.DataAccess.DTOs;

namespace CarSharingManagementSystem.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class JourneysController : ControllerBase
    {
        private readonly IJourneyService _journeyService;
        private readonly IMapService _mapService;
        private readonly IJourneyDayService _journeyDayService;

        public JourneysController(IJourneyService journeyService, IMapService mapService, IJourneyDayService journeyDayService)
        {
            _journeyService = journeyService;
            _mapService = mapService;
            _journeyDayService = journeyDayService;
        }

        // GET: api/Journey/all
        [HttpGet("all")]
        public async Task<IActionResult> GetAllJourneys()
        {
            await _journeyService.AutoDeleteAsync();
            var journeys = await _journeyService.GetAllAsync();
            return Ok(journeys);
        }

        // GET: api/Journey/mine
        [HttpGet("mine/{id}")]
        public async Task<IActionResult> GetMyJourneys(int id)
        {
            await _journeyService.AutoDeleteAsync();
            var journeys = await _journeyService.GetByUserIdAsync(id);
            return Ok(journeys);
        }

        // GET: api/Journey/5
        [HttpGet("{id}")]
        public async Task<IActionResult> GetJourneyById(int id)
        {
            await _journeyService.AutoDeleteAsync();
            var journey = await _journeyService.GetByIdAsync(id);
            if (journey == null)
            {
                return NotFound();
            }
            return Ok(journey);
        }

        [HttpPost("filter")]
        public async Task<IActionResult> FilterJourney([FromBody] JourneyFilterModel filterModel)
        {
            var journey = await _journeyService.GetFilteredJourneysAsync(filterModel);
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

            int result;

            result = await _journeyService.AddAsync(journey);
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
            Journey journey = await _journeyService.GetByIdAsync(id);

            int result = 0;

            if (journey.MapId.HasValue)
                result = await _mapService.DeleteAsync(journey.MapId.Value);
            if (result == -1)
                return StatusCode(StatusCodes.Status500InternalServerError, "Error deleting journey.");

            result = await _journeyService.DeleteAsync(id);
            if (result == -1)
                return StatusCode(StatusCodes.Status500InternalServerError, "Error deleting journey.");

            return NoContent();
        }
    }
}
