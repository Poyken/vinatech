-- =============================================
-- Hotfix ID: 08_FIX_MATERIAL_QC_INSPECTION_HUNG_YEN_SPS
-- Target Object: usp_MaterialQcInspectionItem_ByMaterial_HY_get, usp_MaterialQcInspectionItem_HY_iud, STB_MaterialQcInspectionItem_HY
-- Author: Antigravity (Advanced Agentic Coding)
-- Date: 2026-06-11
-- Description: Tạo SP và bảng liên quan cho quản lý tiêu chuẩn kiểm tra nguyên vật liệu Hưng Yên (_HY).
--              - STB_MaterialQcInspectionItem_HY
--              - usp_MaterialQcInspectionItem_ByMaterial_HY_get
--              - usp_MaterialQcInspectionItem_HY_iud
-- =============================================

USE SmartFactoryV2;
GO

BEGIN TRAN;
GO

PRINT 'Starting Hotfix: 08_FIX_MATERIAL_QC_INSPECTION_HUNG_YEN_SPS...';
GO

-- 1. TẠO BẢNG STB_MaterialQcInspectionItem_HY NẾU CHƯA TỒN TẠI
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'STB_MaterialQcInspectionItem_HY')
BEGIN
    CREATE TABLE [dbo].[STB_MaterialQcInspectionItem_HY] (
        [MaterialCode] VARCHAR(50) NOT NULL,
        [QcInspectionItemCode] VARCHAR(20) NOT NULL,
        [InspectionType] VARCHAR(10) NULL,
        [QcSpecDesc] NVARCHAR(MAX) NULL,
        [InspectionLevel] VARCHAR(20) NULL,
        [AQL] NUMERIC(10, 3) NULL,
        [SpecValue] NUMERIC(20, 5) NULL,
        [USL] NUMERIC(20, 5) NULL,
        [LSL] NUMERIC(20, 5) NULL,
        [UCL] NUMERIC(20, 5) NULL,
        [LCL] NUMERIC(20, 5) NULL,
        [TextSpecValue] NVARCHAR(200) NULL,
        [ItemInspectionPrior] INT NULL,
        [ItemReportPrior] INT NULL,
        [CreateDateTime] DATETIME NULL,
        [CreateUserID] VARCHAR(20) NULL,
        [ChangeDateTime] DATETIME NULL,
        [ChangeUserID] VARCHAR(20) NULL,
        [SampleQty] INT NULL,
        [TempSampleQty] BIGINT NULL,
        CONSTRAINT [PK_STB_MaterialQcInspectionItem_HY] PRIMARY KEY CLUSTERED ([MaterialCode] ASC, [QcInspectionItemCode] ASC)
    );
    PRINT 'Table STB_MaterialQcInspectionItem_HY created successfully.';
END
GO


-- 2. TẠO LẠI CÁC STORED PROCEDURES VỚI TÊN MỚI VÀ BẢNG MỚI
-- =========================================================
-- Stored Procedure: usp_MaterialQcInspectionItem_ByMaterial_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_MaterialQcInspectionItem_ByMaterial_HY_get')
    DROP PROCEDURE [dbo].[usp_MaterialQcInspectionItem_ByMaterial_HY_get];
GO

