

/* exec usp_LotTrackingInfo_VVT2_get '','','VVT','2020-03-09','2020-03-16','','','',''    */

CREATE  PROCEDURE [dbo].[usp_VVT_showOQCrefer_VVT_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	--@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	--@pRouteCode VARCHAR(20) = NULL,
	--@pLineCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL
	--@pMaterialCode VARCHAR(30) = NULL
AS
	--DECLARE @FromDate DATETIME = @pFromDate
	--DECLARE @ToDate DATETIME = @pToDate

	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:30:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    

	--DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	--DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	--DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN 
	
	if (@LotNo='*' or @LotNo='') 
		begin 
			select a.*,c.MaterialCode,c.MaterialName 
			from VVT_OQC_REFER  a  with(nolock)
			join STB_SetInfo  b  WITH(NOLOCK) on a.lotid=b.Barcode 
			join STB_MaterialMaster  c  WITH(NOLOCK) on b.MaterialCode = c.MaterialCode 
			where mergedate >= @FromDate and mergedate<=@ToDate and (finished is not null or finished<>'') 
		end 
	else 
		begin 
	 		select a.*,c.MaterialCode,c.MaterialName 
			from VVT_OQC_REFER  a  with(nolock)
			join STB_SetInfo  b  WITH(NOLOCK) on a.lotid=b.Barcode 
			join STB_MaterialMaster  c  WITH(NOLOCK) on b.MaterialCode = c.MaterialCode 
			where  (finished is not null or finished<>'')  and  mergeid=(select mergeid from VVT_OQC_REFER with(nolock) where lotid= @LotNo)
		end 

END

