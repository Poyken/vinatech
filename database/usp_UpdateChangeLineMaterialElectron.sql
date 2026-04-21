Text
----
-- =============================================

-- Author:		Mr.Duy

-- Create date: 2024-08-13

-- Description:	Chuy?n line cho nguyên li?u di?n c?c

-- =============================================

CREATE PROCEDURE [dbo].[usp_UpdateChangeLineMaterialElectron] 

	@pProcessUserID varchar(20),

								@pProcessLanguage varchar(20),

								@pLotMaterialBarcode VARCHAR(500) = NULL,

								@pLineCode varchar(20)=NULL

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;



	-- ki?m tra xem s? lu?ng còn bao nhiêu

			declare @nvlcon varchar(30)

					-- L?y ra danh sách barcode c?a di?n c?c nh?p

						;with listbarcode as(

						select * from STB_RawMaterialInputHist where (RawMaterialBarcode=@pLotMaterialBarcode  or Lotmaterialcode=@pLotMaterialBarcode)



						),

						exportNVL as (

									select  WarehouseInOutCode,PRO.MaterialWarehouseInOutHistNo,PRO.CompanyCode,PRO.WorkCenterCode,PRO.SourceMaterialWarehouseCode,PRO.TargetMaterialWarehouseCode,

													PRO.LotID,PRO.LineCode,

							

													--isnull(MLI.MaterialCode,si.MaterialCode) as MaterialCode

													--ki?m tra có b?t d?u b?ng CR không. ki?m tra có d?u (-) trong chu?i không

													case

													when  isnull(MLI.MaterialCode,si.MaterialCode) like 'CR%' and  CHARINDEX('-', isnull(MLI.MaterialCode,si.MaterialCode)) > 0  

														then

															-- xóa chu?i sau d?u (-) n?u tìm th?y và d?i kí t? d?u tiên thành S

														   STUFF(SUBSTRING(isnull(MLI.MaterialCode,si.MaterialCode), 1, CHARINDEX('-', isnull(MLI.MaterialCode,si.MaterialCode))-1), 1, 1, 'S')  

														else

														isnull(MLI.MaterialCode,si.MaterialCode) 

													end  as MaterialCode

													,case 

													when esr.GoodQtyLength is not null

													then

													(esr.GoodQtyLength*(esr.SlittingWidth/1000))/0.5

													else

													MLI.CurrentQty

													end

													 as CurrentQty,

													  esr.GoodQtyLength,

													 esr.SlittingWidth

													 from STB_MaterialWarehouseInOutHist PRO

													left join STB_MaterialLotInfo MLI on PRO.LotID = MLI.LotID

													left join STB_ElectrodeSlittingResult esr on PRO.LotID = esr.Barcode

													left join STB_SetInfo si on esr.ElectrodeLotNumber = si.Barcode

													where 

													 1=1

													And WarehouseInOutCode = 'O'

													 and PRO.lotid=@pLotMaterialBarcode

													 AND PRO.CompanyCode = 'VVT' 

						),

							exportNVL1 as ( -- t?ng h?p l?i s? nvl dã chuy?n ra line

							select  WarehouseInOutCode,CompanyCode,WorkCenterCode,SourceMaterialWarehouseCode,TargetMaterialWarehouseCode,

								LotID, MaterialCode,GoodQtyLength,SlittingWidth,Sum(CurrentQty) as CurrentQty

								from exportNVL

								group by   WarehouseInOutCode,CompanyCode,WorkCenterCode,SourceMaterialWarehouseCode,TargetMaterialWarehouseCode,

								LotID, MaterialCode,GoodQtyLength,SlittingWidth

						)

						,

						RawView0 as(

						select  c.PONo,b.CreateUserID,c.Barcode,b.RouteCode,b.RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,

									sum(b.ProdQty) as ProdQty,sum(a.DefectQty) as DefectQty,

									max(b.ProdDateTime) as ProdDateTime, max(b.CreateDateTime) as CreateDateTime

									from  STB_SetInfo c with(nolock) 

									 left outer join  STB_ProdRouteHist      b	 with(nolock) on c.ControlNo=b.ControlNo	

									 left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=c.ControlNo and a.FindRouteCode = b.RouteCode

									 left outer join listbarcode l on c.barcode = l.barcode 

									 where 1=1

									and c.Barcode = l.barcode

									and (b.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','dryroom_worker' ) or b.CreateUserID is null)

									 group by c.PONo,b.CreateUserID,c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,b.ProdQty,a.DefectQty,a.DefectCode--,b.CreateDateTime

									 ),

							RawView as ( -- T?ng h?p l?i các barcode ? trên g?p l?i d? tính t?ng l?i theo t?ng công do?n

	 								select  PONo,CreateUserID,Barcode,RouteCode, FindRouteCode,

									ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01,

									max(ProdQty) as ProdQty, 

									sum(DefectQty) as DefectQty ,

									max(ProdDateTime) as ProdDateTime, 

									max(CreateDateTime) as CreateDateTime

									from  RawView0	

									where 

									1=1

									--and InputLineCode='VVC-01'  

									and  SUBSTRING (Barcode, 1, 1) !='M' 

									 group by PONo,CreateUserID,Barcode,RouteCode,FindRouteCode,ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01 --,a.DefectCode--,b.CreateDateTime

							)

							,

							selectall as( --L?y du?c ra Inputlinecode và MaterialCode  d? link sang boom nhân ra s? lu?ng nvl dã s? d?ng

							select PONo,Barcode,RouteCode ,MaterialCode,InputlineCode ,ISNULL(max(ProdQty),0) as ProdQty,ISNULL(sum(DefectQty),0) as DefectQty from RawView r

							group by PONo,Barcode,MaterialCode,InputLineCode,RouteCode

							),

							selectversion as ( -- xác d?nh xem Bomversion dang du?c s? d?ng là bao nhiêu

							select  BomVersion , BomUnit, PONo,Barcode ,sa.MaterialCode,sa.RouteCode,InputlineCode,IsUsed ,ProdQty,DefectQty  from STB_BomHeader BH

							left outer join selectall sa on Bh.MaterialCode = sa.MaterialCode

							where 

							 IsUsed=1 and BH.MaterialCode=sa.MaterialCode and BomVersion='99'--order by BomVersion desc 

				

							 )

							 , BomCTE AS --Tính toán s? lu?ng nvl dã s? d?ng

									(

										SELECT					

												CONVERT(VARCHAR,ROW_NUMBER() OVER(ORDER BY BD.MaterialCode)) AS Id,

												CONVERT(VARCHAR,NULL) AS ParentId,

												BD.MaterialCode, 

												BD.BomVersion, 

												BD.ChildMaterialCode, 

												BD.ChildBomVersion,

												MaterialName,

												isnull(BD.BomUnit,MaterialUnit) as BomUnit,

												sv.BomUnit AS ParentBomHeaderUnit,

												sv.InputLineCode,

												(

													SELECT

															BH.BomUnit

													FROM

															STB_BomHeader BH

													WHERE

															BH.MaterialCode = BD.ChildMaterialCode AND

															BH.BomVersion = BD.ChildBomVersion

												) AS BomHeaderUnit,

												MM.MaterialUnit,

												BD.UsedQty,

												CONVERT(NUMERIC(20,5), SmartFramework.dbo.fnConvertUnit(BD.BomUnit, sv.BomUnit,BD.UsedQty)) AS ParentBomHeaderUnitUsedQty,					

												CONVERT(NUMERIC(20,5), SmartFramework.dbo.fnConvertUnit(BD.BomUnit, sv.BomUnit,BD.UsedQty * sv.ProdQty)) AS ParentBomHeaderUnitTotalQty,

												CONVERT(NUMERIC(38,19), SmartFramework.dbo.fnConvertUnit(BD.BomUnit, MM.MaterialUnit,SmartFramework.dbo.fnConvertUnit(BD.BomUnit, sv.BomUnit,BD.UsedQty))) AS MaterialUnitUsedQty,

												CONVERT(NUMERIC(20,5), SmartFramework.dbo.fnConvertUnit(BD.BomUnit, MM.MaterialUnit,SmartFramework.dbo.fnConvertUnit(BD.BomUnit, sv.BomUnit,BD.UsedQty * sv.ProdQty))) AS MaterialUnitTotalQty,

												CONVERT(NUMERIC(20,5),BD.UsedQty * sv.ProdQty) as TotalNvlTToQty,

												BD.RouteCode,

												BD.IsOptionItem,

												CONVERT(BIT, 1) AS IsUseOption,

												CASE 

													WHEN ISNULL(MM.IsProdPlan,0) = 1 OR ISNULL(MM.IsPurchase,0) = 1 THEN  1

													ELSE 0

												END AS IsParentUseProduction,

												CASE 

													WHEN ISNULL(MM.IsProdPlan,0) = 1 OR ISNULL(MM.IsPurchase,0) = 1 THEN  1

													ELSE 0

												END AS IsUseProduction,

												MM.IsPurchase,

												MM.IsOrder,

												MM.IsProdPlan,

												ISNULL(MM.RequestGrDay,0) AS RequestGrDay,

												ISNULL(MM.RequestGrDay,0) AS TotalGrDay

										FROM

												STB_BomDetail BD

												INNER JOIN STB_MaterialMaster MM

													ON	MM.MaterialCode = BD.ChildMaterialCode

												inner join selectversion sv on BD.MaterialCode = sv.MaterialCode 

										WHERE

												BD.MaterialCode = sv.MaterialCode AND

												BD.BomVersion = sv.BomVersion

												AND sv.RouteCode like '%'+BD.RouteCode+'%' -- do sv.RouteCode V-24_Bg nên trong BD.RouteCode ch? có V-24.. thì c?n s? d?ng like thay vì so sánh =

		

									)

									,ket as( -- t?ng s? lu?ng nvl g?p theo nhi?u di?u ki?n group by

								 select InputLineCode,MaterialName,BomVersion,ChildMaterialCode,BomUnit,MaterialUnit,UsedQty,ParentBomHeaderUnitUsedQty,SUM(ParentBomHeaderUnitTotalQty) as ParentBomHeaderUnitTotalQty,

								   MaterialUnitUsedQty, SUM(MaterialUnitTotalQty) as MaterialUnitTotalQty,

	   								 SUM(TotalNvlTToQty) as TotalNvlTToQty

								   from BomCTE

								   group by InputLineCode,MaterialName,BomVersion,ChildMaterialCode,BomUnit,MaterialUnit,UsedQty,ParentBomHeaderUnitUsedQty,

								   MaterialUnitUsedQty

								   ),

								   totalQty as ( -- t?ng s? lu?ng nvl dã dùng cho hàng theo nhi?u di?u ki?n group by

										select k.MaterialName,k.BomVersion,k.BomUnit/*,UsedQty*/,k.ChildMaterialCode , Sum(k.MaterialUnitTotalQty)as MaterialUnitTotalQty

										,Sum(k.TotalNvlTToQty) as TotalNvlTToQty

										from ket k 

										group by MaterialName,BomVersion,BomUnit,ChildMaterialCode--,UsedQty

								   ),

								   /*

								   totalQty1 as ( 

										select k.MaterialName,k.BomVersion,k.BomUnit/*,UsedQty*/,k.ChildMaterialCode,GoodQtyLength,SlittingWidth , SUM(k.MaterialUnitTotalQty) as MaterialUnitTotalQty

										,SUM(k.TotalNvlTToQty) as TotalNvlTToQty

										,SUM(e.CurrentQty) as NVLXuat

										 ,

										 case 

													when GoodQtyLength is not null

													then

													 (SUM(e.CurrentQty-k.TotalNvlTToQty)*0.5)/(SlittingWidth/1000)

													else

													 SUM(e.CurrentQty-k.TotalNvlTToQty)

													end

														as nvlcon

										from totalQty k inner join exportNVL1 e on

										

										-- k.ChildMaterialCode = 'SREYO85A'

										 e.MaterialCode like '%'+substring(k.ChildMaterialCode,0,8)+'%'

										group by MaterialName,BomVersion,BomUnit,ChildMaterialCode,GoodQtyLength,SlittingWidth

								   )

									*/

									totalQty1 as ( 

										select  k.BomVersion,k.BomUnit/*,UsedQty*/,GoodQtyLength,SlittingWidth , SUM(k.MaterialUnitTotalQty) as MaterialUnitTotalQty

										,SUM(k.TotalNvlTToQty) as TotalNvlTToQty

										,Max(e.CurrentQty) as NVLXuat

										 ,

										 case 

													when GoodQtyLength is not null

													then

													 ((Max(e.CurrentQty)-SUM(k.TotalNvlTToQty))*0.5)/(SlittingWidth/1000)

													else

													 Max(e.CurrentQty)-SUM(k.TotalNvlTToQty)

													end

														as nvlcon

										from totalQty k 

										inner join exportNVL1 e on

										

										-- k.ChildMaterialCode = 'SREYO85A'

										 e.MaterialCode like '%'+substring(k.ChildMaterialCode,0,7)+'%'

										group by BomVersion,BomUnit,GoodQtyLength,SlittingWidth

								   )

								   select @nvlcon=nvlcon from totalQty1

								   --end ki?m tra s? nvl còn khi dã s? d?ng

		if((@pLineCode is null or @pLineCode = '') and @pLotMaterialBarcode <> ''  )

		begin

			RAISERROR('S? luong còn l?i là  : %s ' ,16, 1,@nvlcon)

						return 0;

		end

		-- ki?m tra xem line dã ch?n chua

		if(@pLineCode is null)

		begin 

					RAISERROR('B?n chua ch?n line chuy?n  : %s' ,16, 1,@pLineCode)

						return 0;

		end 



		declare @total int = 0

		select @total = count(*) from STB_MaterialWarehouseInOutHist where Lotid=@pLotMaterialBarcode 

		group by MaterialWarehouseInOutHistNo , CreateDateTime

		order by CreateDateTime desc

		if(@total < 1)

			begin

						RAISERROR('Mã lot này chua du?c nh?p lên h? th?ng B597 nên không chuy?n line du?c : %s' ,16, 1,@pLotMaterialBarcode)

						return

			end

		else

			begin

			   Declare @MaterialWarehouseInOutHistNo VARCHAR(20)

			   DECLARE @LotMaterialBarcode NVARCHAR(200) =  @pLotMaterialBarcode	





				EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialWarehouseInOutHist',@MaterialWarehouseInOutHistNo OUTPUT



				declare @MaterialWarehouseInOutHistNoOld varchar(20),@totalNum numeric(20,5) =0, @presentLine varchar(20)



				 select top 1 

				 @MaterialWarehouseInOutHistNoOld=MaterialWarehouseInOutHistNo ,@totalNum = ExportSlitingLength,@presentLine = LineCode

				 from STB_MaterialWarehouseInOutHist 

				 where LotID=@LotMaterialBarcode

				 order by CreateDateTime desc





				 -- Ki?m tra trùng line

				 	 if(@pLineCode = @presentLine)

					 begin

					 RAISERROR('Mã di?n c?c này dang ? line b?n mu?n chuy?n : %s' ,16, 1,@pLineCode)

							return

					 end



				 -- thêm khi chuy?n line v?n là xu?t kho

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

														) 

					select top 1  @MaterialWarehouseInOutHistNo,CompanyCode,WorkCenterCode,SourceMaterialWarehouseCode,TargetMaterialWarehouseCode,WarehouseInOutCode,

					@LotMaterialBarcode,WorkerCode,@pLineCode,CreateUserID,Status_Confirm_Export,@nvlcon

					 from STB_MaterialWarehouseInOutHist 

					 where LotID=@LotMaterialBarcode

					  order by CreateDateTime desc



					 --C?p nh?t l?i chi?u dài dã s? d?ng ? line cu

					update STB_MaterialWarehouseInOutHist

					set ExportSlitingLength = ExportSlitingLength - @nvlcon

					where MaterialWarehouseInOutHistNo = @MaterialWarehouseInOutHistNoOld

					



					--l?y d? li?u ra view khi chuy?n thành công

					select top 1 MaterialWarehouseInOutHistNo,LotID,@presentLine as beforeLine,LineCode as afterLine,ExportSlitingLength

						 from STB_MaterialWarehouseInOutHist 

						 where MaterialWarehouseInOutHistNo=@MaterialWarehouseInOutHistNo

			 end

END

