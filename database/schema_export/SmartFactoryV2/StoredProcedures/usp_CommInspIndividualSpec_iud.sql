-- Procedure: usp_CommInspIndividualSpec_iud

-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommInspIndividualSpec_iud]
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

    -- Declare Columns Variable
  DECLARE @OldIndividualSpecNo VARCHAR(20)
  DECLARE @IndividualSpecNo VARCHAR(20)
  DECLARE @CommInspItemCode VARCHAR(50)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @MoldNumber VARCHAR(50)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @CategoryName NVARCHAR(50)
  DECLARE @CommInspItemSpec VARCHAR(50)
  DECLARE @CommInspItemDesc NVARCHAR(200)
  DECLARE @CommInspUpper VARCHAR(50)
  DECLARE @CommInspLower VARCHAR(50)
  DECLARE @ItemImageFileID BIGINT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @FacilityRouteCode VARCHAR(20)
  DECLARE @ProductGroupCode VARCHAR(20)
  DECLARE @CommInspUpperManually VARCHAR(50)
  DECLARE @CommInspLowerManually VARCHAR(50)
  DECLARE @ItemTargetQtyIndividual int
	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CommInspIndividualSpec',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CommInspIndividualSpec AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldIndividualSpecNo IS NULL THEN IndividualSpecNo
							    ELSE OldIndividualSpecNo
							END AS OldIndividualSpecNo,
							IndividualSpecNo,
							CommInspItemCode,
							CompanyCode,
							WorkCenterCode,
							LineCode,
							RouteCode,
							MachineCode,
							MoldNumber,
							MaterialCode,
							CategoryName,
							CommInspItemSpec,
							CommInspItemDesc,
							CommInspUpper,
							CommInspLower,
							ItemImageFileID,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							FacilityRouteCode,
							ProductGroupCode,
							CommInspUpperManually,
							CommInspLowerManually,
							ItemTargetQtyIndividual
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldIndividualSpecNo VARCHAR(20),
										IndividualSpecNo VARCHAR(20),
										CommInspItemCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LineCode VARCHAR(20),
										RouteCode VARCHAR(20),
										MachineCode VARCHAR(20),
										MoldNumber VARCHAR(50),
										MaterialCode VARCHAR(50),
										CategoryName NVARCHAR(50),
										CommInspItemSpec VARCHAR(50),
										CommInspItemDesc NVARCHAR(200),
										CommInspUpper VARCHAR(50),
										CommInspLower VARCHAR(50),
										ItemImageFileID BIGINT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										FacilityRouteCode VARCHAR(20),
										ProductGroupCode VARCHAR(20),
										CommInspUpperManually VARCHAR(50),
										CommInspLowerManually VARCHAR(50),
										ItemTargetQtyIndividual int
									) 
				) AS SourceTable
			ON
				(
					TargetTable.IndividualSpecNo = SourceTable.IndividualSpecNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					IndividualSpecNo = ISNULL(SourceTable.IndividualSpecNo,TargetTable.IndividualSpecNo),
					CommInspItemCode = ISNULL(SourceTable.CommInspItemCode,TargetTable.CommInspItemCode),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					MoldNumber = ISNULL(SourceTable.MoldNumber,TargetTable.MoldNumber),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					CategoryName = ISNULL(SourceTable.CategoryName,TargetTable.CategoryName),
					CommInspItemSpec = ISNULL(SourceTable.CommInspItemSpec,TargetTable.CommInspItemSpec),
					CommInspItemDesc = ISNULL(SourceTable.CommInspItemDesc,TargetTable.CommInspItemDesc),
					CommInspUpper = ISNULL(SourceTable.CommInspUpper,TargetTable.CommInspUpper),
					CommInspLower = ISNULL(SourceTable.CommInspLower,TargetTable.CommInspLower),
					ItemImageFileID = ISNULL(SourceTable.ItemImageFileID,TargetTable.ItemImageFileID),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					FacilityRouteCode = ISNULL(SourceTable.FacilityRouteCode,TargetTable.FacilityRouteCode),
					ProductGroupCode = ISNULL(SourceTable.ProductGroupCode,TargetTable.ProductGroupCode),
					CommInspUpperManually = ISNULL(SourceTable.CommInspUpperManually,TargetTable.CommInspUpperManually),
					CommInspLowerManually = ISNULL(SourceTable.CommInspLowerManually,TargetTable.CommInspLowerManually),
					ItemTargetQtyIndividual = ISNULL(SourceTable.ItemTargetQtyIndividual,TargetTable.ItemTargetQtyIndividual)
			WHEN NOT MATCHED THEN
				INSERT
					(
						IndividualSpecNo,
						CommInspItemCode,
						CompanyCode,
						WorkCenterCode,
						LineCode,
						RouteCode,
						MachineCode,
						MoldNumber,
						MaterialCode,
						CategoryName,
						CommInspItemSpec,
						CommInspItemDesc,
						CommInspUpper,
						CommInspLower,
						ItemImageFileID,
						CreateDateTime,
						CreateUserID,
						FacilityRouteCode,
						ProductGroupCode,
						CommInspUpperManually,
						CommInspLowerManually,
						ItemTargetQtyIndividual
					)
				VALUES
					(
							SourceTable.IndividualSpecNo,
							SourceTable.CommInspItemCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.LineCode,
							SourceTable.RouteCode,
							SourceTable.MachineCode,
							SourceTable.MoldNumber,
							SourceTable.MaterialCode,
							SourceTable.CategoryName,
							SourceTable.CommInspItemSpec,
							SourceTable.CommInspItemDesc,
							SourceTable.CommInspUpper,
							SourceTable.CommInspLower,
							SourceTable.ItemImageFileID,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.FacilityRouteCode,
							SourceTable.ProductGroupCode,
							SourceTable.CommInspUpperManually,
							SourceTable.CommInspLowerManually,
							SourceTable.ItemTargetQtyIndividual
					);


			-- Process Update Table
            MERGE STB_CommInspIndividualSpec AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldIndividualSpecNo IS NULL THEN IndividualSpecNo
							    ELSE OldIndividualSpecNo
							END AS OldIndividualSpecNo,
							IndividualSpecNo,
							CommInspItemCode,
							CompanyCode,
							WorkCenterCode,
							LineCode,
							RouteCode,
							MachineCode,
							MoldNumber,
							MaterialCode,
							CategoryName,
							CommInspItemSpec,
							CommInspItemDesc,
							CommInspUpper,
							CommInspLower,
							ItemImageFileID,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							FacilityRouteCode,
							ProductGroupCode,
							CommInspUpperManually,
							CommInspLowerManually,
							ItemTargetQtyIndividual
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldIndividualSpecNo VARCHAR(20),
										IndividualSpecNo VARCHAR(20),
										CommInspItemCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LineCode VARCHAR(20),
										RouteCode VARCHAR(20),
										MachineCode VARCHAR(20),
										MoldNumber VARCHAR(50),
										MaterialCode VARCHAR(50),
										CategoryName NVARCHAR(50),
										CommInspItemSpec VARCHAR(50),
										CommInspItemDesc NVARCHAR(200),
										CommInspUpper VARCHAR(50),
										CommInspLower VARCHAR(50),
										ItemImageFileID BIGINT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										FacilityRouteCode VARCHAR(20),
										ProductGroupCode VARCHAR(20),
										CommInspUpperManually VARCHAR(50),
										CommInspLowerManually VARCHAR(50),
										ItemTargetQtyIndividual int
									) 
				) AS SourceTable
			ON
				(
					TargetTable.IndividualSpecNo = SourceTable.OldIndividualSpecNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					IndividualSpecNo = ISNULL(SourceTable.IndividualSpecNo,TargetTable.IndividualSpecNo),
					CommInspItemCode = ISNULL(SourceTable.CommInspItemCode,TargetTable.CommInspItemCode),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					MoldNumber = ISNULL(SourceTable.MoldNumber,TargetTable.MoldNumber),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					CategoryName = ISNULL(SourceTable.CategoryName,TargetTable.CategoryName),
					CommInspItemSpec = ISNULL(SourceTable.CommInspItemSpec,TargetTable.CommInspItemSpec),
					CommInspItemDesc = ISNULL(SourceTable.CommInspItemDesc,TargetTable.CommInspItemDesc),
					CommInspUpper = ISNULL(SourceTable.CommInspUpper,TargetTable.CommInspUpper),
					CommInspLower = ISNULL(SourceTable.CommInspLower,TargetTable.CommInspLower),
					ItemImageFileID = ISNULL(SourceTable.ItemImageFileID,TargetTable.ItemImageFileID),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					FacilityRouteCode = ISNULL(SourceTable.FacilityRouteCode,TargetTable.FacilityRouteCode),
					ProductGroupCode = ISNULL(SourceTable.ProductGroupCode,TargetTable.ProductGroupCode),
					CommInspUpperManually = ISNULL(SourceTable.CommInspUpperManually,TargetTable.CommInspUpperManually),
					CommInspLowerManually = ISNULL(SourceTable.CommInspLowerManually,TargetTable.CommInspLowerManually),
					ItemTargetQtyIndividual=ISNULL(SourceTable.ItemTargetQtyIndividual,TargetTable.ItemTargetQtyIndividual)
			WHEN NOT MATCHED THEN
				INSERT
					(
						IndividualSpecNo,
						CommInspItemCode,
						CompanyCode,
						WorkCenterCode,
						LineCode,
						RouteCode,
						MachineCode,
						MoldNumber,
						MaterialCode,
						CategoryName,
						CommInspItemSpec,
						CommInspItemDesc,
						CommInspUpper,
						CommInspLower,
						ItemImageFileID,
						CreateDateTime,
						CreateUserID,
						FacilityRouteCode,
						ProductGroupCode,
						CommInspUpperManually,
						CommInspLowerManually,
						ItemTargetQtyIndividual
					)
				VALUES
					(
							SourceTable.IndividualSpecNo,
							SourceTable.CommInspItemCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.LineCode,
							SourceTable.RouteCode,
							SourceTable.MachineCode,
							SourceTable.MoldNumber,
							SourceTable.MaterialCode,
							SourceTable.CategoryName,
							SourceTable.CommInspItemSpec,
							SourceTable.CommInspItemDesc,
							SourceTable.CommInspUpper,
							SourceTable.CommInspLower,
							SourceTable.ItemImageFileID,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.FacilityRouteCode,
							SourceTable.ProductGroupCode,
							SourceTable.CommInspUpperManually,
							SourceTable.CommInspLowerManually,
							SourceTable.ItemTargetQtyIndividual
					);


			-- Process Delete Table
            MERGE STB_CommInspIndividualSpec AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldIndividualSpecNo IS NULL THEN IndividualSpecNo
							    ELSE OldIndividualSpecNo
							END AS OldIndividualSpecNo,
							IndividualSpecNo,
							CommInspItemCode,
							CompanyCode,
							WorkCenterCode,
							LineCode,
							RouteCode,
							MachineCode,
							MoldNumber,
							MaterialCode,
							CategoryName,
							CommInspItemSpec,
							CommInspItemDesc,
							CommInspUpper,
							CommInspLower,
							ItemImageFileID,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							FacilityRouteCode,
							ProductGroupCode,
							CommInspUpperManually,
							CommInspLowerManually,
							ItemTargetQtyIndividual
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldIndividualSpecNo VARCHAR(20),
										IndividualSpecNo VARCHAR(20),
										CommInspItemCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LineCode VARCHAR(20),
										RouteCode VARCHAR(20),
										MachineCode VARCHAR(20),
										MoldNumber VARCHAR(50),
										MaterialCode VARCHAR(50),
										CategoryName NVARCHAR(50),
										CommInspItemSpec VARCHAR(50),
										CommInspItemDesc NVARCHAR(200),
										CommInspUpper VARCHAR(50),
										CommInspLower VARCHAR(50),
										ItemImageFileID BIGINT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										FacilityRouteCode VARCHAR(20),
										ProductGroupCode VARCHAR(20),
										CommInspUpperManually VARCHAR(50),
										CommInspLowerManually VARCHAR(50),
										ItemTargetQtyIndividual int

									) 
				) AS SourceTable
			ON
				(
					TargetTable.IndividualSpecNo = SourceTable.IndividualSpecNo
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
									OldIndividualSpecNo,
									IndividualSpecNo,
									CommInspItemCode,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									RouteCode,
									MachineCode,
									MoldNumber,
									MaterialCode,
									CategoryName,
									CommInspItemSpec,
									CommInspItemDesc,
									CommInspUpper,
									CommInspLower,
									ItemImageFileID,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									FacilityRouteCode,
									ProductGroupCode,
									CommInspUpperManually,
									CommInspLowerManually,
									ItemTargetQtyIndividual
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldIndividualSpecNo VARCHAR(20),
											 IndividualSpecNo VARCHAR(20),
											 CommInspItemCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 MaterialCode VARCHAR(50),
											 CategoryName NVARCHAR(50),
											 CommInspItemSpec VARCHAR(50),
											 CommInspItemDesc NVARCHAR(200),
											 CommInspUpper VARCHAR(50),
											 CommInspLower VARCHAR(50),
											 ItemImageFileID BIGINT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 FacilityRouteCode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 CommInspUpperManually VARCHAR(50),
											 CommInspLowerManually VARCHAR(50),
											 ItemTargetQtyIndividual int
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldIndividualSpecNo IS NULL THEN IndividualSpecNo
										ELSE OldIndividualSpecNo
									END AS OldIndividualSpecNo,
									IndividualSpecNo,
									CommInspItemCode,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									RouteCode,
									MachineCode,
									MoldNumber,
									MaterialCode,
									CategoryName,
									CommInspItemSpec,
									CommInspItemDesc,
									CommInspUpper,
									CommInspLower,
									ItemImageFileID,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									FacilityRouteCode,
									ProductGroupCode,
									CommInspUpperManually,
									CommInspLowerManually,
									ItemTargetQtyIndividual
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldIndividualSpecNo VARCHAR(20),
											 IndividualSpecNo VARCHAR(20),
											 CommInspItemCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 MaterialCode VARCHAR(50),
											 CategoryName NVARCHAR(50),
											 CommInspItemSpec VARCHAR(50),
											 CommInspItemDesc NVARCHAR(200),
											 CommInspUpper VARCHAR(50),
											 CommInspLower VARCHAR(50),
											 ItemImageFileID BIGINT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 FacilityRouteCode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 CommInspUpperManually VARCHAR(50),
											 CommInspLowerManually VARCHAR(50),
											 ItemTargetQtyIndividual int
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldIndividualSpecNo IS NULL THEN IndividualSpecNo
										ELSE OldIndividualSpecNo
									END AS OldIndividualSpecNo,
									IndividualSpecNo,
									CommInspItemCode,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									RouteCode,
									MachineCode,
									MoldNumber,
									MaterialCode,
									CategoryName,
									CommInspItemSpec,
									CommInspItemDesc,
									CommInspUpper,
									CommInspLower,
									ItemImageFileID,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									FacilityRouteCode,
									ProductGroupCode,
									CommInspUpperManually,
									CommInspLowerManually,
									ItemTargetQtyIndividual
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldIndividualSpecNo VARCHAR(20),
											 IndividualSpecNo VARCHAR(20),
											 CommInspItemCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 MaterialCode VARCHAR(50),
											 CategoryName NVARCHAR(50),
											 CommInspItemSpec VARCHAR(50),
											 CommInspItemDesc NVARCHAR(200),
											 CommInspUpper VARCHAR(50),
											 CommInspLower VARCHAR(50),
											 ItemImageFileID BIGINT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 FacilityRouteCode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 CommInspUpperManually VARCHAR(50),
											CommInspLowerManually VARCHAR(50),
											ItemTargetQtyIndividual int
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldIndividualSpecNo,
								 @IndividualSpecNo,
								 @CommInspItemCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @LineCode,
								 @RouteCode,
								 @MachineCode,
								 @MoldNumber,
								 @MaterialCode,
								 @CategoryName,
								 @CommInspItemSpec,
								 @CommInspItemDesc,
								 @CommInspUpper,
								 @CommInspLower,
								 @ItemImageFileID,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @FacilityRouteCode,
								 @ProductGroupCode,
								 @CommInspUpperManually,
								 @CommInspLowerManually,
								 @ItemTargetQtyIndividual

                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CommInspIndividualSpec WHERE IndividualSpecNo = @IndividualSpecNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @IndividualSpecNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CommInspIndividualSpec',@IndividualSpecNo OUTPUT
                    END

                    INSERT INTO STB_CommInspIndividualSpec
						(
						    IndividualSpecNo,
						    CommInspItemCode,
						    CompanyCode,
						    WorkCenterCode,
						    LineCode,
						    RouteCode,
						    MachineCode,
						    MoldNumber,
						    MaterialCode,
						    CategoryName,
						    CommInspItemSpec,
						    CommInspItemDesc,
						    CommInspUpper,
						    CommInspLower,
						    ItemImageFileID,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    FacilityRouteCode,
						    ProductGroupCode,
							ItemTargetQtyIndividual
						)
						VALUES
						(
						    @IndividualSpecNo,
						    @CommInspItemCode,
						    @CompanyCode,
						    @WorkCenterCode,
						    ISNULL(@LineCode,''),
						    ISNULL(@RouteCode,''),
						    ISNULL(@MachineCode,''),
						    ISNULL(@MoldNumber,''),
						    ISNULL(@MaterialCode,''),
						    ISNULL(@CategoryName,''),
						    @CommInspItemSpec,
						    @CommInspItemDesc,
						    @CommInspUpper,
						    @CommInspLower,
						    @ItemImageFileID,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    ISNULL(@FacilityRouteCode,''),
						    ISNULL(@ProductGroupCode,''),
							@ItemTargetQtyIndividual
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_CommInspIndividualSpec
						SET
						    IndividualSpecNo =   ISNULL(@IndividualSpecNo,IndividualSpecNo),
						    CommInspItemCode =   ISNULL(@CommInspItemCode,CommInspItemCode),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    LineCode =   ISNULL(@LineCode,LineCode),
						    RouteCode =   ISNULL(@RouteCode,RouteCode),
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    MoldNumber =   ISNULL(@MoldNumber,MoldNumber),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    CategoryName =   ISNULL(@CategoryName,CategoryName),
						    CommInspItemSpec =   ISNULL(@CommInspItemSpec,CommInspItemSpec),
						    CommInspItemDesc =   ISNULL(@CommInspItemDesc,CommInspItemDesc),
						    CommInspUpper =   ISNULL(@CommInspUpper,CommInspUpper),
						    CommInspLower =   ISNULL(@CommInspLower,CommInspLower),
						    ItemImageFileID =   ISNULL(@ItemImageFileID,ItemImageFileID),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    FacilityRouteCode =   ISNULL(@FacilityRouteCode,FacilityRouteCode),
						    ProductGroupCode =   ISNULL(@ProductGroupCode,ProductGroupCode),
							CommInspUpperManually =   ISNULL(@CommInspUpperManually,CommInspUpperManually),
						    CommInspLowerManually =   ISNULL(@CommInspLowerManually,CommInspLowerManually),
							ItemTargetQtyIndividual  =   ISNULL(@ItemTargetQtyIndividual,ItemTargetQtyIndividual)
						WHERE
						    IndividualSpecNo = @OldIndividualSpecNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CommInspIndividualSpec
						WHERE
						    IndividualSpecNo = @OldIndividualSpecNo
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

