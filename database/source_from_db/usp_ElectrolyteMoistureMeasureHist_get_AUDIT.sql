-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 2020.06.30
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrolyteMoistureMeasureHist_get_AUDIT]
	@pProcessUserID VARCHAR(20)= NULL,
	@pProcessLanguage VARCHAR(20)= NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS

BEGIN
select * from STB_MoistureMeasureHist_audit
END