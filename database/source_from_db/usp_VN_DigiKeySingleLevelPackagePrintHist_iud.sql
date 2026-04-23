-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_DigiKeySingleLevelPackagePrintHist_iud]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pPackListNumber nvarchar(50) = NULL,
		@pPackageCount VARCHAR(10) = NULL,
		@pSUMPackage VARCHAR(5) = NULL,
		@pWeight VARCHAR(5) = NULL



AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO  STB_DigiKeySingleLevelPackagePrintHist(
		PackListNumber,
		PackageCount,
		SUMPackage,
		[Weight],
		CREATEUSERID,
		CREATEDATE
	)
	VALUES
	 (
		@pPackListNumber ,
		@pPackageCount ,
		@pSUMPackage ,
		@pWeight ,
		@pProcessUserID,
		GETDATE()
	 )

END

--select * from STB_DigiKeySingleLevelPackagePrintHist