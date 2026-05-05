-- Procedure: usp_CheckInputElectrodeInputForCodeProduct
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


	IF @pRouteCode IN ('V-22', 'V-22_BG')
    BEGIN
        DECLARE @countElectrode int = 0;

        -- 2. Đếm số lượng nhóm điện cực (M và P) ĐÃ NHẬP Barcode thực tế
        SELECT @countElectrode = COUNT(DISTINCT ProductGroupCode)
        FROM STB_RawMaterialInputHist WITH(NOLOCK)
        WHERE Barcode = @pBarcode
          AND ProductGroupCode IN ('ElectrodeM', 'ElectrodeP') 
          AND RawMaterialBarcode IS NOT NULL 
          AND RawMaterialBarcode <> ''; -- Chặn cả trường hợp rỗng

        -- 3. Nếu không đủ 2 nhóm (thiếu M hoặc P) thì ném lỗi ngay
        IF @countElectrode < 2
        BEGIN
            RAISERROR (N'Lỗi: Công đoạn Cuốn phải nhập đầy đủ mã Barcode cho cả ElectrodeM và ElectrodeP mới được phép lưu!', 16, 1);
            RETURN;
        END
    END
END




GO

