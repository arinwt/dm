CREATE TABLE dbo.Project (
	"Id"			INT				NOT NULL	IDENTITY,
	"Name"			NVARCHAR(450)	NOT NULL,
	"Root"			NVARCHAR(MAX)	NOT NULL,
	"ProductId"		INT					NULL,
	"CustomerId"	INT					NULL,
	"BlobId"		BIGINT			NOT NULL,
	CONSTRAINT PK_Project PRIMARY KEY ("Id"),
	CONSTRAINT FK_Project_Product FOREIGN KEY ("ProductId")
		REFERENCES dbo.Product ("Id"),
	CONSTRAINT FK_Project_Customer FOREIGN KEY ("CustomerId")
		REFERENCES dbo.Customer ("Id"),
	CONSTRAINT FK_Project_Blob FOREIGN KEY ("BlobId")
		REFERENCES dbo.Blob ("Id"),
	INDEX IX_Project_Name NONCLUSTERED ("Name")
);