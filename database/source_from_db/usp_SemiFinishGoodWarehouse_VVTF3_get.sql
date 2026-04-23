-- =============================================
-- Author:		DinhManh
-- Create date: 2025-08-14
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SemiFinishGoodWarehouse_VVTF3_get]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pBarcode VARCHAR(50) = NULL 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Barcode VARCHAR(50) = CASE WHEN ISNULL(@pBarcode,'') = '' THEN '%' ELSE @pBarcode END

	SELECT 
		    SFG.ID, 
			SFG.OldControlNo,
			SI.PONo,
			SI.DayPlanNo,
			SFG.NewBarcode,
			SFG.ProdQty,
			SI.MaterialCode,
			MM.MaterialName,
			SFG.CreateUserID,
			SFG.CreateDateTime
	FROM STB_SFGWarehouse_VVTF3 SFG WITH(NOLOCK)
	LEFT JOIN STB_SetInfo SI WITH(NOLOCK) ON SFG.OldControlNo = SI.ControlNo
	LEFT JOIN STB_MaterialMaster MM WITH(NOLOCK) ON SI.MaterialCode = MM.MaterialCode
	WHERE 
		SFG.WHStatus = 'IN' AND		
			(SFG.NewBarcode LIKE @Barcode
			OR SI.Barcode LIKE @Barcode)

END
