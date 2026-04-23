

CREATE PROCEDURE usp_ThongTinLoaiHangThemVaoPhe
(
    @pFromdate DATE = NULL,
	@pToDate DATE = NULL,
	@pLine VARCHAR(100) = NULL,
	@pModel VARCHAR(100) = NULL,
	@pWorkCenterCode VARCHAR(100) = NULL
)
AS
BEGIN

select * from STB_VN_B598

END