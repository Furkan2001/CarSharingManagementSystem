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
    public class RequestsController : ControllerBase
    {
        private readonly IRequestService _requestService;

        public RequestsController(IRequestService requestService)
        {
            _requestService = requestService;
        }

        // GET: api/Request
        [HttpGet("{id}")]
        public async Task<IActionResult> GetRequestById(int id)
        {
            var request = await _requestService.GetByIdAsync(id);
            return Ok(request);
        }

        // GET: api/mine/Request
        [HttpGet("mine/{userId}")]
        public async Task<IActionResult> GetMyJourneys(int userId)
        {
            var journeys = await _requestService.GetRequestsByUserId(userId);
            return Ok(journeys);
        }

        [HttpPost]
        public async Task<IActionResult> CreateRequest([FromBody] Request request)
        {
            // Request'in null olmadığını kontrol et
            if (request == null)
            {
                return BadRequest("Request data is null.");
            }

            // Gönderilen verinin doğruluğunu kontrol et
            if (request.JourneyId <= 0 || request.SenderId <= 0 || request.ReceiverId <= 0)
            {
                return BadRequest("Invalid Request data. JourneyId, SenderId, and ReceiverId must be greater than 0.");
            }

            try
            {
                // Request'i ekle
                int result = await _requestService.AddAsync(request);

                // İşlem başarısız olduysa
                if (result == -1)
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, "Error creating request.");
                }

                // Başarılı sonuç döndür
                return CreatedAtAction(
                    nameof(GetRequestById), // İlgili bir GetById action metodu olmalı
                    new { id = request.RequestId }, // Yeni oluşturulan request'in ID'si
                    request // Yanıt olarak request'in kendisi
                );
            }
            catch (Exception ex)
            {
                // Beklenmeyen hatalar için
                return StatusCode(StatusCodes.Status500InternalServerError, $"An error occurred: {ex.Message}");
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateRequest(int id, [FromBody] Request request)
        {
            if (request == null || request.RequestId != id)
            {
                return BadRequest("Request data is incorrect.");
            }

            try
            {
                var result = await _requestService.UpdateAsync(request);

                if (result == -1)
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, "Error updating request.");
                }

                // Başarılı durumda hiçbir içerik dönmeden NoContent (204) döner
                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, $"An error occurred: {ex.Message}");
            }
        }
    }
}