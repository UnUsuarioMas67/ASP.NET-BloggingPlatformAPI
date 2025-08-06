# Blogging Platform API

A simple RESTful API with basic CRUD operations for a personal blogging platform.

Solution for the roadmap.sh project: [Blogging Platform API](https://roadmap.sh/projects/blogging-platform-api)

## Features

- Create a new blog post
- Update an existing blog post
- Delete an existing blog post
- Get a single blog post
- Get all blog posts
- Filter blog posts by a search term
- Blog data is stored in a SQL database

## Requirements

- .NET 8 SDK or later
- Visual Studio 2022 or another IDE of choice
- SQL Server 2022

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/UnUsuarioMas67/ASP.NET-BloggingPlatformAPI
cd BloggingPlatformAPI
```

### 2. Setup Environment Variables

First reate a `.env` file inside the `BloggingPlatformAPI` folder. Then paste the following line to the file:

```
SQL_CONNECTION_STRING=Your SQL Connection String
```

### 3. Restore Dependencies

```bash
dotnet restore
```

### 4. Run the Application

```bash
dotnet run
```

## Usage

### Create Blog Post

Create a new blog post using the `POST` method.

```
POST /posts
{
  "title": "My Title",
  "content": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer a.",
  "category": "MyCategory",
  "tags": ["tag1", "tag2"]
}
```

#### Example Response

```
{
  "postId": 1,
  "title": "My Title",
  "content": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer a.",
  "category": "MyCategory",
  "tags": ["tag1", "tag2"],
  "createdAt": "2025-08-02T23:47:38.927",
  "lastUpdated": null
}
```

### Update Blog Post

Update an existing blog post with the `PUT` method

```
PUT /posts/1
{
  "title": "Updated Title",
  "content": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer a.",
  "category": "Updated Category",
  "tags": ["tag1", "tag2", "new tag"]
}
```

#### Example Response

```
{
  "postId": 1,
  "title": "Updated Title",
  "content": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer a.",
  "category": "Updated Category",
  "tags": ["tag1", "tag2", "new tag"]
  "createdAt": "2025-08-02T23:47:38.927",
  "lastUpdated": "2025-08-03T23:47:38.927"
}
```

### Delete Blog Post

Delete an existing blog post using the `DELETE` method
```
DELETE /posts/1
```

### Get Blog Post

Get a single blog post using the `GET` method
```
GET /posts/1
```

#### Example Response

```
{
  "postId": 1,
  "title": "Updated Title",
  "content": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer a.",
  "category": "Updated Category",
  "tags": ["tag1", "tag2", "new tag"]
  "createdAt": "2025-08-02T23:47:38.927",
  "lastUpdated": "2025-08-03T23:47:38.927"
}
```

### Get All Blog Posts

Get all blog posts using the `GET` method
```
GET /posts
```

Retrieve blog posts filtered by a search term
```
GET /posts?term=title
```

#### Example Response

```
[
    {
      "postId": 1,
      "title": "My Title",
      "content": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer a.",
      "category": "MyCategory",
      "tags": ["tag1", "tag2"],
      "createdAt": "2025-08-02T23:47:38.927",
      "lastUpdated": "2025-08-03T23:47:38.927"
    },
    {
      "postId": 2,
      "title": "Second Post",
      "content": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer a.",
      "category": "AnotherCategory",
      "tags": ["tag3", "tag4", "tag5"],
      "createdAt": "2025-08-03T23:47:38.927",
      "lastUpdated": "2025-08-04T23:47:38.927"
    },
    ...
]
```


