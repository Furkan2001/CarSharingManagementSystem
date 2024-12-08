using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CarSharingManagementSystem.Entities
{
    [Table("Message")]
    public class Message
    {
        [Key]
        [Column("message_id")]
        public int MessageId { get; set; }

        [Column("sender_id")]
        public int SenderId { get; set; }

        [Column("receiver_id")]
        public int ReceiverId { get; set; }

        [Column("message_text")]
        public string MessageText { get; set; }

        [Column("is_read")]
        public bool IsRead { get; set; }

        [Column("time")]
        public DateTime Time { get; set; }

        // Navigation properties
        [ForeignKey("SenderId")]
        public User? Sender { get; set; }

        [ForeignKey("ReceiverId")]
        public User? Receiver { get; set; }
    }
}