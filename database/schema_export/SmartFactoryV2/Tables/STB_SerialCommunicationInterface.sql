CREATE TABLE [dbo].[STB_SerialCommunicationInterface] (
    [SerialCommunicationInterfaceNo] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [LotNo] VARCHAR(20) NULL DEFAULT ,
    [MeasureCode] VARCHAR(20) NULL DEFAULT ,
    [MeasureValue] NUMERIC(20,5) NULL DEFAULT ,
    [InterfaceFinishYn] CHAR(1) NOT NULL DEFAULT ('N'),
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ('eai'),
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

