using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CarSharingManagementSystem.Entities
{
    [Table("Status")]
    public class Status
    {
        [Key]
        [Column("status_id")]
        public int StatusId { get; set; }

        [Column("status")]
        [Required]
        [MaxLength(50)]
        public string StatusName { get; set; }
    }
}