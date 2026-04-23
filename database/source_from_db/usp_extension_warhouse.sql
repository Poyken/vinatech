CREATE PROC [dbo].[usp_extension_warhouse]
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

exec usp_VVT_checkHOLD_QC @pLotNo=@LotNo

 INSERT INTO STB_VN_FINISHGOODS
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