using BloggingPlatformAPI.Models;
using BloggingPlatformAPI.Services;
using Microsoft.AspNetCore.Mvc;

namespace BloggingPlatformAPI.Controllers;

[ApiController]
public class BlogController : ControllerBase
{
    private readonly IPostsService _postsService;

    public BlogController(IPostsService postsService)
    {
        _postsService = postsService;
    }
    
    [HttpPost, Route("posts")]
    [ProducesResponseType(StatusCodes.Status201Created, Type = typeof(PostModel))]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Create(RequestPostModel model)
    {
        var post = await _postsService.CreatePost(model);
        return Created($"posts/{post.PostId}", post);
    }

    [HttpGet, Route("posts/{id}")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(PostModel))]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(int id)
    {
        var post = await _postsService.GetPost(id);
        if (post == null)
            return NotFound();
        
        return Ok(post);
    }
}