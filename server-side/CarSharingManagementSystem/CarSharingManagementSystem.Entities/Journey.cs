using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CarSharingManagementSystem.Entities
{
    [Table("Journey")]
    public class Journey
    {
        [Key]
        [Column("journey_id")]
        public int JourneyId { get; set; }

        [Column("has_vehicle")]
        public bool HasVehicle { get; set; }

        [Column("map_id")]
        public int? MapId { get; set; }  // Foreign key, nullable olabilir

        [Column("time")]
        public DateTime Time { get; set; }

        [Column("is_one_time")]
        public bool IsOneTime { get; set; }

        [Column("user_id")]
        public int UserId { get; set; }

        // Navigation properties
        public User User { get; set; }
        public Map Map { get; set; }
    }
}
