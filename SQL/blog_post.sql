USE master
DROP DATABASE blog_post
GO

CREATE DATABASE blog_post
GO
USE blog_post

CREATE TABLE tag (
	tag_id INT PRIMARY KEY IDENTITY(1,1),
	tag_name VARCHAR(50) NOT NULL
)

CREATE TABLE category (
	category_id INT PRIMARY KEY IDENTITY(1,1),
	category_name VARCHAR(50) NOT NULL
)

CREATE TABLE post (
	post_id INT PRIMARY KEY IDENTITY(1,1),
	title VARCHAR(100) NOT NULL,
	content VARCHAR(MAX) NOT NULL,
	category_id INT NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	last_updated DATETIME DEFAULT NULL

	FOREIGN KEY (category_id) REFERENCES category(category_id)
) 

CREATE TABLE post_tag (
	post_id INT FOREIGN KEY REFERENCES post(post_id),
	tag_id INT FOREIGN KEY REFERENCES tag(tag_id),

	PRIMARY KEY (post_id, tag_id)
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

CREATE TYPE tags_table_type 
AS TABLE
(tag_name VARCHAR(50))
GO

CREATE OR ALTER PROC sp_set_post_tags(@post_id INT, @tvp tags_table_type READONLY)
AS
BEGIN
	SET NOCOUNT ON

	-- Clear all tags from post
	DELETE FROM post_tag WHERE post_id = @post_id

	-- Insert tag_names that don't exists in tag table
	INSERT INTO tag
	SELECT tvp.tag_name 
	FROM @tvp tvp
	LEFT JOIN tag t ON UPPER(tvp.tag_name) = UPPER(t.tag_name)
	WHERE t.tag_name IS NULL

	SELECT t.tag_id 
	INTO #temp -- Create temp table with ids
	FROM tag t 
	JOIN @tvp tvp ON UPPER(tvp.tag_name) = UPPER(t.tag_name)

	INSERT INTO post_tag
	SELECT @post_id, tag_id FROM #temp
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


CREATE OR ALTER PROC sp_add_new_category(@category_name VARCHAR(50))
AS
BEGIN
	DECLARE @category_id INT
	SET NOCOUNT ON
	IF UPPER(@category_name) IN (SELECT UPPER(category_name) FROM category)
		SET @category_id = (SELECT TOP 1 category_id FROM category WHERE UPPER(category_name) = UPPER(@category_name))
	ELSE
		BEGIN
			INSERT INTO category VALUES (@category_name)
			SET @category_id = SCOPE_IDENTITY()
		END

	RETURN @category_id
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
	SELECT p.post_id AS PostId, p.title, p.content, p.created_at AS CreatedAt, p.last_updated AS LastUpdated, 
		c.category_id AS CategoryId, c.category_name AS CategoryName, t.tag_id AS TagId, t.tag_name AS TagName
	FROM post p
	JOIN category c ON p.category_id = c.category_id
	LEFT JOIN post_tag pt ON p.post_id = pt.post_id
	LEFT JOIN tag t ON pt.tag_id = t.tag_id
	WHERE p.post_id = @Id
END
GO

/*
SELECT * FROM post
SELECT * FROM tag
SELECT * FROM post_tag
SELECT * FROM category

EXEC spGetPostRecordsById 6
*/