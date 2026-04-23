

/* exec usp_LotTrackingInfo_VVT2_get '','','VVT','2020-03-09','2020-03-16','','','',''    */

CREATE  PROCEDURE [dbo].[usp_VVT_SnapshotMaterials_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,	
	--@pLineCode VARCHAR(20) = NULL,	
	@pMaterialCode VARCHAR(30) = NULL
AS
	--DECLARE @FromDate DATETIME = @pFromDate
	--DECLARE @ToDate DATETIME = @pToDate
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) --+ ' 10:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 0, CONVERT(smalldatetime, @pToDate)), 120) --+ ' 10:30:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    
		
	--DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '%' ELSE @pLineCode     END	
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '%' ELSE @pMaterialCode END
	DECLARE	@MaterialCode1 VARCHAR(50) = @CompanyCode+'-'+@FromDate+'-'+@ToDate+'-'+@MaterialCode
BEGIN

--raiserror(@MaterialCode1,16,1);
--return;
	
SELECT top (1000000)
      replace(LotID,'-snap','') as LotID
      ,[CompanyCode]
      ,[WorkCenterCode]
      ,[MaterialWarehouseCode]
      ,[MaterialLocationCode]
      ,[MaterialCode]
	  ,(select MaterialName from [SmartFactoryV2].[dbo].[STB_MaterialMaster] where MaterialCode=mls.MaterialCode ) as MaterialName
      ,[MaterialStockAttribute]
      ,[StockAttrib1]
      ,[StockAttrib2]
      ,[StockAttrib3]
      ,[PackingID]
      ,[GRDate]
	  ,(select top 1  DecisionResult  from	STB_MaterialQcInfo where MaterialqcNo in (
			  select MaterialIqcNo from		 STB_MaterialDocDetail where MaterialDocDetailNo 
				in (select MaterialDocDetailNo from	STB_MaterialDocLotInfo  where LotID=replace(mls.LotID,'-snap','') )
		) ) as IQCResult
      ,[InitialQty]
      ,[CurrentQty]
      ,[PickingQty]
	  ,(select MaterialUnit from [SmartFactoryV2].[dbo].[STB_MaterialMaster] where MaterialCode=mls.MaterialCode ) as MaterialUnit
      ,[VendorLotNo]
      ,[LifeBasicDate]
      ,[ProductionDate]
      ,[EndOfLifeDate]
      ,[LotNo]
      ,[IsSplitLot]
      ,[BefMaterialLotNo] 
      ,[LotAttr01]
      ,[LotAttr02]
      ,[LotAttr03]
      ,[LotAttr04]
      ,[LotAttr05]
      ,[LotAttr06]
      ,[LotAttr07]
      ,[LotAttr08]
      ,[LotAttr09]
      ,[LotAttr10]
      ,[CreateDateTime]
      ,[CreateUserID]
      ,[ChangeDateTime]
      ,[ChangeUserID]
  FROM [SmartFactoryV2].[dbo].[STB_MaterialLotSnapshot]  mls
  where       LotID like '%-snap%' and MaterialWarehouseCode='ROH_VN_WH' and MaterialCode like @MaterialCode and  
			CONVERT(VARCHAR(10),ChangeDateTime,120) >= @FromDate and  CONVERT(VARCHAR(10),ChangeDateTime,120) <= @ToDate

END
	
--exec  usp_VVT_SnapshotMaterials_get '','','','2020-05-29'  ,'2020-05-29',''
  