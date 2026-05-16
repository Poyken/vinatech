

-- =========================================================================

-- Author:	    Kim Han Young(hykim@awoo.co.kr)

-- Create date: 2016-06-21

-- Browsable : true

-- Group : 자재관리 > 자재재고리스트 Main  / 자재관리 > [F710]자재재고정보 > Grid2.자재재고리스트

-- Description:	재고 자재리스트를 조회합니다.

-- Modified:

--               단가, 환종, 금액, 환산금액 추가 #200611 Jackaroe

--               검색 속도 개선을 위해 검색조건 변경 #200611 Jackaroe

--               2020.06.16 라벨인쇄기능추가 (구보겸)



-- [usp_vvt_MaterialLotInfo_get] '','','VVT', 'VVT_F1', 'HOLDING_VN_WH', '',  '',  '',  '',  '',  '',  '',  '',  '',  '',  '',  ''

-- [usp_vvt_MaterialLotInfo_get] '','','VVT', 'VVT_F4', 'MODULE_BG2_WH', '',  '',  '',  '',  '',  '',  '',  '',  '',  '',  '',  ''

-- [usp_vvt_MaterialLotInfo_get] '','','VVT', 'VVT_F3', 'ROH_HN_WH', '',  '',  '',  '',  '',  '',  '',  '',  '',  '',  '',  ''



-- [usp_vvt_MaterialLotInfo_get] '','','VVT', 'VVT_F3', 'ROH_HN_WH', '',  '',  '',  '',  '',  '',  '',  '',  '',  '',  '',  ''



-- [usp_vvt_MaterialLotInfo_get] '','','VVT', '', 'ROH_BG_ƯH', '',  '',  '',  '',  '',  '',  '',  '',  '',  '',  ''



-- =========================================================================

CREATE PROCEDURE [dbo].[usp_vvt_MaterialLotInfo_get]

						@pProcessUserID VARCHAR(20),

						@pProcessLanguage VARCHAR(20),

						@pCompanyCode VARCHAR(30) = NULL,

						@pWorkCenterCode VARCHAR(30) = NULL,

						@pMaterialWarehouseCode VARCHAR(50) = NULL,

						@pMaterialLocationCode VARCHAR(50) = NULL,

						@pMaterialCode VARCHAR(50) = NULL,

						@pMaterialStockAttribute VARCHAR(50) = NULL,

						@pStockAttrib1 VARCHAR(50) = NULL,

						@pStockAttrib2 VARCHAR(50) = NULL,

						@pStockAttrib3 VARCHAR(50) = NULL,

						@pBasicMaterialType VARCHAR(50) = NULL,

						@pExcludeBasicMaterialTypes VARCHAR(500) = NULL,

						@pMaterialTypeCode VARCHAR(50) = NULL,

						@pProductGroupCode VARCHAR(50) = NULL,

						@pCanPickingOnly BIT = NULL,	                                          -- 피킹이 가능한 재고만 조회

						@pLotID varchar(50) = Null,                                                  -- M.SH

						@pTargetMaterialLocationCode VARCHAR(50) = NULL

					--	@pLabelType NVARCHAR(60) = NULL                                     -- 2020.06.16 추가 (구보겸)

AS

BEGIN

	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END

	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END

	DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END

	DECLARE @MaterialLocationCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialLocationCode,'') = '' THEN '*' ELSE @pMaterialLocationCode END

	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END



	DECLARE @TargetMaterialLocationCode VARCHAR(50) = @pTargetMaterialLocationCode 

	--DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' 

	--                                                               WHEN @pMaterialCode = '%'  THEN '*' 	ELSE @pMaterialCode END

	--RAISERROR( @MaterialCode ,16, 1)

	DECLARE @MaterialStockAttribute VARCHAR(20) = CASE WHEN ISNULL(@pMaterialStockAttribute,'') = '' THEN '*' ELSE @pMaterialStockAttribute END

	DECLARE @StockAttrib1 VARCHAR(20) = CASE WHEN ISNULL(@pStockAttrib1,'') = '' THEN '*' ELSE @pStockAttrib1 END

	DECLARE @StockAttrib2 VARCHAR(20) = CASE WHEN ISNULL(@pStockAttrib2,'') = '' THEN '*' ELSE @pStockAttrib2 END

	DECLARE @StockAttrib3 VARCHAR(20) = CASE WHEN ISNULL(@pStockAttrib3,'') = '' THEN '*' ELSE @pStockAttrib3 END

	DECLARE @BasicMaterialType VARCHAR(20) = CASE WHEN ISNULL(@pBasicMaterialType,'') = '' THEN '*' ELSE @pBasicMaterialType END

	DECLARE @ExcludeBasicMaterialTypes VARCHAR(100) = @pExcludeBasicMaterialTypes

	DECLARE @MaterialTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '*' ELSE @pMaterialTypeCode END

	DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '*' ELSE @pProductGroupCode END

	DECLARE @CanPickingOnly BIT = ISNULL(@pCanPickingOnly, 0)

	DECLARE @LotID varchar(50) =CASE WHEN ISNULL(@pLotID,'') = '' THEN '*' ELSE @pLotID END -->M.SH

	--DECLARE @LabelType               NVARCHAR(60) = @pLabelType                                           -- 2020.06.16 추가 (구보겸)

    



	--if(@pProcessUserID='nguyentung')

	--begin

	--	raiserror (@MaterialWarehouseCode,16,1);

	--	return;

	--end

		declare @companycodeu varchar(10)='',

			@workcentercodeu varchar(10) = '';

	select @companycodeu = companycode,

			@workcentercodeu = WorkCenterCode

	from STB_UserInfo

	where UserID=@pProcessUserID









					--- cập nhật dữ liệu Ngay Thang SX của Vendor cho những Lót bị trống Ngay Thang SX

						UPDATE STB_MaterialDocLotInfo  

						 SET   LotAttr10 =  [dbo].[fn_VVT_getdatebyVendorLot](materialcode,    case  when LotNo not like materialcode+'%' then LotNo when LotNo like materialcode+'#%' then stuff(LotNo,1,len(materialcode)+1,'') else  stuff(LotNo,1,len(materialcode),'') end)
  

						where replace(isnull(LotAttr10,''),' ','')='' and isnull(LotNo,'')<>''

						and MaterialLocationCode not like 'PROD%'

						and (MaterialLocationCode like '%VN_WH' or MaterialLocationCode like '%BG_WH' or MaterialLocationCode like '%HN_WH' or MaterialLocationCode LIKE '%BG2_WH')

						



						UPDATE STB_MaterialLotInfo  

						 SET   LotAttr10 =  [dbo].[fn_VVT_getdatebyVendorLot](materialcode,    case  when LotNo not like materialcode+'%' then LotNo when LotNo like materialcode+'#%' then stuff(LotNo,1,len(materialcode)+1,'') else  stuff(LotNo,1,len(materialcode),'') end) 
 

						where replace(isnull(LotAttr10,''),' ','')='' and isnull(LotNo,'')<>''

						and MaterialLocationCode not like 'PROD%'

						and (MaterialLocationCode like '%VN_WH' or MaterialLocationCode like '%BG_WH' or MaterialLocationCode like '%HN_WH' or MaterialLocationCode LIKE '%BG2_WH')

														

if(@MaterialWarehouseCode <> 'ROH_VN_WH')  --tiến hành audit cho bắc giang

begin

print('1')

