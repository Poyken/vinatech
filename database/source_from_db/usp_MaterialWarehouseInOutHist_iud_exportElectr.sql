-- =============================================
-- Author:		Mr.Duy
-- Create date: 9/7/2024
-- Description:	Thêm mới và chuyển các lot cho điện cực tính toán số lượng được xuất ra ngoài sx
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialWarehouseInOutHist_iud_exportElectr]
							    @pProcessUserID varchar(20),
								@pProcessLanguage varchar(20),
								@pBarcode VARCHAR(20)= NULL ,	 
								@pLotMaterialBarcode VARCHAR(500) = NULL,
								@pExportSlitingLength numeric(20,5),
								@pcrud varchar(10)
								
AS

BEGIN
declare @companyElect varchar(50),
		@workcentElect varchar(50),
		@ExportSlitingLengthResult numeric(20,5)=0,
		@InputLineCode varchar(50)
	
     	--RAISERROR('Mã loafdsfsf %s' ,16, 1,@pcrud)
-- lấy linecode của con hàng khi xuất kho
select @InputLineCode=li.LineCode , @companyElect= dpl.CompanyCode,@workcentElect = dpl.WorkCenterCode
	from STB_SetInfo  st
	inner join STB_DayProdPlan dpl on st.DayPlanNo = dpl.DayPlanNo
	inner join STB_LineInfo li on dpl.LineCode = li.LineCode 
	where Barcode in (@pBarcode)

	--select * from STB_ElectrodeSlittingResult where barcode='VVOQ1020001E06-016'
					--đổi định dạng theo a huy anh tính trên bom 2024-15-08
--select @ExportSlitingLengthResult = ((esr.SlittingWidth/1000)*esr.GoodQtyLength)/0.5 
select @ExportSlitingLengthResult = esr.GoodQtyLength
from STB_ElectrodeSlittingResult esr
inner join 
Stb_setInfo st  on st.Barcode = esr.ElectrodeLotNumber
inner join STB_DayProdPlan dpl on st.DayPlanNo = dpl.DayPlanNo
 where esr.barcode=@pLotMaterialBarcode


   Declare @MaterialWarehouseInOutHistNo VARCHAR(20)
   DECLARE @LotMaterialBarcode NVARCHAR(200) =  @pLotMaterialBarcode	


	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialWarehouseInOutHist',@MaterialWarehouseInOutHistNo OUTPUT

	declare @checkcountmaterialElectro int = 0,@MaterialWarehouseInOutHistNoOld varchar(20)

	 select top 1 @checkcountmaterialElectro = COUNT(*),
	 @MaterialWarehouseInOutHistNoOld=MaterialWarehouseInOutHistNo 
	 from STB_MaterialWarehouseInOutHist 
	 where LotID=@LotMaterialBarcode
	 group by MaterialWarehouseInOutHistNo , CreateDateTime
	 order by CreateDateTime desc


				if(@checkcountmaterialElectro < 1 and @pcrud = 'insert' )
					begin
					INSERT INTO STB_MaterialWarehouseInOutHist (
														MaterialWarehouseInOutHistNo
														,CompanyCode
														,WorkCenterCode
														,SourceMaterialWarehouseCode
														,TargetMaterialWarehouseCode
														,WarehouseInOutCode
														,LotID
														,WorkerCode
														,LineCode
														,CreateUserID
														,Status_Confirm_Export
														,ExportSlitingLength
														) VALUES  (
														   @MaterialWarehouseInOutHistNo
														  ,@companyElect
														  ,@workcentElect
														  ,'ELEC_VN_WH'
														  ,Case
														   when @workcentElect='VVT_F1' then 'ROUTE_VN_WH' else 'ROUTE_BG_WH' end
														  ,'O'
														  ,@pLotMaterialBarcode
														  ,'32205004'
														  ,@InputLineCode
														  ,@pProcessUserID
														  ,1
														  ,@ExportSlitingLengthResult
																		            )
					end
			if(@pcrud = 'update')
					begin
					-- thêm khi chuyển line vẫn là xuất kho
						INSERT INTO STB_MaterialWarehouseInOutHist (
														MaterialWarehouseInOutHistNo
														,CompanyCode
														,WorkCenterCode
														,SourceMaterialWarehouseCode
														,TargetMaterialWarehouseCode
														,WarehouseInOutCode
														,LotID
														,WorkerCode
														,LineCode
														,CreateUserID
														,Status_Confirm_Export
														,ExportSlitingLength
														) VALUES  (
														   @MaterialWarehouseInOutHistNo
														  ,@companyElect
														  ,@workcentElect
														  ,'ELEC_VN_WH'
														  ,Case
														   when @workcentElect='VVT_F1' then 'ROUTE_VN_WH' else 'ROUTE_BG_WH' end
														  ,'O'
														  ,@pLotMaterialBarcode
														  ,'32205004'
														  ,@InputLineCode
														  ,@pProcessUserID
														  ,1
														  ,@pExportSlitingLength
																		            )
					update STB_MaterialWarehouseInOutHist
					set ExportSlitingLength = ExportSlitingLength - @pExportSlitingLength
					where MaterialWarehouseInOutHistNo = @MaterialWarehouseInOutHistNoOld
					--Cập nhật lại chiều dài đã sử dụng ở line cũ
					
					end
			-- INSERT문
			
			if(@pcrud = 'view')
			begin
				declare @countInOut varchar(50)
				select @countInOut = COUNT(*) from Stb_SlittingStock_VVT a
				inner join STB_MaterialWarehouseInOutHist b on a.Barcode = b.LotID
				where a.barcode = @pLotMaterialBarcode
				if(@countInOut = 0)
					begin
					 RAISERROR('Mã lot này chưa nhập trên hệ thống nên không chuyển line được : %s' ,16, 1,@pLotMaterialBarcode)
					 return
					end
				select a.Barcode as LotMaterialBarcode,
				case
							when  isnull(a.MaterialCode,'') like 'CR%' and  CHARINDEX('-', isnull(a.MaterialCode,'')) > 0  
								then
									-- xóa chuỗi sau dấu (-) nếu tìm thấy và đổi kí tự đầu tiên thành S
								   STUFF(SUBSTRING(isnull(a.MaterialCode,''), 1, CHARINDEX('-', isnull(a.MaterialCode,''))-1), 1, 1, 'S')  
								else
								isnull(a.MaterialCode,'')
							end  as MaterialCode
				,b.ExportSlitingLength
				,'test' as crud
				 from Stb_SlittingStock_VVT a
				inner join STB_MaterialWarehouseInOutHist b on a.Barcode = b.LotID
				where a.barcode = @pLotMaterialBarcode
			end
			
			if(@pcrud = 'test')
			begin
			 RAISERROR('Mã lo' ,16, 1)
			end
END