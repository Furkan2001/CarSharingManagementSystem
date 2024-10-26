using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace CarSharingManagementSystem.Entities
{
    public class Car
    {
        [Key]
        public int CarId { get; set; }  // Primary key

        [Required]
        [MaxLength(50)]
        public required string Make { get; set; }

        [Required]
        [MaxLength(50)]
        public required string Model { get; set; }

        [Required]
        public int Year { get; set; }

        // Bir arabaya ait birçok yolculuk olabilir
        public ICollection<Journey>? Journeys { get; set; }
    }
}
