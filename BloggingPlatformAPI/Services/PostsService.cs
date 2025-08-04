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
        await using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();
        
        var dt = new DataTable();
        dt.Columns.Add("TagName");
        post.Tags.ForEach(tag => dt.Rows.Add(tag));
        
        var spParams = new DynamicParameters();
        spParams.Add("@Title", post.Title, DbType.String, ParameterDirection.Input);
        spParams.Add("@Content", post.Content, DbType.String, ParameterDirection.Input);
        spParams.Add("@CategoryName", post.Category, DbType.String, ParameterDirection.Input);
        spParams.Add("@TagsTvp", dt.AsTableValuedParameter("TagsTableType"), direction: ParameterDirection.Input);
        spParams.Add("@PostId", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

        await conn.ExecuteAsync("spCreatePost", spParams, commandType: CommandType.StoredProcedure);
        var postId = spParams.Get<int>("@PostId");

        return await GetPost(postId) ?? throw new Exception("Failed to create post");
    }

    public async Task<PostModel?> UpdatePost(int id, RequestPostModel post)
    {
        await using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();
        
        var dt = new DataTable();
        dt.Columns.Add("TagName");
        post.Tags.ForEach(tag => dt.Rows.Add(tag));
        
        var spParams = new DynamicParameters();
        spParams.Add("@PostId", id, DbType.Int32, ParameterDirection.Input);
        spParams.Add("@Title", post.Title, DbType.String, ParameterDirection.Input);
        spParams.Add("@Content", post.Content, DbType.String, ParameterDirection.Input);
        spParams.Add("@CategoryName", post.Category, DbType.String, ParameterDirection.Input);
        spParams.Add("@TagsTvp", dt.AsTableValuedParameter("TagsTableType"), direction: ParameterDirection.Input);
        spParams.Add("@Result", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

        await conn.ExecuteAsync("spUpdatePost", spParams, commandType: CommandType.StoredProcedure);
        
        var success = spParams.Get<int>("@Result");
        if (success == 0)
            return null;

        return await GetPost(id) ?? throw new Exception("Failed to update post");
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

    public async Task<List<PostModel>> GetPosts(string searchTerm = "")
    {
        await using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync();

        var posts = await conn.QueryAsync<PostModel, Category, Tag?, PostModel>("spGetPostRecords",
            (post, category, tag) =>
            {
                post.Category = category.CategoryName;
                post.Tags = new List<string>();

                if (tag != null)
                    post.Tags.Add(tag.TagName!);
                return post;
            },
            param: new { SearchTerm = searchTerm },
            commandType: CommandType.StoredProcedure,
            splitOn: "CategoryId, TagId");
        
        var result = posts.GroupBy(post => post.PostId).Select(group =>
        {
            var groupedPost = group.First();
            groupedPost.Tags = group.SelectMany(post => post.Tags).ToList();
            return groupedPost;
        }).ToList();

        return result;
    }
}