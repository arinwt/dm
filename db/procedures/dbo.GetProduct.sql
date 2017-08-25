CREATE PROCEDURE dbo.GetProduct
	@Id		INT				= NULL,
	@Name	NVARCHAR(MAX)	= NULL,
	@Root	NVARCHAR(MAX)	= NULL
AS
SELECT
	p."Id",
	p."Name",
	p."Root",
	b."Shash",
	b."AsOf"
FROM dbo.Product AS p
JOIN dbo.Blob AS b ON b."Id" = p."BlobId"
WHERE (@Id IS NULL OR @Id = p."Id")
	AND (@Name IS NULL OR @Name LIKE p."Name")
	AND (@Root IS NULL OR @Root LIKE p."Root");