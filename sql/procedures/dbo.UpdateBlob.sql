CREATE PROCEDURE dbo.UpdateBlob
	@Id			BIGINT,
	@Shash		BINARY(32),
	@Data		VARBINARY(MAX)	= NULL
AS
BEGIN TRY
	BEGIN TRAN;

	-- Create New Blob
	DECLARE @bi AS TABLE (i BIGINT);

	INSERT INTO dbo.Blob (
		"Shash",
		"PreviousId",
		"Data"
	)
	OUTPUT inserted."Id" INTO @bi
	VALUES (
		@Shash,
		@Id,
		@Data
	);

	DECLARE @newId BIGINT = (SELECT TOP(1) i FROM @bi);

	COMMIT TRAN;
	RETURN @newId;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT = 1
	BEGIN;
		ROLLBACK TRAN;
		PRINT 'transaction rolled back';
	END;
	THROW;
END CATCH;