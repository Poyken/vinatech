-- =============================================
-- Hotfix ID: 06_FIX_QC_INSPECTION_HUNG_YEN_SPS
-- Target Object: usp_QcInspectionGroup_HY_get, usp_QcInspectionItem_HY_get, usp_QcInspectionGroup_HY_iud, usp_QcInspectionItem_HY_iud, STB_QcInspectionGroup_HY, STB_QcInspectionItem_HY
-- Author: Antigravity (Advanced Agentic Coding)
-- Date: 2026-06-11
-- Description: Tạo 4 Stored Procedures và 2 bảng liên quan cho chi nhánh Hưng Yên (_HY).
--              - usp_QcInspectionGroup_HY_get
--              - usp_QcInspectionItem_HY_get
--              - usp_QcInspectionGroup_HY_iud
--              - usp_QcInspectionItem_HY_iud
-- =============================================

USE SmartFactoryV2;
GO

BEGIN TRAN;
GO

PRINT 'Starting Hotfix: 06_FIX_QC_INSPECTION_HUNG_YEN_SPS...';
GO

-- 1. TẠO CÁC BẢNG LIÊN QUAN VỚI HẬU TỐ _HY NẾU CHƯA TỒN TẠI
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'STB_QcInspectionGroup_HY')
BEGIN
    CREATE TABLE [dbo].[STB_QcInspectionGroup_HY] (
        [QcInspectionGroupCode] VARCHAR(20) NOT NULL,
        [QcInspectionGroupName] NVARCHAR(50) NULL,
        [QcInspectionGroupDesc] NVARCHAR(200) NULL,
        [IsUsed] BIT NULL,
        [CreateDateTime] DATETIME NULL,
        [CreateUserID] VARCHAR(20) NULL,
        [ChangeDateTime] DATETIME NULL,
        [ChangeUserID] VARCHAR(20) NULL,
        CONSTRAINT [PK_STB_QcInspectionGroup_HY] PRIMARY KEY CLUSTERED ([QcInspectionGroupCode] ASC)
    );
    PRINT 'Table STB_QcInspectionGroup_HY created successfully.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'STB_QcInspectionItem_HY')
BEGIN
    CREATE TABLE [dbo].[STB_QcInspectionItem_HY] (
        [QcInspectionItemCode] VARCHAR(20) NOT NULL,
        [QcInspectionGroupCode] VARCHAR(20) NULL,
        [QcInspectionItemName] NVARCHAR(200) NULL,
        [QcInspectionItemDesc] NVARCHAR(MAX) NULL,
        [ItemInspectionPrior] INT NULL,
        [ItemReportPrior] INT NULL,
        [IsCanSkip] BIT NULL,
        [InspectionType] VARCHAR(10) NULL,
        [IsMaterialSpec] BIT NULL,
        [QcSpecDesc] NVARCHAR(MAX) NULL,
        [InspectionLevel] VARCHAR(20) NULL,
        [AQL] NUMERIC(10, 3) NULL,
        [NValue] INT NULL,
        [CValue] INT NULL,
        [SpecValue] NUMERIC(20, 5) NULL,
        [USL] NUMERIC(20, 5) NULL,
        [LSL] NUMERIC(20, 5) NULL,
        [UCL] NUMERIC(20, 5) NULL,
        [LCL] NUMERIC(20, 5) NULL,
        [TextSpecValue] NVARCHAR(200) NULL,
        [CreateDateTime] DATETIME NULL,
        [CreateUserID] VARCHAR(20) NULL,
        [ChangeDateTime] DATETIME NULL,
        [ChangeUserID] VARCHAR(20) NULL,
        [IsHideOrShowHistory] BIT NULL,
        [IsSI01Standard] BIT NULL,
        CONSTRAINT [PK_STB_QcInspectionItem_HY] PRIMARY KEY CLUSTERED ([QcInspectionItemCode] ASC)
    );
    PRINT 'Table STB_QcInspectionItem_HY created successfully.';
END
GO


-- 2. TẠO LẠI CÁC STORED PROCEDURES VỚI TÊN MỚI VÀ BẢNG MỚI
-- =========================================================
-- Stored Procedure: usp_QcInspectionGroup_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_QcInspectionGroup_HY_get')
    DROP PROCEDURE [dbo].[usp_QcInspectionGroup_HY_get];
GO

CREATE PROCEDURE [dbo].[usp_QcInspectionGroup_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pQcInspectionGroupCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @QcInspectionGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pQcInspectionGroupCode,'') = '' THEN '*' ELSE @pQcInspectionGroupCode END

    
	SELECT
	        QIG.QcInspectionGroupCode AS OldQcInspectionGroupCode,
	        QIG.QcInspectionGroupCode,
	        QIG.QcInspectionGroupName,
	        QIG.QcInspectionGroupDesc,
	        QIG.IsUsed,
	        QIG.CreateDateTime,
	        QIG.CreateUserID,
	        QIG.ChangeDateTime,
	        QIG.ChangeUserID
	FROM
	        STB_QcInspectionGroup_HY QIG WITH(NOLOCK)
	WHERE
	        ((@QcInspectionGroupCode = '*') OR (QIG.QcInspectionGroupCode = @QcInspectionGroupCode)) 

END
GO

PRINT 'Procedure usp_QcInspectionGroup_HY_get created successfully.';
GO


