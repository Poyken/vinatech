
-- ====================================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2020-08-31
-- Browsable : true
-- Group : 품질관리 > 수입검사 > 시료별수입검사 > 부적합등록(IQC) 등록
-- Description:	수입검사용 부적합등록!!!! 
-- Modified:
--					2020.07.15 DefectImage2 추가 
--					2020.11.12 부적합여부 추가
--					2020.12.30 월별로 없더라도 0표기 요청 (박진호대리)
--					2021.02.19 기준년월 추가

-- [프로시저 실행] :   usp_IQCDefectReportList_PowerBI 
-- =====================================================

CREATE PROCEDURE [dbo].[usp_IQCDefectReportList_PowerBI]
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @OneDay    VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11)        -- select SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11) 
	DECLARE @BaseYm    VARCHAR(06)

	--- 기준년월 (26일부터 ~ 다음달 25일까지)
			SELECT @BaseYm = Replace(BaseMonth, '-', '') 																		
			FROM STB_AggregationPeriod
  			WHERE 1=1									
			  AND  FromDate  <= @OneDay
			  AND  ToDate     >= @OneDay


 	SELECT SNR.NCRNo
             , SNR.JobDate
			 , SNR.CompanyCode as CompanyCode
			 , SNR.CompanyCode as CompanyName
             , SNR.OccurProcessCode
             , SNR.MaterialName
             , SNR.CustomName
             , SNR.StandardName
             , SNR.LotNo
             , SNR.Qty
             , SNR.InspectionQty
             , SNR.BadQty
             , SNR.PPM
             , SNR.InQty
             , SNR.BadLotQty
             , SNR.DefectiveRate
             , SNR.CreateUserID
             , SNR.Nonconformity
             , SNR.ImmediateAction
             , SNR.CustomImmediateAction
             , SNR.CustomCountermeasureImage
             , SNR.IsActionCode
             , IsNull(SNR.EffectivenessCheck, 0) As EffectivenessCheck
             , SNR.DefectImage
             , SNR.DefectImage2
             , SNR.CreateDateTime
	  --      , AFM.[FileName]
			--, AFM.FileSize
			--, CONVERT(VARBINARY(MAX),AFM.FileContents) AS FileData			
			, IsNull(SNR.IncongruityCheck, 0) As IncongruityCheck
		    , QDR.DefectImageUrl               As 이미지URL
		    ,  Substring(Convert(Varchar , SNR.JobDate , 112),1,6) As YearMonth
		    ,   Month(SNR.JobDate) As Month_B
	        ,	(
					SELECT  Replace(BaseMonth, '-', '')		
					FROM STB_AggregationPeriod
					WHERE 1=1									
						AND  FromDate  <=  SNR.JobDate
						AND  ToDate     >=  SNR.JobDate
				 ) AS Month_Vina                                         -- 2021.02.19 추가

  -- FROM STB_IQcDefectReport
	 FROM  STB_NCR_Report SNR
	           LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)	ON AFM.FileID = SNR.CustomCountermeasureImage
			   LEFT OUTER JOIN STB_IQcDefectReport QDR                                      WITH(NOLOCK) ON SNR.NCRNo = QDR.DefectReportNo                    -- 추가부분 (2020.10.30)
      Where 1=1
	     --And SNR.CompanyCode = '본사'
		  AND Substring(Convert(Varchar , SNR.JobDate , 112),1,6)  LIKE '2021%'
	  Order by SNR.CreateDateTime Desc
	  
	   
END
