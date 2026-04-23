-- ====================================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2020-10-30
-- Browsable : true
-- Group : 품질관리 > 수입검사 > 시료별수입검사
-- Description:	수입검사용 부적합등록!!!! 
-- Modified:
--                2020.10.30 수입검사 power-BI용 (최우석 요청)
--                2021.01.12 From~To 조건추가    (최우석 요청)

-- usp_IQCDefectReportList_PowerBI_get '2020-12-01','2021-01-12'
-- =====================================================


CREATE PROCEDURE [dbo].[usp_IQCDefectReportList_PowerBI_get]
	@pFromDate DATETIME,
	@pToDate DATETIME
								
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'

	SET NOCOUNT ON;



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
             ,SNR.DefectImage
             ,SNR.DefectImage2
             ,SNR.CreateDateTime
	        , AFM.[FileName]
			, AFM.FileSize
			, CONVERT(VARBINARY(MAX),AFM.FileContents) AS FileData			
			--, QDR.*
	-- FROM STB_IQcDefectReport
	 FROM  STB_NCR_Report SNR
	           LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)		ON AFM.FileID = SNR.CustomCountermeasureImage
			   LEFT OUTER JOIN  STB_IQcDefectReport QDR                                      WITH(NOLOCK)    ON SNR.NCRNo = QDR.DefectReportNo                    -- 추가부분 (2020.10.30)
   where   1=1
     and  QDR.CreateDateTime BETWEEN @FromDate AND @ToDate

	  Order by SNR.CreateDateTime desc
	  
	   


END