-- =========================================================
-- Stored Procedure: usp_QcInspectionItem_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_QcInspectionItem_HY_get')
    DROP PROCEDURE [dbo].[usp_QcInspectionItem_HY_get];
GO

CREATE PROCEDURE [dbo].[usp_QcInspectionItem_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pQcInspectionGroupCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @QcInspectionGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pQcInspectionGroupCode,'') = '' THEN '' ELSE @pQcInspectionGroupCode END

    
	SELECT
	        QII.QcInspectionItemCode AS OldQcInspectionItemCode,
	        QII.QcInspectionItemCode,
	        QII.QcInspectionGroupCode,
	        QII.QcInspectionItemName,
	        QII.QcInspectionItemDesc,
	        QII.ItemInspectionPrior,
	        QII.ItemReportPrior,
	        QII.IsCanSkip,
	        QII.InspectionType,
	        QII.IsMaterialSpec,
	        QII.QcSpecDesc,
	        QII.InspectionLevel,
	        QII.AQL,
	        QII.SpecValue,
			QII.IsHideOrShowHistory, -- Mr.Duy add show hide history C540
	        QII.USL,
	        QII.LSL,
	        QII.UCL,
	        QII.LCL,
	        QII.TextSpecValue,
	        QII.CreateDateTime,
	        QII.CreateUserID,
	        QII.ChangeDateTime,
	        QII.ChangeUserID
	FROM
	        STB_QcInspectionItem_HY QII WITH(NOLOCK)
	WHERE
	        ((QII.QcInspectionGroupCode = @QcInspectionGroupCode))

END
GO

PRINT 'Procedure usp_QcInspectionItem_HY_get created successfully.';
GO


-- =========================================================
-- Stored Procedure: usp_QcInspectionGroup_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_QcInspectionGroup_HY_iud')
    DROP PROCEDURE [dbo].[usp_QcInspectionGroup_HY_iud];
GO

