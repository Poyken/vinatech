


-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-01
-- Browsable : true
-- Group : 공용검사관리
-- Description:	공용검사항목정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_BENDING_TAPPING_Delete]
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
    --DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    --DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
	DECLARE @OldLotNo  NVARCHAR(50)
	DECLARE @LotNo  NVARCHAR(50)
	DECLARE @CreateDate datetime 

 
	
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
       --         SELECT
       --                 'INSERT' AS IUD_FLAG,
							--		OldCommInspItemCode,
							--		CommInspItemCode,
							--		OldCommInspTypeCode,
							--		CommInspTypeCode,
							--		CompanyCode,
							--		WorkCenterCode,
							--		LineCode,
							--		RouteCode,
							--		FacilityRouteCode,
							--		MachineCode,
							--		MoldNumber,
							--		MaterialCode,
							--		CategoryName,
							--		ProductGroupCode,
							--		CommInspItemDisplayIndex,
							--		CommInspItemGroup1,
							--		CommInspItemGroup2,
							--		CommInspItemGroup3,
							--		CommInspItemName,
							--		CommInspUnit,
							--		CommInspItemDesc,
							--		CommInspInputType,
							--		CommInspSelectGroupCode,
							--		CommInspItemSpec,
							--		CommInspUpper,
							--		CommInspLower,
							--		[FileName],
							--		FileSize,
							--		dbo.fnBase64ToBinary(FileData) as FileData,
							--		ItemImageFileID,
							--		IsIndividualSpec,
							--		ItemTargetQty,
							--		CreateDateTime,
							--		CreateUserID,
							--		ChangeDateTime,
							--		ChangeUserID
							--FROM
							--		OPENXML(@idoc , @InsertTableName , 2)
							--        WITH  (
							--				 OldCommInspItemCode VARCHAR(20),
							--				 CommInspItemCode VARCHAR(20),
							--				 OldCommInspTypeCode VARCHAR(50),
							--				 CommInspTypeCode VARCHAR(50),
							--				 CompanyCode VARCHAR(20),
							--				 WorkCenterCode VARCHAR(20),
							--				 LineCode VARCHAR(20),
							--				 RouteCode VARCHAR(20),
							--				 FacilityRouteCode VARCHAR(20),
							--				 MachineCode VARCHAR(20),
							--				 MoldNumber VARCHAR(50),
							--				 MaterialCode VARCHAR(50),
							--				 CategoryName NVARCHAR(50),
							--				 ProductGroupCode VARCHAR(20),
							--				 CommInspItemDisplayIndex INT,
							--				 CommInspItemGroup1 NVARCHAR(100),
							--				 CommInspItemGroup2 NVARCHAR(100),
							--				 CommInspItemGroup3 NVARCHAR(100),
							--				 CommInspItemName NVARCHAR(100),
							--				 CommInspUnit VARCHAR(20),
							--				 CommInspItemDesc NVARCHAR(200),
							--				 CommInspInputType VARCHAR(1),
							--				 CommInspSelectGroupCode VARCHAR(20),
							--				 CommInspItemSpec VARCHAR(50),
							--				 CommInspUpper VARCHAR(50),
							--				 CommInspLower VARCHAR(50),
							--				 [FileName] NVARCHAR(255),
							--				 FileSize BIGINT,
							--				 FileData VARCHAR(MAX),
							--				 ItemImageFileID BIGINT,
							--				 IsIndividualSpec BIT,
							--				 ItemTargetQty INT,
							--				 CreateDateTime DATETIMEOFFSET,
							--				 CreateUserID VARCHAR(20),
							--				 ChangeDateTime DATETIMEOFFSET,
							--				 ChangeUserID VARCHAR(20)
							--				)
							--UNION ALL
							--SELECT
							--		'UPDATE' AS IUD_FLAG,
							--		CASE 
							--			WHEN OldCommInspItemCode IS NULL THEN CommInspItemCode
							--			ELSE OldCommInspItemCode
							--		END AS OldCommInspItemCode,
							--		CommInspItemCode,
							--		CASE 
							--			WHEN OldCommInspTypeCode IS NULL THEN CommInspTypeCode
							--			ELSE OldCommInspTypeCode
							--		END AS OldCommInspTypeCode,
							--		CommInspTypeCode,
							--		CompanyCode,
							--		WorkCenterCode,
							--		LineCode,
							--		RouteCode,
							--		FacilityRouteCode,
							--		MachineCode,
							--		MoldNumber,
							--		MaterialCode,
							--		CategoryName,
							--		ProductGroupCode,
							--		CommInspItemDisplayIndex,
							--		CommInspItemGroup1,
							--		CommInspItemGroup2,
							--		CommInspItemGroup3,
							--		CommInspItemName,
							--		CommInspUnit,
							--		CommInspItemDesc,
							--		CommInspInputType,
							--		CommInspSelectGroupCode,
							--		CommInspItemSpec,
							--		CommInspUpper,
							--		CommInspLower,
							--		[FileName],
							--		FileSize,
							--		dbo.fnBase64ToBinary(FileData) as FileData,
							--		ItemImageFileID,
							--		IsIndividualSpec,
							--		ItemTargetQty,
							--		CreateDateTime,
							--		CreateUserID,
							--		ChangeDateTime,
							--		ChangeUserID
							--FROM
							--		OPENXML(@idoc , @UpdateTableName , 2)
							--        WITH  (
							--				 OldCommInspItemCode VARCHAR(20),
							--				 CommInspItemCode VARCHAR(20),
							--				 OldCommInspTypeCode VARCHAR(50),
							--				 CommInspTypeCode VARCHAR(50),
							--				 CompanyCode VARCHAR(20),
							--				 WorkCenterCode VARCHAR(20),
							--				 LineCode VARCHAR(20),
							--				 RouteCode VARCHAR(20),
							--				 FacilityRouteCode VARCHAR(20),
							--				 MachineCode VARCHAR(20),
							--				 MoldNumber VARCHAR(50),
							--				 MaterialCode VARCHAR(50),
							--				 CategoryName NVARCHAR(50),
							--				 ProductGroupCode VARCHAR(20),
							--				 CommInspItemDisplayIndex INT,
							--				 CommInspItemGroup1 NVARCHAR(100),
							--				 CommInspItemGroup2 NVARCHAR(100),
							--				 CommInspItemGroup3 NVARCHAR(100),
							--				 CommInspItemName NVARCHAR(100),
							--				 CommInspUnit VARCHAR(20),
							--				 CommInspItemDesc NVARCHAR(200),
							--				 CommInspInputType VARCHAR(1),
							--				 CommInspSelectGroupCode VARCHAR(20),
							--				 CommInspItemSpec VARCHAR(50),
							--				 CommInspUpper VARCHAR(50),
							--				 CommInspLower VARCHAR(50),
							--				 [FileName] NVARCHAR(255),
							--				 FileSize BIGINT,
							--				 FileData VARCHAR(MAX),
							--				 ItemImageFileID BIGINT,
							--				 IsIndividualSpec BIT,
							--				 ItemTargetQty INT,
							--				 CreateDateTime DATETIMEOFFSET,
							--				 CreateUserID VARCHAR(20),
							--				 ChangeDateTime DATETIMEOFFSET,
							--				 ChangeUserID VARCHAR(20)
							--				)
							--UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									LotNo,
									CreateDate
								
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
												LotNo  NVARCHAR(50),
												CreateDate datetime 
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @LotNo,
								 @CreateDate


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                   print '123'

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					
					   print '345'
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN

							--declare @test nvarchar(100)= @CreateDate
							--RAISERROR( @CreateDate ,16, 1)
							--return
					--set @CreateDate  = '2024-12-28 10:15:45.123';
					DECLARE @CreateDateStr VARCHAR(30)=@CreateDate

					---- Chuyển @CreateDate sang chuỗi với định dạng đầy đủ (bao gồm mili giây)
					--SET @CreateDateStr = CONVERT(VARCHAR(23), @CreateDate, 120);

					Declare @test varchar = @CreateDate


					--SELECT @CreateDateStr=  CONVERT(VARCHAR, @CreateDate, 109)  
					RAISERROR(@CreateDateStr, 16, 1);
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



