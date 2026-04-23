
-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 품질관리
-- Description:	[C420] 공정검사이력조회
-- Modified:  
-- 2019-11-09  바코드 추가
-- 2021.10.07  작업자정보 조회조건 추가
--   usp_GetCommInspectionHistory_20211007 'kilee','','VNT','VNT_F1','2021-09-17 00:00:00','2021-09-30 00:00:00','ROUTE_ELECTRODE_QUALITY','', 'VJLR2920001E08', ''
   
   --[usp_GetCommInspectionHistory] 'kilee', '' ,'VNT' ,'VNT_F1' , '2021-09-17 00:00:00', '2021-09-30 00:00:00', 'ROUTE_ELECTRODE_QUALITY', '', 'VJLR2920001E08', ''


-- =============================================


CREATE PROCEDURE [dbo].[usp_GetCommInspectionHistory_20211007]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pCommInspTypeCode VARCHAR(50) = NULL,
	@pIsFinished BIT = NULL,
	@pBarcode VARCHAR(20) = NULL,
	@pWorkerCode VARCHAR(20) = NULL      -- 추가사항(2021.10.07)


AS

BEGIN
	SET NOCOUNT ON;
	
    DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
    DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate DATE = @pToDate
	DECLARE @CommInspTypeCode VARCHAR(50) = CASE WHEN ISNULL(@pCommInspTypeCode,'') = '' THEN '%' ELSE @pCommInspTypeCode END
	DECLARE @IsFinished BIT = @pIsFinished
	DECLARE @Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END                                                             -- 추가사항
    DECLARE @WorkerCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkerCode, '') = '' THEN '*' ELSE @pWorkerCode END                                                             -- 추가사항 (2021.10.7)
	DECLARE @CommInspDocNo VARCHAR(20)


	--SELECT @CommInspDocNo = CommInspDocNo
	--   FROM STB_SetInfo
	--   WHERE 1=1
	--   AND (@Barcode = '*' OR Barcode LIKE @Barcode)

	SELECT
			CASE WHEN CIDH.ComPanyCode = 'VNT' THEN '전주본사'
	        WHEN CIDH.ComPanyCode = 'VVT' THEN '베트남' ELSE '기타' END   AS 사업장,
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
			SI.Barcode,
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
			CIDH.CIDHExtText02                            -- 2020.01.17 비고내용 추가사항
	FROM
			STB_CommInspDocHistory               CIDH WITH(NOLOCK)
			LEFT OUTER JOIN STB_CommInspTypeInfo CITI WITH(NOLOCK) ON CITI.CommInspTypeCode = CIDH.CommInspTypeCode
			LEFT OUTER JOIN STB_MaterialMaster   M	  WITH(NOLOCK) ON M.MaterialCode = CIDH.MaterialCode
			LEFT OUTER JOIN STB_SetInfo          SI   WITH(NOLOCK) ON SI.ControlNo = CIDH.ProdNo			
		    LEFT OUTER JOIN STB_CommInspDocItem       CIDI WITH(NOLOCK) ON CIDI.CommInspDocNo  = CIDH.CommInspDocNo
																 
            LEFT OUTER JOIN STB_CommInspMeasureHist   SCI  WITH(NOLOCK) ON CIDI.CommInspDocItemNo = SCI.CommInspDocItemNo
															      AND SCI.MeasureSeq = 1-- 추가조인사항(2021-10-07)
	WHERE 1=1
	  AND ((@CompanyCode = '*') OR (CIDH.CompanyCode = @CompanyCode)) -- 추가 용은재 (2020.01.23)
	  AND (CIDH.WorkCenterCode = @WorkCenterCode) 
	  AND (CIDH.CommInspTypeCode = @CommInspTypeCode) 
	  AND (CIDH.JobDate BETWEEN @FromDate AND @ToDate) 
	  AND (CIDH.IsFinished = @IsFinished) 
	  AND (@Barcode = '*' OR SI.Barcode LIKE @Barcode)
	  AND (@WorkerCode = '*' OR CIDH.CreateUserID LIKE @WorkerCode)   --추가
	  --AND SCI.MeasureSeq = 1
	  --AND CIDI.CommInspDocItemNo = SCI.CommInspDocItemNo
	  AND CIDI.CommInspItemCode = 'REQ_A01'-- 원본백업
	
END
