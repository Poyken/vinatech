-- Procedure: usp_CheckPQCInputForProductHistForBarcode
-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-12-12
-- Description:	Chặn nếu mà PQC chưa nhập số lượng NG ở mỗi công đoạn thì bắn lỗi
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckPQCInputForProductHistForBarcode]
	-- Add the parameters for the stored procedure here
	@pBarcode varchar(50),
	@pRouteCode varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @NG_Count INT;
	SELECT
		@NG_Count = COUNT(DRI.DefectSummaryNo)
	FROM
			STB_DefectRepairInfo DRI WITH(NOLOCK)
			INNER JOIN STB_SetInfo SI WITH(NOLOCK) ON SI.ControlNo = DRI.ControlNo
			LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK) ON DI.DefectCode = DRI.DefectCode
	WHERE
			(SI.Barcode = @pBarcode) AND
			DRI.FindRouteCode = @pRouteCode AND
			DI.DirectlyUnder IN ('PQC') AND 
			(DRI.RepairType IS NULL OR DRI.RepairType NOT IN ('FINISH')) AND 
			DRI.DefectCode NOT IN (SELECT DefectCode FROM dbo.fn_VVT_QCPARTCODE() WHERE flag ='QC') 
   
	IF (ISNULL(@NG_Count, 0) <= 0)
        BEGIN
             RAISERROR (N'Bên PQC chưa nhập số lượng NG. Vui lòng bảo bên PQC nhập số lượng NG.', 16, 1);
             RETURN;
        END
			
END

GO

