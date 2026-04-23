-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-13
-- Description:	Get All LotID Using SpecialSparepart
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_LotIDUsingSpecialSparePart_get] 
	-- Add the parameters for the stored procedure here
		@pSparePartCode VARCHAR(30) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @SparePartCode VARCHAR(30) = @pSparePartCode

	
		SELECT
			SSPLI.LotID,
			SI.MaterialCode,
			MBI.ModelName,
			CASE WHEN MBI.MBISizeW IS NOT NULL
			     THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
				 ELSE CONVERT(VARCHAR(10), MBI.MBISizeD) END + CASE WHEN CHARINDEX('-L', MBI.ModelName) > 0 THEN 'L' ELSE '' END AS MBISizeD,
			SI.ProdQty,
			SI.InputLineCode,
			SI.InputJobDate,
			SI.InputShiftCode,
			SI.InputDateTime
		FROM
			STB_VN_SpecialSparePartLotInfo SSPLI	WITH(NOLOCK)
			LEFT OUTER JOIN STB_SetInfo SI	WITH(NOLOCK)		ON SI.Barcode = SSPLI.LotID
			LEFT OUTER JOIN VW_ModelBasicInfo MBI WITH(NOLOCK)	ON SI.MaterialCode = MBI.ModelCode
		WHERE 
			SSPLI.SparePartLotID = @SparePartCode
		ORDER BY 
			SI.InputDateTime asc

END
