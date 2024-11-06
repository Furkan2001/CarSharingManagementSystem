namespace CarSharingManagementSystem.DTOs
{
    public class JourneyFilterModel
    {
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public string? StartDistrict { get; set; }
        public string? DestinationDistrict { get; set; }
        public int? HasVehicle { get; set; } // true: 1, false: 0, null: her ikisi de
    }
}