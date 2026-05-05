


-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-01
-- Browsable : true
-- Group : 공용검사관리
-- Description:	공용검사항목정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommInspItem_iud]
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
	DECLARE @OldCommInspItemCode VARCHAR(20)
	DECLARE @CommInspItemCode VARCHAR(20)
	DECLARE @OldCommInspTypeCode VARCHAR(50)
	DECLARE @CommInspTypeCode VARCHAR(50)
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @LineCode VARCHAR(20)
	DECLARE @RouteCode VARCHAR(20)
	DECLARE @FacilityRouteCode VARCHAR(20)
	DECLARE @MachineCode VARCHAR(20)
	DECLARE @MoldNumber VARCHAR(50)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @CategoryName NVARCHAR(50)
	DECLARE @CommInspItemGroup1 NVARCHAR(100)
	DECLARE @CommInspItemGroup2 NVARCHAR(100)
	DECLARE @CommInspItemGroup3 NVARCHAR(100)
	DECLARE @CommInspItemName NVARCHAR(100)
	DECLARE @CommInspUnit VARCHAR(20)
	DECLARE @CommInspItemDesc NVARCHAR(200)
	DECLARE @CommInspInputType VARCHAR(1)
	DECLARE @CommInspSelectGroupCode VARCHAR(20)
	DECLARE @CommInspItemSpec VARCHAR(50)
	DECLARE @CommInspUpper VARCHAR(50)
	DECLARE @CommInspLower VARCHAR(50)
	
	DECLARE @IsIndividualSpec BIT
	
	DECLARE @ItemTargetQty INT
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)
	
	DECLARE @ItemImageFileID BIGINT
	DECLARE @FileName NVARCHAR(255)
	DECLARE @FileSize BIGINT
	DECLARE @FileData VARBINARY(MAX)
	
	DECLARE @CommInspItemDisplayIndex INT
	
	DECLARE @iDoc INT
	
	DECLARE @ProductGroupCode VARCHAR(20)

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CommInspItem',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
 BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldCommInspItemCode,
									CommInspItemCode,
									OldCommInspTypeCode,
									CommInspTypeCode,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									RouteCode,
									FacilityRouteCode,
									MachineCode,
									MoldNumber,
									MaterialCode,
									CategoryName,
									ProductGroupCode,
									CommInspItemDisplayIndex,
									CommInspItemGroup1,
									CommInspItemGroup2,
									CommInspItemGroup3,
									CommInspItemName,
									CommInspUnit,
									CommInspItemDesc,
									CommInspInputType,
									CommInspSelectGroupCode,
									CommInspItemSpec,
									CommInspUpper,
									CommInspLower,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData) as FileData,
									ItemImageFileID,
									IsIndividualSpec,
									ItemTargetQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCommInspItemCode VARCHAR(20),
											 CommInspItemCode VARCHAR(20),
											 OldCommInspTypeCode VARCHAR(50),
											 CommInspTypeCode VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 FacilityRouteCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 MaterialCode VARCHAR(50),
											 CategoryName NVARCHAR(50),
											 ProductGroupCode VARCHAR(20),
											 CommInspItemDisplayIndex INT,
											 CommInspItemGroup1 NVARCHAR(100),
											 CommInspItemGroup2 NVARCHAR(100),
											 CommInspItemGroup3 NVARCHAR(100),
											 CommInspItemName NVARCHAR(100),
											 CommInspUnit VARCHAR(20),
											 CommInspItemDesc NVARCHAR(200),
											 CommInspInputType VARCHAR(1),
											 CommInspSelectGroupCode VARCHAR(20),
											 CommInspItemSpec VARCHAR(50),
											 CommInspUpper VARCHAR(50),
											 CommInspLower VARCHAR(50),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 ItemImageFileID BIGINT,
											 IsIndividualSpec BIT,
											 ItemTargetQty INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCommInspItemCode IS NULL THEN CommInspItemCode
										ELSE OldCommInspItemCode
									END AS OldCommInspItemCode,
									CommInspItemCode,
									CASE 
										WHEN OldCommInspTypeCode IS NULL THEN CommInspTypeCode
										ELSE OldCommInspTypeCode
									END AS OldCommInspTypeCode,
									CommInspTypeCode,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									RouteCode,
									FacilityRouteCode,
									MachineCode,
									MoldNumber,
									MaterialCode,
									CategoryName,
									ProductGroupCode,
									CommInspItemDisplayIndex,
									CommInspItemGroup1,
									CommInspItemGroup2,
									CommInspItemGroup3,
									CommInspItemName,
									CommInspUnit,
									CommInspItemDesc,
									CommInspInputType,
									CommInspSelectGroupCode,
									CommInspItemSpec,
									CommInspUpper,
									CommInspLower,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData) as FileData,
									ItemImageFileID,
									IsIndividualSpec,
									ItemTargetQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCommInspItemCode VARCHAR(20),
											 CommInspItemCode VARCHAR(20),
											 OldCommInspTypeCode VARCHAR(50),
											 CommInspTypeCode VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 FacilityRouteCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 MaterialCode VARCHAR(50),
											 CategoryName NVARCHAR(50),
											 ProductGroupCode VARCHAR(20),
											 CommInspItemDisplayIndex INT,
											 CommInspItemGroup1 NVARCHAR(100),
											 CommInspItemGroup2 NVARCHAR(100),
											 CommInspItemGroup3 NVARCHAR(100),
											 CommInspItemName NVARCHAR(100),
											 CommInspUnit VARCHAR(20),
											 CommInspItemDesc NVARCHAR(200),
											 CommInspInputType VARCHAR(1),
											 CommInspSelectGroupCode VARCHAR(20),
											 CommInspItemSpec VARCHAR(50),
											 CommInspUpper VARCHAR(50),
											 CommInspLower VARCHAR(50),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 ItemImageFileID BIGINT,
											 IsIndividualSpec BIT,
											 ItemTargetQty INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCommInspItemCode IS NULL THEN CommInspItemCode
										ELSE OldCommInspItemCode
									END AS OldCommInspItemCode,
									CommInspItemCode,
									CASE 
										WHEN OldCommInspTypeCode IS NULL THEN CommInspTypeCode
										ELSE OldCommInspTypeCode
									END AS OldCommInspTypeCode,
									CommInspTypeCode,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									RouteCode,
									FacilityRouteCode,
									MachineCode,
									MoldNumber,
									MaterialCode,
									CategoryName,
									ProductGroupCode,
									CommInspItemDisplayIndex,
									CommInspItemGroup1,
									CommInspItemGroup2,
									CommInspItemGroup3,
									CommInspItemName,
									CommInspUnit,
									CommInspItemDesc,
									CommInspInputType,
									CommInspSelectGroupCode,
									CommInspItemSpec,
									CommInspUpper,
									CommInspLower,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData) as FileData,
									ItemImageFileID,
									IsIndividualSpec,
									ItemTargetQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCommInspItemCode VARCHAR(20),
											 CommInspItemCode VARCHAR(20),
											 OldCommInspTypeCode VARCHAR(50),
											 CommInspTypeCode VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 FacilityRouteCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 MaterialCode VARCHAR(50),
											 CategoryName NVARCHAR(50),
											 ProductGroupCode VARCHAR(20),
											 CommInspItemDisplayIndex INT,
											 CommInspItemGroup1 NVARCHAR(100),
											 CommInspItemGroup2 NVARCHAR(100),
											 CommInspItemGroup3 NVARCHAR(100),
											 CommInspItemName NVARCHAR(100),
											 CommInspUnit VARCHAR(20),
											 CommInspItemDesc NVARCHAR(200),
											 CommInspInputType VARCHAR(1),
											 CommInspSelectGroupCode VARCHAR(20),
											 CommInspItemSpec VARCHAR(50),
											 CommInspUpper VARCHAR(50),
											 CommInspLower VARCHAR(50),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 ItemImageFileID BIGINT,
											 IsIndividualSpec BIT,
											 ItemTargetQty INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCommInspItemCode,
								 @CommInspItemCode,
								 @OldCommInspTypeCode,
								 @CommInspTypeCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @LineCode,
								 @RouteCode,
								 @FacilityRouteCode,
								 @MachineCode,
								 @MoldNumber,
								 @MaterialCode,
								 @CategoryName,
								 @ProductGroupCode,
								 @CommInspItemDisplayIndex,
								 @CommInspItemGroup1,
								 @CommInspItemGroup2,
								 @CommInspItemGroup3,
								 @CommInspItemName,
								 @CommInspUnit,
								 @CommInspItemDesc,
								 @CommInspInputType,
								 @CommInspSelectGroupCode,
								 @CommInspItemSpec,
								 @CommInspUpper,
								 @CommInspLower,
								 @FileName,
								 @FileSize,
								 @FileData,
								 @ItemImageFileID,
								 @IsIndividualSpec,
								 @ItemTargetQty,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CommInspItem WHERE CommInspItemCode = @CommInspItemCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CommInspItemCode)
					END
					
					SET @OldCommInspTypeCode = @CommInspTypeCode
					SET @CommInspTypeCode = NULL
					
					SELECT
							@CommInspTypeCode = KeyValue
					FROM
							#SEQUENCE_TABLE
					WHERE
							UID_KEY = @OldCommInspTypeCode
					
					IF @CommInspTypeCode IS NULL
					BEGIN
						SET @CommInspTypeCode = @OldCommInspTypeCode
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CommInspItem', @CommInspItemCode OUTPUT
                    END
                    
                   
                    
                    EXEC SmartFramework.dbo.usp_DoSaveFile
						@pSystemName = 'STB_CommInspItem',
						@pFileContents = @FileData,
						@pFileName = @FileName,
						@pFileSize = @FileSize,
						@pUserID = @ProcessUserID,
						@pFileID = @ItemImageFileID OUTPUT

                    INSERT INTO STB_CommInspItem
						(
						    CommInspItemCode,
						    CommInspTypeCode,
						    CompanyCode,
						    WorkCenterCode,
							LineCode,
						    RouteCode,
						    FacilityRouteCode,
						    MachineCode,
						    MoldNumber,
						    MaterialCode,
						    CategoryName,
						    ProductGroupCode,
						    DisplayIndex,
						    CommInspItemGroup1,
						    CommInspItemGroup2,
						    CommInspItemGroup3,
						    CommInspItemName,
						    CommInspUnit,
						    CommInspItemDesc,
						    CommInspInputType,
						    CommInspSelectGroupCode,
						    CommInspItemSpec,
						    CommInspUpper,
						    CommInspLower,
						    ItemImageFileID,
						    IsIndividualSpec,
						    ItemTargetQty,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CommInspItemCode,
						    @CommInspTypeCode,
						    @CompanyCode,
						    @WorkCenterCode,
							ISNULL(@LineCode,''),
						    ISNULL(@RouteCode,''),
						    ISNULL(@FacilityRouteCode,''),
						    ISNULL(@MachineCode,''),
						    ISNULL(@MoldNumber,''),
						    ISNULL(@MaterialCode,''),
						    ISNULL(@CategoryName,''),
						    ISNULL(@ProductGroupCode,''),
						    @CommInspItemDisplayIndex,
						    @CommInspItemGroup1,
						    @CommInspItemGroup2,
						    @CommInspItemGroup3,
						    @CommInspItemName,
						    @CommInspUnit,
						    @CommInspItemDesc,
						    @CommInspInputType,
						    @CommInspSelectGroupCode,
						    @CommInspItemSpec,
						    @CommInspUpper,
						    @CommInspLower,
						    @ItemImageFileID,
						    ISNULL(@IsIndividualSpec,0),
						    @ItemTargetQty,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)
						
						

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					
					EXEC SmartFramework.dbo.usp_DoSaveFile
						@pSystemName = 'STB_CommInspItem',
						@pFileContents = @FileData,
						@pFileName = @FileName,
						@pFileSize = @FileSize,
						@pUserID = @ProcessUserID,
						@pFileID = @ItemImageFileID OUTPUT

					
					
                    UPDATE STB_CommInspItem
						SET
						    CommInspItemCode =   CASE
						                WHEN @CommInspItemCode IS NOT NULL THEN @CommInspItemCode
						                ELSE CommInspItemCode
						            END,
						    CommInspTypeCode =   CASE
						                WHEN @CommInspTypeCode IS NOT NULL THEN @CommInspTypeCode
						                ELSE CommInspTypeCode
						            END,
						    CompanyCode =   CASE
						                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						                ELSE CompanyCode
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
							LIneCode =   CASE
						                WHEN @LIneCode IS NOT NULL THEN @LIneCode
						                ELSE LIneCode
						            END,
						    RouteCode =   CASE
						                WHEN @RouteCode IS NOT NULL THEN @RouteCode
						                ELSE RouteCode
						            END,
						    MachineCode =   CASE
						                WHEN @MachineCode IS NOT NULL THEN @MachineCode
						                ELSE MachineCode
						            END,
						    FacilityRouteCode = CASE
										WHEN @FacilityRouteCode IS NOT NULL THEN @FacilityRouteCode
										ELSE FacilityRouteCode
									END,
						    MoldNumber =   CASE
						                WHEN @MoldNumber IS NOT NULL THEN @MoldNumber
						                ELSE MoldNumber
						            END,
						    MaterialCode =   CASE
						                WHEN @MaterialCode IS NOT NULL THEN @MaterialCode
						                ELSE MaterialCode
						            END,
						    DisplayIndex = CASE
										WHEN @CommInspItemDisplayIndex IS NOT NULL THEN @CommInspItemDisplayIndex
										ELSE DisplayIndex
									END,
						    CategoryName =   CASE
						                WHEN @CategoryName IS NOT NULL THEN @CategoryName
						                ELSE CategoryName
						            END,
						    ProductGroupCode = CASE
										WHEN @ProductGroupCode IS NOT NULL THEN @ProductGroupCode
										ELSE ProductGroupCode
									END,
						    CommInspItemGroup1 =   CASE
						                WHEN @CommInspItemGroup1 IS NOT NULL THEN @CommInspItemGroup1
						                ELSE CommInspItemGroup1
						            END,
						    CommInspItemGroup2 =   CASE
						                WHEN @CommInspItemGroup2 IS NOT NULL THEN @CommInspItemGroup2
						                ELSE CommInspItemGroup2
						            END,
						    CommInspItemGroup3 =   CASE
						                WHEN @CommInspItemGroup3 IS NOT NULL THEN @CommInspItemGroup3
						                ELSE CommInspItemGroup3
						            END,
						    CommInspItemName =   CASE
						                WHEN @CommInspItemName IS NOT NULL THEN @CommInspItemName
						                ELSE CommInspItemName
						            END,
						    CommInspUnit =   CASE
						                WHEN @CommInspUnit IS NOT NULL THEN @CommInspUnit
						                ELSE CommInspUnit
						            END,
						    CommInspItemDesc =   CASE
						                WHEN @CommInspItemDesc IS NOT NULL THEN @CommInspItemDesc
						                ELSE CommInspItemDesc
						            END,
						    CommInspInputType =   CASE
						                WHEN @CommInspInputType IS NOT NULL THEN @CommInspInputType
						                ELSE CommInspInputType
						            END,
						    --CommInspSelectGroupCode =   CASE
						    --            WHEN @CommInspSelectGroupCode IS NOT NULL THEN @CommInspSelectGroupCode
						    --            ELSE CommInspSelectGroupCode
						    --        END,
						    CommInspSelectGroupCode = @CommInspSelectGroupCode,
						    CommInspItemSpec =   CASE
						                WHEN @CommInspItemSpec IS NOT NULL THEN @CommInspItemSpec
						                ELSE CommInspItemSpec
						            END,
						    CommInspUpper =   CASE
						                WHEN @CommInspUpper IS NOT NULL THEN @CommInspUpper
						                ELSE CommInspUpper
						            END,
						    CommInspLower =   CASE
						                WHEN @CommInspLower IS NOT NULL THEN @CommInspLower
						                ELSE CommInspLower
						            END,
						    ItemImageFileID =   CASE
						                WHEN @ItemImageFileID IS NOT NULL THEN @ItemImageFileID
						                ELSE ItemImageFileID
						            END,
						    IsIndividualSpec = CASE
										WHEN @IsIndividualSpec IS NOT NULL THEN @IsIndividualSpec
										ELSE IsIndividualSpec
									END,
						    ItemTargetQty =   CASE
						                WHEN @ItemTargetQty IS NOT NULL THEN @ItemTargetQty
						                ELSE ItemTargetQty
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
						    CommInspItemCode = @OldCommInspItemCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                
                    DELETE FROM STB_CommInspItem
						WHERE
						    CommInspItemCode = @CommInspItemCode
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



