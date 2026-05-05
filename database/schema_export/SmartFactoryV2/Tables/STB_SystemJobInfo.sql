CREATE TABLE [dbo].[STB_SystemJobInfo] (
    [base_ymd] DATE NOT NULL DEFAULT ,
    [job_id] UNIQUEIDENTIFIER NOT NULL DEFAULT ,
    [step_id] TINYINT NOT NULL DEFAULT ,
    [name] NVARCHAR(128) NOT NULL DEFAULT ,
    [owner_sid] VARBINARY(85) NULL DEFAULT ,
    [date_modified] DATETIME NULL DEFAULT ,
    [command] NVARCHAR(MAX) NULL DEFAULT ,
    [enabled] TINYINT NULL DEFAULT ,
    [date_created] DATETIME NOT NULL DEFAULT (getdate()),
    CONSTRAINT [PK_STB_SystemJobInfo] PRIMARY KEY CLUSTERED ([base_ymd], [job_id], [step_id])
);
GO

