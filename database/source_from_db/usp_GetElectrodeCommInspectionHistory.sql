
-- =============================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2020-09-18
-- Browsable : true
-- Group : 품질관리
-- Description:	[C425] 전극공정검사이력조회
-- Modified:  2019-11-09  바코드 추가
--            2020-09-14 
--            2020-10-06 일괄업로드 데이터의 바코드 표시를 위해 변경 By Jackaroe #201006
--            2021-07-19 Mr.Tung change WHERE condition to  @CommInspTypeCode
--            2021-12-27 점도 추가 이미정 차장 요청 by Jackaroe

-- usp_GetElectrodeCommInspectionHistory   'kilee','','VNT','VNT_F1','2020-09-13 00:00:00','2020-09-17 00:00:00','ROUTE_ELECTRODE_QUALITY','', 'VJKR1212001E05'      -- 한 Lot만 검색시
-- usp_GetElectrodeCommInspectionHistory   'kilee','','VNT','VNT_F4','2026-02-11 00:00:00','2026-02-12 00:00:00','ROUTE_ELECTRODE_QUALITY','', ''                            -- 전체검색시
-- ===================================================================================================================
CREATE PROCEDURE [dbo].[usp_GetElectrodeCommInspectionHistory]
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
			CIDH.CommInspDocNo AS OldCommInspDocNo,
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
			ISNULL(SI.Barcode, CIDH.ElectrodeLotNumber) AS Barcode, --#201006
			SI.PONo,
			CIDH.JobDate,
			CIDH.ShiftCode,
			CIDH.InspTimeCode,
			CIDH.CategoryName,
			CIDH.ProdNo,
			ISNULL(CIDH.IsFinished,0) AS IsFinished,
			ISNULL(SI.IsFinalInspection,0) AS IsFix,
			CIDH.DocDesc,
			CIDH.InspUserID,
			CIDH.CreateDateTime,
			CIDH.CreateUserID,
			CIDH.ChangeDateTime,
			CIDH.ChangeUserID,
			CIDH.CIDHExtText02                            -- 비고내용     
			, dbo.fnGetElectrodeDensity (MAX(CIDI.CommInspDocNo), 1)  AS Thickness_Left              
			, dbo.fnGetElectrodeDensity (MAX(CIDI.CommInspDocNo), 2)  AS  Thickness_Center         
			, dbo.fnGetElectrodeDensity (MAX(CIDI.CommInspDocNo), 3)  AS Thickness_Right         
			, CIMH.InspWorkerCode                                                 AS WorkerCode                                                              -- 공정검사 작업자코드
			, (Select WorkerName  from STB_ProdWorkerInfo SPW  where SPW.WorkerCode =CIMH.InspWorkerCode)  AS WorkerName  -- 공정검사 작업자명 (Barcode에 입력된 작업자)
			, Max(EC.RollingDensityMin) AS RollingDensityMin   --압연밀도하한
			, Max(EC.RollingDensityMax) AS RollingDensityMax  --압연밀도상한
			, dbo.fnGetElectrodeThickness01(MAX(CIDI.CommInspDocNo)) AS ElectrodeThickness01           -- 전극두께부분 (Funtion으로 구성함)
			, dbo.fnGetElectrodeThickness02(MAX(CIDI.CommInspDocNo)) AS ElectrodeThickness02
			, dbo.fnGetElectrodeThickness03(MAX(CIDI.CommInspDocNo)) AS ElectrodeThickness03
			, MAX(W1.WeightLeft) AS WeightLeft
			, MAX(W2.WeightMiddle) AS WeightMiddle
			, MAX(W3.WeightRight) AS WeightRight
			, MAX(EM.ViscosityValue) AS ViscosityValue
	FROM    STB_CommInspDocHistory  CIDH WITH(NOLOCK)
			LEFT OUTER JOIN STB_CommInspTypeInfo      CITI  WITH(NOLOCK)	  ON CITI.CommInspTypeCode = CIDH.CommInspTypeCode
			LEFT OUTER JOIN STB_MaterialMaster               M  WITH(NOLOCK) ON M.MaterialCode = CIDH.MaterialCode
			LEFT OUTER JOIN STB_SetInfo                         SI  WITH(NOLOCK)  ON SI.ControlNo = CIDH.ProdNo			
			LEFT OUTER JOIN  ( 
			                           SELECT CommInspDocNo, CommInspDocItemNo, CommInspInputType
			                                    , CommInspItemCode
			                             FROM STB_CommInspDocItem  WITH(NOLOCK)
                                         WHERE CommInspItemCode IN ('REQ_A01','REQ_A02','REQ_A03','V_REQ_A01','V_REQ_A02','V_REQ_A03') 	-- Mr.Tung on 2021-July-17										  
			                          ) CIDI ON CIDH.CommInspDocNo = CIDI.CommInspDocNo
		    LEFT OUTER JOIN STB_CommInspMeasureHist CIMH   ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo           -- 작업자정보 가져오기 위함 JOIN함 											
			LEFT OUTER JOIN STB_ElectrodeCommon EC             ON CIDH.MaterialCode = EC.ProdCode
			LEFT OUTER JOIN VW_CommInspInputType VIEW_CIIT 	ON VIEW_CIIT.CommInspInputType = CIDI.CommInspInputType
			LEFT OUTER JOIN (
				SELECT CommInspDocNo, CONVERT(NUMERIC(38,25), A.NumericMeasure) AS WeightLeft
					FROM  STB_CommInspMeasureHist A   WITH(NOLOCK)
							LEFT OUTER JOIN STB_CommInspDocItem B ON A.CommInspDocItemNo = B.CommInspDocItemNo
					WHERE B.CommInspItemCode  in ( 'REQ_W01', 'V_REQ_W01')
			) W1
			ON W1.CommInspDocNo = CIDH.CommInspDocNo
			LEFT OUTER JOIN (
				SELECT CommInspDocNo, CONVERT(NUMERIC(38,25), A.NumericMeasure) AS WeightMiddle
					FROM  STB_CommInspMeasureHist A   WITH(NOLOCK)
							LEFT OUTER JOIN STB_CommInspDocItem B ON A.CommInspDocItemNo = B.CommInspDocItemNo
					WHERE B.CommInspItemCode  in ( 'REQ_W02', 'V_REQ_W02')
			) W2
			ON W2.CommInspDocNo = CIDH.CommInspDocNo
			LEFT OUTER JOIN (
				SELECT CommInspDocNo, CONVERT(NUMERIC(38,25), A.NumericMeasure) AS WeightRight
					FROM  STB_CommInspMeasureHist A   WITH(NOLOCK)
							LEFT OUTER JOIN STB_CommInspDocItem B ON A.CommInspDocItemNo = B.CommInspDocItemNo
					WHERE B.CommInspItemCode  in ( 'REQ_W03', 'V_REQ_W03')
			) W3
			ON W3.CommInspDocNo = CIDH.CommInspDocNo
			LEFT OUTER JOIN STB_ElectrodeMixInfo EM
			ON EM.ElectrodeLotNumber = SI.Barcode
	WHERE 1=1
	   AND (@CompanyCode = '*' OR CIDH.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR CIDH.WorkCenterCode = @WorkCenterCode) 
	   AND (CIDH.CommInspTypeCode = @CommInspTypeCode) 
	   AND (CIDH.JobDate BETWEEN @FromDate AND @ToDate) 
	   AND (CIDH.IsFinished = @IsFinished) 
	   AND (@Barcode = '*' OR SI.Barcode LIKE @Barcode)		
	   AND CITI.CommInspTypeCode = @CommInspTypeCode     -- Mr.Tung on 2021-July-17    --'ROUTE_ELECTRODE_QUALITY'                    -- [전극공정검사]를 아예 박음!			  

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