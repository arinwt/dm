CREATE TABLE dbo.DataFolder (
    "Id"            INT             NOT NULL    IDENTITY,
    "Name"          NVARCHAR(450)   NOT NULL,
    "Path"          NVARCHAR(MAX)   NOT NULL,
    "ConnectionId"  INT             NOT NULL,
    CONSTRAINT PK_DataFolder PRIMARY KEY ("Id"),
    CONSTRAINT FK_DataFolder_Connection FOREIGN KEY ("ConnectionId")
        REFERENCES dbo.Connection ("Id")
);