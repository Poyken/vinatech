CREATE TABLE [dbo].[STB_Viscosity_ElectrodCoatingInfo_VVT] (
    [ElectrodeLotNumber] VARCHAR(50) NOT NULL DEFAULT ,
    [ViscosityValue] FLOAT NULL DEFAULT ,
    [ViscosityResult] VARCHAR(50) NULL DEFAULT ('(case when [ViscosityValue]>=(2400) AND [ViscosityValue]<=(3600) then ''OK'' else ''NG'' end)'),
    [TocDo_Coating] FLOAT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(50) NULL DEFAULT 
);
GO

