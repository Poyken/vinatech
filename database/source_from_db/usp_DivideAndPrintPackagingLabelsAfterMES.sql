-- =============================================
-- Author:		Nguyễn Hải Trièu
-- Create date: 2025-09-18
-- Description:	Chia số lượng tồn kho trước MES
-- =============================================
CREATE PROCEDURE [dbo].[usp_DivideAndPrintPackagingLabelsAfterMES]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20) =NULL,
	@pProcessLanguage VARCHAR(20) =NULL,
    @pPackingID NVARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- select * from FinishGoodMESInstock_HN
    -- Insert statements for procedure here
    DECLARE @DividePackagingID NVARCHAR(50);
	DECLARE @PackingID NVARCHAR(50) = @pPackingID;
	DECLARE @psagemcom VARCHAR(10) = 'sagemcom';
	DECLARE @LabelType VARCHAR(50) = 'BoxLabel';
	/*
	-- Kiểm tra tồn tại trong kho MES
	IF NOT EXISTS (SELECT 1 FROM FinishGoodMESInstock_HN WHERE PackingID = @PackingID)
	BEGIN
		RAISERROR(N'Lot này không tồn tại hoặc chưa đóng gói',16,1);		
		RETURN;
	END;
	*/
	-- Nếu chưa tồn tại trong STB_DividePackaging thì thêm vào
	IF NOT EXISTS (SELECT 1 FROM STB_DividePackaging WHERE PackingID = @PackingID)
	BEGIN
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DividePackaging', @DividePackagingID OUTPUT;

		INSERT INTO STB_DividePackaging (
			DividePackagingID,
			PackingID,
			Qty,
			GRDate,
			MaterialCode,
			LotNo,
			CreateDateTime,
			CreateUserID
		)
		-- select top 1 * from FinishGoodMESInstock_HN
		SELECT TOP (1)
			@DividePackagingID,
			@PackingID,
			Quantity,
			NULL,
			MaterialCode,
			LotNo,
			GETDATE(),
			@pProcessUserID
		FROM FinishGoodMESInstock_HN 
		WHERE PackingID = @PackingID 
		ORDER BY CreateDateTime DESC;
	END;


	SELECT TOP (1) 
		DP.DividePackagingID,
		MLI.MaterialCode,
		MLI.ProductName,
		MLI.PackingID,

		'Report'  AS CommandType,
		MLI.Quantity,
		MLI.LotNo,
		MLI.Voltage, 
		MLI.Farad,
		 MLI.MBISizeW,
		 MLI.MBISizeH,
		  0 as QtySliptBox

	FROM STB_DividePackaging DP
	JOIN FinishGoodMESInstock_HN MLI WITH(NOLOCK) 
		ON DP.PackingID = MLI.PackingID 
	WHERE DP.PackingID = @PackingID;
end

