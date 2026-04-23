-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-06-15
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트 출고이력 관리(커링고마 from web)
-- Modified:
-- =============================================
CREATE PROCEDURE usp_DoAddSparePartOutgoingHistoryForWeb
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCurlingGomaUniqueNo VARCHAR(20),
	@pLineCode VARCHAR(20)
AS
BEGIN
	DECLARE @IUD_FLAG VARCHAR(10) = 'INSERT'
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT

	DECLARE @CompanyCode VARCHAR(20) = 'VNT'
	DECLARE @WorkCenterCode VARCHAR(20) = 'VNT_F1'
	DECLARE @SPWarehouseCode VARCHAR(20) = 'SWH1'
	DECLARE @SPLocationCode VARCHAR(20) = 'SWHL1'
	DECLARE @SparePartIOTypeCode VARCHAR(20) = 'GI_REPARE'
	DECLARE @SparePartCode VARCHAR(20) = 'CurlingGoma'
	DECLARE @VendorCode VARCHAR(20) = NULL
	DECLARE @UnitPrice NUMERIC(20,5) = 0
	DECLARE @ProcessQty NUMERIC(20,5) = 1
	DECLARE @HistoryText NVARCHAR(100) = NULL

	DECLARE @LineCode VARCHAR(20) = @pLineCode

	EXEC SmartFramework.dbo.usp_GetSerialRule 
				@pTableName = 'STB_SparePartIOHistory',
				@pIsAutoKey = @IsAutoKey OUTPUT,
				@pIsLoopIUD = @IsLoopIUD OUTPUT,
				@pPrefixData = @PrefixString OUTPUT,
				@pSerialLen = @SerialLen OUTPUT

	Declare @SparePartIOHistoryNo VARCHAR(20)

	Declare @CurlingGomaUniqueNo VARCHAR(20) = @pCurlingGomaUniqueNo

	EXEC usp_DoSparePartOutHistory_iud  @pCompanyCode = @CompanyCode,
										@pWorkCenterCode = @WorkCenterCode,
										@pOldSparePartIOHistoryNo = @SparePartIOHistoryNo,
										@pSparePartIOHistoryNo = @SparePartIOHistoryNo,
										@pSPWarehouseCode = @SPWarehouseCode,
										@pSparePartCode = @SparePartCode,
										@pSPLocationCode = @SPLocationCode,
										@pSparePartIOTypeCode = @SparePartIOTypeCode,
										@pProcessQty = @ProcessQty,
										@pHistoryText = @HistoryText,
										@pBasicUnitPrice = 0,
										@pIUD_FLAG = @IUD_FLAG,
										@pProcessUserID = 'eai',
										@pPrefixString = @PrefixString,
										@pSerialLen = @SerialLen,
										@pCurlingGomaUniqueNo = @CurlingGomaUniqueNo,
										@pLineCode = @LineCode
END