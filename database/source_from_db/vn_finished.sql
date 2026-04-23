CREATE PROC [dbo].[vn_finished] --exec vn_finished
@LotNo NVARCHAR(50),
@PackQty NVARCHAR(50),
@PublicCode NVARCHAR(50),
@PartNo NVARCHAR(50),
@SoPhieuNhapKho NVARCHAR(50),
@INPUTFROM NVARCHAR(50),
@CreateDate NVARCHAR(50),
@IDCODE NVARCHAR(50)
as
begin
INSERT INTO STB_VN_FINISHGOODS (LotNo,PackQty,PublicCode, PartNo,SoPhieuNhapKho,INPUTFROM,CreateDate,IDCODE,Statusout,USERID,MethodActions)
VALUES (@LotNo,@PackQty,@PublicCode,@PartNo,@SoPhieuNhapKho,@INPUTFROM,@CreateDate,@IDCODE,N'Nhập','nguyentha',N'Nhập bằng Excel')
end