CREATE PROC usp_SystemParamTest_get
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pCompanyCode VARCHAR(20)
   ,@pWorkCenterCode VARCHAR(20)
   ,@pFromDate DATE
   ,@pToDate DATE
AS 
BEGIN
	SELECT '' AS Txt
END