using CarSharingManagementSystem.Entities;
using CarSharingManagementSystem.DataAccess.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;
using CarSharingManagementSystem.DataAccess.DTOs;

namespace CarSharingManagementSystem.DataAccess.Repositories.Implementations
{
    public class JourneyRepository : IJourneyRepository
    {
        private readonly AppDbContext _context;

        public JourneyRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Journey>> GetAllAsync()
        {
            // User ve Map ilişkilerini dahil ederek tüm Journey kayıtlarını getiriyoruz
            return await _context.Journeys
                .Include(j => j.User)
                .Include(j => j.Map)
                .Include(j => j.JourneyDays)
                    .ThenInclude(jd => jd.Day)
                .ToListAsync();
        }

        public async Task<Journey> GetByIdAsync(int id)
        {
            // Tek bir Journey kaydını ilişkili User ve Map ile birlikte getiriyoruz
            return await _context.Journeys
                .Include(j => j.User)
                .Include(j => j.Map)
                .Include(j => j.JourneyDays)
                    .ThenInclude(jd => jd.Day)
                .FirstOrDefaultAsync(j => j.JourneyId == id);
        }

        // Eğer kullanıcı kendi postuna bakacaksa bu fonksiyonu kullanmalıdır, çünkü isteklerde altında verilecek.
        public async Task<Journey> GetByIdAndUserIdAsync(int id, int userId)
        {
            return await _context.Journeys
                .Include(j => j.User)
                .Include(j => j.Map)
                .Include(j => j.Requests.Where(r =>
                    r.JourneyId == id && // Request'in JourneyId'si belirtilen id ile eşleşmeli
                    (
                        (r.SenderId == userId && !r.SenderIsDeleted) || // Silinmemiş gönderici
                        (r.ReceiverId == userId && !r.ReceiverIsDeleted) // Silinmemiş alıcı
                    )))
                    .ThenInclude(r => r.Sender) // Gönderen kullanıcı bilgisi
                .Include(j => j.Requests.Where(r =>
                    r.JourneyId == id && // Request'in JourneyId'si belirtilen id ile eşleşmeli
                    (
                        (r.SenderId == userId && !r.SenderIsDeleted) || // Silinmemiş gönderici
                        (r.ReceiverId == userId && !r.ReceiverIsDeleted) // Silinmemiş alıcı
                    )))
                    .ThenInclude(r => r.Receiver) // Alıcı kullanıcı bilgisi
                .Include(j => j.Requests.Where(r =>
                    r.JourneyId == id && // Request'in JourneyId'si belirtilen id ile eşleşmeli
                    (
                        (r.SenderId == userId && !r.SenderIsDeleted) || // Silinmemiş gönderici
                        (r.ReceiverId == userId && !r.ReceiverIsDeleted) // Silinmemiş alıcı
                    )))
                    .ThenInclude(r => r.Status) // Request durumu
                .Include(j => j.JourneyDays)
                    .ThenInclude(jd => jd.Day)
                .FirstOrDefaultAsync(j => j.JourneyId == id && j.UserId == userId);
        }

        public async Task<IEnumerable<Journey>> GetByUserIdAsync(int userId)
        {
            return await _context.Journeys
                .Where(j => j.UserId == userId)
                .Include(j => j.User)
                .Include(j => j.Map)
                .Include(j => j.JourneyDays)
                    .ThenInclude(jd => jd.Day)
                .ToListAsync();
        }

        public async Task<IEnumerable<Journey>> GetAccordingToTime(DateTime start, DateTime end)
        {
            return await _context.Journeys
                .Where(j => j.Time > end && start < j.Time)
                .Include(j => j.User)
                .Include(j => j.Map)
                .Include(j => j.JourneyDays)
                    .ThenInclude(jd => jd.Day)
                .ToListAsync();
        }

        public async Task<IEnumerable<Journey>> GetAccordingToStartAndDestinationLocation(string startDistrict, string destinationDistrict)
        {
            return await _context.Journeys
                .Where(j => j.Map.CurrentDistrict == startDistrict && j.Map.DestinationDistrict == destinationDistrict)
                .Include(j => j.User)
                .Include(j => j.Map)
                .Include(j => j.JourneyDays)
                    .ThenInclude(jd => jd.Day)
                .ToListAsync();
        }

        public async Task<IEnumerable<Journey>> GetAccordingToStartLocation(string startDistrict)
        {
            return await _context.Journeys
                .Where(j => j.Map.CurrentDistrict == startDistrict)
                .Include(j => j.User)
                .Include(j => j.Map)
                .Include(j => j.JourneyDays)
                    .ThenInclude(jd => jd.Day)
                .ToListAsync();
        }

