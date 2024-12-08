using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CarSharingManagementSystem.Entities
{
    [Table("User")]
    public class User
    {
        [Key]
        [Column("user_id")]
        public int UserId { get; set; }

        [Column("unique_id")]
        public string UniqueId { get; set; }

        [Column("username")]
        public string Username { get; set; }

        [Column("email")]
        public string Email { get; set; }

        [Column("name")]
        public string Name { get; set; }

        [Column("surname")]
        public string Surname { get; set; }

        [Column("gender")]
        public string Gender { get; set; }

        [Column("is_in_institution")]
        public bool IsInInstitution { get; set; }

        [Column("is_student")]
        public bool IsStudent { get; set; }

        [Column("is_academic_personal")]
        public bool IsAcademicPersonal { get; set; }

        [Column("is_administrative_staff")]
        public bool IsAdministrativeStaff { get; set; }

        [Column("sustainability_point")]
        public int? SustainabilityPoint { get; set; }

        [Column("api_key")]
        public string? apiKey {get; set; }
    }
}