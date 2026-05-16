-- =============================================
-- Author : Mr.Tung
-- Date: 06-15-2021

--     usp_Vietnam_RawMaterialInputHist_uid  '','','','VVPM082R750609','Separator','ML20250225000112','','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_RawMaterialInputHist_uid]
	@pProcessUserID VARCHAR(20), 
	@pProcessLanguage VARCHAR(20), 
	@pRawMaterialInputHistNo VARCHAR(20)= NULL, 
	@pBarcode VARCHAR(20)			    = NULL ,	 
	@pProductGroupCode VARCHAR(20)	    = NULL , 
	@pRawMaterialBarcode NVARCHAR(200)   = NULL, 
	@pLotID_Warehouse_Created VARCHAR(20)	    = NULL ,  
	@pCreateDateTime DATETIME		    = NULL , 
	@pChangeDateTime DATETIME		    = NULL  ,
	@pMaterialCode VARCHAR(50)	    = NULL -- Mr.Duy check ha nam factory 2025-01-13 
AS

BEGIN
	
		Declare @err nvarchar(2000)=''; 

		--raiserror(@pRawMaterialBarcode,16,1)
	declare @validDate varchar(20);
	declare @MaterialCode varchar(50)=''
	Declare @count int=0; 
	DECLARE @RawMaterialBarcode NVARCHAR(200) =  @pRawMaterialBarcode

	DECLARE @LotMaterialBarcode NVARCHAR(200) =  @pRawMaterialBarcode	-- lấy mã nguyên liệu nhập vào không được thay đổi 
	DECLARE @BarcodeInsert NVARCHAR(200) =  @pBarcode -- lấy code của sản xuất nhập vào không được thay đổi 

	declare @ChildMaterialCode varchar(50)=@pMaterialCode -- đây là lấy mã code nguyên liệu trong BOM
	--raiserror(@MaterialCode,16,1)

	DECLARE @LotNonew1 VARCHAR(20) = ''
	DECLARE @LotNonew2 VARCHAR(20) = ''
	DECLARE @LotNonew3 VARCHAR(20) = ''
	DECLARE @LotNonew4 VARCHAR(20) = ''
	DECLARE @LotNonew5 VARCHAR(20) = ''
	DECLARE @LotNonew6 VARCHAR(20) = ''
	select @LotNonew1 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@pBarcode; 
	
	select @LotNonew2 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew1 ;

	select @LotNonew3 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew2 ;

	select @LotNonew4 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew3 ;

	select @LotNonew5 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew4 ;

	select @LotNonew6 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew5 ;
		
	
	declare @bangcode varchar(30)= @pBarcode;
	DECLARE @checkWorkCenterCode VARCHAR(10) = NULL
	-- Lấy mã Model Code của hàng Thành phẩm , mã code Cell hoặc Module
	--select @pBarcode = Barcode , @MaterialCode=MaterialCode
	--from STB_SetInfo   WITH(NOLOCK) where Barcode in (@pBarcode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6);
	
	select @pBarcode = Barcode , @MaterialCode=SI.MaterialCode, @checkWorkCenterCode = DPP.WorkCenterCode
	from STB_SetInfo SI  WITH(NOLOCK) 
	LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK) ON SI.DayPlanNo = DPP.DayPlanNo
	where Barcode in (@pBarcode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6);


	--- đoạn này nếu để MÃ Lót ở bên dưới đây , thì sẽ không kiểm tra gì cả , Lưu lại được luôn
	--Md.Diep request pass condition for this Lot 2023-07-31
	-- Mở thêm từ VVNU013R060614

	--check nvl đã được xuất ra sx hay chưa

	--Declare @InputLineCode1 varchar(50),@ExportLineCode
	
	/*
	if(@pCompanyCode = 'VVT' and  UPPER(isnull(@pProductGroupCode,'')) not in ( 'ELECTRODEP','ELECTRODEM' ) and @pRawMaterialBarcode <> '')
	begin
		exec usp_checkExportWarehouseCodeInRouteWh @pWorkCenterCode,@pRawMaterialBarcode,@Linecode output
	end
	
	
	--Kiểm tra xem hàng và nvl xuất có cùng line làm hay không 
	if(@InputLineCode <> @Linecode)
	begin
			declare @errorInput nvarchar(200) = N'Lot : ' +@pRawMaterialBarcode+N' được xuất ra line : '+@Linecode+N' không phải ra line bạn đang nhập vui lòng kiểm tra lại với kho !'

			RAISERROR(@errorInput,16,1)
	end
	*/


-- Chia nhà máy BG2 riêng
IF @checkWorkCenterCode NOT IN ('VVT_F4')
BEGI
