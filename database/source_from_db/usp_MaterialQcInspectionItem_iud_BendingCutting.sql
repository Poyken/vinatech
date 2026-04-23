-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-15
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE usp_MaterialQcInspectionItem_iud_BendingCutting
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

  DECLARE @ItemInspectionPrior INT   --2016-08-07 LDS
  DECLARE @ItemReportPrior INT
  DECLARE @SampleQty INT
	


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialQcInspectionItem_BendingCutting',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT



    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			
			-- Process ALL Table
            MERGE STB_MaterialQcInspectionItem_BendingCutting AS TargetTable
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

							XMLData.ItemInspectionPrior,   --2016-08-07 LDS
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
										ItemInspectionPrior INT,   --2016-08-07 LDS
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
				    ItemInspectionPrior = SourceTable.ItemInspectionPrior,   --2016-08-07 LDS
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
						ItemInspectionPrior,   --2016-08-07 LDS
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
							SourceTable.ItemInspectionPrior,   --2016-08-07 LDS
							SourceTable.ItemReportPrior,
							SourceTable.SampleQty
					);
																		
			-- Process Insert Table
            MERGE STB_MaterialQcInspectionItem_BendingCutting AS TargetTable
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
							XMLData.ItemInspectionPrior,   --2016-08-07 LDS
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
            MERGE STB_MaterialQcInspectionItem_BendingCutting AS TargetTable
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
            MERGE STB_MaterialQcInspectionItem_BendingCutting AS TargetTable
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
									XMLData.ItemInspectionPrior,   --2016-08-07 LDS
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
											 ItemInspectionPrior INT,   --2016-08-07 LDS
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
									XMLData.ItemInspectionPrior,   --2016-08-07 LDS
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
											 ItemInspectionPrior INT,   --2016-08-07 LDS
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
									XMLData.ItemInspectionPrior INT,   --2016-08-07 LDS
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
											 ItemInspectionPrior INT,   --2016-08-07 LDS
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
								 @ItemInspectionPrior,   --2016-08-07 LDS
								 @ItemReportPrior,
								 @SampleQty

				
			


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialQcInspectionItem_BendingCutting WHERE MaterialCode = @MaterialCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialQcInspectionItem_BendingCutting', @MaterialCode OUTPUT
                    END

                    INSERT INTO STB_MaterialQcInspectionItem_BendingCutting
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
							ItemInspectionPrior,   --2016-08-07 LDS
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
							@ItemInspectionPrior,   --2016-08-07 LDS
							@ItemReportPrior,
							@SampleQty
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					

                    UPDATE STB_MaterialQcInspectionItem_BendingCutting
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
											ELSE ItemInspectionPrior   --2016-08-07 LDS
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
                    DELETE FROM STB_MaterialQcInspectionItem_BendingCutting
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

