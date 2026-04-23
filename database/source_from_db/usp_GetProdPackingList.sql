
-- =============================================
-- Author: kilee
-- Create date: 2019-08-05
-- Browsable : true
-- Group : 생산관리 > 생산현황 > [B690] 일일포장현황
-- Description: 포장공정담당자가 요청한 화면
-- Modified: 일일포장실적을 보기위한 데이터조회
--                라인코드 전체조회시 오류개선 (2019.09.04)
--                From, TO, 주/야 구분 (2019.09.18)
-- =============================================

--  EXEC usp_GetProdPackingList '','','', '2020-08-01 00:00:00', '2020-08-10 23:59:59', '', '', '', 'VNT'

CREATE PROCEDURE [dbo].[usp_GetProdPackingList]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pBarcode VARCHAR(50) = NULL,
					@pFromDate DATE ,
					@pToDate DATE,
					@pPackingID VARCHAR(50) = NULL,                                  -- 추가사항 (2019.08.20)
					@pLineCode            VARCHAR(20) = NULL,                        -- 추가사항 (2019.08.28) 최덕렬과장
					@pShiftCode            VARCHAR(02) = NULL, 
					@pCompanyCode      VARCHAR(20) = NULL                        -- 2020.02.19 추가사항
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage
	DECLARE @LineCode            VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '*'  ELSE @pLineCode     END 

	DECLARE @BarCode            VARCHAR(20) = CASE WHEN ISNULL(@pBarCode,'') = ''  THEN '*'  ELSE @pBarCode       END 
	
	-- ......
	-- DECLARE @FromDate           DATE = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	-- DECLARE @ToDate              DATE =  CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:29:59'

	DECLARE @FromDate           DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	DECLARE @ToDate              DATETIME =  CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:29:59'

	DECLARE @PackingID           VARCHAR(20) = CASE WHEN ISNULL(@pPackingID,'') = '' THEN '*' ELSE @pPackingID     END 
	DECLARE @ShiftCode           VARCHAR(02) = CASE WHEN ISNULL(@pShiftCode,'') = '' THEN '*' ELSE @pShiftCode     END 
	DECLARE @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	
	
	-- 변경 (2019-08-20, kilee)
	SELECT
			SI.ControlNo,
			SI.DayPlanNo,
			SI.PONo,
			SI.Barcode,
			SI.MaterialCode,		
		    (SELECT MM.MaterialName FROM STB_MaterialMaster MM WHERE MM.MaterialCode = SI.MaterialCode )                                           AS MaterialName	,
			SI.ProdQty,
			--PRH.ProdQty                                                                                                                                                         AS ProdRouteQty.      -- 기존수량백업
			SML.CurrentQty                                                                                                                                                       AS CurrentQty,         -- 추가 (2019.08.28)
			(SELECT SUM(PRH.ProdQty) FROM STB_ProdRouteHist  PRH WHERE SI.ControlNo = PRH.ControlNo AND PRH.RouteCode in ( 'E-28', 'V-28') )  AS PackQty,             -- 추가 (2019.08.28)
			SML.PackingID,
			SML.CreateDateTime,
			SI.InputLineCode,
			(SELECT LineName  FROM STB_LineInfo LI WHERE LI.LineCode = SI.InputLineCode) AS LineName,
			CASE WHEN SML.MaterialLotNo = (SELECT MAX(MaterialLotNo) FROM STB_MaterialLotInfo WHERE PackingID = SML.PackingID) THEN '대표 Lot' ELSE '' END AS LabelLotNo
          , CASE WHEN SI.InputShiftCode  = 1 THEN '주간'  WHEN SI.InputShiftCode  = 2 THEN '야간'  WHEN SI.InputShiftCode  = 3 THEN '휴무' ELSE '기타'       END AS InputShiftCode      --추가
      FROM STB_MaterialLotInfo SML WITH(NOLOCK)			
	  LEFT OUTER JOIN  STB_SetInfo SI WITH(NOLOCK) 
	   ON SI.Barcode =  SML.LotNo
	WHERE 1=1			
	   AND (SML.CreateDateTime BetWeen @FromDate  AND  @ToDate)
	   AND (@BarCode = '*' OR SI.Barcode = @Barcode)
	   AND (@PackingID = '*' OR SML.PackingID = @PackingID) 	                                        
	   AND (@LineCode = '*' OR SI.InputLineCode = @LineCode)   
	   AND (@ShiftCode = '*' OR SI.InputShiftCode = @ShiftCode)
	   AND ((@CompanyCode = '*') OR (SML.CompanyCode = @CompanyCode)) 
     ORDER BY SML.CreateDateTime, SML.PackingID, SI.Barcode, SI.InputLineCode, SI.InputShiftCode 
END