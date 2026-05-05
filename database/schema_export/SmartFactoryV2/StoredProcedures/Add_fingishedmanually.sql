-- Procedure: Add_fingishedmanually
create PROC Add_fingishedmanually
@IDCODE NVARCHAR(50),
@LotNo NVARCHAR(50),
@PackQty NVARCHAR(50),
@PublicCode NVARCHAR(50),
@PartNo NVARCHAR(50),
@SoPhieuNhapKho NVARCHAR(50),
@INPUTFROM NVARCHAR(50),
@CreateDate NVARCHAR(50)
as
begin
			INSERT INTO STB_VN_FINISHGOODS (IDCODE,LotNo,PackQty,PublicCode,PartNo,SoPhieuNhapKho,INPUTFROM,CreateDate,USERID,StatusSystem,MethodActions)
			VALUES (@IDCODE,@LotNo,@PackQty,@PublicCode,@PartNo,@SoPhieuNhapKho,@INPUTFROM,@CreateDate,'nguyentha',N'Nhập',N'Nhập bằng Excel')
end
GO

