CREATE TABLE [dbo].[Stb_vvt_TiGiaHoiDoai] (
    [id] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [bankname] VARCHAR(50) NULL DEFAULT ,
    [type] VARCHAR(50) NOT NULL DEFAULT ,
    [muatm] FLOAT NULL DEFAULT ,
    [muack] FLOAT NULL DEFAULT ,
    [bantm] FLOAT NULL DEFAULT ,
    [banck] FLOAT NULL DEFAULT ,
    [bankdate] VARCHAR(30) NULL DEFAULT ,
    [createdatetime] DATETIME NULL DEFAULT (getdate())
);
GO

