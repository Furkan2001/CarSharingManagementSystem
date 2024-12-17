using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CarSharingManagementSystem.Entities
{
    [Table("UserDeviceTokens")]
    public class UserDeviceToken
    {
        [Key]
        [Column("user_device_id")]
        public int UserDeviceId { get; set; } 

        [Required]
        [Column("user_id")]
        public int UserId { get; set; } 

        [Required]
        [Column("token")]
        [StringLength(255)]
        public string? Token { get; set; }

        [Required]
        [Column("time")]
        public DateTime Time { get; set; } = DateTime.UtcNow;
    }
}