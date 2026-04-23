-- =============================================
-- Author:
-- Create date:
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VietNam_FinishGood_BG_StockOut_get]
	-- Add the parameters for the stored procedure here
	    @pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pPublicCode VARCHAR(20) = NULL,
		@pLotNo  NVARCHAR(50) = NULL,
		@pInvoiceNo NVARCHAR(50) = NULL
		--@pPackQty INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @PublicCode VARCHAR(50) = CASE WHEN ISNULL(@pPublicCode,'') = '' THEN '%' ELSE @pPublicCode END
	DECLARE @LotNo NVARCHAR(50) = CASE WHEN ISNULL(@pLotNo,'') = '' THEN '%' ELSE @pLotNo END
	DECLARE	@Country NVARCHAR(50)
	DECLARE @SoPhieuXuatKho NVARCHAR(50)
	DECLARE @SoInVoice NVARCHAR(50)
	DECLARE @SoToKhaiHaiQuan NVARCHAR(50)
	DECLARE @TYPEEXPORT NVARCHAR(50)
	DECLARE @LevelsOut  NVARCHAR(50)
	DECLARE @Transport NVARCHAR(50)
	DECLARE @CustomerName NVARCHAR(100)
	DECLARE @BoxQuantity INT
	DECLARE @PalletQuantity INT
	DECLARE @Note NVARCHAR(MAX)
	DECLARE @TotalPackQty INT,
	@BoxQty INT,
	@PO NVARCHAR(50),
	@HH_PN NVARCHAR(50)

	IF (ISNULL(@pLotNo, '') = '' AND ISNULL(@pInvoiceNo, '') = '')
    BEGIN
        SELECT TOP 0 * FROM STB_VN_FINISHGOODS_BG_Test_20251225;
        RETURN;
    END


    IF (
    (SELECT LEFT(Partno, CHARINDEX('(', Partno + '(') - 1) AS CleanPartNo FROM PublicCodeAndPartNo WHERE PublicCode = @PublicCode) 
    NOT LIKE 
    '%' + (
    SELECT 
    LEFT(FinalName, CHARINDEX(' ', FinalName + ' ') - 1) AS FinalPartNo
    FROM (
    SELECT 
        CASE 
            WHEN CHARINDEX('-', CleanedName) > 0 
            THEN LEFT(CleanedName, CHARINDEX('-', CleanedName) - 1)
            ELSE CleanedName 
        END AS FinalName
    FROM (
        SELECT 
            LTRIM(REPLACE(ModelName, 'HY-CAP', '')) AS CleanedName
        FROM Stb_ModelBasicInfo 
        WHERE ModelCode = (SELECT TOP 1 MaterialCode FROM STB_SetInfo WHERE Barcode = @LotNo)
    ) AS SubStep1
) AS SubStep2
    ) + '%'
)
	BEGIN
	RAISERROR(N'Mã lot với PartNo không khớp', 16, 1, @LotNo)
	RETURN;
	END

	IF((Select Count(*) From STB_VN_FINISHGOODS_BG_Test_20251225 where LotNo = @LotNo and DateExport is null) <= 0)
	BEGIN
	RAISERROR(N'Lot đã được xuất kho', 16, 1, @LotNo)
	RETURN;
	END

	IF ISNULL(@pLotNo, '') <> ''
	BEGIN
    IF NOT EXISTS (SELECT LotNo FROM STB_VN_FINISHGOODS_BG_Test_20251225 WHERE LotNo = @LotNo)
    BEGIN
        RAISERROR(N'Mã lot %s này chưa được nhập kho. Vui lòng kiểm tra lại', 16, 1, @LotNo)
        RETURN;
    END
	BEGIN
	SELECT 
	       VFBG.IDCODE,
		   VFBG.PackingID,
		   VFBG.LotNo,
		   MM.MaterialCode,
		   MM.MaterialName,
		   @Country as Country,
		   @SoPhieuXuatKho as SoPhieuXuatKho,
		   @pInvoiceNo as SoInVoice,
		   @SoToKhaiHaiQuan as SoToKhaiHaiQuan,
		   @TYPEEXPORT as TYPEEXPORT,
		   @LevelsOut as LevelsOut,
		   @Transport as TRANSPORT,
		   @CustomerName as CUSTOMERNAME,
		   @BoxQty as BoxQuantity,
		   @PalletQuantity as PalletQuantity,
		   @TotalPackQty as TotalPackQty,
		   @Note as Note,
		   VFBG.PackQty,
		   EmpNo,
		   ProductionSize,
		   VFBG.PublicCode as PublicCode,
		   MM.MaterialName as PartNo,
		   TypeProduction,
		   USERID,
		   VFBG.Levels as Levels,
		   VFBG.SoPhieuNhapKho,
		   CODELOCATION,
		   @PO as PO,
		   @HH_PN as HH_PN

		    FROM STB_VN_FINISHGOODS_BG_Test_20251225 VFBG
                INNER JOIN Stb_SetInfo SI ON VFBG.LotNo = SI.Barcode
				LEFT JOIN STB_MaterialMaster MM ON VFBG.MaterialCode = MM.MaterialCode 
                WHERE VFBG.LotNo = @LotNo and VFBG.Statusout is null
	END
    END
	
END
