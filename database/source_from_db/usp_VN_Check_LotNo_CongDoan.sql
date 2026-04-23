CREATE PROC [dbo].[usp_VN_Check_LotNo_CongDoan] --  exec usp_VN_Check_LotNo_CongDoan 'VVOJ082R718613','V-22_BG'
@LotNo NVARCHAR(50),
@Stages NVARCHAR(50)
AS
BEGIN
		SELECT TOP(1)*
		FROM
				STB_VN_STAGES_TRANSFER WITH(NOLOCK)
		WHERE
				Barcode = @LotNo AND RouteCode = @Stages
END