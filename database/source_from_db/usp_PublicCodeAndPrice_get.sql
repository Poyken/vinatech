-- =============================================
-- Author:		<DinhManh>
-- Create date: <2025-01-16>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_PublicCodeAndPrice_get]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pPublicCode VARCHAR(30) = NULL,
		@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @PublicCode VARCHAR(30) = CASE WHEN ISNULL(@pPublicCode,'') = '' THEN '%' ELSE @pPublicCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END

    -- Insert statements for procedure here
	SELECT 
		PCAP.ID,
		PCAP.PublicCode,
		PCAP.Price,
		PCAP.IsUsed,
		PCAP.WorkCenterCode,
		PCAP.CreateDateTime,
		PCAP.CreateUserID,
		PCAP.ChangeDateTime,
		PCAP.ChangeUserID,
		PCAP.OnlyImport -- DinhManh update 2025-04-19 for some PublicCode just in Import list
	FROM
		STB_PublicCodeAndPrice PCAP WITH(NOLOCK)

	WHERE 
			PCAP.PublicCode LIKE @PublicCode
		AND PCAP.WorkCenterCode LIKE @WorkCenterCode
END
