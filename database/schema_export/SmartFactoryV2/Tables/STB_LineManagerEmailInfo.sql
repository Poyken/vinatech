CREATE TABLE [dbo].[STB_LineManagerEmailInfo] (
    [LineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ManagerID] VARCHAR(20) NOT NULL DEFAULT ,
    [ManagerEmail] VARCHAR(200) NOT NULL DEFAULT ,
    [IsUsed] BIT NOT NULL DEFAULT ((1)),
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_LineManagerEmailInfo] PRIMARY KEY CLUSTERED ([LineCode], [ManagerID], [ManagerEmail])
);
GO

