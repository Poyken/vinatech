-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-12
-- Description:	Xem chi tiết thùng con đóng để tạo thùng to
-- exec usp_HistoryPackingOutPutFinishGoodsDetail 'PKHNOP202504250000000002'
-- =============================================
CREATE PROCEDURE [dbo].[usp_HistoryPackingOutPutFinishGoodsDetail]
	-- Add the parameters for the stored procedure here
	@pMergeParentId varchar(50)=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @MergeParentId VARCHAR(50) = @pMergeParentId 
	SELECT MLI.LotID,MLI.MaterialCode,MLI.PackingID,MLI.CurrentQty,CML.MarkingName,
	MLI.LotNo,
	ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage,
    ISNULL(PLS.Farad, MBI.MBIExtText05) AS Farad,
    CONVERT(VARCHAR, CONVERT(NUMERIC(20,1),MBI.MBISizeW)) AS MBISizeW,
    CONVERT(VARCHAR, CONVERT(NUMERIC(20,1), MBI.MBISizeH)) AS MBISizeH,

	ISNULL(PLS.Rating, '(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')') AS Rating
		
	
	FROM STB_MaterialLotInfo MLI

	LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK)  ON MLI.MaterialCode = MBI.ModelCode
	LEFT OUTER JOIN STB_PackingLabelSpec PLS WITH(NOLOCK) 			            ON MLI.LotID = PLS.LotID
	LEFT OUTER JOIN STB_SetInfo SI  WITH(NOLOCK) ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
	LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.MarkingCode = CML.MarkingCode
	where MergeParentId=@MergeParentId

END
