using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CarSharingManagementSystem.Entities
{
    [Table("Day")]
    public class Day
    {
        [Key]
        [Column("day_id")]
        public int DayId { get; set; }

        [Column("day_name")]
        public string DayName { get; set; }
    }
}