;WITH LABELINFO AS

	(

		SELECT

				RANK() OVER (PARTITION BY LI.LabelType,LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,

				LI.LabelType,

				LI.FormatName,

				LI.CommandType,

				LI.Dpi,

				LI.PrinterName

		FROM

				SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)

		WHERE

				LI.IsApproval = 1 AND

				LI.ApplyDate <= GETDATE()

	),

	 basedat as (

				select a1.LotID--a1.materialcode as mat,a1.StockAttrib1,a1.StockAttrib2,a1.StockAttrib3,a1.MaterialStockAttribute, sum(stockqty) as stock,isnull(MDI.SourceCustomerCode,MaterialDocTypeCode) as SourceCustomerCode,cI2.CustomerName

			from	[SmartFactoryV2].[dbo].[STB_MaterialDocLotInfo] a1 WITH(NOLOCK)

			LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo = a1.MaterialDocDetailNo 

			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)   on MDD.MaterialDocNo = MDI.MaterialDocNo

						--left outer join STB_CustomerInfo ci2  WITH(NOLOCK) on MDi.SourceCustomerCode = ci2.CustomerCode 



			 where  

			 (@pMaterialWarehouseCode='TOTAL_MATERIALS'    and MaterialLocationCode not like 'PROD%'    and  MaterialLocationCode  not like 'ROUTE%'

							 or MaterialLocationCode like @MaterialWarehouseCode+'%'

					)

			and (select  count(*) from [SmartFactoryV2].[dbo].[STB_MaterialDocLotInfo]  WITH(NOLOCK) where LotID=a1.lotid and materiallotno is not null ) = 0 --and materiallotno is not null



			and (select  count(*) from [SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  WITH(NOLOCK) where LotID=a1.lotid  ) = 0 ---dd

			and (select  count(*) from [SmartFactoryV2].[dbo].[STB_MaterialLotSnapshot]  WITH(NOLOCK) where LotID=a1.lotid  ) = 0  

			and lotid>'ML20191120' and lotid not in ('ML20210630000413','ML20210630000414','ML20220110000007','ML20220110000008','ML20220110000009','ML20220110000010','ML20220110000011','ML20220110000012','ML20211020000127')

			--group by a1.MaterialCode,a1.StockAttrib1,a1.StockAttrib2,a1.StockAttrib3,a1.MaterialStockAttribute,MDI.SourceCustomerCode,cI2.CustomerName,MaterialDocTypeCode

			--and  a1.Isused <>1 -- không lấy lot đã chia rồi 

			union all 

			select lotid from [SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  WITH(NOLOCK) 

			where LotID  like 'SP%' 

			and (@MaterialCode = '*' OR MaterialCode LIKE @MaterialCode)  --Mr.Duy thêm cho tìm kiếm theo mã NVL

			 --and MaterialCode NOT IN (	'ECVT30-358',

				--						'MCIS00-001',

				--						'MCMR00-001',

				--						'MPBT00-001',

				--						'PD-MMBM00-001',

				--						'MWLA00-037',

				--						'MWLA00-034',

				--						'MCYH00-009',

				--						'MWLA00-040',

				--						'MMHA00-002',

				--						'MMHA00-001') -- 2026-03-28 Mr.Manh audit Bắc Giang 2

			and MaterialWarehouseCode like @MaterialWarehouseCode

			

			or MaterialWarehouseCode= case when @MaterialWarehouseCode not in ('ROH_VN_WH','ROUTE_VN_WH','ROH_BG_WH','ROUTE_BG_WH', 'MODULE_BG2_WH', 'ROUTE_BG2_WH') then @MaterialWarehouseCode else '' end

),  holddate as(

		--select top (1)* from STB_MaterialWarehouseInOutHist where  TargetMaterialWarehouseCode ='HOLDING_VN_WH' or TargetMaterialWarehouseCode ='HOLDING_BG_WH'   order by CreateDateTime DESC

		--select  DISTINCT LotID from STB_MaterialWarehouseInOutHist 

		--where  TargetMaterialWarehouseCode ='HOLDING_VN_WH' or TargetMaterialWarehouseCode ='HOLDING_BG_WH'   order by CreateDateTime DESC



				SELECT

					LotID

					,

					MAX(CreateDateTime) AS LatestCreateDateTime

				FROM

					STB_MaterialWarehouseInOutHist

				WHERE  

					TargetMaterialWarehouseCode = 'HOLDING_VN_WH'

					OR TargetMaterialWarehouseCode = 'HOLDING_BG_WH'

					OR TargetMaterialWarehouseCode = 'HOLDING_HN_WH'

				GROUP BY

					LotID

				--ORDER BY

				--	LatestCreateDateTime DESC

) , Lottachdaxuat as(         --------add 02/10/2024  

		select LotID,sum(DIVIDE_STOCKQTY) as DIVIDE_STOCKQTY  from STB_VN_DIVIDEMATERIALSMAL  where PACKINGIDSMALL  in (select LotID from STB_MaterialWarehouseInOutHist) group by LotID

)

--, LotDaSlitting as(         --------add 02/10/2024  

--		select PackingIdParent as LotID, sum(CurrentQty) as StockSltiting from STB_MaterialLotInfo 

--				where MaterialWarehouseCode like 'SLITTING_HN_WH%' and MaterialLocationCode like 'SLITTING_HN_WH%' 

--				and  (PackingIdParent is not null or PackingIdParent <>'')

--				group by PackingIdParent

--)

,



 table1 as (

			SELECT

			isnull(MLI.MaterialLotNo,MdLI.MaterialLotNo) AS OldMaterialLotNo,

			case when MaterialDocType='GI' then 'AUDIT' else  MaterialDocType end MaterialDocType,

			isnull(MLI.MaterialLotNo,MdLI.MaterialLotNo) AS MaterialLotNo,

			isnull(MLI.LotID,MdLI.LotID) as LotID,

			isnull(MLI.CompanyCode,mdi.TargetCompanyCode) as CompanyCode,

			MLI.WorkCenterCode,

			coalesce(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode,mdi.TargetMaterialWarehouseCode) as MaterialWarehouseCode,

			'' MaterialWarehouseName,

			MLI.MaterialLocationCode,

			'' MaterialLocationName,

			isnull(MLI.MaterialCode,MdLI.MaterialCode) as MaterialCode,

			CASE 

				WHEN MM.MaterialCode = 'GBAKAC-608' THEN REPLACE(MM.MaterialName, '(', '-600F(')

				WHEN MM.MaterialCode = 'GBAKAC-048' THEN REPLACE(MM.MaterialName, '(', '-VPC(')

				WHEN MM.MaterialCode = 'GBAKAC-039' THEN REPLACE(MM.MaterialName, '(', '-VPC(')

				WHEN MM.MaterialCode = 'GBAKAC-050' THEN REPLACE(MM.MaterialName, '(', '-VPC(')

				WHEN MM.MaterialCode = 'GBAKAC-033' THEN REPLACE(MM.MaterialName, '(', '-500F(')

				ELSE MM.MaterialName 

			END AS MaterialName,

			MM.MaterialTypeCode,

			'' MaterialTypeName,

			MM.ProductGroupCode,

			'' ProductGroupName,

			MM.MaterialSpec,

			MM.MaterialUnit,

			MLI.MaterialStockAttribute,

			--MLI.StockAttrib1,

			--MLI.StockAttrib2,

			--MLI.StockAttrib3,

			MLI.PackingID,

			MLI.GRDate,

			MLI.MaterialDeliveryNo,

			MLI.MaterialDeliveryDetailNo,

			isnull(MLI.InitialQty,mdli.StockQty) as InitialQty,

			isnull(MLI.CurrentQty,mdli.StockQty) as CurrentQty,

			CASE 

				

				WHEN LTDX.DIVIDE_STOCKQTY>0 or LTDX.DIVIDE_STOCKQTY is not null THEN isnull(MLI.CurrentQty,mdli.StockQty)- LTDX.DIVIDE_STOCKQTY

				ELSE isnull(MLI.CurrentQty,mdli.StockQty)

			END as StockQty,

			--isnull(MLI.CurrentQty,mdli.StockQty) AS StockQty,

			MLI.PickingQty,

			isnull(MLI.CurrentQty - MLI.PickingQty,mdli.StockQty) AS AvailableQty,

			MLI.VendorLotNo,

			MLI.LifeBasicDate,

			MDLI.LotAttr10 as ProductionDate,

			MLI.EndOfLifeDate,

			isnull(mdli11.CreateDatetime,mli.CreateDateTime) as InputDay,

			mdli.LotNo,

			MLI.IsSplitLot,

			CONVERT(NUMERIC(20,5), NULL) AS SplitQty,	-- 재고분리를 위한 DUMMY 컬럼

			MLI.BefMaterialLotNo,

			--MLI.CreateDateTime,

			--MLI.CreateUserID,

			--MLI.ChangeDateTime,

			--MLI.ChangeUserID,

			--'MATERIAL_LABEL' AS LabelType,

			--Label.FormatName AS LabelFormatName,



			'PartLabel' AS LabelType,			       -- 자재라벨로 Fix (2020.06.16)  'PartLabel' 

			 '자재라벨'  AS LabelFormatName,       -- 자재라벨로 Fix (2020.06.16)

			'Report' AS CommandType,               -- 자재라벨로 Fix (2020.06.16) 

				

			MLI.LotAttr01,

			MLI.LotAttr02,

			--MLI.LotAttr03,

			CASE WHEN ISNULL(MLI.LotAttr03, '') <> '' THEN MLI.LotAttr03 

				ELSE ci2.CustomerName

				END AS LotAttr03,		-- mr.Manh update 2026-03-28 for Bac Giang 2 audit

			MLI.LotAttr04,

			MLI.LotAttr05,

			MLI.LotAttr06,

			MLI.LotAttr07,

			MLI.LotAttr08,

			MdLI.LotAttr09,

			mdli11.LevelJIANGHAI,

			MDD.ManufacturerCode,

			Ci3.CustomerName AS ManufacturerName,

			MDD.WeekCode,

			MDD.RevisionsVer,



			--ci2.CustomerName,

			-- 추가부분 (kilee)

			--CONVERT(DATE, MLI.LotAttr10)                                                                                                                                 AS LotAttr10,		 -- 제조일자	(원본)



			MDLI.LotAttr10 AS LotAttr10 ,

			--CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.LotAttr10), 121)), 121) AS PackDate,

			MM.MMExtText02,

			MM.MMExtText03,

			ISNULL(MSAI.SaftyStock, 0) AS SaftyStock,

			 

		

			--dateadd (   day,  

						

			--			CASE WHEN @companycode='VVT' and @MaterialWarehouseCode LIKE 'MODULE_BG2_WH' THEN CONVERT(VARCHAR(10), DATEADD(DAY, 0, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121) -- 2026-04-11 Mr.Manh update for BG2

			--			--CASE WHEN @companycode='VVT' and @workcentercode IN ('VVT_F4') THEN CONVERT(VARCHAR(10), DATEADD(DAY, 0, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121) -- 2026-04-11 Mr.Manh update for BG2

			--				ELSE (CONVERT(INT, CASE WHEN MM.MMExtInt01 IS NULL OR LTRIM(RTRIM(MM.MMExtInt01))='' THEN 3 ELSE MM.MMExtInt01 END) * 30)  -- 09/04/2026 [Just for code: 'MDFLUX-002' = 179 days] -- ThucTD

			--			END,

			--			-- 1 + convert(INT,case when MMExtInt01 is null or ltrim(rtrim(MMExtInt01))='' then 3 else MMExtInt01 end)*30 , 

			--			case when  len(((mdli.LotAttr10)))=10 

			--					and ((mdli.LotAttr10)) like '20%' 

			--					and substring(((mdli.LotAttr10)),5,1)='-' 

			--					and substring(((mdli.LotAttr10)),8,1)='-'  

			--					and substring(((mdli.LotAttr10)),3,2)>='00' and substring(((mdli.LotAttr10)),3,2)<='99'



			--					and substring(((mdli.LotAttr10)),6,2)>='01' and substring(((mdli.LotAttr10)),6,2)<='12'



			--					and substring(((mdli.LotAttr10)),9,2)>='01' and substring(((mdli.LotAttr10)),9,2)<=(case when substring(((mdli.LotAttr10)),6,2)='02' then '28' 

			--																										when substring(((mdli.LotAttr10)),6,2) in ('04', '06', '09', '11') then '30' else '31' end)



			--					and substring(((mdli.LotAttr10)),3,1)>='0'   and substring(((mdli.LotAttr10)),3,1)<='9'

			--					and substring(((mdli.LotAttr10)),4,1)>='0'   and substring(((mdli.LotAttr10)),4,1)<='9'

			--					and substring(((mdli.LotAttr10)),6,1)>='0'   and substring(((mdli.LotAttr10)),6,1)<='9'

			--					and substring(((mdli.LotAttr10)),7,1)>='0'   and substring(((mdli.LotAttr10)),7,1)<='9'

			--					and substring(((mdli.LotAttr10)),9,1)>='0'   and substring(((mdli.LotAttr10)),9,1)<='9'

			--					and substring(((mdli.LotAttr10)),10,1)>='0' and substring(((mdli.LotAttr10)),10,1)<='9'

			--				 then ((mdli.LotAttr10)) else mdi.BasicDate  end

			--		) as  EffectDate,



			-- update 





			CASE WHEN @companycode='VVT' and @workcentercodeu IN ('VVT_F4') and MDLI.MaterialCode NOT IN ('DOW01-001', 'SILDOW-002') THEN CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)



				ELSE 

				dateadd (   day,  

							(CONVERT(INT, CASE WHEN MM.MMExtInt01 IS NULL OR LTRIM(RTRIM(MM.MMExtInt01))='' THEN 3 ELSE MM.MMExtInt01 END) * 30)  -- 09/04/2026 [Just for code: 'MDFLUX-002' = 179 days] -- ThucTD

						,

						case when  len(((mdli.LotAttr10)))=10 

								and ((mdli.LotAttr10)) like '20%' 

								and substring(((mdli.LotAttr10)),5,1)='-' 

								and substring(((mdli.LotAttr10)),8,1)='-'  

								and substring(((mdli.LotAttr10)),3,2)>='00' and substring(((mdli.LotAttr10)),3,2)<='99'



								and substring(((mdli.LotAttr10)),6,2)>='01' and substring(((mdli.LotAttr10)),6,2)<='12'



								and substring(((mdli.LotAttr10)),9,2)>='01' and substring(((mdli.LotAttr10)),9,2)<=(case when substring(((mdli.LotAttr10)),6,2)='02' then '28' 

																													when substring(((mdli.LotAttr10)),6,2) in ('04', '06', '09', '11') then '30' else '31' end)



								and substring(((mdli.LotAttr10)),3,1)>='0'   and substring(((mdli.LotAttr10)),3,1)<='9'

								and substring(((mdli.LotAttr10)),4,1)>='0'   and substring(((mdli.LotAttr10)),4,1)<='9'

								and substring(((mdli.LotAttr10)),6,1)>='0'   and substring(((mdli.LotAttr10)),6,1)<='9'

								and substring(((mdli.LotAttr10)),7,1)>='0'   and substring(((mdli.LotAttr10)),7,1)<='9'

								and substring(((mdli.LotAttr10)),9,1)>='0'   and substring(((mdli.LotAttr10)),9,1)<='9'

								and substring(((mdli.LotAttr10)),10,1)>='0' and substring(((mdli.LotAttr10)),10,1)<='9'

							 then ((mdli.LotAttr10)) else mdi.BasicDate  end

					) END as  EffectDate,



			case when dateadd(  month,  convert(INT,case when MMExtInt01 is null or MMExtInt01='' then 3 else MMExtInt01 end) , 						

			

			case when  len(((mdli.LotAttr10)))=10 

								and ((mdli.LotAttr10)) like '20%' 

								and substring(((mdli.LotAttr10)),5,1)='-' 

								and substring(((mdli.LotAttr10)),8,1)='-'  

								and substring(((mdli.LotAttr10)),3,2)>='00' and substring(((mdli.LotAttr10)),3,2)<='99'



								and substring(((mdli.LotAttr10)),6,2)>='01' and substring(((mdli.LotAttr10)),6,2)<='12'



								and substring(((mdli.LotAttr10)),9,2)>='01' and substring(((mdli.LotAttr10)),9,2)<=(case when substring(((mdli.LotAttr10)),6,2)='02' then '28' 

																													when substring(((mdli.LotAttr10)),6,2) in ('04', '06', '09', '11') then '30' else '31' end)



								and substring(((mdli.LotAttr10)),3,1)>='0'   and substring(((mdli.LotAttr10)),3,1)<='9'

								and substring(((mdli.LotAttr10)),4,1)>='0'   and substring(((mdli.LotAttr10)),4,1)<='9'

								and substring(((mdli.LotAttr10)),6,1)>='0'   and substring(((mdli.LotAttr10)),6,1)<='9'

								and substring(((mdli.LotAttr10)),7,1)>='0'   and substring(((mdli.LotAttr10)),7,1)<='9'

								and substring(((mdli.LotAttr10)),9,1)>='0'   and substring(((mdli.LotAttr10)),9,1)<='9'

								and substring(((mdli.LotAttr10)),10,1)>='0' and substring(((mdli.LotAttr10)),10,1)<='9'

							 then ((mdli.LotAttr10)) else  mdi.BasicDate  end ) <= getdate() then 'Expired' 



			when  dateadd(  month,  convert(INT,case when MMExtInt01 is null or MMExtInt01='' then 3 else MMExtInt01 end) , 						

			

			case when  len(((mdli.LotAttr10)))=10 

								and ((mdli.LotAttr10)) like '20%' 

								and substring(((mdli.LotAttr10)),5,1)='-' 

								and substring(((mdli.LotAttr10)),8,1)='-'  

								and substring(((mdli.LotAttr10)),3,2)>='00' and substring(((mdli.LotAttr10)),3,2)<='99'



								and substring(((mdli.LotAttr10)),6,2)>='01' and substring(((mdli.LotAttr10)),6,2)<='12'



								and substring(((mdli.LotAttr10)),9,2)>='01' and substring(((mdli.LotAttr10)),9,2)<=(case when substring(((mdli.LotAttr10)),6,2)='02' then '28' 

																													when substring(((mdli.LotAttr10)),6,2) in ('04', '06', '09', '11') then '30' else '31' end)



								and substring(((mdli.LotAttr10)),3,1)>='0'   and substring(((mdli.LotAttr10)),3,1)<='9'

								and substring(((mdli.LotAttr10)),4,1)>='0'   and substring(((mdli.LotAttr10)),4,1)<='9'

								and substring(((mdli.LotAttr10)),6,1)>='0'   and substring(((mdli.LotAttr10)),6,1)<='9'

								and substring(((mdli.LotAttr10)),7,1)>='0'   and substring(((mdli.LotAttr10)),7,1)<='9'

								and substring(((mdli.LotAttr10)),9,1)>='0'   and substring(((mdli.LotAttr10)),9,1)<='9'

								and substring(((mdli.LotAttr10)),10,1)>='0' and substring(((mdli.LotAttr10)),10,1)<='9'

							 then ((mdli.LotAttr10)) else  mdi.BasicDate  end ) <= dateadd(day, 

							(case when mm.ProductGroupCode like '%coat%roll%' or  

									mm.ProductGroupCode like '%slit%roll%' then 15 else 30 end) 

								,getdate() 

								)  then 'Warning' 

			else 'Safe' end as Statut ,



									

			MMExtInt01 AS Effectivemonths,

			1              AS LabelQty   ,

			

			MDD.MRMDExtText01 as PaperNoImport,

			MDD.MRMDExtText02 as PaperNoExport,

			MDD.MRMDExtText03 as CustomsDeclare,

			case 

			when  @MaterialWarehouseCode <>'ROH_VN_WH' and  @MaterialWarehouseCode <>'ROH_BG_WH'  and  @MaterialWarehouseCode <>'ROH_HN_WH' and @MaterialWarehouseCode <> 'MODULE_BG2_WH' then   convert(varchar(10),inout.LatestCreateDateTime,120)

			when isnull(substring(MDD.MRMDExtText04,1,10),'')<>''  then substring(MDD.MRMDExtText04,1,10) else convert(varchar(10),mdd.createdatetime,120) end as DateImport,

			case when isnull(substring(MDD.MRMDExtText05,1,10),'')<>''  then substring(MDD.MRMDExtText05,1,10) else '' end as DateExport,

			case when isnull(mli.DateConfirmEx,'')<>'' then mli.DateConfirmEx else '' end as DateConfirmEX, --Mr.Duy Add 2023-12-25

			case when MLI.CreateDateTime < dateadd(month,-3,getdate()) then 'O' else '' end 'Over 3 months',

			MergeParentId

			--inout.LatestCreateDateTime as test123

			           -- 바코드출력라벨 고정인듯 (2020.06.16 추가)





			----,mli.Holddate as test

			--,CAST(inout.Createdatetime  AS DATE) as Holddate

			--,CONVERT(DATE, DATEADD(DAY, 3, inout.Createdatetime)) AS HoldPeriod

			------,mli.HoldPeriod

			----,mli.HoldError,

			----CASE 

			----		WHEN mli.Holddate is not null and DATEDIFF(minute,CONVERT(VARCHAR,mli.Holddate,120)  ,CONVERT(VARCHAR, GETDATE(), 120) )>4320 THEN N'Expired' 

			----		WHEN mli.Holddate is not null and DATEDIFF(minute,CONVERT(VARCHAR,mli.Holddate,120)  ,CONVERT(VARCHAR, GETDATE(), 120) )<4320  THEN N'Handling' 

			----		--WHEN  mli.Holddate is not null and DATEDIFF(minute,CONVERT(VARCHAR,mli.Holddate,120)  ,CONVERT(VARCHAR, GETDATE(), 120) )<1   THEN N'Expired Holding' 

			------CASE WHEN mli.Holddate is null  THEN N'' 

			----ELSE N''  

			----END as HoldState,

			----inout.Status_confirm_Export

			--,CASE 

			--		WHEN inout.Createdatetime is not null and DATEDIFF(minute,CONVERT(VARCHAR,inout.Createdatetime,120)  ,CONVERT(VARCHAR, GETDATE(), 120) )>4320 THEN N'Expired' 

			--		WHEN inout.Createdatetime is not null and DATEDIFF(minute,CONVERT(VARCHAR,inout.Createdatetime,120)  ,CONVERT(VARCHAR, GETDATE(), 120) )<4320  THEN N'Handling' 

			--		--WHEN  mli.Holddate is not null and DATEDIFF(minute,CONVERT(VARCHAR,mli.Holddate,120)  ,CONVERT(VARCHAR, GETDATE(), 120) )<1   THEN N'Expired Holding' 

			----CASE WHEN mli.Holddate is null  THEN N'' 

			--ELSE N''  

			--END as HoldState,

			--inout.errorcontent  as HoldError

	--INTO #MLITemp

	FROM

		(

		select  CreateDateTime,MaterialDocDetailNo,MaterialLotNo,lotno,LotID,MaterialLocationCode,MaterialCode,StockQty,LotAttr09,replace(replace(replace(ltrim(rtrim(isnull(LotAttr10,''))),'--','-' ),'--','-' ),' ','' )as LotAttr10

		from STB_MaterialdocLotInfo  WITH(NOLOCK) 

		where

		--(isnull(Lotattr09,'') <> ''   )

		--and LotAttr09 IS NOT NULL

		--and

		--lotid='ML20221109000155' and

		MaterialLocationCode LIKE @MaterialWarehouseCode+'%'

		and (@MaterialCode = '*' OR MaterialCode LIKE @MaterialCode) --Mr.Duy thêm cho tìm kiếm theo mã NVL

		--and   Isused is null

		and CreateUserID <> '23091804'		-- Mr.Manh update 2026-01-09 because duplicate lot

		

		union  all

		(select CreateDateTime ,'',MaterialLotNo,lotno,LotID,MaterialLocationCode,MaterialCode,currentqty,LotAttr09,replace(replace(replace(ltrim(rtrim(isnull(LotAttr10,''))),'--','-' ),'--','-' ),' ','' )as LotAttr10

		from STB_MaterialLotInfo  WITH(NOLOCK) 

		where

		--(isnull(Lotattr09,'') <> ''   )

		--and LotAttr09 IS NOT NULL

		--and

		--lotid='SM20250210000005'

		--MergeParentId is  null

		(lotid like 'SP%' or lotid like 'SL%'or lotid like 'SM%' 

		OR (MaterialCode IN ('MPBT00-001', 'BEINS0-003', 'BEMC00-068', 'BEMC00-105', 'BEMC00-045', 'MDCLEAN-001', 'BEMC00-043','MWLA00-037'

		,'MCIS00-001','MCMR00-001','MPBT00-001','PD-MMBM00-001','MWLA00-037','MWLA00-034','MWLA00-040','MMHA00-002','MMHA00-001') 

			--or MaterialCode LIKE 'BEIN%' 

			--or MaterialCode LIKE 'BEMC00%'

			) ) and -- thêm ds BG2

		 MergeParentId is  null

		 and MaterialWarehouseCode LIKE @MaterialWarehouseCode

		or MaterialWarehouseCode= case when @MaterialWarehouseCode not in ('ROH_VN_WH','ROUTE_VN_WH','ROH_BG_WH','ROUTE_BG_WH','ROH_HN_WH','ROUTE_HN_WH', 'MODULE_BG2_WH', 'ROUTE_BG2_WH') then @MaterialWarehouseCode else '' end

		and (@MaterialCode = '*' OR MaterialCode LIKE @MaterialCode) --Mr.Duy thêm cho tìm kiếm theo mã NVL

	

		and  ((IsSlitting is null and PackingIdParent is null) or (PackingIdParent is not null and IsSlitting is not null ) ) --Ms.Ha lay cac lot chua slitting hoac cac lot con da slitting

		)) mdli --with(nolock) 

		left outer join STB_MaterialLotInfo mli  with(nolock) on mdli.LotID = mli.LotID

		left outer join STB_MaterialDocLotInfo mdli11  with(nolock) on (mdli11.LotID = mdli.LotID and mdli11.CreateUserID <> '23091804')-- Mr.Manh update 2026-01-09 because duplicate lot

		left outer join STB_MaterialDocDetail mdd  with(nolock) on (mdd.MaterialDocDetailNo = mdli.MaterialDocDetailNo and mdd.CreateUserID <> '23091804') -- Mr.Manh update 2026-01-09 because duplicate lot

		left outer join holddate inout with(nolock) on mdli.LotID = inout.LotID

		left outer join STB_MaterialDocInfo mdi with(nolock)  on mdd.MaterialDocNo = mdi.MaterialDocNo

		left outer join basedat on mdli.LotID = basedat.LotID 

		

			LEFT OUTER jOIN STB_MaterialMaster MM WITH(NOLOCK)			ON	MdLI.MaterialCode = MM.MaterialCode

			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				ON	MM.MaterialTypeCode = MT.MaterialTypeCode 

			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				ON	PG.ProductGroupCode = MM.ProductGroupCode

			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)		ON	MW.MaterialWarehouseCode = mdi.TargetMaterialWarehouseCode

			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)			ON	ML.MaterialLocationCode = MdLI.MaterialLocationCode

			 --JOIN STB_ModelLabelInfo Label WITH (NOLOCK)	--	ON (Label.LabelType = 'MATERIAL_LABEL' AND Label.ModelCode = MLI.MaterialCode)

			LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI WITH(NOLOCK)		ON MM.MaterialCode = MSAI.MaterialCode                                            -- 추가부분			

			LEFT OUTER JOIN Lottachdaxuat LTDX WITH(NOLOCK)		ON mdli.LotID  = LTDX.LotID                                            -- 추가부분			

			--LEFT OUTER JOIN LotDaSlitting LDS WITH(NOLOCK)		ON mdli.LotID  = LDS.LotID   

			--JOIN STB_ModelLabelInfo SML WITH(NOLOCK)	 ON SML.ModelCode = MLI.MaterialCode           --    AND	 SML.LabelType = @LabelType                  -- 2020.06.16			

			 --JOIN LABELINFO LBI				                         ON LBI.LabelType = @LabelType                          AND	 LBI.FormatName = SML.FormatName    AND	LBI.RankIndex = 1                -- 2020.06.16

		left outer join STB_CustomerInfo ci2  WITH(NOLOCK) on MDi.SourceCustomerCode = ci2.CustomerCode 

		left outer join STB_CustomerInfo ci3  WITH(NOLOCK) on MDD.ManufacturerCode = ci3.CustomerCode 

	where  

			(MLI.CompanyCode = @CompanyCode) 		

			--and MLI.LotID not in (select PACKINGIDSMALL from STB_VN_DIVIDEMATERIALSMAL) --không cho hiển thị mã MLML

			--and MLI.LotID not in (select LOTID from STB_VN_DIVIDEMATERIALSMAL) -- không lấy lot đã chia rồi 

			--and  ((MLI.isSlitting <>1 and MLI.PackingIdParent is null) or(MLI.isSlitting = 1 and MLI.PackingIdParent is not null ))

			and (@pMaterialWarehouseCode='TOTAL_MATERIALS'    and isnull(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode) not like 'PROD%'    and  isnull(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode)  not like 'ROUTE%'

				or isnull(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode) LIKE @MaterialWarehouseCode+'%') 			

			--and mdi.isUsed =NULL

			and (@MaterialCode = '*' OR MLI.MaterialCode LIKE @MaterialCode) 			

			and (@LotID = '*' OR MLI.LotID = @LotID)

			--and (MaterialDocType<>'GI' or MaterialDocType is null)

			and (MaterialDocType<>'GI' or MaterialDocType is null)

		   -- and (isnull(MLI.Lotattr09,'') <> ''   )

			--and MLI.LotAttr09 IS NOT NULL

			--AND MLI.MaterialCode NOT IN (	'ECVT30-358',

			--							'MCIS00-001',

			--							'MCMR00-001',

			--							'MPBT00-001',

			--							'PD-MMBM00-001',

			--							'MWLA00-037',

			--							'MWLA00-034',

			--							'MCYH00-009',

			--							'MWLA00-040',

			--							'MMHA00-002',

			--							'MMHA00-001') -- 2026-03-28 Mr.Manh audit Bắc Giang 2





			and mdli11.MaterialDocDetailNo NOT IN ('251015000297','251015000307','251015000281','250930000194','251120000171','240508000133','251120000176','260309000383') -- Mr.Triều update for Bắc Giàng Factory

			--and MLI.LotID not in ('ML20260320000286', 'ML20260320000287') -- 2026-03-29 Mr.Manh audit Bắc Giang 2'.

		  --and  MLI.LotID not in ('ML20251223000089')

			or mdli.LotID in (select LotID from basedat)

		



)select * from table1 t1 where t1.StockQty>0

