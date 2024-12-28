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
        private readonly IUserService _userService;

        public RequestsController(IRequestService requestService, IUserService userService)
        {
            _requestService = requestService;
            _userService = userService;
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
                if (request == null)
                {
                    return BadRequest("Invalid request data.");
                }

                var existingRequest = await _requestService.GetByIdAsync(id);
                if (existingRequest == null)
                {
                    return NotFound("Request not found.");
                }

                if (existingRequest.StatusId == 1 && request.StatusId == 2)
                {
                    request.Sender.SustainabilityPoint += 10;
                    request.Receiver.SustainabilityPoint += 10;

                    await _userService.UpdateAsync(request.Sender);
                    await _userService.UpdateAsync(request.Receiver);
                }
                else if (existingRequest.StatusId == 2 && request.StatusId == 3)
                {
                    request.Sender.SustainabilityPoint -= 10;
                    request.Receiver.SustainabilityPoint -= 10;

                    await _userService.UpdateAsync(request.Sender);
                    await _userService.UpdateAsync(request.Receiver);
                }
                else if (existingRequest.StatusId == 3 && request.StatusId == 2)
                {
                    request.Sender.SustainabilityPoint += 10;
                    request.Receiver.SustainabilityPoint += 10;

                    await _userService.UpdateAsync(request.Sender);
                    await _userService.UpdateAsync(request.Receiver);
                }

                // - Sender request attıysa ve sonrada daha hiç request e cevap gelmeden silerse request herkesten silinmelidir.
                if (existingRequest.SenderIsDeleted == false && request.SenderIsDeleted == true && existingRequest.StatusId == 1)
                    await _requestService.DeleteAsync(id);

                existingRequest.JourneyId = request.JourneyId;
                existingRequest.SenderId = request.SenderId;
                existingRequest.ReceiverId = request.ReceiverId;
                existingRequest.Time = request.Time;
                existingRequest.StatusId = request.StatusId;
                existingRequest.ReceiverIsDeleted = request.ReceiverIsDeleted;
                existingRequest.SenderIsDeleted = request.SenderIsDeleted;

                var result = await _requestService.UpdateAsync(existingRequest);
                if (result == -1)
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, "Error updating request.");
                }

                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, $"An error occurred: {ex.Message}");
            }
        }
    }
}
