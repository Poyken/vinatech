CREATE PROC usp_DoCreatePaymentInfo
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pBaseMonth DATE = NULL
AS
BEGIN
	exec usp_DoCreateEmployeeSalary @pProcessUserID, @pProcessLanguage, @pBaseMonth
	exec usp_DoCreateEmployeeWorkTime @pProcessUserID, @pProcessLanguage, @pBaseMonth
END