        public async Task<IEnumerable<Journey>> GetAccordingToDestinationLocation(string destinationDistrict)
        {
            return await _context.Journeys
                .Where(j => j.Map.DestinationDistrict == destinationDistrict)
                .Include(j => j.User)
                .Include(j => j.Map)
                .Include(j => j.JourneyDays)
                    .ThenInclude(jd => jd.Day)
                .ToListAsync();
        }

        public async Task<IEnumerable<Journey>> GetAccordingToHasVehicle(bool hasVehicle)
        {
            return await _context.Journeys
                .Where(j => j.HasVehicle == hasVehicle)
                .Include(j => j.User)
                .Include(j => j.Map)
                .Include(j => j.JourneyDays)
                    .ThenInclude(jd => jd.Day)
                .ToListAsync();
        }

        public async Task<IEnumerable<Journey>> GetFilteredJourneysAsync(JourneyFilterModel filterModel)
        {
            var query = _context.Journeys
                .Include(j => j.User)
                .Include(j => j.Map)
                .Include(j => j.JourneyDays)
                    .ThenInclude(jd => jd.Day)
                .AsQueryable();

            if (filterModel.StartTime.HasValue)
            {
                query = query.Where(j => j.Time >= filterModel.StartTime.Value);
            }

            if (filterModel.EndTime.HasValue)
            {
                query = query.Where(j => j.Time <= filterModel.EndTime.Value);
            }

            if (!string.IsNullOrEmpty(filterModel.StartDistrict))
            {
                query = query.Where(j => j.Map.CurrentDistrict == filterModel.StartDistrict);
            }

            if (!string.IsNullOrEmpty(filterModel.DestinationDistrict))
            {
                query = query.Where(j => j.Map.DestinationDistrict == filterModel.DestinationDistrict);
            }

            if (filterModel.HasVehicle.HasValue)
            {
                bool hasVehicle = filterModel.HasVehicle == 1;
                query = query.Where(j => j.HasVehicle == hasVehicle);
            }

            return await query.ToListAsync();
        }

        public async Task<int> AddAsync(Journey journey)
        {
            try
            {
                await _context.Journeys.AddAsync(journey);
                await _context.SaveChangesAsync();
                return 0; // Success
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return -1; // Failure
            }
        }

        public async Task<int> UpdateAsync(Journey journey)
        {
            try
            {
                _context.Journeys.Update(journey);
                await _context.SaveChangesAsync();
                return 0; // Success
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return -1; // Failure
            }
        }

        public async Task<int> DeleteAsync(int id)
        {
            try
            {
                var journey = await _context.Journeys
                    .Include(j => j.Map)
                    .Include(j => j.JourneyDays)
                    .FirstOrDefaultAsync(j => j.JourneyId == id);
                    
                if (journey != null)
                {
                    _context.Journeys.Remove(journey);
                    await _context.SaveChangesAsync();
                    return 0; // Success
                }
                return -1; // Journey not found
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return -1; // Failure
            }
        }

        public async Task AutoDeleteAsync()
        {
            var expiredJourneys = await _context.Journeys
                .Where(j => j.Time < DateTime.Now && j.IsOneTime == true)
                .ToListAsync();

            if (expiredJourneys.Any())
            {
                var mapIdsToDelete = expiredJourneys
                    .Where(j => j.MapId.HasValue)
                    .Select(j => j.MapId.Value)
                    .Distinct();

                var journeyIdsToDelete = expiredJourneys
                    .Select(j => j.JourneyId)
                    .ToList();
                
                var requestsToDelete = await _context.Requests
                    .Where(r => journeyIdsToDelete.Contains(r.JourneyId))
                    .ToListAsync();

                var mapsToDelete = await _context.Maps
                    .Where(m => mapIdsToDelete.Contains(m.MapId))
                    .ToListAsync();

                var journeyDaysToDelete = await _context.JourneyDays
                    .Where(jd => journeyIdsToDelete.Contains(jd.JourneyId))
                    .ToListAsync();

                _context.Requests.RemoveRange(requestsToDelete);
                _context.Maps.RemoveRange(mapsToDelete);
                _context.JourneyDays.RemoveRange(journeyDaysToDelete);
                _context.Journeys.RemoveRange(expiredJourneys);

                await _context.SaveChangesAsync();
            }
        }
    }
}