using System.ComponentModel.DataAnnotations;

namespace BloggingPlatformAPI.Models;

public class RequestPostModel
{
    [Required, StringLength(100)] public string Title { get; set; }
    [Required, StringLength(int.MaxValue)] public string Content { get; set; }
    [Required, StringLength(50)] public string Category { get; set; }
    [Required] public List<string> Tags { get; set; }
}