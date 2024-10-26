using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CarSharingManagementSystem.Entities
{
    public class Journey
    {
        [Key]
        public int JourneyId { get; set; }

        [Required]
        [MaxLength(50)]
        public string UserName { get; set; }  // Kullanıcı adı

        [Required]
        [MaxLength(100)]
        public string Beginning { get; set; }  // Başlangıç noktası

        [Required]
        [MaxLength(100)]
        public string Destination { get; set; }  // Varış noktası

        [Required]
        public DateTime Time { get; set; }  // Yolculuk zamanı

        // Foreign Key (Car)
        public int CarId { get; set; }

        [ForeignKey("CarId")]
        public Car Car { get; set; }  // İlişkili araba
    }
}
