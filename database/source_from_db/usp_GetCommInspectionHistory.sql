-- ED-VJPMTR000000014
-- ====================================================================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 품질관리
-- Description:	 [C420] 공정검사이력조회
-- Modified:  
-- 2019-11-09  바코드 추가
-- 2021-10-08  작업자정보 조회조건 추가
-- 2022-01-04  공정검사시 공정정보 추가
-- 프로시저 실행 :   usp_GetCommInspectionHistory 'kilee', '' ,'VNT' ,'VNT_F1' , '2021-09-17 00:00:00', '2021-09-30 00:00:00', 'ROUTE_ELECTRODE_QUALITY', '', 'VJLR2920001E08', ''
--                       usp_GetCommInspectionHistory 'kilee', '' ,'VNT' ,'VNT_F1' , '2021-12-01 00:00:00', '2022-01-15 00:00:00', 'ROUTE_QUALITY', '', 'VJLU302R710609' , '', ''
-- ================================================================================================================================

CREATE PROCEDURE [dbo].[usp_GetCommInspectionHistory]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pCommInspTypeCode VARCHAR(50) = NULL,
	@pIsFinished BIT = NULL,
	@pBarcode VARCHAR(20) = NULL,
	@pWorkerCode VARCHAR(20) = NULL,     -- 추가사항(2021.10.07)
	@pProcessSteps VARCHAR(20) = NULL    --공정정보 추가 (권취, 커링 2021. 10. 20 KILEE) 
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
    DECLARE @WorkerCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkerCode, '') = '' THEN '*' ELSE @pWorkerCode END                                           -- 추가사항 (2021.10.7)
	DECLARE @ProcessSteps VARCHAR(20) = CASE WHEN ISNULL(@pProcessSteps, '') = '' THEN '*' ELSE @pProcessSteps END                                           -- 추가사항 (2021.10.20)


	SELECT
			CASE WHEN CIDH.ComPanyCode = 'VNT' THEN '비나텍 본사'
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
			CIDH.VPCMachineCode,
		    MM.MachineName AS VPCMachineName,
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
			CIDH.CIDHExtText02                           -- 2020.01.17 비고내용 추가사항
		   ,SCI.InspWorkerCode      as       WorkerCode               -- 입력자 추가사항
		   ,SP.WorkerName     AS WorkerName      -- 입력자명 추가사항
		  -- , CIDH.CIDHExtText03 AS ProcessSteps   -- 2021. 10. 20 공정명 추가 KILEE
		   ,CIDI.ProcessSteps AS ProcessSteps   -- 2021. 10. 20 공정명 추가 KILEE
		   ,CASE WHEN XRay.Barcode is Not Null THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END   AS IsXRayImage	--2022.	01.	11 XRayImage 추가 SJC
		   ,CASE WHEN dbo.fnIsCheckCommInspItem(SI.Barcode, @CommInspTypeCode, 'RQ_F') > 0 THEN 1 ELSE 0 END AS IsWinding
		   ,CASE WHEN dbo.fnIsCheckCommInspItem(SI.Barcode, @CommInspTypeCode, 'RQ_WB') > 0 THEN 1 ELSE 0 END AS IsAssemble
		   ,CASE	WHEN SI.SIExtInt01 IS NULL THEN '정상제품'
				    WHEN SI.SIExtInt01 = 0      THEN '검사부적합 이력제품'
				    WHEN SI.SIExtInt01 = 1      THEN '검사부적합품'		END AS RouteTestResult
		   ,CASE WHEN SI.SIExtInt01 = 1 THEN (SELECT MAX(FindDateTime) FROM STB_DefectRepairInfo WHERE ControlNo = SI.ControlNo ) ELSE NULL END AS RouteTestDecisionDate
		   ,WI.WorkCenterName
	FROM
			STB_CommInspDocHistory                     CIDH WITH(NOLOCK)
			LEFT OUTER JOIN STB_CommInspTypeInfo CITI  WITH(NOLOCK)	 ON CITI.CommInspTypeCode = CIDH.CommInspTypeCode
			LEFT OUTER JOIN STB_MaterialMaster         M  WITH(NOLOCK)	 ON M.MaterialCode = CIDH.MaterialCode
			LEFT OUTER JOIN STB_SetInfo                   SI  WITH(NOLOCK)	 ON SI.ControlNo = CIDH.ProdNo					
				
			--INNER JOIN STB_CommInspDocItem       CIDI WITH(NOLOCK) ON CIDI.CommInspDocNo  = CIDH.CommInspDocNo      -- 원본백업
   --         INNER JOIN STB_CommInspMeasureHist  SCI WITH(NOLOCK)  ON SCI.CommInspDocItemNo = CIDI.CommInspDocItemNo   AND CIDI.CommInspDocItemNo = SCI.CommInspDocItemNo  AND SCI.MeasureSeq = 1   -- 추가사항(2021-10-07)
			--LEFT OUTER JOIN STB_ProdWorkerInfo      SP WITH(NOLOCK)	 ON SP.WorkerCode = SCI.InspWorkerCode

			LEFT OUTER JOIN STB_CommInspDocItem       CIDI WITH(NOLOCK) ON CIDI.CommInspDocNo  = CIDH.CommInspDocNo AND CIDI.CommInspItemCode = 'REQ_A01'-- 원본백업      -- 원본백업
            LEFT OUTER JOIN STB_CommInspMeasureHist  SCI WITH(NOLOCK)  ON CIDI.CommInspDocItemNo = SCI.CommInspDocItemNo  AND SCI.MeasureSeq = 1   -- 추가사항(2021-10-07)
			LEFT OUTER JOIN STB_ProdWorkerInfo      SP WITH(NOLOCK)	 ON SP.WorkerCode = SCI.InspWorkerCode
			LEFT OUTER JOIN STB_MachineMaster MM  WITH(NOLOCK) ON MM.MachineCode = CIDH.VPCMachineCode
			--LEFT OUTER JOIN STB_XRayImageUploadHist XIUH WITH(NOLOCK)	ON XIUH.Barcode = SI.Barcode	--2022.	01.	11 XRayImage 추가 SJC
			--LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)	ON AFM.FileID = XIUH.XRayImageFileID AND AFM.SystemName = 'STB_XRayImageUploadHist_pqc'	--2022.	01.	11 XRayImage 추가 SJC
			LEFT OUTER JOIN (
								SELECT XIUH.Barcode, XIUH.XRayImageFileID
					FROM STB_XRayImageUploadHist XIUH
					INNER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM
					  ON XIUH.XRayImageFileID = AFM.FileID And AFM.SystemName = 'STB_XRayImageUploadHist_pqc'
					--Where (@Barcode = '*' OR XIUH.Barcode LIKE @Barcode)
			) XRay
			ON SI.Barcode = XRay.Barcode

			LEFT OUTER JOIN STB_WorkCenterInfo WI ON WI.WorkCenterCode = CIDH.WorkCenterCode

	WHERE 1=1
	   AND ((@CompanyCode = '*') OR (CIDH.CompanyCode = @CompanyCode)) -- 추가 용은재 (2020-01-23)
	   AND (CIDH.WorkCenterCode = @WorkCenterCode) 
	   AND (CIDH.CommInspTypeCode = @CommInspTypeCode) 
	   AND (CIDH.JobDate BETWEEN @FromDate AND @ToDate) 
	   AND (CIDH.IsFinished = @IsFinished) 
	   AND (@Barcode = '*' OR SI.Barcode LIKE @Barcode + '%')
	   AND (@WorkerCode = '*' OR SCI.InspWorkerCode  LIKE @WorkerCode)   -- 추가 (2021-10-07)
	   AND (@ProcessSteps = '*' OR CIDI.ProcessSteps = @ProcessSteps)   -- 추가 (2021-10-20)
	  
END