-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리 > 고객불만 발생현황 popup조회
-- Browsable : true
-- Create date : 2019-10-22
-- Description : 보고서 채번 로직 변경 Jackaroe #200609
--                   2021.02.19 발행부서 Fix
-- 프로시저실행 :  usp_OccurrencePhenomenon_get  'kilee','Korean',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_OccurrencePhenomenon_get]

    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
	--@pDefectReportNo VARCHAR(20) = NULL
	@pCustomerComplaintsManagementNo VARCHAR(30) = NULL

AS

BEGIN
	Declare @CustomerComplaintsManagementNo VARCHAR(30) = @pCustomerComplaintsManagementNo
	         , @DummyReportNo VARCHAR(30) = @pCustomerComplaintsManagementNo


	
	SELECT DefectImage
	  FROM STB_CustomerComplaintsManagementInfo  SCM	  
	 WHERE 1=1 
	   --AND SCM.CustomerComplaintsManagementNo = 'VJQA04SC22-227'
	   AND SCM.CustomerComplaintsManagementNo = @DummyReportNo

END
