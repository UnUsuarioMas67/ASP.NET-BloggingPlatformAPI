using System.Data;
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
        var sql = @"INSERT INTO post (title, content, category_id) VALUES (@Title, @Content, @CategoryId);
SELECT CAST(SCOPE_IDENTITY() as INT)";

        await using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        // get category id
        var spParams = new DynamicParameters();
        spParams.Add("@category_name", post.Category);
        spParams.Add("@CategoryId", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

        await conn.ExecuteAsync("sp_add_new_category", spParams, commandType: CommandType.StoredProcedure);
        var categoryId = spParams.Get<int>("@CategoryId");

        // insert post into table
        var insertParams = new { post.Title, post.Content, CategoryId = categoryId };
        var postId = await conn.ExecuteScalarAsync<int>(sql, insertParams);

        // add tags
        var dt = new DataTable();
        dt.Columns.Add("tag_name");
        post.Tags.ForEach(tag => dt.Rows.Add(tag));

        await conn.ExecuteAsync("sp_set_post_tags",
            new { post_id = postId, tvp = dt.AsTableValuedParameter("tags_table_type") },
            commandType: CommandType.StoredProcedure);

        return await GetPost(postId) ?? throw new Exception("Failed to create post");
    }

    public Task<PostModel?> UpdatePost(int id, RequestPostModel post)
    {
        throw new NotImplementedException();
    }

    public Task<bool> DeletePost(int id)
    {
        throw new NotImplementedException();
    }

    public async Task<PostModel?> GetPost(int id)
    {
        await using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        var posts = (await conn.QueryAsync<PostModel, Category, Tag?, PostModel>("spGetPostRecordsById",
            (post, category, tag) =>
            {
                post.Category = category.CategoryName;
                post.Tags = new List<string>();
                
                if (tag != null)
                    post.Tags.Add(tag.TagName!);
                return post;
            },
            param: new { Id = id },
            commandType: CommandType.StoredProcedure,
            splitOn: "CategoryId, TagId")).ToList();

        var result = posts.FirstOrDefault();
        if (result is null)
            return null;

        result.Tags = posts.SelectMany(post => post.Tags).ToList();
        return result;
    }

    public Task<List<PostModel>> GetPosts(string? searchTerm = "")
    {
        throw new NotImplementedException();
    }
}