-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2026-04-06
-- Description:	Thêm dữ liệu bổ sung nhâp kho thành phẩm cho nhà máy BG2
-- =============================================
CREATE PROCEDURE usp_extension_warhouse_BG2 
	-- Add the parameters for the stored procedure here
@IDCODE NVARCHAR(500),
@PhieuNhapKho NVARCHAR(50),
@PhieuXuatKho NVARCHAR(50),
@Maketoan NVARCHAR(50),
@QuocGia NVARCHAR(50),
@SoInvoice NVARCHAR(50),
@LotNo NVARCHAR(50),
@ToKhaiHaiQuan NVARCHAR(50),
@MaNguyenLieu NVARCHAR(50),
@TenSanPham NVARCHAR(50),
@SoLuong NVARCHAR(50),
@KichCo NVARCHAR(50),
@PartNo NVARCHAR(50),
@TrangThaiNhapKho NVARCHAR(50),
--@TrangThaiXuatKho NVARCHAR(50),
@ViTri NVARCHAR(50),
@CapDo NVARCHAR(50),
@KieuXuat NVARCHAR(50),
@NhapTuDau NVARCHAR(50),
@USERID NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
exec usp_VVT_checkHOLD_QC @pLotNo=@LotNo

 INSERT INTO STB_VN_FINISHGOODS_BG2
 (
	IDCODE,
	SoPhieuNhapKho,
	SoPhieuXuatKho,
	PublicCode,
	Country,
	SoInVoice,
	LotNo,
	SoToKhaiHaiQuan,
	MaterialCode,
	MaterialName,
	PackQty,
	ProductionSize,
	PartNo,
	StatusSystem,
	--Statusout,
	LOCATIONS,
	Levels,
	TYPEEXPORT,
	INPUTFROM,
	CreateDate,
    USERID,
	MethodActions
 )
 VALUES
 (
	@IDCODE,
	@PhieuNhapKho,
	@PhieuXuatKho,
	@Maketoan,
	@QuocGia,
	@SoInvoice,
	@LotNo,
	@ToKhaiHaiQuan,
	@MaNguyenLieu,
	@TenSanPham,
	@SoLuong,
	@KichCo,
	@PartNo,
	@TrangThaiNhapKho,
	--@TrangThaiXuatKho,
	@ViTri,
	@CapDo,
	@KieuXuat,
	@NhapTuDau,
	GETDATE(),
	@USERID,
	N'Nhập bằng Excel'
 )
END
