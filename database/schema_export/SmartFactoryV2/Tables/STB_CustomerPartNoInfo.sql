CREATE TABLE [dbo].[STB_CustomerPartNoInfo] (
    [MaterialCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CustomerName] NVARCHAR(50) NOT NULL DEFAULT ,
    [CustomerPartNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_CustomerPartNoInfo] PRIMARY KEY CLUSTERED ([MaterialCode], [CustomerPartNo])
);
GO

