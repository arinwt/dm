CREATE PROCEDURE dbo.UpdateProduct
	@Id		INT,
	@Name	NVARCHAR(450)	= NULL,
	@Root	NVARCHAR(MAX)	= NULL,
	@Shash	BINARY(32)		= NULL,
	@Data	VARBINARY(MAX)	= NULL
AS
BEGIN TRY
	BEGIN TRAN;

	-- Update Blob Data
	IF @Shash IS NOT NULL
	BEGIN;
		DECLARE @prevBlobId BIGINT, @newBlobId BIGINT;

		-- Get Previous Blob ID
		SELECT TOP(1) @prevBlobId = "BlobId"
		FROM dbo.Product
		WHERE "Id" = @Id;

		-- Get New Blob ID
		EXEC @newBlobId = dbo.UpdateBlob
			@Id = @prevBlobId,
			@Shash = @Shash,
			@Data = @Data;

		-- Update Blob Pointer
		UPDATE dbo.Product
		SET "BlobId" = @newBlobId
		WHERE "Id" = @Id;
	END;

	-- Update Metadata
	IF @Name IS NOT NULL
	BEGIN;
		UPDATE dbo.Product
		SET "Name" = @Name,
			"Root" = @Root
		WHERE "Id" = @Id;
	END;

	COMMIT TRAN;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT = 1
	BEGIN;
		ROLLBACK TRAN;
		PRINT 'transaction rolled back';
	END;
	THROW;
END CATCH;