CREATE PROCEDURE [dbo].[usp_MaterialQcInspectionItem_ByMaterial_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '' ELSE @pMaterialCode END

	IF
		(
			SELECT 
					COUNT(*)
			FROM
					STB_MaterialMaster MM WITH (NOLOCK)
					LEFT OUTER JOIN STB_MaterialType MT WITH (NOLOCK)						ON (MT.MaterialTypeCode = MM.MaterialTypeCode)
					LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK)						ON (PG.ProductGroupCode = MM.ProductGroupCode)
			WHERE	
					MM.MaterialCode = @MaterialCode
		) < 1
	BEGIN
			RAISERROR('등록되지 않은 자재코드 입니다', 16, 1)
			RETURN
	END
	
	SELECT
			MIII.MaterialCode AS OldMaterialCode,
			MIII.MaterialCode,
			MM.MaterialName,
			MM.ProductGroupCode,
			QIG.QcInspectionGroupCode, 
			QIG.QcInspectionGroupName,
			QIG.QcInspectionGroupDesc,
			MIII.QcInspectionItemCode AS OldQcInspectionItemCode,
			MIII.QcInspectionItemCode,
			III.QcInspectionItemName,
			III.QcInspectionItemDesc,
			MIII.ItemInspectionPrior,
			MIII.ItemReportPrior,
			III.IsCanSkip,
			MIII.InspectionType,
			IT.InspectionTypeName,
			MIII.QcSpecDesc,
	        MIII.InspectionLevel,
	        MIII.AQL,
	        MIII.SpecValue,
	        MIII.USL,
	        MIII.LSL,
	        MIII.UCL,
	        MIII.LCL,
	        MIII.TextSpecValue,
	        MIII.CreateDateTime,
	        MIII.CreateUserID,
	        MIII.ChangeDateTime,
	        MIII.ChangeUserID,
			QIG.QcInspectionGroupDesc,
			MIII.SampleQty
	
	FROM
								  STB_MaterialQcInspectionItem_HY MIII WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH (NOLOCK)				ON (MM.MaterialCode = MIII.MaterialCode)
			LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK)				ON (PG.ProductGroupCode = MM.ProductGroupCode)
			LEFT OUTER JOIN STB_QcInspectionItem_HY III WITH (NOLOCK)			ON (III.QcInspectionItemCode = MIII.QcInspectionItemCode)
			LEFT OUTER JOIN STB_QcInspectionGroup_HY QIG WITH (NOLOCK)		ON (QIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
			LEFT OUTER JOIN VW_InspectionType IT									ON (IT.InspectionType = MIII.InspectionType)
	WHERE
			((@MaterialCode = '*') OR (MIII.MaterialCode = @MaterialCode))
	ORDER BY 
			III.ItemReportPrior,
			III.ItemInspectionPrior
			
	-- Model 정보를 보여주기 위한 Table
	SELECT 
			*
	FROM
			STB_MaterialMaster MM WITH (NOLOCK)
			LEFT OUTER JOIN STB_MaterialType MT WITH (NOLOCK)				ON (MT.MaterialTypeCode = MM.MaterialTypeCode)
			LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK)				ON (PG.ProductGroupCode = MM.ProductGroupCode)
	WHERE	
			MM.MaterialCode = @MaterialCode

END
GO

PRINT 'Procedure usp_MaterialQcInspectionItem_ByMaterial_HY_get created successfully.';
GO


-- =========================================================
-- Stored Procedure: usp_MaterialQcInspectionItem_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_MaterialQcInspectionItem_HY_iud')
    DROP PROCEDURE [dbo].[usp_MaterialQcInspectionItem_HY_iud];
GO