CREATE PROCEDURE [dbo].[usp_QcInspectionGroup_HY_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  DECLARE @OldQcInspectionGroupCode VARCHAR(20)
  DECLARE @QcInspectionGroupCode VARCHAR(20)
  DECLARE @QcInspectionGroupName NVARCHAR(50)
  DECLARE @QcInspectionGroupDesc NVARCHAR(200)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_QcInspectionGroup_HY',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_QcInspectionGroup_HY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldQcInspectionGroupCode IS NULL THEN XMLData.QcInspectionGroupCode
							    ELSE XMLData.OldQcInspectionGroupCode
							END AS OldQcInspectionGroupCode,
							XMLData.QcInspectionGroupCode,
							XMLData.QcInspectionGroupName,
							XMLData.QcInspectionGroupDesc,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldQcInspectionGroupCode VARCHAR(20),
										QcInspectionGroupCode VARCHAR(20),
										QcInspectionGroupName NVARCHAR(50),
										QcInspectionGroupDesc NVARCHAR(200),
										IsUsed BIT,
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.QcInspectionGroupCode = SourceTable.QcInspectionGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					QcInspectionGroupCode = SourceTable.QcInspectionGroupCode,
					QcInspectionGroupName = SourceTable.QcInspectionGroupName,
					QcInspectionGroupDesc = SourceTable.QcInspectionGroupDesc,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						QcInspectionGroupCode,
						QcInspectionGroupName,
						QcInspectionGroupDesc,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.QcInspectionGroupCode,
							SourceTable.QcInspectionGroupName,
							SourceTable.QcInspectionGroupDesc,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_QcInspectionGroup_HY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldQcInspectionGroupCode IS NULL THEN XMLData.QcInspectionGroupCode
							    ELSE XMLData.OldQcInspectionGroupCode
							END AS OldQcInspectionGroupCode,
							XMLData.QcInspectionGroupCode,
							XMLData.QcInspectionGroupName,
							XMLData.QcInspectionGroupDesc,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldQcInspectionGroupCode VARCHAR(20),
										QcInspectionGroupCode VARCHAR(20),
										QcInspectionGroupName NVARCHAR(50),
										QcInspectionGroupDesc NVARCHAR(200),
										IsUsed BIT,
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.QcInspectionGroupCode = SourceTable.OldQcInspectionGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					QcInspectionGroupCode = SourceTable.QcInspectionGroupCode,
					QcInspectionGroupName = SourceTable.QcInspectionGroupName,
					QcInspectionGroupDesc = SourceTable.QcInspectionGroupDesc,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						QcInspectionGroupCode,
						QcInspectionGroupName,
						QcInspectionGroupDesc,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.QcInspectionGroupCode,
							SourceTable.QcInspectionGroupName,
							SourceTable.QcInspectionGroupDesc,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_QcInspectionGroup_HY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldQcInspectionGroupCode IS NULL THEN XMLData.QcInspectionGroupCode
							    ELSE XMLData.OldQcInspectionGroupCode
							END AS OldQcInspectionGroupCode,
							XMLData.QcInspectionGroupCode,
							XMLData.QcInspectionGroupName,
							XMLData.QcInspectionGroupDesc,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldQcInspectionGroupCode VARCHAR(20),
										QcInspectionGroupCode VARCHAR(20),
										QcInspectionGroupName NVARCHAR(50),
										QcInspectionGroupDesc NVARCHAR(200),
										IsUsed BIT,
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.QcInspectionGroupCode = SourceTable.QcInspectionGroupCode
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									XMLData.OldQcInspectionGroupCode,
									XMLData.QcInspectionGroupCode,
									XMLData.QcInspectionGroupName,
									XMLData.QcInspectionGroupDesc,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldQcInspectionGroupCode VARCHAR(20),
											 QcInspectionGroupCode VARCHAR(20),
											 QcInspectionGroupName NVARCHAR(50),
											 QcInspectionGroupDesc NVARCHAR(200),
											 IsUsed BIT,
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldQcInspectionGroupCode IS NULL THEN XMLData.QcInspectionGroupCode
										ELSE XMLData.OldQcInspectionGroupCode
									END AS OldQcInspectionGroupCode,
									XMLData.QcInspectionGroupCode,
									XMLData.QcInspectionGroupName,
									XMLData.QcInspectionGroupDesc,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldQcInspectionGroupCode VARCHAR(20),
											 QcInspectionGroupCode VARCHAR(20),
											 QcInspectionGroupName NVARCHAR(50),
											 QcInspectionGroupDesc NVARCHAR(200),
											 IsUsed BIT,
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldQcInspectionGroupCode IS NULL THEN XMLData.QcInspectionGroupCode
										ELSE XMLData.OldQcInspectionGroupCode
									END AS OldQcInspectionGroupCode,
									XMLData.QcInspectionGroupCode,
									XMLData.QcInspectionGroupName,
									XMLData.QcInspectionGroupDesc,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldQcInspectionGroupCode VARCHAR(20),
											 QcInspectionGroupCode VARCHAR(20),
											 QcInspectionGroupName NVARCHAR(50),
											 QcInspectionGroupDesc NVARCHAR(200),
											 IsUsed BIT,
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldQcInspectionGroupCode,
								 @QcInspectionGroupCode,
								 @QcInspectionGroupName,
								 @QcInspectionGroupDesc,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_QcInspectionGroup_HY WHERE QcInspectionGroupCode = @QcInspectionGroupCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @QcInspectionGroupCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QcInspectionGroup_HY', @QcInspectionGroupCode OUTPUT
                    END

                    INSERT INTO STB_QcInspectionGroup_HY
						(
						    QcInspectionGroupCode,
						    QcInspectionGroupName,
						    QcInspectionGroupDesc,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @QcInspectionGroupCode,
						    @QcInspectionGroupName,
						    @QcInspectionGroupDesc,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_QcInspectionGroup_HY
						SET
						    QcInspectionGroupCode =   CASE
						                WHEN @QcInspectionGroupCode IS NOT NULL THEN @QcInspectionGroupCode
						                ELSE QcInspectionGroupCode
						            END,
						    QcInspectionGroupName =   CASE
						                WHEN @QcInspectionGroupName IS NOT NULL THEN @QcInspectionGroupName
						                ELSE QcInspectionGroupName
						            END,
						    QcInspectionGroupDesc =   CASE
						                WHEN @QcInspectionGroupDesc IS NOT NULL THEN @QcInspectionGroupDesc
						                ELSE QcInspectionGroupDesc
						            END,
						    IsUsed =   CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
						            END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    QcInspectionGroupCode = @OldQcInspectionGroupCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_QcInspectionGroup_HY
						WHERE
						    QcInspectionGroupCode = @QcInspectionGroupCode
                END
            END
        END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	
    END
END
GO

PRINT 'Procedure usp_QcInspectionGroup_HY_iud created successfully.';
GO


-- =========================================================
-- Stored Procedure: usp_QcInspectionItem_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_QcInspectionItem_HY_iud')
    DROP PROCEDURE [dbo].[usp_QcInspectionItem_HY_iud];
GO

CREATE PROCEDURE [dbo].[usp_QcInspectionItem_HY_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  DECLARE @OldQcInspectionItemCode VARCHAR(20)
  DECLARE @QcInspectionItemCode VARCHAR(20)
  DECLARE @QcInspectionGroupCode VARCHAR(20)
  DECLARE @QcInspectionItemName NVARCHAR(200)
  DECLARE @QcInspectionItemDesc NVARCHAR(MAX)
  DECLARE @ItemInspectionPrior INT
  DECLARE @ItemReportPrior INT
  DECLARE @IsCanSkip BIT
  DECLARE @InspectionType VARCHAR(10)
  DECLARE @IsMaterialSpec BIT
  DECLARE @IsHideOrShowHistory BIT
  DECLARE @QcSpecDesc NVARCHAR(MAX)
  DECLARE @InspectionLevel VARCHAR(20)
  DECLARE @AQL NUMERIC(10,3)
  DECLARE @SpecValue NUMERIC(20,5)
  DECLARE @USL NUMERIC(20,5)
  DECLARE @LSL NUMERIC(20,5)
  DECLARE @UCL NUMERIC(20,5)
  DECLARE @LCL NUMERIC(20,5)
  DECLARE @TextSpecValue NVARCHAR(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_QcInspectionItem_HY',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_QcInspectionItem_HY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldQcInspectionItemCode IS NULL THEN XMLData.QcInspectionItemCode
							    ELSE XMLData.OldQcInspectionItemCode
							END AS OldQcInspectionItemCode,
							XMLData.QcInspectionItemCode,
							XMLData.QcInspectionGroupCode,
							XMLData.QcInspectionItemName,
							XMLData.QcInspectionItemDesc,
							XMLData.ItemInspectionPrior,
							XMLData.ItemReportPrior,
							XMLData.IsCanSkip,
							XMLData.InspectionType,
							XMLData.IsMaterialSpec,
							XMLData.IsHideOrShowHistory,
							XMLData.QcSpecDesc,
							XMLData.InspectionLevel,
							XMLData.AQL,
							XMLData.SpecValue,
							XMLData.USL,
							XMLData.LSL,
							XMLData.UCL,
							XMLData.LCL,
							XMLData.TextSpecValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldQcInspectionItemCode VARCHAR(20),
										QcInspectionItemCode VARCHAR(20),
										QcInspectionGroupCode VARCHAR(20),
										QcInspectionItemName NVARCHAR(200),
										QcInspectionItemDesc NVARCHAR(MAX),
										ItemInspectionPrior INT,
										ItemReportPrior INT,
										IsCanSkip BIT,
										InspectionType VARCHAR(10),
										IsMaterialSpec BIT,
										IsHideOrShowHistory BIT,
										QcSpecDesc NVARCHAR(MAX),
										InspectionLevel VARCHAR(20),
										AQL NUMERIC(10,3),
										SpecValue NUMERIC(20,5),
										USL NUMERIC(20,5),
										LSL NUMERIC(20,5),
										UCL NUMERIC(20,5),
										LCL NUMERIC(20,5),
										TextSpecValue NVARCHAR(200),
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.QcInspectionItemCode = SourceTable.QcInspectionItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					QcInspectionItemCode = SourceTable.QcInspectionItemCode,
					QcInspectionGroupCode = SourceTable.QcInspectionGroupCode,
					QcInspectionItemName = SourceTable.QcInspectionItemName,
					QcInspectionItemDesc = SourceTable.QcInspectionItemDesc,
					ItemInspectionPrior = SourceTable.ItemInspectionPrior,
					ItemReportPrior = SourceTable.ItemReportPrior,
					IsCanSkip = SourceTable.IsCanSkip,
					InspectionType = SourceTable.InspectionType,
					IsMaterialSpec = SourceTable.IsMaterialSpec,
					IsHideOrShowHistory = SourceTable.IsHideOrShowHistory,
					QcSpecDesc = SourceTable.QcSpecDesc,
					InspectionLevel = SourceTable.InspectionLevel,
					AQL = SourceTable.AQL,
					SpecValue = SourceTable.SpecValue,
					USL = SourceTable.USL,
					LSL = SourceTable.LSL,
					UCL = SourceTable.UCL,
					LCL = SourceTable.LCL,
					TextSpecValue = SourceTable.TextSpecValue,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						QcInspectionItemCode,
						QcInspectionGroupCode,
						QcInspectionItemName,
						QcInspectionItemDesc,
						ItemInspectionPrior,
						ItemReportPrior,
						IsCanSkip,
						InspectionType,
						IsMaterialSpec,
						IsHideOrShowHistory,
						QcSpecDesc,
						InspectionLevel,
						AQL,
						SpecValue,
						USL,
						LSL,
						UCL,
						LCL,
						TextSpecValue,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.QcInspectionItemCode,
							SourceTable.QcInspectionGroupCode,
							SourceTable.QcInspectionItemName,
							SourceTable.QcInspectionItemDesc,
							SourceTable.ItemInspectionPrior,
							SourceTable.ItemReportPrior,
							SourceTable.IsCanSkip,
							SourceTable.InspectionType,
							SourceTable.IsMaterialSpec,
							SourceTable.IsHideOrShowHistory,
							SourceTable.QcSpecDesc,
							SourceTable.InspectionLevel,
							SourceTable.AQL,
							SourceTable.SpecValue,
							SourceTable.USL,
							SourceTable.LSL,
							SourceTable.UCL,
							SourceTable.LCL,
							SourceTable.TextSpecValue,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_QcInspectionItem_HY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldQcInspectionItemCode IS NULL THEN XMLData.QcInspectionItemCode
							    ELSE XMLData.OldQcInspectionItemCode
							END AS OldQcInspectionItemCode,
							XMLData.QcInspectionItemCode,
							XMLData.QcInspectionGroupCode,
							XMLData.QcInspectionItemName,
							XMLData.QcInspectionItemDesc,
							XMLData.ItemInspectionPrior,
							XMLData.ItemReportPrior,
							XMLData.IsCanSkip,
							XMLData.InspectionType,
							XMLData.IsMaterialSpec,
							XMLData.IsHideOrShowHistory,
							XMLData.QcSpecDesc,
							XMLData.InspectionLevel,
							XMLData.AQL,
							XMLData.SpecValue,
							XMLData.USL,
							XMLData.LSL,
							XMLData.UCL,
							XMLData.LCL,
							XMLData.TextSpecValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldQcInspectionItemCode VARCHAR(20),
										QcInspectionItemCode VARCHAR(20),
										QcInspectionGroupCode VARCHAR(20),
										QcInspectionItemName NVARCHAR(200),
										QcInspectionItemDesc NVARCHAR(MAX),
										ItemInspectionPrior INT,
										ItemReportPrior INT,
										IsCanSkip BIT,
										InspectionType VARCHAR(10),
										IsMaterialSpec BIT,
										IsHideOrShowHistory BIT,
										QcSpecDesc NVARCHAR(MAX),
										InspectionLevel VARCHAR(20),
										AQL NUMERIC(10,3),
										SpecValue NUMERIC(20,5),
										USL NUMERIC(20,5),
										LSL NUMERIC(20,5),
										UCL NUMERIC(20,5),
										LCL NUMERIC(20,5),
										TextSpecValue NVARCHAR(200),
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.QcInspectionItemCode = SourceTable.OldQcInspectionItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					QcInspectionItemCode = SourceTable.QcInspectionItemCode,
					QcInspectionGroupCode = SourceTable.QcInspectionGroupCode,
					QcInspectionItemName = SourceTable.QcInspectionItemName,
					QcInspectionItemDesc = SourceTable.QcInspectionItemDesc,
					ItemInspectionPrior = SourceTable.ItemInspectionPrior,
					ItemReportPrior = SourceTable.ItemReportPrior,
					IsCanSkip = SourceTable.IsCanSkip,
					InspectionType = SourceTable.InspectionType,
					IsMaterialSpec = SourceTable.IsMaterialSpec,
					IsHideOrShowHistory = SourceTable.IsHideOrShowHistory,
					QcSpecDesc = SourceTable.QcSpecDesc,
					InspectionLevel = SourceTable.InspectionLevel,
					AQL = SourceTable.AQL,
					SpecValue = SourceTable.SpecValue,
					USL = SourceTable.USL,
					LSL = SourceTable.LSL,
					UCL = SourceTable.UCL,
					LCL = SourceTable.LCL,
					TextSpecValue = SourceTable.TextSpecValue,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						QcInspectionItemCode,
						QcInspectionGroupCode,
						QcInspectionItemName,
						QcInspectionItemDesc,
						ItemInspectionPrior,
						ItemReportPrior,
						IsCanSkip,
						InspectionType,
						IsMaterialSpec,
						IsHideOrShowHistory,
						QcSpecDesc,
						InspectionLevel,
						AQL,
						SpecValue,
						USL,
						LSL,
						UCL,
						LCL,
						TextSpecValue,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.QcInspectionItemCode,
							SourceTable.QcInspectionGroupCode,
							SourceTable.QcInspectionItemName,
							SourceTable.QcInspectionItemDesc,
							SourceTable.ItemInspectionPrior,
							SourceTable.ItemReportPrior,
							SourceTable.IsCanSkip,
							SourceTable.InspectionType,
							SourceTable.IsMaterialSpec,
							SourceTable.IsHideOrShowHistory,
							SourceTable.QcSpecDesc,
							SourceTable.InspectionLevel,
							SourceTable.AQL,
							SourceTable.SpecValue,
							SourceTable.USL,
							SourceTable.LSL,
							SourceTable.UCL,
							SourceTable.LCL,
							SourceTable.TextSpecValue,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_QcInspectionItem_HY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldQcInspectionItemCode IS NULL THEN XMLData.QcInspectionItemCode
							    ELSE XMLData.OldQcInspectionItemCode
							END AS OldQcInspectionItemCode,
							XMLData.QcInspectionItemCode,
							XMLData.QcInspectionGroupCode,
							XMLData.QcInspectionItemName,
							XMLData.QcInspectionItemDesc,
							XMLData.ItemInspectionPrior,
							XMLData.ItemReportPrior,
							XMLData.IsCanSkip,
							XMLData.InspectionType,
							XMLData.IsMaterialSpec,
							XMLData.IsHideOrShowHistory,
							XMLData.QcSpecDesc,
							XMLData.InspectionLevel,
							XMLData.AQL,
							XMLData.SpecValue,
							XMLData.USL,
							XMLData.LSL,
							XMLData.UCL,
							XMLData.LCL,
							XMLData.TextSpecValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldQcInspectionItemCode VARCHAR(20),
										QcInspectionItemCode VARCHAR(20),
										QcInspectionGroupCode VARCHAR(20),
										QcInspectionItemName NVARCHAR(200),
										QcInspectionItemDesc NVARCHAR(MAX),
										ItemInspectionPrior INT,
										ItemReportPrior INT,
										IsCanSkip BIT,
										InspectionType VARCHAR(10),
										IsMaterialSpec BIT,
										IsHideOrShowHistory BIT,
										QcSpecDesc NVARCHAR(MAX),
										InspectionLevel VARCHAR(20),
										AQL NUMERIC(10,3),
										SpecValue NUMERIC(20,5),
										USL NUMERIC(20,5),
										LSL NUMERIC(20,5),
										UCL NUMERIC(20,5),
										LCL NUMERIC(20,5),
										TextSpecValue NVARCHAR(200),
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.QcInspectionItemCode = SourceTable.QcInspectionItemCode
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									XMLData.OldQcInspectionItemCode,
									XMLData.QcInspectionItemCode,
									XMLData.QcInspectionGroupCode,
									XMLData.QcInspectionItemName,
									XMLData.QcInspectionItemDesc,
									XMLData.ItemInspectionPrior,
									XMLData.ItemReportPrior,
									XMLData.IsCanSkip,
									XMLData.InspectionType,
									XMLData.IsMaterialSpec,
									XMLData.IsHideOrShowHistory,
									XMLData.QcSpecDesc,
									XMLData.InspectionLevel,
									XMLData.AQL,
									XMLData.SpecValue,
									XMLData.USL,
									XMLData.LSL,
									XMLData.UCL,
									XMLData.LCL,
									XMLData.TextSpecValue,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldQcInspectionItemCode VARCHAR(20),
											 QcInspectionItemCode VARCHAR(20),
											 QcInspectionGroupCode VARCHAR(20),
											 QcInspectionItemName NVARCHAR(200),
											 QcInspectionItemDesc NVARCHAR(MAX),
											 ItemInspectionPrior INT,
											 ItemReportPrior INT,
											 IsCanSkip BIT,
											 InspectionType VARCHAR(10),
											 IsMaterialSpec BIT,
											 IsHideOrShowHistory  BIT,
											 QcSpecDesc NVARCHAR(MAX),
											 InspectionLevel VARCHAR(20),
											 AQL NUMERIC(10,3),
											 SpecValue NUMERIC(20,5),
											 USL NUMERIC(20,5),
											 LSL NUMERIC(20,5),
											 UCL NUMERIC(20,5),
											 LCL NUMERIC(20,5),
											 TextSpecValue NVARCHAR(200),
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldQcInspectionItemCode IS NULL THEN XMLData.QcInspectionItemCode
										ELSE XMLData.OldQcInspectionItemCode
									END AS OldQcInspectionItemCode,
									XMLData.QcInspectionItemCode,
									XMLData.QcInspectionGroupCode,
									XMLData.QcInspectionItemName,
									XMLData.QcInspectionItemDesc,
									XMLData.ItemInspectionPrior,
									XMLData.ItemReportPrior,
									XMLData.IsCanSkip,
									XMLData.InspectionType,
									XMLData.IsMaterialSpec,
									XMLData.IsHideOrShowHistory,
									XMLData.QcSpecDesc,
									XMLData.InspectionLevel,
									XMLData.AQL,
									XMLData.SpecValue,
									XMLData.USL,
									XMLData.LSL,
									XMLData.UCL,
									XMLData.LCL,
									XMLData.TextSpecValue,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldQcInspectionItemCode VARCHAR(20),
											 QcInspectionItemCode VARCHAR(20),
											 QcInspectionGroupCode VARCHAR(20),
											 QcInspectionItemName NVARCHAR(200),
											 QcInspectionItemDesc NVARCHAR(MAX),
											 ItemInspectionPrior INT,
											 ItemReportPrior INT,
											 IsCanSkip BIT,
											 InspectionType VARCHAR(10),
											 IsMaterialSpec BIT,
											 IsHideOrShowHistory BIT,
											 QcSpecDesc NVARCHAR(MAX),
											 InspectionLevel VARCHAR(20),
											 AQL NUMERIC(10,3),
											 SpecValue NUMERIC(20,5),
											 USL NUMERIC(20,5),
											 LSL NUMERIC(20,5),
											 UCL NUMERIC(20,5),
											 LCL NUMERIC(20,5),
											 TextSpecValue NVARCHAR(200),
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldQcInspectionItemCode IS NULL THEN XMLData.QcInspectionItemCode
										ELSE XMLData.OldQcInspectionItemCode
									END AS OldQcInspectionItemCode,
									XMLData.QcInspectionItemCode,
									XMLData.QcInspectionGroupCode,
									XMLData.QcInspectionItemName,
									XMLData.QcInspectionItemDesc,
									XMLData.ItemInspectionPrior,
									XMLData.ItemReportPrior,
									XMLData.IsCanSkip,
									XMLData.InspectionType,
									XMLData.IsMaterialSpec,
									XMLData.IsHideOrShowHistory,
									XMLData.QcSpecDesc,
									XMLData.InspectionLevel,
									XMLData.AQL,
									XMLData.SpecValue,
									XMLData.USL,
									XMLData.LSL,
									XMLData.UCL,
									XMLData.LCL,
									XMLData.TextSpecValue,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldQcInspectionItemCode VARCHAR(20),
											 QcInspectionItemCode VARCHAR(20),
											 QcInspectionGroupCode VARCHAR(20),
											 QcInspectionItemName NVARCHAR(200),
											 QcInspectionItemDesc NVARCHAR(MAX),
											 ItemInspectionPrior INT,
											 ItemReportPrior INT,
											 IsCanSkip BIT,
											 InspectionType VARCHAR(10),
											 IsMaterialSpec BIT,
											 IsHideOrShowHistory BIT,
											 QcSpecDesc NVARCHAR(MAX),
											 InspectionLevel VARCHAR(20),
											 AQL NUMERIC(10,3),
											 SpecValue NUMERIC(20,5),
											 USL NUMERIC(20,5),
											 LSL NUMERIC(20,5),
											 UCL NUMERIC(20,5),
											 LCL NUMERIC(20,5),
											 TextSpecValue NVARCHAR(200),
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldQcInspectionItemCode,
								 @QcInspectionItemCode,
								 @QcInspectionGroupCode,
								 @QcInspectionItemName,
								 @QcInspectionItemDesc,
								 @ItemInspectionPrior,
								 @ItemReportPrior,
								 @IsCanSkip,
								 @InspectionType,
								 @IsMaterialSpec,
								 @IsHideOrShowHistory,
								 @QcSpecDesc,
								 @InspectionLevel,
								 @AQL,
								 @SpecValue,
								 @USL,
								 @LSL,
								 @UCL,
								 @LCL,
								 @TextSpecValue,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_QcInspectionItem_HY WHERE QcInspectionItemCode = @QcInspectionItemCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @QcInspectionItemCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QcInspectionItem_HY', @QcInspectionItemCode OUTPUT
                    END

                    INSERT INTO STB_QcInspectionItem_HY
						(
						    QcInspectionItemCode,
						    QcInspectionGroupCode,
						    QcInspectionItemName,
						    QcInspectionItemDesc,
						    ItemInspectionPrior,
						    ItemReportPrior,
						    IsCanSkip,
						    InspectionType,
						    IsMaterialSpec,
							IsHideOrShowHistory,
						    QcSpecDesc,
						    InspectionLevel,
						    AQL,
						    SpecValue,
						    USL,
						    LSL,
						    UCL,
						    LCL,
						    TextSpecValue,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @QcInspectionItemCode,
						    @QcInspectionGroupCode,
						    @QcInspectionItemName,
						    @QcInspectionItemDesc,
						    @ItemInspectionPrior,
						    @ItemReportPrior,
						    @IsCanSkip,
						    @InspectionType,
						    @IsMaterialSpec,
							@IsHideOrShowHistory,
						    @QcSpecDesc,
						    @InspectionLevel,
						    @AQL,
						    @SpecValue,
						    @USL,
						    @LSL,
						    @UCL,
						    @LCL,
						    @TextSpecValue,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_QcInspectionItem_HY
						SET
						    QcInspectionItemCode =   CASE
						                WHEN @QcInspectionItemCode IS NOT NULL THEN @QcInspectionItemCode
						                ELSE QcInspectionItemCode
						            END,
						    QcInspectionGroupCode =   CASE
						                WHEN @QcInspectionGroupCode IS NOT NULL THEN @QcInspectionGroupCode
						                ELSE QcInspectionGroupCode
						            END,
						    QcInspectionItemName =   CASE
						                WHEN @QcInspectionItemName IS NOT NULL THEN @QcInspectionItemName
						                ELSE QcInspectionItemName
						            END,
						    QcInspectionItemDesc =   CASE
						                WHEN @QcInspectionItemDesc IS NOT NULL THEN @QcInspectionItemDesc
						                ELSE QcInspectionItemDesc
						            END,
						    ItemInspectionPrior =   CASE
						                WHEN @ItemInspectionPrior IS NOT NULL THEN @ItemInspectionPrior
						                ELSE ItemInspectionPrior
						            END,
						    ItemReportPrior =   CASE
						                WHEN @ItemReportPrior IS NOT NULL THEN @ItemReportPrior
						                ELSE ItemReportPrior
						            END,
						    IsCanSkip =   CASE
						                WHEN @IsCanSkip IS NOT NULL THEN @IsCanSkip
						                ELSE IsCanSkip
						            END,
						    InspectionType =   CASE
						                WHEN @InspectionType IS NOT NULL THEN @InspectionType
						                ELSE InspectionType
						            END,
						    IsMaterialSpec =   CASE
						                WHEN @IsMaterialSpec IS NOT NULL THEN @IsMaterialSpec
						                ELSE IsMaterialSpec
						            END,
							IsHideOrShowHistory =   CASE
						                WHEN @IsHideOrShowHistory IS NOT NULL THEN @IsHideOrShowHistory
						                ELSE IsHideOrShowHistory
						            END,
						    QcSpecDesc =   CASE
						                WHEN @QcSpecDesc IS NOT NULL THEN @QcSpecDesc
						                ELSE QcSpecDesc
						            END,
						    InspectionLevel =   CASE
						                WHEN @InspectionLevel IS NOT NULL THEN @InspectionLevel
						                ELSE InspectionLevel
						            END,
						    AQL =   CASE
						                WHEN @AQL IS NOT NULL THEN @AQL
						                ELSE AQL
						            END,
						    SpecValue =   CASE
						                WHEN @SpecValue IS NOT NULL THEN @SpecValue
						                ELSE SpecValue
						            END,
						    USL =   CASE
						                WHEN @USL IS NOT NULL THEN @USL
						                ELSE USL
						            END,
						    LSL =   CASE
						                WHEN @LSL IS NOT NULL THEN @LSL
						                ELSE LSL
						            END,
						    UCL =   CASE
						                WHEN @UCL IS NOT NULL THEN @UCL
						                ELSE UCL
						            END,
						    LCL =   CASE
						                WHEN @LCL IS NOT NULL THEN @LCL
						                ELSE LCL
						            END,
						    TextSpecValue =   CASE
						                WHEN @TextSpecValue IS NOT NULL THEN @TextSpecValue
						                ELSE TextSpecValue
						            END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    QcInspectionItemCode = @OldQcInspectionItemCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_QcInspectionItem_HY
						WHERE
						    QcInspectionItemCode = @QcInspectionItemCode
                END
            END
        END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	
    END
END
GO

PRINT 'Procedure usp_QcInspectionItem_HY_iud created successfully.';
GO


-- 3. CHẠY THỬ NGHIỆM SIMULATION TEST
PRINT 'Testing Stored Procedures...';
GO

DECLARE @XmlGroup NVARCHAR(MAX) = N'
<DataSet>
    <InspectionGroup_INSERT>
        <QcInspectionGroupCode>GRP_HY_TEST</QcInspectionGroupCode>
        <QcInspectionGroupName>Test Group HY</QcInspectionGroupName>
        <QcInspectionGroupDesc>Test Group Hung Yen Description</QcInspectionGroupDesc>
        <IsUsed>1</IsUsed>
    </InspectionGroup_INSERT>
</DataSet>';

BEGIN TRY
    EXEC usp_QcInspectionGroup_HY_iud 
        @pProcessUserID = 'vinaadmin', 
        @pProcessLanguage = 'vi-VN', 
        @pProcessViewName = 'InspectionGroup', 
        @pXml = @XmlGroup;

    IF EXISTS (SELECT 1 FROM STB_QcInspectionGroup_HY WHERE QcInspectionGroupCode = 'GRP_HY_TEST')
        PRINT 'Test usp_QcInspectionGroup_HY_iud (INSERT): PASSED.';
    ELSE
        PRINT 'Test usp_QcInspectionGroup_HY_iud (INSERT): FAILED!';
END TRY
BEGIN CATCH
    PRINT 'Test usp_QcInspectionGroup_HY_iud (INSERT): FAILED with error: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
    IF EXISTS (SELECT 1 FROM STB_QcInspectionGroup_HY WHERE QcInspectionGroupCode = 'GRP_HY_TEST')
    BEGIN
        PRINT 'Running usp_QcInspectionGroup_HY_get...';
        EXEC usp_QcInspectionGroup_HY_get @pProcessUserID = 'vinaadmin', @pProcessLanguage = 'vi-VN', @pQcInspectionGroupCode = 'GRP_HY_TEST';
        PRINT 'Test usp_QcInspectionGroup_HY_get: PASSED.';
    END
END TRY
BEGIN CATCH
    PRINT 'Test usp_QcInspectionGroup_HY_get: FAILED with error: ' + ERROR_MESSAGE();
END CATCH;
GO

DECLARE @XmlItem NVARCHAR(MAX) = N'
<DataSet>
    <InspectionItem_INSERT>
        <QcInspectionItemCode>ITEM_HY_TEST</QcInspectionItemCode>
        <QcInspectionGroupCode>GRP_HY_TEST</QcInspectionGroupCode>
        <QcInspectionItemName>Test Item HY</QcInspectionItemName>
        <QcInspectionItemDesc>Test Item Hung Yen Description</QcInspectionItemDesc>
        <ItemInspectionPrior>1</ItemInspectionPrior>
        <ItemReportPrior>1</ItemReportPrior>
        <IsCanSkip>0</IsCanSkip>
        <InspectionType>IQC</InspectionType>
        <IsMaterialSpec>1</IsMaterialSpec>
        <QcSpecDesc>Spec Description</QcSpecDesc>
        <InspectionLevel>GII</InspectionLevel>
        <AQL>0.65</AQL>
        <SpecValue>10.5</SpecValue>
        <USL>11.0</USL>
        <LSL>10.0</LSL>
        <UCL>10.8</UCL>
        <LCL>10.2</LCL>
        <TextSpecValue>Test Spec Value</TextSpecValue>
        <IsHideOrShowHistory>0</IsHideOrShowHistory>
    </InspectionItem_INSERT>
</DataSet>';

BEGIN TRY
    EXEC usp_QcInspectionItem_HY_iud 
        @pProcessUserID = 'vinaadmin', 
        @pProcessLanguage = 'vi-VN', 
        @pProcessViewName = 'InspectionItem', 
        @pXml = @XmlItem;

    IF EXISTS (SELECT 1 FROM STB_QcInspectionItem_HY WHERE QcInspectionItemCode = 'ITEM_HY_TEST')
        PRINT 'Test usp_QcInspectionItem_HY_iud (INSERT): PASSED.';
    ELSE
        PRINT 'Test usp_QcInspectionItem_HY_iud (INSERT): FAILED!';
END TRY
BEGIN CATCH
    PRINT 'Test usp_QcInspectionItem_HY_iud (INSERT): FAILED with error: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
    IF EXISTS (SELECT 1 FROM STB_QcInspectionItem_HY WHERE QcInspectionItemCode = 'ITEM_HY_TEST')
    BEGIN
        PRINT 'Running usp_QcInspectionItem_HY_get...';
        EXEC usp_QcInspectionItem_HY_get @pProcessUserID = 'vinaadmin', @pProcessLanguage = 'vi-VN', @pQcInspectionGroupCode = 'GRP_HY_TEST';
        PRINT 'Test usp_QcInspectionItem_HY_get: PASSED.';
    END
END TRY
BEGIN CATCH
    PRINT 'Test usp_QcInspectionItem_HY_get: FAILED with error: ' + ERROR_MESSAGE();
END CATCH;
GO


-- 4. HỦY BỎ GIAO DỊCH ĐỂ ĐẢM BẢO KHÔNG LƯU DỮ LIỆU RÁC (DBA SẼ ĐỔI SANG COMMIT KHI CHẠY THỰC TẾ)
ROLLBACK TRAN;
PRINT 'Transaction ROLLBACK successfully. DB remains untouched.';
GO
