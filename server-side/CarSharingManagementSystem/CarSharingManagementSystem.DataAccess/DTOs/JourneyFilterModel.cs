namespace CarSharingManagementSystem.DataAccess.DTOs
{
    public class JourneyFilterModel
    {
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public string? StartDistrict { get; set; }
        public string? DestinationDistrict { get; set; }
        public int? HasVehicle { get; set; }
    }
}