-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-03-25
-- Description:	get Samjin label
-- =============================================
CREATE PROCEDURE [dbo].[usp_SamjinLabelPrint_get_Vietnam] 
	-- Add the parameters for the stored procedure here
				@pProcessUserID VARCHAR(20)=null,
				@pProcessLanguage VARCHAR(20)=null,
				@pSamjinCode VARCHAR(50) = NULL,
				@pVinatechCode VARCHAR(50) = null

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--DECLARE @SamjinCode VARCHAR(50) = NULL

	--IF @pVinatechCode = 'VEL08253R8506G-B034' 
	--	BEGIN
	--		SET @SamjinCode = 'CC30017-00393'
	--	END
	--ELSE IF @pVinatechCode = 'VEL08253R8506G-B030R' 
	--	BEGIN
	--		SET @SamjinCode = 'CC30017-00430'
	--	END

	SELECT 
		@pVinatechCode AS VinatechCode,
		@pSamjinCode AS SamjinCode,
		1 AS LabelQty,
		'Report' AS CommandType

END
