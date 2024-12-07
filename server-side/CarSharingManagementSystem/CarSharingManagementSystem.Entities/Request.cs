using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CarSharingManagementSystem.Entities
{
    [Table("Request")]
    public class Request
    {
        [Key]
        [Column("request_id")]
        public int RequestId { get; set; }

        [Column("journey_id")]
        public int JourneyId { get; set; }

        [Column("sender_id")]
        public int SenderId { get; set; }

        [Column("receiver_id")]
        public int ReceiverId { get; set; }

        [Column("time")]
        public DateTime Time { get; set; } = DateTime.Now;

        [Column("status_id")]
        public int StatusId { get; set; }

        [Column("receiver_is_deleted")]
        public bool ReceiverIsDeleted { get; set; } = false;

        [Column("sender_is_deleted")]
        public bool SenderIsDeleted { get; set; } = false;

        // Navigation properties
        [ForeignKey("JourneyId")]
        public Journey Journey { get; set; }

        [ForeignKey("SenderId")]
        public User Sender { get; set; }

        [ForeignKey("ReceiverId")]
        public User Receiver { get; set; }

        [ForeignKey("StatusId")]
        public Status Status { get; set; }
    }
}