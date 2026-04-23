-- =============================================
-- Author:		DinhManh
-- Create date: 2025-05-06
-- Description:	Get customer for Ha Nam factory
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerCodeEnesol_get]
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pCustomerCode varchar(20) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '%' ELSE @pCustomerCode END

	SELECT 
		CustomerCode,
		CustomerName,
		CreateDateTime,
		CreateUserID,
		ChangeDateTime,
		ChangeUserID

	FROM 
		STB_CustomerInfoEnesol

	WHERE 
		CustomerCode LIKE @CustomerCode
END
