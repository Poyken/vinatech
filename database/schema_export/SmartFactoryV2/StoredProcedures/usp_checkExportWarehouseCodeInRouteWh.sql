-- Procedure: usp_checkExportWarehouseCodeInRouteWh
-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-07-17
-- Description:	Chặn nguyên vật liệu  phải được xuât ra sản xuất thì mới cho nhập lên màn hình B597
-- =============================================
-- exec usp_checkExportWarehouseCodeInRouteWh 'VVT_F2','ML202309200000501'
CREATE PROCEDURE [dbo].[usp_checkExportWarehouseCodeInRouteWh]
		@pRawMaterialBarcode  varchar(50) = Null,
		@pBarcode varchar(50) = NULL,
		@pProductGroupCode varchar(50)=NULL         
AS
BEGIN
 
	SET NOCOUNT ON;

	declare @InputLineCode varchar(30),
	@pPono varchar(30), 
	@CompanyCode varchar(30) , 
	@WorkCenterCode varchar(30),
	@Linecode varchar(50),
	@ExportLinecode varchar(50),
	@MaterialCode varchar(50),
	@count int=0,	
	@err nvarchar(500)
				
	-- Lấy mã Model Code của hàng Thành phẩm , mã code Cell hoặc Module
	select  @MaterialCode=MaterialCode ,@InputLineCode=InputLineCode , @pPono=PONo
	from STB_SetInfo  WITH(NOLOCK) where Barcode in (@pBarcode);

	-- lấy xem dữ liệu có trong bảng xuất kho chưa
	select @count = COUNT(*) from STB_MaterialWarehouseInOutHist where LotID=@pRawMaterialBarcode

	-- Lấy nhà máy sản xuất ra con hàng
	select @CompanyCode=CompanyCode,@WorkCenterCode = WorkCenterCode from STB_ProductionOrderInfo where PONo=@pPono

	if(@InputLineCode is null)
		begin
				SET @err = N'Lot hàng chưa biết sản xuất ở line nào vui lòng thêm mã line cho lot hàng !....'
				raiserror ( @err ,16,1)
				return
		end
		-- kiểm tra điều kiện khi không phải nvl điện cực
	if(@CompanyCode = 'VVT' and  UPPER(isnull(@pProductGroupCode,'')) not in ( 'ELECTRODEP','ELECTRODEM' ) and @pRawMaterialBarcode <> '')
		begin
			if(@count > 0)
				begin
					select top 1 @ExportLinecode = LineCode from STB_MaterialWarehouseInOutHist 
					where LotID=@pRawMaterialBarcode
					order by CreateDateTime desc
						
						if(@InputLineCode != @ExportLinecode)
							begin
								SET @err = N'NVL nhập không đúng mã line. Line cần nhập là : %s '
								raiserror ( @err ,16,1,@InputLineCode)
								return
							end
				end	
			else
				begin
						SET @err = N'NVL chưa được xuất ra sản xuất!... Liên hệ với kho nvl..'
						raiserror ( @err ,16,1)
						return
				end
		end

		-- kiểm tra điều kiện khi là nhập điện cực
	if(@CompanyCode = 'VVT' and  UPPER(isnull(@pProductGroupCode,'')) in ( 'ELECTRODEP','ELECTRODEM' ) and @pRawMaterialBarcode <> '')
		begin
			if(@count > 0)
				begin
					select @ExportLinecode = LineCode from STB_MaterialWarehouseInOutHist 
					where LotID=@pRawMaterialBarcode
					order by CreateDateTime desc

						if(@InputLineCode != @ExportLinecode)
							begin
								SET @err = N'NVL điện cực nhập không đúng mã line. Line cần nhập là : %s '
								raiserror ( @err ,16,1,@InputLineCode)
								return
							end
				end
	
	
		end

END


GO

