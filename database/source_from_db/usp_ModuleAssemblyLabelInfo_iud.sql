
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-07-17
-- Browsable : true
-- Group : 모듈관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModuleAssemblyLabelInfo_iud]
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
  DECLARE @OldModuleAssemblyLotNo VARCHAR(20)
  DECLARE @ModuleAssemblyLotNo VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ModuleParentLotNo VARCHAR(20)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @DefectCode VARCHAR(20)
  DECLARE @IsPacking BIT

  DECLARE @PackingDateTime DATETIME
  DECLARE @IsShipment BIT
  DECLARE @ShipmentDateTime DATETIME


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ModuleAssemblyLabelInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        PRINT 'Batch was removed'
    END ELSE BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldModuleAssemblyLotNo,
									ModuleAssemblyLotNo,
									CreateDateTime,
									CreateUserID,
									ModuleParentLotNo,
									RouteCode,
									DefectCode,
									IsPacking,
									PackingDateTime,
									IsShipment,
									ShipmentDateTime
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldModuleAssemblyLotNo VARCHAR(20),
											 ModuleAssemblyLotNo VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ModuleParentLotNo VARCHAR(20),
											 RouteCode VARCHAR(20),
											 DefectCode VARCHAR(20),
											 IsPacking BIT,
											PackingDateTime DATETIMEOFFSET,
											IsShipment BIT,
											ShipmentDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldModuleAssemblyLotNo IS NULL THEN ModuleAssemblyLotNo
										ELSE OldModuleAssemblyLotNo
									END AS OldModuleAssemblyLotNo,
									ModuleAssemblyLotNo,
									CreateDateTime,
									CreateUserID,
									ModuleParentLotNo,
									RouteCode,
									DefectCode,
									IsPacking,
									PackingDateTime,
									IsShipment,
									ShipmentDateTime
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldModuleAssemblyLotNo VARCHAR(20),
											 ModuleAssemblyLotNo VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ModuleParentLotNo VARCHAR(20),
											 RouteCode VARCHAR(20),
											 DefectCode VARCHAR(20),
											 IsPacking BIT,
											PackingDateTime DATETIMEOFFSET,
											IsShipment BIT,
											ShipmentDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldModuleAssemblyLotNo IS NULL THEN ModuleAssemblyLotNo
										ELSE OldModuleAssemblyLotNo
									END AS OldModuleAssemblyLotNo,
									ModuleAssemblyLotNo,
									CreateDateTime,
									CreateUserID,
									ModuleParentLotNo,
									RouteCode,
									DefectCode,
									IsPacking,
									PackingDateTime,
									IsShipment,
									ShipmentDateTime
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldModuleAssemblyLotNo VARCHAR(20),
											 ModuleAssemblyLotNo VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ModuleParentLotNo VARCHAR(20),
											 RouteCode VARCHAR(20),
											 DefectCode VARCHAR(20),
											 IsPacking BIT,
											PackingDateTime DATETIMEOFFSET,
											IsShipment BIT,
											ShipmentDateTime DATETIMEOFFSET
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldModuleAssemblyLotNo,
								 @ModuleAssemblyLotNo,
								 @CreateDateTime,
								 @CreateUserID,
								 @ModuleParentLotNo,
								 @RouteCode,
								 @DefectCode,
								 @IsPacking,
								 @PackingDateTime,
								 @IsShipment,
								 @ShipmentDateTime


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ModuleAssemblyLabelInfo WHERE ModuleAssemblyLotNo = @ModuleAssemblyLotNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ModuleAssemblyLotNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_ModuleAssemblyLabelInfo',@ModuleAssemblyLotNo OUTPUT
                    END

                    INSERT INTO STB_ModuleAssemblyLabelInfo
						(
						    ModuleAssemblyLotNo,
						    CreateDateTime,
						    CreateUserID,
						    ModuleParentLotNo,
						    RouteCode,
						    DefectCode,
							IsPacking,
							PackingDateTime,
							IsShipment,
							ShipmentDateTime
						)
						VALUES
						(
						    @ModuleAssemblyLotNo,
						    GETDATE(),
						    @pProcessUserID,
						    @ModuleParentLotNo,
						    @RouteCode,
						    @DefectCode,
							@IsPacking,
							@PackingDateTime,
							@IsShipment,
							@ShipmentDateTime
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ModuleAssemblyLabelInfo
						SET
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ModuleParentLotNo =   ISNULL(@ModuleParentLotNo,ModuleParentLotNo),
						    RouteCode =   ISNULL(@RouteCode,RouteCode),
						    DefectCode =   ISNULL(@DefectCode,DefectCode),
							IsPacking = ISNULL(@IsPacking, IsPacking),
							PackingDateTime = CASE WHEN @IsPacking = CONVERT(BIT, 1) THEN GETDATE() ELSE NULL END,
							IsShipment = ISNULL(@IsShipment, IsShipment),
							ShipmentDateTime = CASE WHEN @IsShipment = CONVERT(BIT, 1) THEN GETDATE() ELSE NULL END
						WHERE
						    ModuleAssemblyLotNo = @OldModuleAssemblyLotNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ModuleAssemblyLabelInfo
						WHERE
						    ModuleAssemblyLotNo = @OldModuleAssemblyLotNo
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
