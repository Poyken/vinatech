CREATE TABLE [dbo].[STB_OccasionalCheckScheduleInfo] (
    [LineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CheckDate] DATE NOT NULL DEFAULT ,
    [Seq] INT NOT NULL DEFAULT ,
    [OccasionalCheckItemName] VARCHAR(100) NULL DEFAULT ,
    [CheckYn] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    CONSTRAINT [PK_STB_OccasionalCheckScheduleInfo] PRIMARY KEY CLUSTERED ([LineCode], [CheckDate], [Seq])
);
GO

