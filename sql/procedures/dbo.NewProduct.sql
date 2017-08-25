CREATE PROCEDURE dbo.NewProduct
	@Name	NVARCHAR(450),
	@Root	NVARCHAR(MAX),
	@Shash	BINARY(32),
	@Data	VARBINARY(MAX)	= NULL
AS
BEGIN TRY
	BEGIN TRAN;

	-- Create Blob
	DECLARE @bi AS TABLE (i BIGINT);

	INSERT INTO dbo.Blob (
		"Shash",
		"Data"
	)
	OUTPUT inserted."Id" INTO @bi
	VALUES (
		@Shash,
		@Data
	);

	DECLARE @BlobId BIGINT = (SELECT TOP(1) i FROM @bi);

	-- Create Product
	DECLARE @i AS TABLE (i INT);

	INSERT INTO dbo.Product (
		"Name",
		"Root",
		"BlobId"
	)
	OUTPUT inserted."Id" INTO @i
	VALUES (
		@Name,
		@Root,
		@BlobId
	);

	DECLARE @ProductId INT = (SELECT TOP(1) i FROM @i);

	COMMIT TRAN;
	SELECT @ProductId;
	RETURN @ProductId;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT = 1
	BEGIN;
		ROLLBACK TRAN;
		PRINT 'transaction rolled back';
	END;
	THROW;
END CATCH;