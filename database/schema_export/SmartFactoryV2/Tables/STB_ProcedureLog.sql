CREATE TABLE [dbo].[STB_ProcedureLog] (
    [Idx] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [ProcedureName] VARCHAR(200) NOT NULL DEFAULT ,
    [VariableName] VARCHAR(50) NULL DEFAULT ,
    [VariableValue] NVARCHAR(100) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate())
);
GO

