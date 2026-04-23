
-- =============================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2020-08-31
-- Browsable : true
-- Group : 품질관리 > 수입검사 > 시료별수입검사
-- Description:	수입검사용 부적합등록!!!! 
-- Modified:
--                2020.07.15 DefectImage2 추가 

-- 프로시저 실행   :  usp_IQCDefectReportList_get '',''
-- =============================================
-- select * from STB_IQcDefectReport

Create PROCEDURE [dbo].[usp_IQCDefectReportList_get_backup]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20)
		
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage

 	SELECT SNR.*
	        , AFM.[FileName]
			, AFM.FileSize
			, CONVERT(VARBINARY(MAX),NULL) AS FileData
	-- FROM STB_IQcDefectReport
	 FROM  STB_NCR_Report SNR
	           LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)				ON AFM.FileID = SNR.CustomCountermeasureImage




END


/*

SELECT * FROM STB_NCR_Report  
--where companycode = '본사' 
Order by CreateDateTime desc


Begin Tran
-- Commit
ALTER TABLE STB_NCR_Report ALTER COLUMN CustomCountermeasureImage Bigint NULL   -- 컬럼변경


Begin Tran
-- Commit
ALTER TABLE STB_NCR_Report MODIFY (CustomCountermeasureImage, Bigint)

*/
