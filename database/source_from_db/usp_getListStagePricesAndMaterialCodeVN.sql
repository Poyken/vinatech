-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-10-08
-- Description:	Lấy danh sách giá tiền B682 và thêm mã hàng việt nam cho từng công đoạn
-- =============================================
CREATE PROCEDURE [dbo].[usp_getListStagePricesAndMaterialCodeVN]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pWorkCenterCode varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if(@pWorkCenterCode='VVT_F1')
	begin
			select 
				model,
			RouteV22,
			PriceV22,
			RouteV23,
			PriceV23,
			RouteV24,
			PriceV24,
			RouteV25,
			PriceV25,
			RouteV26,
			PriceV26,
			RouteV27,
			PriceV27,
			RouteV28,
			PriceV28,
			RouteV29,
			PriceV29,
			RouteV30,
			PriceV30,
			RouteV31,
			PriceV31,
			RouteV32,
			PriceV32,
			RouteV33,
			PriceV33,
			RouteV34,
			PriceV34,
			CreateDate,
			MaterialCodeVN_V22,
			MaterialCodeVN_V23,
			MaterialCodeVN_V24,
			MaterialCodeVN_V25,
			MaterialCodeVN_V26,
			MaterialCodeVN_V27,
			MaterialCodeVN_V28,
			MaterialCodeVN_V29,
			MaterialCodeVN_V30,
			MaterialCodeVN_V31,
			MaterialCodeVN_V32,
			MaterialCodeVN_V33,
			MaterialCodeVN_V34,
			WorkCenterCode
	from STB_VVT_StagePrices where WorkCenterCode=@pWorkCenterCode
	end
	else if (@pWorkCenterCode='VVT_F3')
	begin
				select 
				model,
				RouteVE01,
				RouteVE02,
				RouteVE03,
				RouteVE04,
				RouteVE05,
				RouteVE06,
				RouteVE07,
				RouteVE08,
				RouteVE09,
				RouteVE10,
				PriceVE01,
				PriceVE02,
				PriceVE03,
				PriceVE04,
				PriceVE05,
				PriceVE06,
				PriceVE07,
				PriceVE08,
				PriceVE09,
				PriceVE10,
			WorkCenterCode
	from STB_VVT_StagePrices where WorkCenterCode=@pWorkCenterCode
	end
END