CREATE PROCEDURE [dbo].[usp_MaterialQcInspectionItem_HY_iud]
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
    DECLARE @AllTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  DECLARE @OldMaterialCode VARCHAR(50)
  DECLARE @OldQcInspectionItemCode VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @QcInspectionItemCode VARCHAR(20)
  DECLARE @InspectionType VARCHAR(10)
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

  DECLARE @ItemInspectionPrior INT
  DECLARE @ItemReportPrior INT
  DECLARE @SampleQty INT
	

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialQcInspectionItem_HY',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			
			-- Process ALL Table
            MERGE STB_MaterialQcInspectionItem_HY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
							    ELSE XMLData.OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN XMLData.OldQcInspectionItemCode IS NULL THEN XMLData.QcInspectionItemCode
							    ELSE XMLData.OldQcInspectionItemCode
							END AS OldQcInspectionItemCode,
							XMLData.MaterialCode,
							XMLData.QcInspectionItemCode,
							XMLData.InspectionType,
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
							@pProcessUserID AS ChangeUserID,

							XMLData.ItemInspectionPrior,
							XMLData.ItemReportPrior,
							XMLData.SampleQty
					FROM
							OPENXML(@idoc , @AllTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldQcInspectionItemCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										QcInspectionItemCode VARCHAR(20),
										InspectionType VARCHAR(10),
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
										ChangeUserID VARCHAR(20),
										ItemInspectionPrior INT,
									    ItemReportPrior INT,
										SampleQty  INT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.QcInspectionItemCode = SourceTable.QcInspectionItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = SourceTable.MaterialCode,
					QcInspectionItemCode = SourceTable.QcInspectionItemCode,
					InspectionType = SourceTable.InspectionType,
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
					ChangeUserID = SourceTable.ChangeUserID,
				    ItemInspectionPrior = SourceTable.ItemInspectionPrior,
					ItemReportPrior = SourceTable.ItemReportPrior,
					 SampleQty = SourceTable.SampleQty

			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						QcInspectionItemCode,
						InspectionType,
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
						ItemInspectionPrior,
						ItemReportPrior,
						SampleQty
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.QcInspectionItemCode,
							SourceTable.InspectionTYpe,
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
							SourceTable.CreateUserID,
							SourceTable.ItemInspectionPrior,
							SourceTable.ItemReportPrior,
							SourceTable.SampleQty
					);
																		
			-- Process Insert Table
            MERGE STB_MaterialQcInspectionItem_HY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
							    ELSE XMLData.OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN XMLData.OldQcInspectionItemCode IS NULL THEN XMLData.QcInspectionItemCode
							    ELSE XMLData.OldQcInspectionItemCode
							END AS OldQcInspectionItemCode,
							XMLData.MaterialCode,
							XMLData.QcInspectionItemCode,
							XMLData.InspectionType,
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
							@pProcessUserID AS ChangeUserID,
							XMLData.ItemInspectionPrior,
							XMLData.ItemReportPrior,
							XMLData.SampleQty
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldQcInspectionItemCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										QcInspectionItemCode VARCHAR(20),
										InspectionType VARCHAR(10),
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
										ChangeUserID VARCHAR(20),
										ItemInspectionPrior INT,
										ItemReportPrior INT,
										SampleQty INT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.QcInspectionItemCode = SourceTable.QcInspectionItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = SourceTable.MaterialCode,
					QcInspectionItemCode = SourceTable.QcInspectionItemCode,
					InspectionType = SourceTable.InspectionType,
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
					ChangeUserID = SourceTable.ChangeUserID,
					ItemInspectionPrior = SourceTable.ItemInspectionPrior,
					ItemReportPrior = SourceTable.ItemReportPrior,
					SampleQty= SourceTable.SampleQty
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						QcInspectionItemCode,
						InspectionType,
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
						ItemInspectionPrior,
						ItemReportPrior,
						SampleQty
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.QcInspectionItemCode,
							SourceTable.InspectionType,
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
							SourceTable.CreateUserID,
							SourceTable.ItemInspectionPrior,
							SourceTable.ItemReportPrior,
							SourceTable.SampleQty
					);


			-- Process Update Table
            MERGE STB_MaterialQcInspectionItem_HY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
							    ELSE XMLData.OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN XMLData.OldQcInspectionItemCode IS NULL THEN XMLData.QcInspectionItemCode
							    ELSE XMLData.OldQcInspectionItemCode
							END AS OldQcInspectionItemCode,
							XMLData.MaterialCode,
							XMLData.QcInspectionItemCode,
							XMLData.InspectionType,
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
							@pProcessUserID AS ChangeUserID,
							XMLData.ItemInspectionPrior,
							XMLData.ItemReportPrior,
							XMLData.SampleQty
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldQcInspectionItemCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										QcInspectionItemCode VARCHAR(20),
										InspectionType VARCHAR(10),
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
										ChangeUserID VARCHAR(20),
										ItemInspectionPrior INT,
										ItemReportPrior INT,
										SampleQty INT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.OldMaterialCode AND
					TargetTable.QcInspectionItemCode = SourceTable.OldQcInspectionItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = SourceTable.MaterialCode,
					QcInspectionItemCode = SourceTable.QcInspectionItemCode,
					InspectionType= SourceTable.InspectionType,
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
					ChangeUserID = SourceTable.ChangeUserID,
					ItemInspectionPrior = SourceTable.ItemInspectionPrior,
					ItemReportPrior = SourceTable.ItemReportPrior,
					SampleQty = SourceTable.SampleQty

			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						QcInspectionItemCode,
						InspectionType,
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
						ItemInspectionPrior,
						ItemReportPrior,
						SampleQty
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.QcInspectionItemCode,
							SourceTable.InspectionType,
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
							SourceTable.CreateUserID,
							SourceTable.ItemInspectionPrior,
							SourceTable.ItemReportPrior,
							SourceTable.SampleQty
					);


			-- Process Delete Table
            MERGE STB_MaterialQcInspectionItem_HY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
							    ELSE XMLData.OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN XMLData.OldQcInspectionItemCode IS NULL THEN XMLData.QcInspectionItemCode
							    ELSE XMLData.OldQcInspectionItemCode
							END AS OldQcInspectionItemCode,
							XMLData.MaterialCode,
							XMLData.QcInspectionItemCode,
							XMLData.InspectionType,
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
							@pProcessUserID AS ChangeUserID,
							XMLData.ItemInspectionPrior,
							XMLData.ItemReportPrior
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldQcInspectionItemCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										QcInspectionItemCode VARCHAR(20),
										InspectionType VARCHAR(10),
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
										ChangeUserID VARCHAR(20),
										ItemInspectionPrior INT,
										ItemReportPrior INT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
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
									XMLData.OldMaterialCode,
									XMLData.OldQcInspectionItemCode,
									XMLData.MaterialCode,
									XMLData.QcInspectionItemCode,
									XMLData.InspectionType,
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
									XMLData.ChangeUserID,
									XMLData.ItemInspectionPrior,
									XMLData.ItemReportPrior
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldQcInspectionItemCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 QcInspectionItemCode VARCHAR(20),
											 InspectionType VARCHAR(10),
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
											 ChangeUserID VARCHAR(20),											 
											 ItemInspectionPrior INT,
											 ItemReportPrior INT
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
										ELSE XMLData.OldMaterialCode
									END AS OldMaterialCode,
									CASE 
										WHEN XMLData.OldQcInspectionItemCode IS NULL THEN XMLData.QcInspectionItemCode
										ELSE XMLData.OldQcInspectionItemCode
									END AS OldQcInspectionItemCode,
									XMLData.MaterialCode,
									XMLData.QcInspectionItemCode,
									XMLData.InspectionType,
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
									XMLData.ChangeUserID,
									XMLData.ItemInspectionPrior,
									XMLData.ItemReportPrior
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldQcInspectionItemCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 QcInspectionItemCode VARCHAR(20),
											 InspectionType VARCHAR(10),
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
											 ChangeUserID VARCHAR(20),
											 ItemInspectionPrior INT,
											 ItemReportPrior INT
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
										ELSE XMLData.OldMaterialCode
									END AS OldMaterialCode,
									CASE 
										WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.QcInspectionItemCode
										ELSE XMLData.OldMaterialCode
									END AS OldQcInspectionItemCode,
									XMLData.MaterialCode,
									XMLData.QcInspectionItemCode,
									XMLData.InspectionType,
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
									XMLData.ChangeUserID,
									XMLData.ItemInspectionPrior INT,
									XMLData.ItemReportPrior INT
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldQcInspectionItemCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 QcInspectionItemCode VARCHAR(20),
											 InspectionType VARCHAR(10),
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
											 ChangeUserID VARCHAR(20),
											 ItemInspectionPrior INT,
											 ItemReportPrior INT
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialCode,
								 @OldQcInspectionItemCode,
								 @MaterialCode,
								 @QcInspectionItemCode,
								 @InspectionType,
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
								 @ChangeUserID,
								 @ItemInspectionPrior,
								 @ItemReportPrior,
								 @SampleQty


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialQcInspectionItem_HY WHERE MaterialCode = @MaterialCode AND QcInspectionItemCode = @QcInspectionItemCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialQcInspectionItem_HY', @MaterialCode OUTPUT
                    END

                    INSERT INTO STB_MaterialQcInspectionItem_HY
						(
						    MaterialCode,
						    QcInspectionItemCode,
							InspectionType,
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
						    ChangeUserID,
							ItemInspectionPrior,
							ItemReportPrior,
							SampleQty
						)
						VALUES
						(
						    @MaterialCode,
						    @QcInspectionItemCode,
							@InspectionType,
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
						    @ChangeUserID,
							@ItemInspectionPrior,
							@ItemReportPrior,
							@SampleQty
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MaterialQcInspectionItem_HY
						SET
						    MaterialCode =   CASE
						                WHEN @MaterialCode IS NOT NULL THEN @MaterialCode
						                ELSE MaterialCode
						            END,
						    QcInspectionItemCode =   CASE
						                WHEN @QcInspectionItemCode IS NOT NULL THEN @QcInspectionItemCode
						                ELSE QcInspectionItemCode
						            END,
						    InspectionType =   CASE
						                WHEN @InspectionType IS NOT NULL THEN @InspectionType
						                ELSE InspectionType
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
						    ChangeUserID = @pProcessUserID,
							ItemInspectionPrior = CASE
											WHEN @ItemInspectionPrior IS NOT NULL THEN @ItemInspectionPrior
											ELSE ItemInspectionPrior
										END,
							ItemReportPrior = CASE
											WHEN @ItemReportPrior IS NOT NULL THEN @ItemReportPrior
											ELSE ItemReportPrior
										END,
								SampleQty = CASE
											WHEN @SampleQty IS NOT NULL THEN @SampleQty
											ELSE SampleQty
										END
						WHERE
						    MaterialCode = @OldMaterialCode AND
						    QcInspectionItemCode = @OldQcInspectionItemCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialQcInspectionItem_HY
						WHERE
						    MaterialCode = @MaterialCode AND
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

PRINT 'Procedure usp_MaterialQcInspectionItem_HY_iud created successfully.';
GO


-- 3. CHẠY THỬ NGHIỆM SIMULATION TEST
PRINT 'Testing Stored Procedures...';
GO

-- Thêm tạm thời MaterialMaster test
IF NOT EXISTS (SELECT 1 FROM STB_MaterialMaster WHERE MaterialCode = 'MAT_HY_TEST')
BEGIN
    INSERT INTO STB_MaterialMaster (MaterialCode, MaterialName, MaterialTypeCode, ProductGroupCode)
    VALUES ('MAT_HY_TEST', 'Test Material HY', 'FERT', 'PG01');
END

-- Thêm tạm thời Group & Item QC HY test
IF NOT EXISTS (SELECT 1 FROM STB_QcInspectionGroup_HY WHERE QcInspectionGroupCode = 'GRP_HY_TEST')
BEGIN
    INSERT INTO STB_QcInspectionGroup_HY (QcInspectionGroupCode, QcInspectionGroupName, IsUsed)
    VALUES ('GRP_HY_TEST', 'Test Group HY', 1);
END

IF NOT EXISTS (SELECT 1 FROM STB_QcInspectionItem_HY WHERE QcInspectionItemCode = 'ITEM_HY_TEST')
BEGIN
    INSERT INTO STB_QcInspectionItem_HY (QcInspectionItemCode, QcInspectionGroupCode, QcInspectionItemName)
    VALUES ('ITEM_HY_TEST', 'GRP_HY_TEST', 'Test Item HY');
END
GO

DECLARE @Xml NVARCHAR(MAX) = N'
<DataSet>
    <MaterialQcInspectionItem>
        <MaterialCode>MAT_HY_TEST</MaterialCode>
        <QcInspectionItemCode>ITEM_HY_TEST</QcInspectionItemCode>
        <InspectionType>IQC</InspectionType>
        <QcSpecDesc>Spec Description</QcSpecDesc>
        <InspectionLevel>GII</InspectionLevel>
        <AQL>0.65</AQL>
        <SpecValue>10.5</SpecValue>
        <USL>11.0</USL>
        <LSL>10.0</LSL>
        <UCL>10.8</UCL>
        <LCL>10.2</LCL>
        <TextSpecValue>Test Spec Value</TextSpecValue>
        <ItemInspectionPrior>1</ItemInspectionPrior>
        <ItemReportPrior>1</ItemReportPrior>
        <SampleQty>5</SampleQty>
    </MaterialQcInspectionItem>
</DataSet>';

BEGIN TRY
    EXEC usp_MaterialQcInspectionItem_HY_iud
        @pProcessUserID = 'vinaadmin',
        @pProcessLanguage = 'vi-VN',
        @pProcessViewName = 'MaterialQcInspectionItem',
        @pXml = @Xml;

    IF EXISTS (SELECT 1 FROM STB_MaterialQcInspectionItem_HY WHERE MaterialCode = 'MAT_HY_TEST')
        PRINT 'Test usp_MaterialQcInspectionItem_HY_iud (INSERT): PASSED.';
    ELSE
        PRINT 'Test usp_MaterialQcInspectionItem_HY_iud (INSERT): FAILED!';
END TRY
BEGIN CATCH
    PRINT 'Test usp_MaterialQcInspectionItem_HY_iud (INSERT): FAILED with error: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
    IF EXISTS (SELECT 1 FROM STB_MaterialQcInspectionItem_HY WHERE MaterialCode = 'MAT_HY_TEST')
    BEGIN
        PRINT 'Running usp_MaterialQcInspectionItem_ByMaterial_HY_get...';
        EXEC usp_MaterialQcInspectionItem_ByMaterial_HY_get @pProcessUserID = 'vinaadmin', @pProcessLanguage = 'vi-VN', @pMaterialCode = 'MAT_HY_TEST';
        PRINT 'Test usp_MaterialQcInspectionItem_ByMaterial_HY_get: PASSED.';
    END
END TRY
BEGIN CATCH
    PRINT 'Test usp_MaterialQcInspectionItem_ByMaterial_HY_get: FAILED with error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Dọn dẹp dữ liệu test phụ thuộc trong transaction (trước rollback)
DELETE FROM STB_MaterialMaster WHERE MaterialCode = 'MAT_HY_TEST';
GO

-- 4. HỦY GIAO DỊCH ĐỂ ĐẢM BẢO AN TOÀN TRÊN PRODUCTION (DBA SẼ ĐỔI SANG COMMIT KHI CHẠY THỰC TẾ)
ROLLBACK TRAN;
PRINT 'Transaction ROLLBACK successfully. DB remains untouched.';
GO
