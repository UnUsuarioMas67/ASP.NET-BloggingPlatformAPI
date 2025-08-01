using BloggingPlatformAPI.Models;
using Dapper;
using Microsoft.Data.SqlClient;

namespace BloggingPlatformAPI.Services;

public interface IPostsService
{
    Task<PostModel> CreatePost(RequestPostModel post);
    Task<PostModel?> UpdatePost(int id, RequestPostModel post);
    Task<bool> DeletePost(int id);
    Task<PostModel?> GetPost(int id);
    Task<List<PostModel>> GetPosts(string searchTerm = "");
}

public class PostsService : IPostsService
{
    private readonly string _connectionString;

    public PostsService()
    {
        _connectionString = Environment.GetEnvironmentVariable("SQL_CONNECTION_STRING")
                            ?? throw new InvalidOperationException("No SQL Connection String found");
    }

    public async Task<PostModel> CreatePost(RequestPostModel post)
    {
        var sql1 = @"INSERT INTO post (title, content, category) VALUES (@Title, @Content, @Category);
SELECT CAST(SCOPE_IDENTITY() as INT)";
        var parameters = new { Title = post.Title, Content = post.Content, Category = post.Category };
        
        var sql2 = @"SELECT post_id as PostId, title, content, category, created_at as CreatedAt, last_updated as LastUpdated  
FROM post WHERE post_id = @PostId";

        await using var con = new SqlConnection(_connectionString);
        await con.OpenAsync();
        var postId = await con.ExecuteScalarAsync<int>(sql1, parameters);
        var createdPost = await con.QuerySingleAsync<PostModel>(sql2, new { PostId = postId });
        return createdPost;
    }

    public Task<PostModel?> UpdatePost(int id, RequestPostModel post)
    {
        throw new NotImplementedException();
    }

    public Task<bool> DeletePost(int id)
    {
        throw new NotImplementedException();
    }

    public Task<PostModel?> GetPost(int id)
    {
        throw new NotImplementedException();
    }

    public Task<List<PostModel>> GetPosts(string? searchTerm = "")
    {
        throw new NotImplementedException();
    }
}