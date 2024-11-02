using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CarSharingManagementSystem.Entities
{
    [Table("Map")]
    public class Map
    {
        [Key]
        [Column("map_id")]
        public int MapId { get; set; }

        [Column("destination_latitude")]
        public string DestinationLatitude { get; set; }

        [Column("destination_longitude")]
        public string DestinationLongitude { get; set; }

        [Column("departure_latitude")]
        public string DepartureLatitude { get; set; }

        [Column("departure_longitude")]
        public string DepartureLongitude { get; set; }

        [Column("map_route")]
        public string MapRoute { get; set; }

        // Navigation property
        public ICollection<Journey> Journeys { get; set; }
    }
}