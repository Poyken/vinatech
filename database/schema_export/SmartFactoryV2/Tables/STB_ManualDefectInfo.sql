CREATE TABLE [dbo].[STB_ManualDefectInfo] (
    [BaseDate] DATE NOT NULL DEFAULT ,
    [ShiftCode] CHAR(1) NOT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WindingDefectWeight] NUMERIC(20,5) NULL DEFAULT ,
    [RubberDefectWeight] NUMERIC(20,5) NULL DEFAULT ,
    [CurlingDefectWeight] NUMERIC(20,5) NULL DEFAULT ,
    [SleeveDefectWeight] NUMERIC(20,5) NULL DEFAULT ,
    [QcWindingInspWeight] NUMERIC(20,5) NULL DEFAULT ,
    [QcSleeveInspWeight] NUMERIC(20,5) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

