CREATE PROC usp_JabilManualLabelPrintHist_get
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pBaseYm DATE
AS
BEGIN
	Declare @BaseYm CHAR(6) = CONVERT(CHAR(6), @pBaseYm, 112)

	SELECT  JabilManualLabelPrintHistNo
		   ,DC
		   ,QTY
		   ,LOT
		   ,CreateDateTime
		   ,CreateUserID
		   ,'Report' AS CommandType
	  FROM STB_JabilManualLabelPrintHist
	 WHERE DC = @BaseYm
	 ORDER BY JabilManualLabelPrintHistNo
END