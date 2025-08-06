USE master
DROP DATABASE blog_post
GO

CREATE DATABASE blog_post
GO
USE blog_post

CREATE TABLE Tag (
	TagId INT PRIMARY KEY IDENTITY(1,1),
	TagName VARCHAR(50) NOT NULL
)

CREATE TABLE Category (
	CategoryId INT PRIMARY KEY IDENTITY(1,1),
	CategoryName VARCHAR(50) NOT NULL
)

CREATE TABLE Post (
	PostId INT PRIMARY KEY IDENTITY(1,1),
	Title VARCHAR(100) NOT NULL,
	Content VARCHAR(MAX) NOT NULL,
	CategoryId INT NOT NULL,
	CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
	LastUpdated DATETIME DEFAULT NULL

	FOREIGN KEY (CategoryId) REFERENCES category(CategoryId)
) 

CREATE TABLE Post_Tag (
	PostId INT FOREIGN KEY REFERENCES post(PostId),
	TagId INT FOREIGN KEY REFERENCES tag(TagId),

	PRIMARY KEY (PostId, TagId)
)
GO

CREATE TYPE TagsTableType 
AS TABLE
(TagName VARCHAR(50))
GO

CREATE OR ALTER PROC spSetPostTags(@PostId INT, @Tvp TagsTableType READONLY)
AS
BEGIN
	SET NOCOUNT ON

	-- Clear all tags from post
	DELETE FROM Post_Tag WHERE PostId = @PostId

	-- Insert tag_names that don't exist in tag table
	INSERT INTO tag
	SELECT tvp.TagName 
	FROM @Tvp tvp
	LEFT JOIN tag t ON UPPER(tvp.TagName) = UPPER(t.TagName)
	WHERE t.TagName IS NULL

	SELECT t.TagId 
	INTO #temp -- Create temp table with ids
	FROM tag t 
	JOIN @Tvp tvp ON UPPER(tvp.TagName) = UPPER(t.TagName)

	INSERT INTO post_tag
	SELECT @PostId, TagId FROM #temp
END
GO

CREATE OR ALTER PROC spAddNewCategory(@CategoryName VARCHAR(50))
AS
BEGIN
	DECLARE @CategoryId INT
	SET NOCOUNT ON
	IF UPPER(@CategoryName) IN (SELECT UPPER(CategoryName) FROM category)
		SET @CategoryId = (SELECT TOP 1 CategoryId FROM category WHERE UPPER(CategoryName) = UPPER(@CategoryName))
	ELSE
		BEGIN
			INSERT INTO category VALUES (@CategoryName)
			SET @CategoryId = SCOPE_IDENTITY()
		END

	RETURN @CategoryId
END
GO

CREATE OR ALTER PROC spCreatePost(
	@Title VARCHAR(100),
	@Content VARCHAR(MAX),
	@CategoryName VARCHAR(50),
	@TagsTvp TagsTableType READONLY
)
AS
BEGIN 
	SET NOCOUNT ON
	DECLARE @CategoryId INT, @PostId INT
	EXEC @CategoryId = spAddNewCategory @CategoryName

	INSERT INTO Post (Title, Content, CategoryId) VALUES (@Title, @Content, @CategoryId)
	SET @PostId = SCOPE_IDENTITY()

	EXEC spSetPostTags @PostId, @TagsTvp

	RETURN @PostId
END
GO


CREATE OR ALTER PROC spUpdatePost(
	@PostId INT,
	@Title VARCHAR(100),
	@Content VARCHAR(MAX),
	@CategoryName VARCHAR(50),
	@TagsTvp TagsTableType READONLY
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Result BIT

	IF EXISTS (SELECT * FROM Post WHERE PostId = @PostId)
		BEGIN
			DECLARE @CategoryId INT
			EXEC @CategoryId = spAddNewCategory @CategoryName

			UPDATE Post
			SET Title = @Title, Content = @Content, CategoryId = @CategoryId, LastUpdated = GETDATE()
			WHERE PostId = @PostId

			EXEC spSetPostTags @PostId, @TagsTvp
			SET @Result = 1
		END
	ELSE
		SET @Result = 0
	
	RETURN @Result
END
GO


CREATE OR ALTER PROC spGetPostRecordsById(@Id INT)
AS
BEGIN
	SELECT p.PostId, p.Title, p.Content, p.CreatedAt, p.LastUpdated, 
		c.CategoryId, c.CategoryName, t.TagId, t.TagName
	FROM post p
	JOIN category c ON p.CategoryId = c.CategoryId
	LEFT JOIN post_tag pt ON p.PostId = pt.PostId
	LEFT JOIN tag t ON pt.TagId = t.TagId
	WHERE p.PostId = @Id
END
GO

CREATE OR ALTER PROC spGetPostRecords(@SearchTerm VARCHAR(MAX) = '')
AS
BEGIN
    SELECT p.PostId, p.Title, p.Content, p.CreatedAt, p.LastUpdated,
           c.CategoryId, c.CategoryName, t.TagId, t.TagName
    FROM post p
    JOIN category c ON p.CategoryId = c.CategoryId
    LEFT JOIN post_tag pt ON p.PostId = pt.PostId
    LEFT JOIN tag t ON pt.TagId = t.TagId
	WHERE p.Title LIKE CONCAT('%', @SearchTerm, '%')
		OR p.Content LIKE CONCAT('%', @SearchTerm, '%') 
		OR c.CategoryName LIKE CONCAT('%', @SearchTerm, '%') 
END
GO


CREATE OR ALTER PROC spDeletePost(@PostId INT)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Result BIT

	IF EXISTS (SELECT * FROM Post WHERE PostId = @PostId)
		BEGIN
			-- Delete related Post_Tag records
			DELETE FROM Post_Tag WHERE PostId = @PostId

			-- Delete Post record
			DELETE FROM Post WHERE PostId = @PostId
			
			SET @Result = 1
		END
	ELSE
		SET @Result = 0
	
	RETURN @Result
END