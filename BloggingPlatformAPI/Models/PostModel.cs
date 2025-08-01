using System.ComponentModel.DataAnnotations;

namespace BloggingPlatformAPI.Models;

public class PostModel
{
    [Key] public int PostId { get; set; }
    [Required, StringLength(100)] public string Title { get; set; }
    [Required, StringLength(int.MaxValue)] public string Content { get; set; }
    [Required, StringLength(50)] public string Category { get; set; }
    [Required] public List<string> Tags { get; set; }
    [DataType(DataType.DateTime)] public DateTime CreatedAt { get; set; }
    [DataType(DataType.DateTime)] public DateTime? LastUpdated { get; set; }
}