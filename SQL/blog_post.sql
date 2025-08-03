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

/*
CREATE OR ALTER TRIGGER tr_update_post ON post
FOR UPDATE
AS BEGIN
	SET NOCOUNT ON
	UPDATE post
	SET last_updated = GETDATE()
	FROM post p
	JOIN inserted i ON i.post_id = p.post_id
END
GO
*/

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

	-- Insert tag_names that don't exists in tag table
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

/*
DECLARE @post_id INT, @tvp tags_table_type
SET @post_id = 1
INSERT INTO @tvp
VALUES ('reading'), ('books'), ('stuff')

EXEC sp_set_post_tags @post_id, @tvp
GO
*/


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

/*
DECLARE @category_id INT
EXEC @category_id = sp_add_new_category 'Literature'

INSERT INTO post(title, content, category_id)
VALUES
('Best books of 2025', 'content', @category_id)
GO
*/


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

/*
SELECT * FROM post
SELECT * FROM tag
SELECT * FROM post_tag
SELECT * FROM category

EXEC spGetPostRecordsById 10
*/