-- Procedure: usp_CodeNVL_B598
CREATE PROC [dbo].[usp_CodeNVL_B598]
@pLoaiHang NVARCHAR(50) = null
AS
BEGIN
		SELECT
				CODENVL AS MaLotNguyenLieu, NAMESNVL AS Model,UNIT AS UNIT
		FROM STB_VN_B598 WITH(NOLOCK)
		WHERE LOAIHANG = @pLoaiHang AND IsDeleted=1
			
END

GO

