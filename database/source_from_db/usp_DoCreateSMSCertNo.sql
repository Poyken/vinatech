CREATE PROC usp_DoCreateSMSCertNo
	@pUserName NVARCHAR(30) 
   ,@pRRN CHAR(7)
   ,@pID BIGINT OUTPUT
   ,@pSMSCertNo VARCHAR(10) OUTPUT
AS
BEGIN
	Declare @UserName NVARCHAR(30) = @pUserName
	       ,@RRN CHAR(7) = @pRRN

	INSERT INTO STB_SMSCertHist (UserName, RRN) VALUES (@UserName, @RRN)

	SELECT @pID = SCOPE_IDENTITY()

	SELECT @pSMSCertNo = SMSCertNo FROM STB_SMSCertHist WHERE ID = @pID
END
