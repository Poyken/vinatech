-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 자재관리
-- Description:	자재창고관리 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialWarehouse_iud]
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
  DECLARE @OldMaterialWarehouseCode VARCHAR(20)
  DECLARE @MaterialWarehouseCode VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @MaterialWarehouseName NVARCHAR(50)
  DECLARE @MaterialWarehouseNameL NVARCHAR(200)
  DECLARE @MaterialWarehouseDesc NVARCHAR(200)
  DECLARE @MaterialWarehouseDescL NVARCHAR(200)
  DECLARE @DefaultLocationCode VARCHAR(20)
  DECLARE @IsMes BIT
  DECLARE @IsUsed BIT
  DECLARE @IsUsedStock BIT
  DECLARE @ErpSL VARCHAR(50)
  DECLARE @RequestProductGroupCode VARCHAR(MAX)
  DECLARE @WHExtText01 NVARCHAR(MAX)
  DECLARE @WHExtText02 NVARCHAR(MAX)
  DECLARE @WHExtText03 NVARCHAR(MAX)
  DECLARE @WHExtText04 NVARCHAR(MAX)
  DECLARE @WHExtText05 NVARCHAR(MAX)
  DECLARE @IsAllowMixedPOPicking BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  Declare @IsRouteWarehouse BIT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialWarehouse',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    

        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									XMLData.OldMaterialWarehouseCode,
									XMLData.MaterialWarehouseCode,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.MaterialWarehouseName,
									XMLData.MaterialWarehouseNameL,
									XMLData.MaterialWarehouseDesc,
									XMLData.MaterialWarehouseDescL,
									XMLData.DefaultLocationCode,
									XMLData.RequestProductGroupCode,
									XMLData.IsUsed,
									XMLData.WHExtText01,
									XMLData.WHExtText02,
									XMLData.WHExtText03,
									XMLData.WHExtText04,
									XMLData.WHExtText05,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.IsRouteWarehouse
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialWarehouseCode VARCHAR(20),
											 MaterialWarehouseCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialWarehouseName NVARCHAR(50),
											 MaterialWarehouseNameL NVARCHAR(200),
											 MaterialWarehouseDesc NVARCHAR(200),
											 MaterialWarehouseDescL NVARCHAR(200),
											 DefaultLocationCode VARCHAR(20),
											 RequestProductGroupCode VARCHAR(MAX),
											 IsUsed BIT,
											 WHExtText01 NVARCHAR(MAX),
											 WHExtText02 NVARCHAR(MAX),
											 WHExtText03 NVARCHAR(MAX),
											 WHExtText04 NVARCHAR(MAX),
											 WHExtText05 NVARCHAR(MAX),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsRouteWarehouse BIT
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMaterialWarehouseCode IS NULL THEN XMLData.MaterialWarehouseCode
										ELSE XMLData.OldMaterialWarehouseCode
									END AS OldMaterialWarehouseCode,
									XMLData.MaterialWarehouseCode,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.MaterialWarehouseName,
									XMLData.MaterialWarehouseNameL,
									XMLData.MaterialWarehouseDesc,
									XMLData.MaterialWarehouseDescL,
									XMLData.DefaultLocationCode,
									XMLData.RequestProductGroupCode,
									XMLData.IsUsed,
									XMLData.WHExtText01,
									XMLData.WHExtText02,
									XMLData.WHExtText03,
									XMLData.WHExtText04,
									XMLData.WHExtText05,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.IsRouteWarehouse
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialWarehouseCode VARCHAR(20),
											 MaterialWarehouseCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialWarehouseName NVARCHAR(50),
											 MaterialWarehouseNameL NVARCHAR(200),
											 MaterialWarehouseDesc NVARCHAR(200),
											 MaterialWarehouseDescL NVARCHAR(200),
											 DefaultLocationCode VARCHAR(20),
											 RequestProductGroupCode VARCHAR(MAX),
											 IsUsed BIT,
											 WHExtText01 NVARCHAR(MAX),
											 WHExtText02 NVARCHAR(MAX),
											 WHExtText03 NVARCHAR(MAX),
											 WHExtText04 NVARCHAR(MAX),
											 WHExtText05 NVARCHAR(MAX),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsRouteWarehouse BIT
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMaterialWarehouseCode IS NULL THEN XMLData.MaterialWarehouseCode
										ELSE XMLData.OldMaterialWarehouseCode
									END AS OldMaterialWarehouseCode,
									XMLData.MaterialWarehouseCode,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.MaterialWarehouseName,
									XMLData.MaterialWarehouseNameL,
									XMLData.MaterialWarehouseDesc,
									XMLData.MaterialWarehouseDescL,
									XMLData.DefaultLocationCode,
									XMLData.RequestProductGroupCode,
									XMLData.IsUsed,
									XMLData.WHExtText01,
									XMLData.WHExtText02,
									XMLData.WHExtText03,
									XMLData.WHExtText04,
									XMLData.WHExtText05,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.IsRouteWarehouse
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialWarehouseCode VARCHAR(20),
											 MaterialWarehouseCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialWarehouseName NVARCHAR(50),
											 MaterialWarehouseNameL NVARCHAR(200),
											 MaterialWarehouseDesc NVARCHAR(200),
											 MaterialWarehouseDescL NVARCHAR(200),
											 DefaultLocationCode VARCHAR(20),
											 RequestProductGroupCode VARCHAR(MAX),
											 IsUsed BIT,
											 WHExtText01 NVARCHAR(MAX),
											 WHExtText02 NVARCHAR(MAX),
											 WHExtText03 NVARCHAR(MAX),
											 WHExtText04 NVARCHAR(MAX),
											 WHExtText05 NVARCHAR(MAX),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsRouteWarehouse BIT
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialWarehouseCode,
								 @MaterialWarehouseCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @MaterialWarehouseName,
								 @MaterialWarehouseNameL,
								 @MaterialWarehouseDesc,
								 @MaterialWarehouseDescL,
								 @DefaultLocationCode,
								 @RequestProductGroupCode,
								 @IsUsed,
								 @WHExtText01,
								 @WHExtText02,
								 @WHExtText03,
								 @WHExtText04,
								 @WHExtText05,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @IsRouteWarehouse


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialWarehouse WHERE MaterialWarehouseCode = @MaterialWarehouseCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialWarehouseCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialWarehouse', @MaterialWarehouseCode OUTPUT
                    END
                    
                    -- 임시SEQUENCE TABLE 사용버젼 : MASTER 처리
					INSERT INTO #SEQUENCE_TABLE
						(KeyValue, UID_KEY)
					VALUES
						(@MaterialWarehouseCode, @OldMaterialWarehouseCode)
					--  

                    INSERT INTO STB_MaterialWarehouse
						(
						    MaterialWarehouseCode,
						    CompanyCode,
						    WorkCenterCode,
						    MaterialWarehouseName,
						    MaterialWarehouseNameL,
						    MaterialWarehouseDesc,
						    MaterialWarehouseDescL,
						    DefaultLocationCode,
							RequestProductGroupCode,
						    IsUsed,
						    WHExtText01,
						    WHExtText02,
						    WHExtText03,
						    WHExtText04,
						    WHExtText05,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							IsRouteWarehouse
						)
						VALUES
						(
						    @MaterialWarehouseCode,
						    @CompanyCode,
						    @WorkCenterCode,
						    @MaterialWarehouseName,
						    @MaterialWarehouseNameL,
						    @MaterialWarehouseDesc,
						    @MaterialWarehouseDescL,
						    @DefaultLocationCode,
							@RequestProductGroupCode,
						    @IsUsed,
						    @WHExtText01,
						    @WHExtText02,
						    @WHExtText03,
						    @WHExtText04,
						    @WHExtText05,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@IsRouteWarehouse
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MaterialWarehouse
						SET
						    MaterialWarehouseCode =   CASE
						                WHEN @MaterialWarehouseCode IS NOT NULL THEN @MaterialWarehouseCode
						                ELSE MaterialWarehouseCode
						            END,
						    CompanyCode =   CASE
						                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						                ELSE CompanyCode
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						    MaterialWarehouseName =   CASE
						                WHEN @MaterialWarehouseName IS NOT NULL THEN @MaterialWarehouseName
						                ELSE MaterialWarehouseName
						            END,
						    MaterialWarehouseNameL =   CASE
						                WHEN @MaterialWarehouseNameL IS NOT NULL THEN @MaterialWarehouseNameL
						                ELSE MaterialWarehouseNameL
						            END,
						    MaterialWarehouseDesc =   CASE
						                WHEN @MaterialWarehouseDesc IS NOT NULL THEN @MaterialWarehouseDesc
						                ELSE MaterialWarehouseDesc
						            END,
						    MaterialWarehouseDescL =   CASE
						                WHEN @MaterialWarehouseDescL IS NOT NULL THEN @MaterialWarehouseDescL
						                ELSE MaterialWarehouseDescL
						            END,
						    DefaultLocationCode =   CASE
						                WHEN @DefaultLocationCode IS NOT NULL THEN @DefaultLocationCode
						                ELSE DefaultLocationCode
						            END,
							RequestProductGroupCode =   CASE
						                WHEN @RequestProductGroupCode IS NOT NULL THEN @RequestProductGroupCode
						                ELSE RequestProductGroupCode
						            END,
						    IsUsed =   CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
						            END,
						    WHExtText01 =   CASE
						                WHEN @WHExtText01 IS NOT NULL THEN @WHExtText01
						                ELSE WHExtText01
						            END,
						    WHExtText02 =   CASE
						                WHEN @WHExtText02 IS NOT NULL THEN @WHExtText02
						                ELSE WHExtText02
						            END,
						    WHExtText03 =   CASE
						                WHEN @WHExtText03 IS NOT NULL THEN @WHExtText03
						                ELSE WHExtText03
						            END,
						    WHExtText04 =   CASE
						                WHEN @WHExtText04 IS NOT NULL THEN @WHExtText04
						                ELSE WHExtText04
						            END,
						    WHExtText05 =   CASE
						                WHEN @WHExtText05 IS NOT NULL THEN @WHExtText05
						                ELSE WHExtText05
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
							IsRouteWarehouse = CASE WHEN @IsRouteWarehouse IS NOT NULL THEN @IsRouteWarehouse ELSE IsRouteWarehouse END
						WHERE
						    MaterialWarehouseCode = @OldMaterialWarehouseCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					
					DELETE FROM STB_MaterialLocation
					WHERE
							MaterialWarehouseCode = @MaterialWarehouseCode
					
                    DELETE FROM STB_MaterialWarehouse
						WHERE
						    MaterialWarehouseCode = @MaterialWarehouseCode
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
