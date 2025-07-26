using Microsoft.AspNetCore.Mvc;

namespace BloggingPlatformAPI.Controllers;

[ApiController]
[Route("[controller]/[action]")]
public class BlogController : ControllerBase
{
    [HttpGet]
    public IActionResult Index()
    {
        return Ok("Hello World!");
    }
}