CREATE TABLE [dbo].[STB_QuotationInfo] (
    [QuotationNo] VARCHAR(20) NOT NULL DEFAULT ,
    [OrgQuotationNo] VARCHAR(20) NULL DEFAULT ,
    [QuotationSeq] INT NULL DEFAULT ,
    [QuotationDate] DATE NULL DEFAULT ,
    [QuotationVersionDesc] NVARCHAR(100) NULL DEFAULT ,
    [QuotationUserID] VARCHAR(20) NULL DEFAULT ,
    [CurrencyUnit] VARCHAR(20) NULL DEFAULT ,
    [ExchangeRate] NUMERIC(20,5) NULL DEFAULT ,
    [TotalAmount] NUMERIC(20,5) NULL DEFAULT ,
    [TotalWonAmount] NUMERIC(20,5) NULL DEFAULT ,
    [NegoTotalAmount] NUMERIC(20,5) NULL DEFAULT ,
    [NegoTotalWonAmount] NUMERIC(20,5) NULL DEFAULT ,
    [QuotationDetailDesc] NVARCHAR(MAX) NULL DEFAULT ,
    [RequestDeliveryDate] DATE NULL DEFAULT ,
    [IsApproval] BIT NULL DEFAULT ,
    [ApprovalUserID] VARCHAR(20) NULL DEFAULT ,
    [ApprovalDateTime] DATETIME NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

