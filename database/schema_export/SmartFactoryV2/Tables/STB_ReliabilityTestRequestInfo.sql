CREATE TABLE [dbo].[STB_ReliabilityTestRequestInfo] (
    [RTRequestNo] VARCHAR(50) NOT NULL DEFAULT ,
    [RequestDate] DATE NULL DEFAULT ,
    [RequestDeptCode] VARCHAR(20) NULL DEFAULT ,
    [RequesterID] VARCHAR(20) NULL DEFAULT ,
    [MassProductionLotNo] VARCHAR(20) NULL DEFAULT ,
    [TestPurposeComment] VARCHAR(MAX) NULL DEFAULT ,
    [CapacityCondition] VARCHAR(1000) NULL DEFAULT ,
    [ACEsrCondition] VARCHAR(1000) NULL DEFAULT ,
    [DCEsrCondition] VARCHAR(1000) NULL DEFAULT ,
    [SDCondition] VARCHAR(1000) NULL DEFAULT ,
    [LCCondition] VARCHAR(1000) NULL DEFAULT ,
    [ETCCondition] VARCHAR(1000) NULL DEFAULT ,
    [RequestRemark] VARCHAR(MAX) NULL DEFAULT ,
    [RecipientID] VARCHAR(20) NULL DEFAULT ,
    [ReceptionDate] DATETIME NULL DEFAULT ,
    [ReceptionNo] VARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [TestClassCode] VARCHAR(10) NULL DEFAULT ,
    [LengthCondition] VARCHAR(MAX) NULL DEFAULT ,
    [WeightCondition] VARCHAR(MAX) NULL DEFAULT 
);
GO

