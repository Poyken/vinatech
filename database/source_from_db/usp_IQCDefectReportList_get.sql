
-- ================================================================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2020-08-31
-- Browsable : true
-- Group : 품질관리 > 수입검사 > 시료별수입검사 > 부적합등록(IQC) 등록
-- Description:	수입검사용 부적합등록!!!! 
-- Modified:
-- 2020.07.15 DefectImage2 추가 
-- 2020.11.12 부적합여부 추가
-- 2021.10.25 조회조건 - 사업장코드 추가 (Kangs )

-- 프로시저 실행
-- usp_IQCDefectReportList_get 'kilee2' ,'Korean', '' ,'VNT'    -- 한개만 조회하는 경우
-- usp_IQCDefectReportList_get '','','VNT'   -- 전체 조회하는 경우 (화면에서 Check표시가 된 경우임)
-- =============================================================================

CREATE PROCEDURE [dbo].[usp_IQCDefectReportList_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
					--	@pIQCCheckList   BIT = Null,
						@pCompanyCode VARCHAR(20) = NULL
		
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	--DECLARE @IQCCheckList BIT = @pIQCCheckList
	 DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' 
	                                                                           WHEN ISNULL(@pCompanyCode,'') = 'VNT' THEN 'VN%'   
																			   WHEN ISNULL(@pCompanyCode,'') = 'VVT' THEN 'VV%'    ELSE @pCompanyCode END

	--IF ISNULL(@IQCCheckList,'') = 1

 	SELECT SNR.NCRNo
             ,SNR.JobDate
             , Case When SNR.CompanyCode = 'VNT' Then '본사' 
			          When SNR.CompanyCode = 'VVT' Then '베트남' Else SNR.CompanyCode End as CompanyCode
             ,SNR.OccurProcessCode
             ,SNR.MaterialName
             ,SNR.CustomName
             ,SNR.standardName
             ,SNR.LotNo
             ,SNR.Qty
             ,SNR.InspectionQty
             ,SNR.BadQty
             ,SNR.PPM
             ,SNR.InQty
             ,SNR.BadLotQty
             ,SNR.DefectiveRate
             ,SNR.CreateUserID
             ,SNR.Nonconformity
             ,SNR.ImmediateAction
             ,SNR.CustomImmediateAction
             ,SNR.CustomCountermeasureImage
             ,SNR.IsActionCode
             ,IsNull(SNR.EffectivenessCheck, 0) As EffectivenessCheck
             --,SNR.DefectImage
             --,SNR.DefectImage2
             ,SNR.CreateDateTime
	        , AFM.[FileName]
			, AFM.FileSize
			, CONVERT(VARBINARY(MAX),AFM.FileContents) AS FileData			
			, IsNull(SNR.IncongruityCheck, 0) AS IncongruityCheck
			--, QDR.*
	-- FROM STB_IQcDefectReport
	 FROM  STB_NCR_Report SNR
	 
	           LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)		ON AFM.FileID = SNR.CustomCountermeasureImage
			 --  LEFT OUTER JOIN  STB_IQcDefectReport QDR                                      WITH(NOLOCK)    ON SNR.NCRNo = QDR.DefectReportNo                    -- 추가부분 (2020.10.30)
    WHERE 1=1
	   AND  SNR.NCRNo Like @CompanyCode    -- Kangs추가  (2021-10-25)	   
	   --AND NOT SNR.NCRNo IN ('VNI211201-01')
	   --AND SNR.NCRNo = 'VNI210701-01' --22. 5. 09 삼성 오딧 대응, 22. 5. 10일 이후 삭제
	  Order by SNR.CreateDateTime desc
	  
	   

	--   ELSE  
	   
	   
	--   -- 무조건 한 개만 조회되는경우임 Top1

	--   BEGIN
	--		--EXEC usp_RaiseLocalizedError @pProcessLanguage, '[부적합등록현황] Tab을 조회하실 경우에는 IQC List에 체크하시고 조회하시기 바랍니다. '


	--		SELECT Top 1  SNR.NCRNo
 --            ,SNR.JobDate
 --            , Case When SNR.CompanyCode = 'VNT' Then '본사' 
	--		          When SNR.CompanyCode = 'VVT' Then '베트남' Else SNR.CompanyCode End as CompanyCode
 --            ,SNR.OccurProcessCode
 --            ,SNR.MaterialName
 --            ,SNR.CustomName
 --            ,SNR.standardName
 --            ,SNR.LotNo
 --            ,SNR.Qty
 --            ,SNR.InspectionQty
 --            ,SNR.BadQty
 --            ,SNR.PPM
 --            ,SNR.InQty
 --            ,SNR.BadLotQty
 --            ,SNR.DefectiveRate
 --            ,SNR.CreateUserID
 --            ,SNR.Nonconformity
 --            ,SNR.ImmediateAction
 --            ,SNR.CustomImmediateAction
 --            ,SNR.CustomCountermeasureImage
 --            ,SNR.IsActionCode
 --            ,IsNull(SNR.EffectivenessCheck, 0) As EffectivenessCheck
 --            --,SNR.DefectImage
 --            --,SNR.DefectImage2
 --            ,SNR.CreateDateTime
	--        , AFM.[FileName]
	--		, AFM.FileSize
	--		, CONVERT(VARBINARY(MAX),AFM.FileContents) AS FileData			
	--		, IsNull(SNR.IncongruityCheck, 0) AS IncongruityCheck                  -- 부적합여부
	--		--, QDR.*
	---- FROM STB_IQcDefectReport
	-- FROM  STB_NCR_Report SNR
	--           LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)		ON AFM.FileID = SNR.CustomCountermeasureImage
	--  WHERE 1=1
	--    AND  SNR.NCRNo Like @CompanyCode    -- Kangs추가  (2021-10-25)	   	
	--	--AND NOT SNR.NCRNo IN ('VNI211201-01')   -- 김민수요청사항
	--   ORDER BY CreateDateTime DESC

	--     --AND SNR.NCRNo = 'VNI200106-01'
	--		--RETURN
	--    END

END







/*
-- Select CustomCountermeasureImage, * from STB_NCR_Report where  NCRNo = 'VNI200106-01'

SELECT SNR.*
	        , AFM.[FileName]
			, AFM.FileSize
			, CONVERT(VARBINARY(MAX),NULL) AS FileData
	-- FROM STB_IQcDefectReport
	 FROM  STB_NCR_Report SNR
	           LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)				ON AFM.FileID = SNR.CustomCountermeasureImage
  WHERE SNR.NCRNo =  'VNI200106-01'


  SELECT * FROM SmartFramework_File.dbo.STB_AttachedFileMaster where  CreateUserID in ( 'kilee', 'kilee2')
 */
