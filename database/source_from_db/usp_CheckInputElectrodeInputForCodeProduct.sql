-- =============================================
-- Author:		Nguyễn Hải Triều (Dev)
-- Create date: 2026-03-21
-- Description:	Kiểm tra xem các công đoạn đã nhập mã điện cực âm và điện cực dương hay chưa?
-- exec usp_CheckInputElectrodeInputForCodeProduct 'VVQL233R033517','V-22'
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckInputElectrodeInputForCodeProduct]
	-- Add the parameters for the stored procedure here
    @pBarcode varchar(50),
	@pRouteCode varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @check int = 0;

	IF @pRouteCode in ( 'V-22','V-22_BG')
	BEGIN
		DECLARE @countElectrode int = 0;

		SELECT @countElectrode = COUNT(*)
		FROM STB_RawMaterialInputHist WITH(NOLOCK)
		WHERE (Barcode = @pBarcode)
		  AND ProductGroupCode IN ('ElectrodeM', 'ElectrodeP') 
		  AND RawMaterialBarcode IS NOT NULL 
		  AND RawMaterialBarcode <> '';

		IF @countElectrode < 2
		BEGIN
			RAISERROR (N'Công đoạn Cuốn cầu phải nhập đủ cả 2 mã ElectrodeM và ElectrodeP!', 16, 1);
			RETURN;
		END
	END
END



