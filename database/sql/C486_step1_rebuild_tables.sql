USE SmartFactoryV2;
GO

-- STEP 1A: Rebuild ALCase table
BEGIN TRANSACTION;
BEGIN TRY
    CREATE TABLE [dbo].[STB_VVT_SortingErrorData_ALCase_NEW] (
        [ID] INT IDENTITY(1,1) NOT NULL,
        [Date] DATE NULL, [Shift] NVARCHAR(10) NULL, [Person] NVARCHAR(100) NULL,
        [Vendor] NVARCHAR(100) NULL, [Factory] NVARCHAR(100) NULL,
        [MaterialCode] NVARCHAR(50) NULL,
        [Invoice] NVARCHAR(100) NULL,
        [LotNo] NVARCHAR(50) NULL,
        [QtyCheck] INT NULL, [QtyOK] INT NULL,
        [BurrAl] INT NULL, [BurrPlastic] INT NULL, [BurrRubber] INT NULL,
        [PlasticPeeling] INT NULL, [Scratch] INT NULL, [Deform] INT NULL,
        [ExposedCopper] INT NULL, [RubberDeform] INT NULL, [CrackWood] INT NULL,
        [Discoloration] INT NULL, [OtherError] INT NULL, [Total] INT NULL,
        [Note] NVARCHAR(500) NULL,
        [CreateUserID] VARCHAR(20) NULL, [CreateDateTime] DATETIME NULL,
        [ChangeUserID] VARCHAR(20) NULL, [ChangeDateTime] DATETIME NULL,
        CONSTRAINT [PK_STB_VVT_SortingErrorData_ALCase_NEW] PRIMARY KEY CLUSTERED ([ID])
    );
    SET IDENTITY_INSERT [dbo].[STB_VVT_SortingErrorData_ALCase_NEW] ON;
    INSERT INTO [dbo].[STB_VVT_SortingErrorData_ALCase_NEW]
        (ID,[Date],Shift,Person,Vendor,Factory,MaterialCode,Invoice,LotNo,QtyCheck,QtyOK,
         BurrAl,BurrPlastic,BurrRubber,PlasticPeeling,Scratch,Deform,ExposedCopper,
         RubberDeform,CrackWood,Discoloration,OtherError,Total,Note,
         CreateUserID,CreateDateTime,ChangeUserID,ChangeDateTime)
    SELECT ID,[Date],Shift,Person,Vendor,Factory,MaterialCode,NULL,LotNo,QtyCheck,QtyOK,
         BurrAl,BurrPlastic,BurrRubber,PlasticPeeling,Scratch,Deform,ExposedCopper,
         RubberDeform,CrackWood,Discoloration,OtherError,Total,NULL,
         CreateUserID,CreateDateTime,ChangeUserID,ChangeDateTime
    FROM [dbo].[STB_VVT_SortingErrorData_ALCase];
    SET IDENTITY_INSERT [dbo].[STB_VVT_SortingErrorData_ALCase_NEW] OFF;
    DROP TABLE [dbo].[STB_VVT_SortingErrorData_ALCase];
    EXEC sp_rename 'STB_VVT_SortingErrorData_ALCase_NEW','STB_VVT_SortingErrorData_ALCase';
    EXEC sp_rename 'PK_STB_VVT_SortingErrorData_ALCase_NEW','PK_STB_VVT_SortingErrorData_ALCase';
    COMMIT TRANSACTION;
    PRINT 'STEP 1A OK: ALCase rebuilt';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'STEP 1A FAILED: ' + ERROR_MESSAGE(); THROW;
END CATCH
GO

-- STEP 1B: Rebuild Plate table
BEGIN TRANSACTION;
BEGIN TRY
    CREATE TABLE [dbo].[STB_VVT_SortingErrorData_Plate_NEW] (
        [ID] INT IDENTITY(1,1) NOT NULL,
        [Date] DATE NULL, [Shift] NVARCHAR(10) NULL, [Person] NVARCHAR(100) NULL,
        [Vendor] NVARCHAR(100) NULL, [Factory] NVARCHAR(100) NULL,
        [MaterialCode] NVARCHAR(50) NULL,
        [Invoice] NVARCHAR(100) NULL,
        [LotNo] NVARCHAR(50) NULL,
        [QtyCheck] INT NULL, [QtyOK] INT NULL,
        [Burr] INT NULL, [Dent] INT NULL, [Deform] INT NULL, [Scratch] INT NULL,
        [NGPlating] INT NULL, [RoughFace] INT NULL, [Dirty] INT NULL,
        [DentBottom] INT NULL, [Discolor] INT NULL, [OtherError] INT NULL,
        [Total] INT NULL,
        [Note] NVARCHAR(500) NULL,
        [CreateUserID] VARCHAR(20) NULL, [CreateDateTime] DATETIME NULL,
        [ChangeUserID] VARCHAR(20) NULL, [ChangeDateTime] DATETIME NULL,
        CONSTRAINT [PK_STB_VVT_SortingErrorData_Plate_NEW] PRIMARY KEY CLUSTERED ([ID])
    );
    SET IDENTITY_INSERT [dbo].[STB_VVT_SortingErrorData_Plate_NEW] ON;
    INSERT INTO [dbo].[STB_VVT_SortingErrorData_Plate_NEW]
        (ID,[Date],Shift,Person,Vendor,Factory,MaterialCode,Invoice,LotNo,QtyCheck,QtyOK,
         Burr,Dent,Deform,Scratch,NGPlating,RoughFace,Dirty,DentBottom,Discolor,OtherError,Total,Note,
         CreateUserID,CreateDateTime,ChangeUserID,ChangeDateTime)
    SELECT ID,[Date],Shift,Person,Vendor,Factory,MaterialCode,NULL,LotNo,QtyCheck,QtyOK,
         Burr,Dent,Deform,Scratch,NGPlating,RoughFace,Dirty,DentBottom,Discolor,OtherError,Total,NULL,
         CreateUserID,CreateDateTime,ChangeUserID,ChangeDateTime
    FROM [dbo].[STB_VVT_SortingErrorData_Plate];
    SET IDENTITY_INSERT [dbo].[STB_VVT_SortingErrorData_Plate_NEW] OFF;
    DROP TABLE [dbo].[STB_VVT_SortingErrorData_Plate];
    EXEC sp_rename 'STB_VVT_SortingErrorData_Plate_NEW','STB_VVT_SortingErrorData_Plate';
    EXEC sp_rename 'PK_STB_VVT_SortingErrorData_Plate_NEW','PK_STB_VVT_SortingErrorData_Plate';
    COMMIT TRANSACTION;
    PRINT 'STEP 1B OK: Plate rebuilt';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'STEP 1B FAILED: ' + ERROR_MESSAGE(); THROW;
END CATCH
GO
