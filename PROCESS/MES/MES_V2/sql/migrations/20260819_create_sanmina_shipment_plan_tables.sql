-- =========================================================================================
-- Migration: Create STB_SanminaShipmentPlan & STB_SanminaShipmentPlanLot
-- Target DB: SmartFactoryV2
-- Purpose  : Poka-Yoke Sanmina Label Printing - Preset Shipment Plan
-- Author   : Antigravity MES Engineer
-- Date     : 2026-08-19
-- =========================================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

-- 1. Table STB_SanminaShipmentPlan (Master Plan)
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'STB_SanminaShipmentPlan')
BEGIN
    CREATE TABLE [dbo].[STB_SanminaShipmentPlan] (
        [PlanID] INT IDENTITY(1,1) NOT NULL,
        [PlanCode] VARCHAR(30) NOT NULL,
        [PONumber] VARCHAR(50) NOT NULL,
        [PartNumber] VARCHAR(50) NOT NULL,
        [MPN] VARCHAR(50) NOT NULL CONSTRAINT [DF_SanminaPlan_MPN] DEFAULT ('VEC3R0727QG'),
        [PartDesc] NVARCHAR(100) NOT NULL CONSTRAINT [DF_SanminaPlan_PartDesc] DEFAULT (N'CAP,TH EDLC 720F 3V D35MMXL105MM'),
        [QtyPerBox] INT NOT NULL CONSTRAINT [DF_SanminaPlan_QtyPerBox] DEFAULT (200),
        [TotalBox] INT NOT NULL,
        [PrintedBoxCount] INT NOT NULL CONSTRAINT [DF_SanminaPlan_PrintedBoxCount] DEFAULT (0),
        [Status] VARCHAR(20) NOT NULL CONSTRAINT [DF_SanminaPlan_Status] DEFAULT ('PENDING'),
        [Remark] NVARCHAR(255) NULL,
        [CreateUserID] VARCHAR(30) NULL,
        [CreateDateTime] DATETIME NOT NULL CONSTRAINT [DF_SanminaPlan_CreateDateTime] DEFAULT (GETDATE()),
        [UpdateUserID] VARCHAR(30) NULL,
        [UpdateDateTime] DATETIME NULL,
        [FinishDateTime] DATETIME NULL,
        CONSTRAINT [PK_STB_SanminaShipmentPlan] PRIMARY KEY CLUSTERED ([PlanID] ASC),
        CONSTRAINT [UQ_STB_SanminaShipmentPlan_PlanCode] UNIQUE NONCLUSTERED ([PlanCode] ASC)
    );

    CREATE NONCLUSTERED INDEX [IX_STB_SanminaShipmentPlan_Status] 
        ON [dbo].[STB_SanminaShipmentPlan] ([Status]) 
        INCLUDE ([PONumber], [PartNumber], [TotalBox], [PrintedBoxCount]);

    CREATE NONCLUSTERED INDEX [IX_STB_SanminaShipmentPlan_PONumber] 
        ON [dbo].[STB_SanminaShipmentPlan] ([PONumber]);
        
    PRINT 'Created table STB_SanminaShipmentPlan successfully.';
END
ELSE
BEGIN
    PRINT 'Table STB_SanminaShipmentPlan already exists.';
END
GO

-- 2. Table STB_SanminaShipmentPlanLot (Detail / Printed Carton Box Tracking)
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'STB_SanminaShipmentPlanLot')
BEGIN
    CREATE TABLE [dbo].[STB_SanminaShipmentPlanLot] (
        [DetailID] INT IDENTITY(1,1) NOT NULL,
        [PlanID] INT NOT NULL,
        [LotNo] VARCHAR(50) NOT NULL,
        [BoxSeq] INT NOT NULL,
        [CartonBoxNo] VARCHAR(20) NOT NULL,
        [BoxSerialNo] VARCHAR(100) NULL,
        [Inner1Serial] VARCHAR(50) NULL,
        [Inner2Serial] VARCHAR(50) NULL,
        [PrintedTime] DATETIME NOT NULL CONSTRAINT [DF_SanminaPlanLot_PrintedTime] DEFAULT (GETDATE()),
        [PrintUserID] VARCHAR(30) NULL,
        CONSTRAINT [PK_STB_SanminaShipmentPlanLot] PRIMARY KEY CLUSTERED ([DetailID] ASC),
        CONSTRAINT [FK_STB_SanminaShipmentPlanLot_Plan] FOREIGN KEY ([PlanID]) 
            REFERENCES [dbo].[STB_SanminaShipmentPlan] ([PlanID]) ON DELETE CASCADE
    );

    CREATE NONCLUSTERED INDEX [IX_STB_SanminaShipmentPlanLot_PlanID] 
        ON [dbo].[STB_SanminaShipmentPlanLot] ([PlanID]);

    CREATE NONCLUSTERED INDEX [IX_STB_SanminaShipmentPlanLot_LotNo] 
        ON [dbo].[STB_SanminaShipmentPlanLot] ([LotNo]);
        
    PRINT 'Created table STB_SanminaShipmentPlanLot successfully.';
END
ELSE
BEGIN
    PRINT 'Table STB_SanminaShipmentPlanLot already exists.';
END
GO
