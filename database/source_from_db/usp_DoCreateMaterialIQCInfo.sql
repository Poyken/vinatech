
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-16
-- Browsable : true
-- Group : 품질관리
-- Description:	입하 시 수입검사 정보를 등록합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateMaterialIQCInfo]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialDocNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @MaterialDocNo VARCHAR(50) = @pMaterialDocNo -- 
	
	DECLARE @ERROR_MSG NVARCHAR(MAX)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
	DECLARE @MaxKeyField VARCHAR(20)

	-- Declare Columns Variable
	--DECLARE @MaterialIqcNo VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @InspectionType VARCHAR(20)
	DECLARE @MaterialStockAttribute VARCHAR(20)
	DECLARE @StockAttrib1 VARCHAR(20)
	DECLARE @MaterialDocDetailNo VARCHAR(20)
	DECLARE @VendorLotNo VARCHAR(100)

	DECLARE @iDoc INT

    --EXEC SmartFramework.dbo.usp_GetSerialRule 
	--		@pTableName = 'STB_MaterialIqcInfo',
	--		@pIsAutoKey = @IsAutoKey OUTPUT,
	--		@pIsLoopIUD = @IsLoopIUD OUTPUT,
	--		@pPrefixData = @PrefixString OUTPUT,
	--		@pSerialLen = @SerialLen OUTPUT
	
	declare @companycode VARCHAR(10)='';
	select @companycode = CompanyCode 
	from STB_UserInfo with(nolock) 
	where userid=@pProcessUserID;

				
    BEGIN
        BEGIN TRY
		    
		    DECLARE SourceData CURSOR FOR
                SELECT
						MDD.MaterialCode,
						MDD.InspectionType,
						MDD.MaterialStockAttribute,
						MDD.StockAttrib1,
						MDD.VendorLotNo		-- 업체 Lot 추가
				FROM
						STB_MaterialDocDetail MDD
				WHERE
						MDD.MaterialDocNo = @MaterialDocNo --AND
						--MDD.InspectionType NOT IN ('NONE') 무검사품의 경우도 수입검사의뢰를 생성하도록 수정 2019.07.01 
				GROUP BY
						MDD.MaterialCode,
						MDD.InspectionType,
						MDD.MaterialStockAttribute,
						MDD.StockAttrib1,
						MDD.VendorLotNo		-- 업체 Lot 추가
            OPEN SourceData

            WHILE 1 = 1 BEGIN
			
                FETCH NEXT FROM SourceData INTO
								 @MaterialCode,
								 @InspectionType,
								 @MaterialStockAttribute,
								 @StockAttrib1,
								 @VendorLotNo

				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				--PRINT 'EXEC usp_DoMakeMaterialIQCInfoList ' + @MaterialDocNo + '/' + @MaterialCode + '/' + @InspectionType + '/' + @MaterialStockAttribute + '/' + @StockAttrib1
				-- Make 프로시저 호출				
				EXEC usp_DoMakeMaterialIQCInfoList @ProcessUserID, @ProcessLanguage,@MaterialDocNo,@MaterialCode, @InspectionType, @MaterialStockAttribute, @StockAttrib1, @VendorLotNo
            END

			DECLARE @AutoSuccess VARCHAR(10) = dbo.fnGetProcessRule('IQC_AUTO_SUCCESS_VENDORLOT','N')

			Declare @isHyCap INT = 0; --add by Mr.Tung 2023-Jan-06 , for auto PASS the HY-CAP materials, from Korea to Vietnam			
			select @isHyCap= count(*) from STB_MaterialMaster with(nolock) 
									where MaterialCode=@MaterialCode
									and (MaterialName like 'HY-CAP %')
									and @companycode='VVT';

			IF @AutoSuccess = 'Y' or @isHyCap>0 BEGIN
					EXEC usp_DoSuccessMaterialQcInfoForVendorLot	@pProcessUserID = @ProcessUserID,
																	@pProcessLanguage = @ProcessLanguage,
																	@pMaterialDocNo = @MaterialDocNo
			END
        END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;

    END
END