/*

--- (Hải Triều) thêm để khi audit cho nhà máy Bắc Giang

 AND t1.MaterialWarehouseCode LIKE @MaterialWarehouseCode + '%' 



  AND (

        -- Nếu mà không phải kho bên nhà máy BG thì lấy tất cả

        @MaterialWarehouseCode <> 'ROH_VN_WH' 

        OR 

        -- Nếu LÀ kho Bắc Giang thì BẮT BUỘC phải có Đặc tính 9

        (

          @MaterialWarehouseCode = 'ROH_VN_WH' 

          AND ISNULL(t1.LotAttr09, '') <> '' 

          AND LEN(LTRIM(RTRIM(t1.LotAttr09))) > 0

        )

      )		

 					      

*/

end

else

begin

	print('2')

	;WITH LABELINFO AS

	(

		SELECT

				RANK() OVER (PARTITION BY LI.LabelType,LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,

				LI.LabelType,

				LI.FormatName,

				LI.CommandType,

				LI.Dpi,

				LI.PrinterName

		FROM

				SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)

		WHERE

				LI.IsApproval = 1 AND

				LI.ApplyDate <= GETDATE()

	),

	 basedat as (

				select a1.LotID--a1.materialcode as mat,a1.StockAttrib1,a1.StockAttrib2,a1.StockAttrib3,a1.MaterialStockAttribute, sum(stockqty) as stock,isnull(MDI.SourceCustomerCode,MaterialDocTypeCode) as SourceCustomerCode,cI2.CustomerName

			from	[SmartFactoryV2].[dbo].[STB_MaterialDocLotInfo] a1 WITH(NOLOCK)

			LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo = a1.MaterialDocDetailNo 

			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)   on MDD.MaterialDocNo = MDI.MaterialDocNo

			--			left outer join STB_CustomerInfo ci2  WITH(NOLOCK) on MDi.SourceCustomerCode = ci2.CustomerCode 



			 where  

			 (@pMaterialWarehouseCode='TOTAL_MATERIALS'    and MaterialLocationCode not like 'PROD%'    and  MaterialLocationCode  not like 'ROUTE%'

							 or MaterialLocationCode like @MaterialWarehouseCode+'%'

					)

			and (select  count(*) from [SmartFactoryV2].[dbo].[STB_MaterialDocLotInfo]  WITH(NOLOCK) where LotID=a1.lotid and materiallotno is not null ) = 0

			and (select  count(*) from [SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  WITH(NOLOCK) where LotID=a1.lotid  ) = 0 ---dd

			and (select  count(*) from [SmartFactoryV2].[dbo].[STB_MaterialLotSnapshot]  WITH(NOLOCK) where LotID=a1.lotid  ) = 0  

			and lotid>'ML20191120' and lotid not in ('ML20210630000413','ML20210630000414','ML20220110000007','ML20220110000008','ML20220110000009','ML20220110000010','ML20220110000011','ML20220110000012','ML20211020000127')

			--group by a1.MaterialCode,a1.StockAttrib1,a1.StockAttrib2,a1.StockAttrib3,a1.MaterialStockAttribute,MDI.SourceCustomerCode,cI2.CustomerName,MaterialDocTypeCode

			--and  a1.Isused <>1 -- không lấy lot đã chia rồi 

			union all 

			select lotid from [SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  WITH(NOLOCK) 

			where LotID  like 'SP%' 

			and (@MaterialCode = '*' OR MaterialCode LIKE @MaterialCode)  --Mr.Duy thêm cho tìm kiếm theo mã NVL

			and MaterialWarehouseCode LIKE @MaterialWarehouseCode + '%'

			or MaterialWarehouseCode= case when @MaterialWarehouseCode not in ('ROH_VN_WH','ROUTE_VN_WH','ROH_BG_WH','ROUTE_BG_WH', 'MODULE_BG2_WH', 'ROUTE_BG2_WH') then @MaterialWarehouseCode else '' end

),  holddate as(

		--select top (1)* from STB_MaterialWarehouseInOutHist where  TargetMaterialWarehouseCode ='HOLDING_VN_WH' or TargetMaterialWarehouseCode ='HOLDING_BG_WH'   order by CreateDateTime DESC

		--select  DISTINCT LotID from STB_MaterialWarehouseInOutHist 

		--where  TargetMaterialWarehouseCode ='HOLDING_VN_WH' or TargetMaterialWarehouseCode ='HOLDING_BG_WH'   order by CreateDateTime DESC



				SELECT

					LotID

					,

					MAX(CreateDateTime) AS LatestCreateDateTime

				FROM

					STB_MaterialWarehouseInOutHist

				WHERE  

					TargetMaterialWarehouseCode = 'HOLDING_VN_WH'

					OR TargetMaterialWarehouseCode = 'HOLDING_BG_WH'

					OR TargetMaterialWarehouseCode = 'HOLDING_HN_WH'

				GROUP BY

					LotID

				--ORDER BY

				--	LatestCreateDateTime DESC

) , Lottachdaxuat as(         --------add 02/10/2024  

		select LotID,sum(DIVIDE_STOCKQTY) as DIVIDE_STOCKQTY  from STB_VN_DIVIDEMATERIALSMAL  where PACKINGIDSMALL  in (select LotID from STB_MaterialWarehouseInOutHist) group by LotID

)

--, LotDaSlitting as(         --------add 02/10/2024  

--		select PackingIdParent as LotID, sum(CurrentQty) as StockSltiting from STB_MaterialLotInfo 

--				where MaterialWarehouseCode like 'SLITTING_HN_WH%' and MaterialLocationCode like 'SLITTING_HN_WH%' 

--				and  (PackingIdParent is not null or PackingIdParent <>'')

--				group by PackingIdParent

--)

,



 table1 as (

			SELECT

			isnull(MLI.MaterialLotNo,MdLI.MaterialLotNo) AS OldMaterialLotNo,

			case when MaterialDocType='GI' then 'AUDIT' else  MaterialDocType end MaterialDocType,

			isnull(MLI.MaterialLotNo,MdLI.MaterialLotNo) AS MaterialLotNo,

			isnull(MLI.LotID,MdLI.LotID) as LotID,

			isnull(MLI.CompanyCode,mdi.TargetCompanyCode) as CompanyCode,

			MLI.WorkCenterCode,

			coalesce(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode,mdi.TargetMaterialWarehouseCode) as MaterialWarehouseCode,

			'' MaterialWarehouseName,

			MLI.MaterialLocationCode,

			'' MaterialLocationName,

			isnull(MLI.MaterialCode,MdLI.MaterialCode) as MaterialCode,

			CASE 

				WHEN MM.MaterialCode = 'GBAKAC-608' THEN REPLACE(MM.MaterialName, '(', '-600F(')

				WHEN MM.MaterialCode = 'GBAKAC-048' THEN REPLACE(MM.MaterialName, '(', '-VPC(')

				WHEN MM.MaterialCode = 'GBAKAC-039' THEN REPLACE(MM.MaterialName, '(', '-VPC(')

				WHEN MM.MaterialCode = 'GBAKAC-050' THEN REPLACE(MM.MaterialName, '(', '-VPC(')

				WHEN MM.MaterialCode = 'GBAKAC-033' THEN REPLACE(MM.MaterialName, '(', '-500F(')

				ELSE MM.MaterialName 

			END AS MaterialName,

			MM.MaterialTypeCode,

			'' MaterialTypeName,

			MM.ProductGroupCode,

			'' ProductGroupName,

			MM.MaterialSpec,

			MM.MaterialUnit,

			MLI.MaterialStockAttribute,

			--MLI.StockAttrib1,

			--MLI.StockAttrib2,

			--MLI.StockAttrib3,

			MLI.PackingID,

			MLI.GRDate,

			MLI.MaterialDeliveryNo,

			MLI.MaterialDeliveryDetailNo,

			isnull(MLI.InitialQty,mdli.StockQty) as InitialQty,

			isnull(MLI.CurrentQty,mdli.StockQty) as CurrentQty,

			CASE 

				

				WHEN LTDX.DIVIDE_STOCKQTY>0 or LTDX.DIVIDE_STOCKQTY is not null THEN isnull(MLI.CurrentQty,mdli.StockQty)- LTDX.DIVIDE_STOCKQTY

				ELSE isnull(MLI.CurrentQty,mdli.StockQty)

			END as StockQty,

			--isnull(MLI.CurrentQty,mdli.StockQty) AS StockQty,

			MLI.PickingQty,

			isnull(MLI.CurrentQty - MLI.PickingQty,mdli.StockQty) AS AvailableQty,

			MLI.VendorLotNo,

			MLI.LifeBasicDate,

			MDLI.LotAttr10 as ProductionDate,

			MLI.EndOfLifeDate,

			isnull(mdli11.CreateDatetime,mli.CreateDateTime) as InputDay,

			mdli.LotNo,

			MLI.IsSplitLot,

			CONVERT(NUMERIC(20,5), NULL) AS SplitQty,	-- 재고분리를 위한 DUMMY 컬럼

			MLI.BefMaterialLotNo,

			--MLI.CreateDateTime,

			--MLI.CreateUserID,

			--MLI.ChangeDateTime,

			--MLI.ChangeUserID,

			--'MATERIAL_LABEL' AS LabelType,

			--Label.FormatName AS LabelFormatName,



			'PartLabel' AS LabelType,			       -- 자재라벨로 Fix (2020.06.16)  'PartLabel' 

			 '자재라벨'  AS LabelFormatName,       -- 자재라벨로 Fix (2020.06.16)

			'Report' AS CommandType,               -- 자재라벨로 Fix (2020.06.16) 

				

			MLI.LotAttr01,

			MLI.LotAttr02,

			MLI.LotAttr03,

			MLI.LotAttr04,

			MLI.LotAttr05,

			MLI.LotAttr06,

			MLI.LotAttr07,

			MLI.LotAttr08,

			MdLI.LotAttr09,

			mdli11.LevelJIANGHAI,

			

			-- 추가부분 (kilee)

			--CONVERT(DATE, MLI.LotAttr10)                                                                                                                                 AS LotAttr10,		 -- 제조일자	(원본)



			MDLI.LotAttr10 AS LotAttr10 ,

			--CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.LotAttr10), 121)), 121) AS PackDate,

			MM.MMExtText02,

			MM.MMExtText03,

			ISNULL(MSAI.SaftyStock, 0) AS SaftyStock,

			 

		

			dateadd (   day,  

						CASE WHEN MDLI.MaterialCode = 'MDFLUX-002' THEN (MM.MMExtInt01*30)-1

							 ELSE (CONVERT(INT, CASE WHEN MM.MMExtInt01 IS NULL OR LTRIM(RTRIM(MM.MMExtInt01))='' THEN 3 ELSE MM.MMExtInt01 END)*30)  -- 09/04/2026 ThucTd

								END,

						-- 1 + convert(INT,case when MMExtInt01 is null or ltrim(rtrim(MMExtInt01))='' then 3 else MMExtInt01 end)*30 , 

						case when  len(((mdli.LotAttr10)))=10 

								and ((mdli.LotAttr10)) like '20%' 

								and substring(((mdli.LotAttr10)),5,1)='-' 

								and substring(((mdli.LotAttr10)),8,1)='-'  

								and substring(((mdli.LotAttr10)),3,2)>='00' and substring(((mdli.LotAttr10)),3,2)<='99'



								and substring(((mdli.LotAttr10)),6,2)>='01' and substring(((mdli.LotAttr10)),6,2)<='12'



								and substring(((mdli.LotAttr10)),9,2)>='01' and substring(((mdli.LotAttr10)),9,2)<=(case when substring(((mdli.LotAttr10)),6,2)='02' then '28' 

																													when substring(((mdli.LotAttr10)),6,2) in ('04', '06', '09', '11') then '30' else '31' end)



								and substring(((mdli.LotAttr10)),3,1)>='0'   and substring(((mdli.LotAttr10)),3,1)<='9'

								and substring(((mdli.LotAttr10)),4,1)>='0'   and substring(((mdli.LotAttr10)),4,1)<='9'

								and substring(((mdli.LotAttr10)),6,1)>='0'   and substring(((mdli.LotAttr10)),6,1)<='9'

								and substring(((mdli.LotAttr10)),7,1)>='0'   and substring(((mdli.LotAttr10)),7,1)<='9'

								and substring(((mdli.LotAttr10)),9,1)>='0'   and substring(((mdli.LotAttr10)),9,1)<='9'

								and substring(((mdli.LotAttr10)),10,1)>='0' and substring(((mdli.LotAttr10)),10,1)<='9'

							 then ((mdli.LotAttr10)) else mdi.BasicDate  end

					) as  EffectDate,



			case when dateadd(  month,  convert(INT,case when MMExtInt01 is null or MMExtInt01='' then 3 else MMExtInt01 end) , 						

			

			case when  len(((mdli.LotAttr10)))=10 

								and ((mdli.LotAttr10)) like '20%' 

								and substring(((mdli.LotAttr10)),5,1)='-' 

								and substring(((mdli.LotAttr10)),8,1)='-'  

								and substring(((mdli.LotAttr10)),3,2)>='00' and substring(((mdli.LotAttr10)),3,2)<='99'



								and substring(((mdli.LotAttr10)),6,2)>='01' and substring(((mdli.LotAttr10)),6,2)<='12'



								and substring(((mdli.LotAttr10)),9,2)>='01' and substring(((mdli.LotAttr10)),9,2)<=(case when substring(((mdli.LotAttr10)),6,2)='02' then '28' 

																													when substring(((mdli.LotAttr10)),6,2) in ('04', '06', '09', '11') then '30' else '31' end)



								and substring(((mdli.LotAttr10)),3,1)>='0'   and substring(((mdli.LotAttr10)),3,1)<='9'

								and substring(((mdli.LotAttr10)),4,1)>='0'   and substring(((mdli.LotAttr10)),4,1)<='9'

								and substring(((mdli.LotAttr10)),6,1)>='0'   and substring(((mdli.LotAttr10)),6,1)<='9'

								and substring(((mdli.LotAttr10)),7,1)>='0'   and substring(((mdli.LotAttr10)),7,1)<='9'

								and substring(((mdli.LotAttr10)),9,1)>='0'   and substring(((mdli.LotAttr10)),9,1)<='9'

								and substring(((mdli.LotAttr10)),10,1)>='0' and substring(((mdli.LotAttr10)),10,1)<='9'

							 then ((mdli.LotAttr10)) else  mdi.BasicDate  end ) <= getdate() then 'Expired' 



			when  dateadd(  month,  convert(INT,case when MMExtInt01 is null or MMExtInt01='' then 3 else MMExtInt01 end) , 						

			

			case when  len(((mdli.LotAttr10)))=10 

								and ((mdli.LotAttr10)) like '20%' 

								and substring(((mdli.LotAttr10)),5,1)='-' 

								and substring(((mdli.LotAttr10)),8,1)='-'  

								and substring(((mdli.LotAttr10)),3,2)>='00' and substring(((mdli.LotAttr10)),3,2)<='99'



								and substring(((mdli.LotAttr10)),6,2)>='01' and substring(((mdli.LotAttr10)),6,2)<='12'



								and substring(((mdli.LotAttr10)),9,2)>='01' and substring(((mdli.LotAttr10)),9,2)<=(case when substring(((mdli.LotAttr10)),6,2)='02' then '28' 

																													when substring(((mdli.LotAttr10)),6,2) in ('04', '06', '09', '11') then '30' else '31' end)



								and substring(((mdli.LotAttr10)),3,1)>='0'   and substring(((mdli.LotAttr10)),3,1)<='9'

								and substring(((mdli.LotAttr10)),4,1)>='0'   and substring(((mdli.LotAttr10)),4,1)<='9'

								and substring(((mdli.LotAttr10)),6,1)>='0'   and substring(((mdli.LotAttr10)),6,1)<='9'

								and substring(((mdli.LotAttr10)),7,1)>='0'   and substring(((mdli.LotAttr10)),7,1)<='9'

								and substring(((mdli.LotAttr10)),9,1)>='0'   and substring(((mdli.LotAttr10)),9,1)<='9'

								and substring(((mdli.LotAttr10)),10,1)>='0' and substring(((mdli.LotAttr10)),10,1)<='9'

							 then ((mdli.LotAttr10)) else  mdi.BasicDate  end ) <= dateadd(day, 

							(case when mm.ProductGroupCode like '%coat%roll%' or  

									mm.ProductGroupCode like '%slit%roll%' then 15 else 30 end) 

								,getdate() 

								)  then 'Warning' 

			else 'Safe' end as Statut ,



									

			MMExtInt01 AS Effectivemonths,

			1              AS LabelQty   ,

			

			MDD.MRMDExtText01 as PaperNoImport,

			MDD.MRMDExtText02 as PaperNoExport,

			MDD.MRMDExtText03 as CustomsDeclare,

			case 

			when  @MaterialWarehouseCode <>'ROH_VN_WH' and  @MaterialWarehouseCode <>'ROH_BG_WH'  and  @MaterialWarehouseCode <>'ROH_HN_WH' and @MaterialWarehouseCode <> 'MODULE_BG2_WH' then   convert(varchar(10),inout.LatestCreateDateTime,120)

			when isnull(substring(MDD.MRMDExtText04,1,10),'')<>''  then substring(MDD.MRMDExtText04,1,10) else convert(varchar(10),mdd.createdatetime,120) end as DateImport,

			case when isnull(substring(MDD.MRMDExtText05,1,10),'')<>''  then substring(MDD.MRMDExtText05,1,10) else '' end as DateExport,

			case when isnull(mli.DateConfirmEx,'')<>'' then mli.DateConfirmEx else '' end as DateConfirmEX, --Mr.Duy Add 2023-12-25

			case when MLI.CreateDateTime < dateadd(month,-3,getdate()) then 'O' else '' end 'Over 3 months',

			MergeParentId

			--inout.LatestCreateDateTime as test123

			           -- 바코드출력라벨 고정인듯 (2020.06.16 추가)





			----,mli.Holddate as test

			--,CAST(inout.Createdatetime  AS DATE) as Holddate

			--,CONVERT(DATE, DATEADD(DAY, 3, inout.Createdatetime)) AS HoldPeriod

			------,mli.HoldPeriod

			----,mli.HoldError,

			----CASE 

			----		WHEN mli.Holddate is not null and DATEDIFF(minute,CONVERT(VARCHAR,mli.Holddate,120)  ,CONVERT(VARCHAR, GETDATE(), 120) )>4320 THEN N'Expired' 

			----		WHEN mli.Holddate is not null and DATEDIFF(minute,CONVERT(VARCHAR,mli.Holddate,120)  ,CONVERT(VARCHAR, GETDATE(), 120) )<4320  THEN N'Handling' 

			----		--WHEN  mli.Holddate is not null and DATEDIFF(minute,CONVERT(VARCHAR,mli.Holddate,120)  ,CONVERT(VARCHAR, GETDATE(), 120) )<1   THEN N'Expired Holding' 

			------CASE WHEN mli.Holddate is null  THEN N'' 

			----ELSE N''  

			----END as HoldState,

			----inout.Status_confirm_Export

			--,CASE 

			--		WHEN inout.Createdatetime is not null and DATEDIFF(minute,CONVERT(VARCHAR,inout.Createdatetime,120)  ,CONVERT(VARCHAR, GETDATE(), 120) )>4320 THEN N'Expired' 

			--		WHEN inout.Createdatetime is not null and DATEDIFF(minute,CONVERT(VARCHAR,inout.Createdatetime,120)  ,CONVERT(VARCHAR, GETDATE(), 120) )<4320  THEN N'Handling' 

			--		--WHEN  mli.Holddate is not null and DATEDIFF(minute,CONVERT(VARCHAR,mli.Holddate,120)  ,CONVERT(VARCHAR, GETDATE(), 120) )<1   THEN N'Expired Holding' 

			----CASE WHEN mli.Holddate is null  THEN N'' 

			--ELSE N''  

			--END as HoldState,

			--inout.errorcontent  as HoldError

	--INTO #MLITemp

	FROM

		(

		select  CreateDateTime,MaterialDocDetailNo,MaterialLotNo,lotno,LotID,MaterialLocationCode,MaterialCode,StockQty,LotAttr09,replace(replace(replace(ltrim(rtrim(isnull(LotAttr10,''))),'--','-' ),'--','-' ),' ','' )as LotAttr10

		from STB_MaterialdocLotInfo  WITH(NOLOCK) 

		where

		--lotid='ML20221109000155' and

		MaterialLocationCode LIKE @MaterialWarehouseCode+'%'

		and (@MaterialCode = '*' OR MaterialCode LIKE @MaterialCode) --Mr.Duy thêm cho tìm kiếm theo mã NVL

		and CreateUserID <> '23091804'		-- Mr.Manh update 2026-01-09 because duplicate lot

		--and   Isused is null

		union all 

		select CreateDateTime ,CAST('' AS NVARCHAR(50)) AS MaterialDocDetailNo,MaterialLotNo,lotno,LotID,MaterialLocationCode,MaterialCode,currentqty,LotAttr09,replace(replace(replace(ltrim(rtrim(isnull(LotAttr10,''))),'--','-' ),'--','-' ),' ','' )as LotAttr1
0

		from STB_MaterialLotInfo  WITH(NOLOCK) 

		where  

		--lotid='SM20250210000005'

		--MergeParentId is  null

		(lotid like 'SP%' or lotid like 'SL%'or lotid like 'SM%')

		 --and MergeParentId is  null

		--and 	(isnull(Lotattr09,'') <> ''   )

		 --and LotAttr09 IS NOT NULL

		 and MaterialWarehouseCode LIKE @MaterialWarehouseCode

		or MaterialWarehouseCode= case when @MaterialWarehouseCode not in ('ROH_VN_WH','ROUTE_VN_WH','ROH_BG_WH','ROUTE_BG_WH','ROH_HN_WH','ROUTE_HN_WH', 'MODULE_BG2_WH', 'ROUTE_BG2_WH') then @MaterialWarehouseCode else '' end

		and (@MaterialCode = '*' OR MaterialCode LIKE @MaterialCode) --Mr.Duy thêm cho tìm kiếm theo mã NVL

	

		and  ((IsSlitting is null and PackingIdParent is null) or (PackingIdParent is not null and IsSlitting is not null ) ) --Ms.Ha lay cac lot chua slitting hoac cac lot con da slitting

		) mdli --with(nolock) 

		left outer join STB_MaterialLotInfo mli  with(nolock) on mdli.LotID = mli.LotID

		left outer join STB_MaterialDocLotInfo mdli11  with(nolock) on (mdli11.LotID = mdli.LotID and mdli11.CreateUserID <> '23091804') -- Mr.Manh update 2026-01-09 because duplicate lot

		left outer join STB_MaterialDocDetail mdd  with(nolock) on (mdd.MaterialDocDetailNo = mdli.MaterialDocDetailNo and mdd.CreateUserID <> '23091804')  -- -- Mr.Manh update 2026-01-09 because duplicate lot

		left outer join holddate inout with(nolock) on mdli.LotID = inout.LotID

		left outer join STB_MaterialDocInfo mdi with(nolock)  on mdd.MaterialDocNo = mdi.MaterialDocNo 

		left outer join basedat on mdli.LotID = basedat.LotID 

		

			LEFT OUTER jOIN STB_MaterialMaster MM WITH(NOLOCK)			ON	MdLI.MaterialCode = MM.MaterialCode

			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				ON	MM.MaterialTypeCode = MT.MaterialTypeCode 

			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				ON	PG.ProductGroupCode = MM.ProductGroupCode

			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)		ON	MW.MaterialWarehouseCode = mdi.TargetMaterialWarehouseCode

			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)			ON	ML.MaterialLocationCode = MdLI.MaterialLocationCode

			 --JOIN STB_ModelLabelInfo Label WITH (NOLOCK)	--	ON (Label.LabelType = 'MATERIAL_LABEL' AND Label.ModelCode = MLI.MaterialCode)

			LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI WITH(NOLOCK)		ON MM.MaterialCode = MSAI.MaterialCode                                            -- 추가부분			

			LEFT OUTER JOIN Lottachdaxuat LTDX WITH(NOLOCK)		ON mdli.LotID  = LTDX.LotID                                            -- 추가부분			

			--LEFT OUTER JOIN LotDaSlitting LDS WITH(NOLOCK)		ON mdli.LotID  = LDS.LotID   

			--JOIN STB_ModelLabelInfo SML WITH(NOLOCK)	 ON SML.ModelCode = MLI.MaterialCode           --    AND	 SML.LabelType = @LabelType                                                          -- 2020.06.16			

			 --JOIN LABELINFO LBI				                         ON LBI.LabelType = @LabelType                          AND	 LBI.FormatName = SML.FormatName    AND	LBI.RankIndex = 1                -- 2020.06.16

		

	where  

			(MLI.CompanyCode = @CompanyCode) 		

			--and MLI.LotID not in (select PACKINGIDSMALL from STB_VN_DIVIDEMATERIALSMAL) --không cho hiển thị mã MLML

			--and MLI.LotID not in (select LOTID from STB_VN_DIVIDEMATERIALSMAL) -- không lấy lot đã chia rồi 

			--and  ((MLI.isSlitting <>1 and MLI.PackingIdParent is null) or(MLI.isSlitting = 1 and MLI.PackingIdParent is not null ))

			and (@pMaterialWarehouseCode='TOTAL_MATERIALS'    and isnull(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode) not like 'PROD%'    and  isnull(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode)  not like 'ROUTE%'

				or isnull(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode) LIKE @MaterialWarehouseCode+'%') 			

			--and mdi.isUsed =NULL

			and (@MaterialCode = '*' OR MLI.MaterialCode LIKE @MaterialCode) 			

			and (@LotID = '*' OR MLI.LotID = @LotID)	

			--and (isnull(MLI.Lotattr09,'') <> ''   )

			--and MLI.LotAttr09 IS NOT NULL

			and (MaterialDocType<>'GI' or MaterialDocType is null)

			and mdli11.MaterialDocDetailNo NOT IN ('251015000297','251015000307','251015000281','250930000194','251120000171','240508000133','251120000176','260309000383') -- Mr.Triều update for Bắc Giàng Factory

			--and  MLI.LotID not in ('ML20251223000089')

			or mdli.LotID in (select LotID from basedat)

		



)select * from table1 t1 where t1.StockQty>0

