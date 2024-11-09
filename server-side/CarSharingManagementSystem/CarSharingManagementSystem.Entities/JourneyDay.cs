using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CarSharingManagementSystem.Entities
{
    [Table("JourneyDay")]
    public class JourneyDay
    {
        [Key]
        [Column("journey_day_id")]
        public int JourneyDayId { get; set; }

        [Column("journey_id")]
        public int JourneyId { get; set; }

        [Column("day_id")]
        public int DayId { get; set; }

        public Day? Day { get; set; }
    }
}