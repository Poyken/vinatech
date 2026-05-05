CREATE TABLE [dbo].[STB_SQLAgentJobChangesLog] (
    [idx] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [base_ymd] DATE NOT NULL DEFAULT ,
    [name_before] NVARCHAR(128) NOT NULL DEFAULT ,
    [name_after] NVARCHAR(128) NULL DEFAULT ,
    [date_modified_before] DATETIME NOT NULL DEFAULT ,
    [date_modified_after] DATETIME NULL DEFAULT ,
    [enabled_before] TINYINT NOT NULL DEFAULT ,
    [enabled_after] TINYINT NULL DEFAULT ,
    [command_before] NVARCHAR(MAX) NULL DEFAULT ,
    [command_after] NVARCHAR(MAX) NULL DEFAULT 
);
GO

