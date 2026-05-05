CREATE TABLE [dbo].[STB_UltraSrtNcst] (
    [BaseDate] DATE NOT NULL DEFAULT ,
    [BaseHour] INT NOT NULL DEFAULT ,
    [OriginalXML] XML NULL DEFAULT ,
    [Temperature] NUMERIC(10,2) NULL DEFAULT ,
    [Humidity] NUMERIC(10,2) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_UltraSrtNcst] PRIMARY KEY CLUSTERED ([BaseDate], [BaseHour])
);
GO