/*

--- (Hải Triều) thêm để khi audit cho nhà máy Bắc Giang

  AND t1.MaterialWarehouseCode LIKE @MaterialWarehouseCode + '%'



  AND (

        -- Nếu mà không phải kho bên nhà máy BG thì lấy tất cả

        @MaterialWarehouseCode <> 'ROH_VN_WH' 

        OR 

        -- Nếu LÀ kho Bắc Giang thì BẮT BUỘC phải có Đặc tính 9

        (

          @MaterialWarehouseCode = 'ROH_VN_WH' 

          AND ISNULL(t1.LotAttr09, '') <> '' 

          AND LEN(LTRIM(RTRIM(t1.LotAttr09))) > 0

        )

      )		

*/

end

END

	--IF @MaterialCode = '*' Or @MaterialCode = '' 

	

	--			BEGIN 

	--					SELECT * 

	--						,case when EffectDate <= getdate() then 'Expired' 

	--						when  EffectDate <= dateadd(day, 

	--									  (case when ProductGroupCode like '%coat%roll%' or  

	--												ProductGroupCode like '%slit%roll%' then 15 else 30 end) 

	--										  ,getdate() 

	--										 )  then 'Warning' 

	--						else 'Safe' end as Statut 

	--						FROM #MLITemp 

	--			END 	

	--		ELSE 

	--				BEGIN

	--					SELECT * 

	--							,case when EffectDate <= getdate() then 'Expired' 

	--							when  EffectDate <= dateadd(day, 

	--										  (case when ProductGroupCode like '%coat%roll%' or  

	--													ProductGroupCode like '%slit%roll%' then 15 else 30 end) 

	--											  ,getdate() 

	--											 )  then 'Warning' 

	--							else 'Safe' end as Statut 

	--							,dbo.fnGetERPUnitPrice(MaterialCode) AS UnitPrice 

	--							,dbo.fnGetERPCurrencyType(MaterialCode) AS CurrencyType 

	--							,dbo.fnGetERPUnitPrice(MaterialCode) * CurrentQty AS Price 

	--							,dbo.fnGetERPConvertPrice(MaterialCode) * CurrentQty AS ConvertPrice 

	--						FROM #MLITemp 

	--				END 















	--where  

	--		(MLI.CompanyCode = @CompanyCode) AND		

	--		--(@WorkCenterCode = '*' OR MLI.WorkCenterCode = @WorkCenterCode) AND



	--		(@pMaterialWarehouseCode='' and MLI.MaterialWarehouseCode not like 'PROD%' and  MLI.MaterialWarehouseCode not like 'ROUTE%'

	--			or isnull(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode) LIKE @MaterialWarehouseCode+'%') AND			





	--		--(@MaterialLocationCode = '*' OR MLI.MaterialLocationCode LIKE @MaterialLocationCode) AND





	--		(@MaterialCode = '*' OR MLI.MaterialCode LIKE @MaterialCode) AND





	--		--(@MaterialStockAttribute = '*' OR MLI.MaterialStockAttribute LIKE @MaterialStockAttribute) AND

	--		--(@StockAttrib1 = '*' OR MLI.StockAttrib1 LIKE @StockAttrib1) AND

	--		--(@StockAttrib2 = '*' OR MLI.StockAttrib2 LIKE @StockAttrib2) AND

	--		--(@StockAttrib3 = '*' OR MLI.StockAttrib3 LIKE @StockAttrib3) AND

	--		--(@MaterialTypeCode = '*' OR MT.MaterialTypeCode LIKE @MaterialTypeCode) AND

	--		--(@BasicMaterialType = '*' OR MT.BasicMaterialType LIKE @BasicMaterialType) AND

	--		 --MT.BasicMaterialType NOT IN (

	--			--									SELECT

	--			--											Item

	--			--									FROM

	--			--											dbo.fnSplitToTable(',',@ExcludeBasicMaterialTypes)

	--			--						         ) AND 

	--		--(@ProductGroupCode = '*' OR MM.ProductGroupCode LIKE @ProductGroupCode) AND

	--		--MLI.CurrentQty - MLI.PickingQty > 0 AND





	--		(@LotID = '*' OR MLI.LotID = @LotID)





	--		--and (case when @MaterialWarehouseCode='ROH_VN_WH' then 'GI' end) <> MaterialDocType





	--		and (MaterialDocType<>'GI' or MaterialDocType is null)

	--		or mdli.LotID in (select LotID from basedat)

--ML20240627000036,ML20240415000022





