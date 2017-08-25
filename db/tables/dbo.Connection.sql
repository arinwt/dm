CREATE TABLE dbo.Connection (
    "Id"                INT             NOT NULL    IDENTITY,
    "Name"              NVARCHAR(450)   NOT NULL,
    "ConnectionString"  NVARCHAR(MAX)   NOT NULL,
    CONSTRAINT PK_Connection PRIMARY KEY ("Id")
)