
-- =============================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2020-09-18
-- Browsable : true
-- Group : 품질관리
-- Description:	[C425] 전극공정검사이력조회
-- Modified:  2019-11-09  바코드 추가
--            2020-09-14 
--            2020-10-06 일괄업로드 데이터의 바코드 표시를 위해 변경 By Jackaroe #201006

-- usp_GetElectrodeCommInspectionHistory   'kilee','','VNT','VNT_F1','2020-09-13 00:00:00','2020-09-17 00:00:00','ROUTE_ELECTRODE_QUALITY','', 'VJKR1212001E05'      -- 한 Lot만 검색시
-- usp_GetElectrodeCommInspectionHistory   'kilee','','VNT','VNT_F1','2020-09-13 00:00:00','2020-09-17 00:00:00','ROUTE_ELECTRODE_QUALITY','', ''                            -- 전체검색시
-- ===================================================================================================================
CREATE PROCEDURE usp_GetElectrodeCommInspectionHistory_20210105
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
	DECLARE @CommInspTypeCode VARCHAR(50) = CASE WHEN ISNULL(@pCommInspTypeCode,'') = '' THEN '*' ELSE @pCommInspTypeCode END
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
			CIDH.CIDHExtText02,
			Max(EC.RollingDensityMin) AS RollingDensityMin,
			Max(EC.RollingDensityMax) AS RollingDensityMax
	FROM    STB_CommInspDocHistory  CIDH WITH(NOLOCK)
			LEFT OUTER JOIN STB_CommInspTypeInfo CITI  WITH(NOLOCK)	  
			  ON CITI.CommInspTypeCode = CIDH.CommInspTypeCode
			LEFT OUTER JOIN STB_MaterialMaster M  WITH(NOLOCK) 
			  ON M.MaterialCode = CIDH.MaterialCode
			LEFT OUTER JOIN STB_SetInfo SI  WITH(NOLOCK)  
			  ON SI.ControlNo = CIDH.ProdNo			
			LEFT OUTER JOIN STB_ElectrodeCommon EC             ON CIDH.MaterialCode = EC.ProdCode
	WHERE 1=1
	   AND ((@CompanyCode = '*') OR (CIDH.CompanyCode = @CompanyCode))
	   AND ((@WorkCenterCode = '*') OR (CIDH.WorkCenterCode = @WorkCenterCode)) 
	   AND (CIDH.CommInspTypeCode = @CommInspTypeCode) 
	   AND (CIDH.JobDate BETWEEN @FromDate AND @ToDate) 
	   AND (CIDH.IsFinished = @IsFinished) 
	   AND (@Barcode = '*' OR SI.Barcode = @Barcode)		
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
END