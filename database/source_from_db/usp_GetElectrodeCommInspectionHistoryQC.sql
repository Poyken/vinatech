
-- =============================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2020-09-18
-- Browsable : true
-- Group : 품질관리
-- Description:	[C425] 전극공정검사이력조회
-- Modified:  2019-11-09  바코드 추가
--            2020-09-14 
--            2020-10-06 일괄업로드 데이터의 바코드 표시를 위해 변경 By Jackaroe #201006
-- ===================================================================================================================
CREATE PROCEDURE [dbo].[usp_GetElectrodeCommInspectionHistoryQC]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL,
						@pCommInspTypeCode VARCHAR(50) = NULL,
						@pIsFinished BIT = NULL,
						@pBarcode VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;
	
    DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate    DATE = @pToDate
	DECLARE @CommInspTypeCode VARCHAR(50) = CASE WHEN ISNULL(@pCommInspTypeCode,'') = '' THEN '%' ELSE @pCommInspTypeCode END
	DECLARE @IsFinished BIT = @pIsFinished
	DECLARE @Barcode   VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END                                                             -- 추가사항    

   -- 조회부분
	SELECT
			CASE WHEN CIDH.ComPanyCode = 'VNT' THEN '전주본사'
	                WHEN CIDH.ComPanyCode = 'VVT' THEN '베트남'     ELSE '기타' END   AS 사업장,
			CIDH.CommInspDocNo AS 검사번호,
			CIDH.CommInspTypeCode AS 검사유형코드,
			CITI.CommInspTypeName AS 검사유형명,
			CITI.CommInspTypeDesc AS 검사유형비고,
			CIDH.CompanyCode AS 사업장코드,
			CIDH.WorkCenterCode AS 작업장코드,
			CIDH.MaterialCode AS 품목코드,
			M.MaterialName AS 품목명,
			ISNULL(SI.Barcode, CIDH.ElectrodeLotNumber) AS Lot번호, --#201006
			CIDH.JobDate AS 작업일자,
			CIDH.ShiftCode AS 주야,
			CIDH.InspTimeCode AS 검사일시,
			CIDH.DocDesc,
			CIDH.CIDHExtText02 AS 비고                            -- 비고내용     
			, dbo.fnGetElectrodeDensity (MAX(CIDI.CommInspDocNo), 1)  AS [밀도(좌)]
			, dbo.fnGetElectrodeDensity (MAX(CIDI.CommInspDocNo), 2)  AS [밀도(중)]
			, dbo.fnGetElectrodeDensity (MAX(CIDI.CommInspDocNo), 3)  AS [밀도(우)]
			, CIMH.InspWorkerCode                                                 AS 검사자사번                                                              -- 공정검사 작업자코드
			, (Select WorkerName  from STB_ProdWorkerInfo SPW  where SPW.WorkerCode =CIMH.InspWorkerCode)  AS 검사자명  -- 공정검사 작업자명 (Barcode에 입력된 작업자)
			, Max(EC.RollingDensityMin) AS 밀도하한
			, Max(EC.RollingDensityMax) AS 밀도상한
			, dbo.fnGetElectrodeThickness01(MAX(CIDI.CommInspDocNo)) AS [전극두께(좌)]
			, dbo.fnGetElectrodeThickness02(MAX(CIDI.CommInspDocNo)) AS [전극두께(중)]
			, dbo.fnGetElectrodeThickness03(MAX(CIDI.CommInspDocNo)) AS [전극두께(우)]

	FROM                        STB_CommInspDocHistory  CIDH WITH(NOLOCK)
			LEFT OUTER JOIN STB_CommInspTypeInfo      CITI  WITH(NOLOCK)	  ON CITI.CommInspTypeCode = CIDH.CommInspTypeCode
			LEFT OUTER JOIN STB_MaterialMaster               M  WITH(NOLOCK) ON M.MaterialCode = CIDH.MaterialCode
			LEFT OUTER JOIN STB_SetInfo                         SI  WITH(NOLOCK)  ON SI.ControlNo = CIDH.ProdNo			
	     
			LEFT OUTER JOIN  ( 
			                           SELECT CommInspDocNo, CommInspDocItemNo, CommInspInputType
			                                    , CommInspItemCode
			                             FROM STB_CommInspDocItem
                                         WHERE CommInspItemCode IN ('REQ_A01','REQ_A02','REQ_A03') 											  
			                          ) CIDI ON CIDH.CommInspDocNo = CIDI.CommInspDocNo

												--SELECT CommInspDocNo, CommInspDocItemNo, CommInspInputType, CommInspItemCode, *
												--FROM STB_CommInspDocItem
												--WHERE CommInspItemCode IN ('REQ_A01','REQ_A02','REQ_A03') 	
												--AND 		CommInspDocItemNo = '20200913004067'		


			--LEFT OUTER JOIN   ( SELECT CommInspItemCode
			--                             FROM  STB_CommInspItem    
			--							 WHERE 1=1
			--							 AND CommInspItemCode IN ('REQ_A01','REQ_A02','REQ_A03') --AND DisplayIndex ='1'										 
			--							 GROUP BY CommInspItemCode
			--						  ) CII  ON 	 CIDI.CommInspItemCode = CII.CommInspItemCode
					
		    LEFT OUTER JOIN STB_CommInspMeasureHist CIMH   ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo           -- 작업자정보 가져오기 위함 JOIN함 											
			LEFT OUTER JOIN STB_ElectrodeCommon EC             ON CIDH.MaterialCode = EC.ProdCode
			LEFT OUTER JOIN VW_CommInspInputType VIEW_CIIT 	ON VIEW_CIIT.CommInspInputType = CIDI.CommInspInputType
	WHERE 1=1
	   AND (@CompanyCode = '*' OR CIDH.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR CIDH.WorkCenterCode = @WorkCenterCode) 
	   AND (CIDH.CommInspTypeCode = @CommInspTypeCode) 
	   AND (CIDH.JobDate BETWEEN @FromDate AND @ToDate) 
	   AND (CIDH.IsFinished = @IsFinished) 
	   AND (@Barcode = '*' OR SI.Barcode LIKE @Barcode)		
	   AND CITI.CommInspTypeCode = 'ROUTE_ELECTRODE_QUALITY'                    -- [전극공정검사]를 아예 박음!			  

	GROUP BY CIDH.ComPanyCode ,
					CIDH.CommInspDocNo,			
					CIDH.CommInspTypeCode,
					CITI.CommInspTypeName,
					CITI.CommInspTypeDesc,
					CIDH.CompanyCode,
					CIDH.WorkCenterCode,
					CIDH.MaterialCode,
					M.MaterialName,
					M.MaterialTypeCode,
					M.ProductGroupCode,
					CIDH.RefDocNo,
					ISNULL(SI.Barcode, CIDH.ElectrodeLotNumber), --#201006
					SI.PONo,
					CIDH.JobDate,
					CIDH.ShiftCode,
					CIDH.InspTimeCode,
					CIDH.CategoryName,
					CIDH.ProdNo,
					CIDH.IsFinished,
					SI.IsFinalInspection,
					CIDH.DocDesc,
					CIDH.InspUserID,
					CIDH.CreateDateTime,
					CIDH.CreateUserID,
					CIDH.ChangeDateTime,
					CIDH.ChangeUserID,
					CIDH.CIDHExtText02     
				  , CIMH.InspWorkerCode                       
                  , VIEW_CIIT.CommInspInputTypeName     -- 두께산술부분 
	              , CIMH.MeasureResult 								
END