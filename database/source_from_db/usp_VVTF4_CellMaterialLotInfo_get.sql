-- =============================================
-- Author:		DinhManh
-- Create date: 2026-04-09
-- Description:	Get Cell Material Stock for Bac Giang 2
-- =============================================
CREATE PROCEDURE [dbo].[usp_VVTF4_CellMaterialLotInfo_get]	-- usp_VVTF4_CellMaterialLotInfo_get 'DinhManh' ,'vi', '', ''
	-- Add the parameters for the stored procedure here
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pMaterialDocDetailNo VARCHAR(20) = NULL,
				@pMaterialCode VARCHAR(50) = NULL
				--@pLotNo VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @MaterialDocDetailNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocDetailNo,'') = '' THEN '%' ELSE @pMaterialDocDetailNo END
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '164855-%' ELSE @pMaterialCode END
	--DECLARE @LotNo VARCHAR(50) = CASE WHEN ISNULL(@pLotNo,'') = '' THEN '%' ELSE @pLotNo END


	declare @companycode VARCHAR(10),
			@workcentercode VARCHAR(10);
	Select @companycode = CompanyCode
			,@WorkCenterCode = WorkCenterCode  -- turn on for audit 2025-09-05
	FROM  STB_UserInfo 
	where UserID=@pProcessUserID ;


	;with table1 AS(
		SELECT 
		--MDLI.MaterialLotNo,
		MDLI.MaterialDocDetailNo,
		MDLI.LotID,
		MDLI.MaterialCode,
		MM.MaterialName,
		MDLI.LotNo,
		CONCAT(ISNULL(PLS.Voltage, MBI.MBIExtText04), 'V') AS Voltage,
		CONCAT(ISNULL(PLS.Farad, MBI.MBIExtText05), 'F') AS Farad,

		CASE WHEN MBI.ModelCode = 'ECVT30-357' THEN	RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 3) 
			ELSE RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2)
		END	AS ModelC,
		case when  isnull(MDLI.LotAttr10,'')='' then  ''  when ISDATE(MDLI.LotAttr10)=1  then MDLI.LotAttr10 else N'Error Date LotAttr10_Lỗi ngày tháng' end LotAttr10,  --MR.Tung prevent EXCEPTION convert DATETIME 2023-11-17     

		  
		 case when  isnull(MDLI.LotAttr10,'')='' then  ''
		 	  when @companycode='VVT' and @WorkCenterCode IN ('VVT_F4') and ISDATE(MDLI.Lotattr10)=1  then CONVERT(VARCHAR(10), DATEADD(DAY, 0, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)
			  when @companycode='VVT' and ISDATE(MDLI.Lotattr10)=1  then CONVERT(VARCHAR(10), DATEADD(DAY, 0, CONVERT(VARCHAR(10), DATEADD(day,  MM.MMExtInt01*30, MDLI.Lotattr10), 121)), 121)
		      when  ISDATE(MDLI.LotAttr10)=1  then  CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)
			  else N'Error Date LotAttr10_Lỗi ngày tháng' end  AS PackDate,   -- [유효기한] = [유효일] + [제조일자] -1           (2019.03.12 kilee 추가)
		'035-V188' AS VC,
		LEFT(CAST(MDLI.StockQty AS VARCHAR(20)), CHARINDEX('.', CAST(MDLI.StockQty AS VARCHAR(20)) + '.') - 1) AS Qty,
		'QLKc' AS MarkingDC,
		--FORMAT(ROW_NUMBER() OVER (PARTITION BY	MDLI.LotNo	ORDER BY MDLI.LotID	asc), '000') AS SN,
		FORMAT(MDLI.MDLISeqNo, '000') AS SN,
		'VN' AS CC,
		'NA' AS REV,
		'1002' AS SiteL,
		--'0001081' AS PO,
		dbo.fnGetWeekNumber(CONVERT(DATE, dbo.fnPharseLotNo(MDLI.LotNo, 'D'), 112)) AS DC,
		RIGHT(MDLI.MaterialCode, 1) AS MakerBatchcode,
		--'VEC3R0727QG' AS MakerPN,
		case when substring(MBI.ModelName,1,3) in ('VEC','WEC') then RTRIM(LTRIM(substring(MBI.ModelName,1,11))) 
						when substring(MBI.ModelName,1,3) in ('VEL') then RTRIM(LTRIM(substring(MBI.ModelName,1,14))) 
						when substring(MBI.ModelName,8,20) in ('WEM12R0126QG') then (RTRIM(LTRIM(SUBSTRING(MBI.ModelName, CHARINDEX(' ', MBI.ModelName)+1, 12)))) --Duy thêm tạm 
						else (RTRIM(LTRIM(SUBSTRING(MBI.ModelName, CHARINDEX(' ', MBI.ModelName), 12)))) end AS MakerPN, 
		'VINATechVINA' AS MakerName,
		'NA' AS MiscData,
		'PartLabel' AS LabelType,
		'자재라벨' AS LabelFormatName,	
		'Report' AS CommandType


		FROM STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
		LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK) ON MDLI.MaterialCode = MM.MaterialCode
		LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK) ON SI.Barcode = MDLI.LotNo
		LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK) ON SI.MaterialCode = MBI.ModelCode
		LEFT OUTER JOIN STB_PackingLabelSpec PLS WITH(NOLOCK) ON MDLI.LotNo = PLS.LotID
		WHERE 
			MDLI.MaterialLocationCode = 'MODULE_BG2_WH_01' AND
			MDLI.MaterialDocDetailNo LIKE @MaterialDocDetailNo AND
			(MDLI.MaterialCode LIKE '164855-%' OR MDLI.MaterialCode IN ('ECVT30-358'))
			--MDLI.LotNo LIKE @LotNo
	)
	select 
		t1.*
		,CONCAT(ISNULL(t1.MaterialCode, '') ,';', ISNULL(t1.VC, '') ,';',ISNULL(t1.Qty, ''), ';',ISNULL(t1.MarkingDC, ''), ';',ISNULL(t1.LotID, ''),';', ISNULL(t1.SN, '') , ';',ISNULL(t1.CC, ''),';',ISNULL(t1.REV, ''),';',ISNULL(t1.SiteL, '') ,';',ISNULL(t1.DC, ''),';',ISNULL(t1.MakerBatchcode, ''),';' ,ISNULL(t1.MakerPN, ''),';' , ISNULL(t1.MakerName, ''), ';', t1.MiscData, ';') AS  QRCode
	from table1 t1 





--	-- COMMENT

--			;WITH basedat as (
--				select a1.LotID
--			from	[SmartFactoryV2].[dbo].[STB_MaterialDocLotInfo] a1 WITH(NOLOCK)
--			LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo = a1.MaterialDocDetailNo 
--			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)   on MDD.MaterialDocNo = MDI.MaterialDocNo


--			 where  
--			 (@pMaterialWarehouseCode='TOTAL_MATERIALS'    and MaterialLocationCode not like 'PROD%'    and  MaterialLocationCode  not like 'ROUTE%'
--							 or MaterialLocationCode like @MaterialWarehouseCode+'%'
--					)
--			and (select  count(*) from [SmartFactoryV2].[dbo].[STB_MaterialDocLotInfo]  WITH(NOLOCK) where LotID=a1.lotid and materiallotno is not null ) = 0 --and materiallotno is not null

--			and (select  count(*) from [SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  WITH(NOLOCK) where LotID=a1.lotid  ) = 0 ---dd
--			and (select  count(*) from [SmartFactoryV2].[dbo].[STB_MaterialLotSnapshot]  WITH(NOLOCK) where LotID=a1.lotid  ) = 0  
--			and a1.MaterialCode LIKE @MaterialCode
--			union all 
--			select lotid from [SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  WITH(NOLOCK) 
--			where LotID  like 'SP%' 
--			and (@MaterialCode = '*' OR MaterialCode LIKE @MaterialCode)  --Mr.Duy thêm cho tìm kiếm theo mã NVL

--			and MaterialWarehouseCode like @MaterialWarehouseCode
			
--			or MaterialWarehouseCode= case when @MaterialWarehouseCode not in ('ROH_VN_WH','ROUTE_VN_WH','ROH_BG_WH','ROUTE_BG_WH', 'MODULE_BG2_WH', 'ROUTE_BG2_WH') then @MaterialWarehouseCode else '' end
--),  holddate as(

--				SELECT
--					LotID
--					,
--					MAX(CreateDateTime) AS LatestCreateDateTime
--				FROM
--					STB_MaterialWarehouseInOutHist
--				WHERE  
--					TargetMaterialWarehouseCode = 'HOLDING_VN_WH'
--					OR TargetMaterialWarehouseCode = 'HOLDING_BG_WH'
--					OR TargetMaterialWarehouseCode = 'HOLDING_HN_WH'
--				GROUP BY
--					LotID

--) , Lottachdaxuat as(         --------add 02/10/2024  
--		select LotID,sum(DIVIDE_STOCKQTY) as DIVIDE_STOCKQTY  from STB_VN_DIVIDEMATERIALSMAL  where PACKINGIDSMALL  in (select LotID from STB_MaterialWarehouseInOutHist) group by LotID
--)

--,

-- table1 as (
--			SELECT
--			isnull(MLI.LotID,MdLI.LotID) as LotID,
--			coalesce(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode,mdi.TargetMaterialWarehouseCode) as MaterialWarehouseCode,
--			isnull(MLI.MaterialCode,MdLI.MaterialCode) as MaterialCode,
--			MM.MaterialName,
--			isnull(MLI.InitialQty,mdli.StockQty) as InitialQty,
--			isnull(MLI.CurrentQty,mdli.StockQty) as CurrentQty,
--			CASE 
				
--				WHEN LTDX.DIVIDE_STOCKQTY>0 or LTDX.DIVIDE_STOCKQTY is not null THEN isnull(MLI.CurrentQty,mdli.StockQty)- LTDX.DIVIDE_STOCKQTY
--				ELSE isnull(MLI.CurrentQty,mdli.StockQty)
--			END as StockQty,
--			--isnull(MLI.CurrentQty,mdli.StockQty) AS StockQty,
--			MLI.PickingQty,
--			isnull(MLI.CurrentQty - MLI.PickingQty,mdli.StockQty) AS AvailableQty,
--			isnull(mdli11.CreateDatetime,mli.CreateDateTime) as InputDay,
--			mdli.LotNo,
--			MLI.IsSplitLot,
--			CONVERT(NUMERIC(20,5), NULL) AS SplitQty,
--			MLI.BefMaterialLotNo,

--			'PartLabel' AS LabelType,	
--			'Report' AS CommandType, 
				
--			CASE WHEN ISNULL(MLI.LotAttr03, '') <> '' THEN MLI.LotAttr03 
--				ELSE ci2.CustomerName
--				END AS LotAttr03,		-- mr.Manh update 2026-03-28 for Bac Giang 2 audit

--			MDLI.LotAttr10 AS LotAttr10 ,
--			MDLI.LotAttr10 as ProductionDate,
		
--			dateadd (   day,  
--						CASE WHEN MDLI.MaterialCode = 'MDFLUX-002' THEN (MM.MMExtInt01*30)-1
--							ELSE (CONVERT(INT, CASE WHEN MM.MMExtInt01 IS NULL OR LTRIM(RTRIM(MM.MMExtInt01))='' THEN 3 ELSE MM.MMExtInt01 END) * 30)  -- 09/04/2026 [Just for code: 'MDFLUX-002' = 179 days] -- ThucTD
--						END,
--						case when  len(((mdli.LotAttr10)))=10 
--								and ((mdli.LotAttr10)) like '20%' 
--								and substring(((mdli.LotAttr10)),5,1)='-' 
--								and substring(((mdli.LotAttr10)),8,1)='-'  
--								and substring(((mdli.LotAttr10)),3,2)>='00' and substring(((mdli.LotAttr10)),3,2)<='99'

--								and substring(((mdli.LotAttr10)),6,2)>='01' and substring(((mdli.LotAttr10)),6,2)<='12'

--								and substring(((mdli.LotAttr10)),9,2)>='01' and substring(((mdli.LotAttr10)),9,2)<=(case when substring(((mdli.LotAttr10)),6,2)='02' then '28' 
--																													when substring(((mdli.LotAttr10)),6,2) in ('04', '06', '09', '11') then '30' else '31' end)

--								and substring(((mdli.LotAttr10)),3,1)>='0'   and substring(((mdli.LotAttr10)),3,1)<='9'
--								and substring(((mdli.LotAttr10)),4,1)>='0'   and substring(((mdli.LotAttr10)),4,1)<='9'
--								and substring(((mdli.LotAttr10)),6,1)>='0'   and substring(((mdli.LotAttr10)),6,1)<='9'
--								and substring(((mdli.LotAttr10)),7,1)>='0'   and substring(((mdli.LotAttr10)),7,1)<='9'
--								and substring(((mdli.LotAttr10)),9,1)>='0'   and substring(((mdli.LotAttr10)),9,1)<='9'
--								and substring(((mdli.LotAttr10)),10,1)>='0' and substring(((mdli.LotAttr10)),10,1)<='9'
--							 then ((mdli.LotAttr10)) else mdi.BasicDate  end
--					) as  EffectDate,

--			case when dateadd(  month,  convert(INT,case when MMExtInt01 is null or MMExtInt01='' then 3 else MMExtInt01 end) , 						
			
--			case when  len(((mdli.LotAttr10)))=10 
--								and ((mdli.LotAttr10)) like '20%' 
--								and substring(((mdli.LotAttr10)),5,1)='-' 
--								and substring(((mdli.LotAttr10)),8,1)='-'  
--								and substring(((mdli.LotAttr10)),3,2)>='00' and substring(((mdli.LotAttr10)),3,2)<='99'

--								and substring(((mdli.LotAttr10)),6,2)>='01' and substring(((mdli.LotAttr10)),6,2)<='12'

--								and substring(((mdli.LotAttr10)),9,2)>='01' and substring(((mdli.LotAttr10)),9,2)<=(case when substring(((mdli.LotAttr10)),6,2)='02' then '28' 
--																													when substring(((mdli.LotAttr10)),6,2) in ('04', '06', '09', '11') then '30' else '31' end)

--								and substring(((mdli.LotAttr10)),3,1)>='0'   and substring(((mdli.LotAttr10)),3,1)<='9'
--								and substring(((mdli.LotAttr10)),4,1)>='0'   and substring(((mdli.LotAttr10)),4,1)<='9'
--								and substring(((mdli.LotAttr10)),6,1)>='0'   and substring(((mdli.LotAttr10)),6,1)<='9'
--								and substring(((mdli.LotAttr10)),7,1)>='0'   and substring(((mdli.LotAttr10)),7,1)<='9'
--								and substring(((mdli.LotAttr10)),9,1)>='0'   and substring(((mdli.LotAttr10)),9,1)<='9'
--								and substring(((mdli.LotAttr10)),10,1)>='0' and substring(((mdli.LotAttr10)),10,1)<='9'
--							 then ((mdli.LotAttr10)) else  mdi.BasicDate  end ) <= getdate() then 'Expired' 

--			when  dateadd(  month,  convert(INT,case when MMExtInt01 is null or MMExtInt01='' then 3 else MMExtInt01 end) , 						
			
--			case when  len(((mdli.LotAttr10)))=10 
--								and ((mdli.LotAttr10)) like '20%' 
--								and substring(((mdli.LotAttr10)),5,1)='-' 
--								and substring(((mdli.LotAttr10)),8,1)='-'  
--								and substring(((mdli.LotAttr10)),3,2)>='00' and substring(((mdli.LotAttr10)),3,2)<='99'

--								and substring(((mdli.LotAttr10)),6,2)>='01' and substring(((mdli.LotAttr10)),6,2)<='12'

--								and substring(((mdli.LotAttr10)),9,2)>='01' and substring(((mdli.LotAttr10)),9,2)<=(case when substring(((mdli.LotAttr10)),6,2)='02' then '28' 
--																													when substring(((mdli.LotAttr10)),6,2) in ('04', '06', '09', '11') then '30' else '31' end)

--								and substring(((mdli.LotAttr10)),3,1)>='0'   and substring(((mdli.LotAttr10)),3,1)<='9'
--								and substring(((mdli.LotAttr10)),4,1)>='0'   and substring(((mdli.LotAttr10)),4,1)<='9'
--								and substring(((mdli.LotAttr10)),6,1)>='0'   and substring(((mdli.LotAttr10)),6,1)<='9'
--								and substring(((mdli.LotAttr10)),7,1)>='0'   and substring(((mdli.LotAttr10)),7,1)<='9'
--								and substring(((mdli.LotAttr10)),9,1)>='0'   and substring(((mdli.LotAttr10)),9,1)<='9'
--								and substring(((mdli.LotAttr10)),10,1)>='0' and substring(((mdli.LotAttr10)),10,1)<='9'
--							 then ((mdli.LotAttr10)) else  mdi.BasicDate  end ) <= dateadd(day, 
--							(case when mm.ProductGroupCode like '%coat%roll%' or  
--									mm.ProductGroupCode like '%slit%roll%' then 15 else 30 end) 
--								,getdate() 
--								)  then 'Warning' 
--			else 'Safe' end as [Status] ,

									
--			MMExtInt01 AS Effectivemonths,
--			1              AS LabelQty  ,
--			--- ADD

--			'035-V188' AS VC,
--			--LEFT(isnull(MLI.InitialQty,mdli.StockQty), CHARINDEX('.', isnull(MLI.InitialQty,mdli.StockQty) + '.') - 1) AS Qty,
--			--LEFT(CAST(t1.InitialQty AS VARCHAR(20)), CHARINDEX('.', CAST(t1.InitialQty AS VARCHAR(20)) + '.') - 1)
--			LEFT(CAST(isnull(MLI.InitialQty,mdli.StockQty) AS VARCHAR(20)), CHARINDEX('.', CAST(isnull(MLI.InitialQty,mdli.StockQty) AS VARCHAR(20)) + '.') - 1) AS Qty,
--			'QLKc' AS MarkingDC,
--			--'001' AS SN,
--			FORMAT(ROW_NUMBER() OVER (PARTITION BY	mdli.LotNo	ORDER BY mdli.LotID	asc), '000') AS SN,
--			'VN' AS CC,
--			'NA' AS REV,
--			'1002' AS [Site],
--			'0001081' AS PO,
--			dbo.fnGetWeekNumber(CONVERT(DATE, dbo.fnPharseLotNo(mdli.LotNo, 'D'), 112)) AS DC,
--			--'' AS DC,
--			RIGHT(isnull(MLI.MaterialCode,MdLI.MaterialCode), 1) AS MakerBatchcode,
--			'VEC3R0727QG' AS MakerPN,
--			'VINATechVINA' AS MakerName,
--			'NA' AS MiscData

--	FROM
--		(
--		select  CreateDateTime,MaterialDocDetailNo,MaterialLotNo,lotno,LotID,MaterialLocationCode,MaterialCode,StockQty,LotAttr09,replace(replace(replace(ltrim(rtrim(isnull(LotAttr10,''))),'--','-' ),'--','-' ),' ','' )as LotAttr10
--		from STB_MaterialdocLotInfo  WITH(NOLOCK) 
--		where

--		MaterialLocationCode LIKE @MaterialWarehouseCode+'%'
--		and (@MaterialCode = '*' OR MaterialCode LIKE @MaterialCode) --Mr.Duy thêm cho tìm kiếm theo mã NVL
--		and CreateUserID <> '23091804'		-- Mr.Manh update 2026-01-09 because duplicate lot
		
--		union  all
--		(select CreateDateTime ,'',MaterialLotNo,lotno,LotID,MaterialLocationCode,MaterialCode,currentqty,LotAttr09,replace(replace(replace(ltrim(rtrim(isnull(LotAttr10,''))),'--','-' ),'--','-' ),' ','' )as LotAttr10
--		from STB_MaterialLotInfo  WITH(NOLOCK) 
--		where

--		(lotid like 'SP%' or lotid like 'SL%'or lotid like 'SM%' 
--		OR (MaterialCode IN ('MPBT00-001', 'BEINS0-003', 'BEMC00-068', 'BEMC00-105', 'BEMC00-045', 'MDBAR-001', 'MDCLEAN-001', 'MDFLUX-001', 'MDIPA-001', 'BEMC00-043', 'BEMC00-044') 

--			) ) and -- thêm ds BG2
--		 MergeParentId is  null
--		 and MaterialWarehouseCode LIKE @MaterialWarehouseCode
--		or MaterialWarehouseCode= case when @MaterialWarehouseCode not in ('ROH_VN_WH','ROUTE_VN_WH','ROH_BG_WH','ROUTE_BG_WH','ROH_HN_WH','ROUTE_HN_WH', 'MODULE_BG2_WH', 'ROUTE_BG2_WH') then @MaterialWarehouseCode else '' end
--		and (@MaterialCode = '*' OR MaterialCode LIKE @MaterialCode) --Mr.Duy thêm cho tìm kiếm theo mã NVL
	
--		and  ((IsSlitting is null and PackingIdParent is null) or (PackingIdParent is not null and IsSlitting is not null ) ) --Ms.Ha lay cac lot chua slitting hoac cac lot con da slitting
--		)) mdli --with(nolock) 
--		left outer join STB_MaterialLotInfo mli  with(nolock) on mdli.LotID = mli.LotID
--		left outer join STB_MaterialDocLotInfo mdli11  with(nolock) on (mdli11.LotID = mdli.LotID and mdli11.CreateUserID <> '23091804')-- Mr.Manh update 2026-01-09 because duplicate lot
--		left outer join STB_MaterialDocDetail mdd  with(nolock) on (mdd.MaterialDocDetailNo = mdli.MaterialDocDetailNo and mdd.CreateUserID <> '23091804') -- Mr.Manh update 2026-01-09 because duplicate lot
--		left outer join holddate inout with(nolock) on mdli.LotID = inout.LotID
--		left outer join STB_MaterialDocInfo mdi with(nolock)  on mdd.MaterialDocNo = mdi.MaterialDocNo
--		left outer join basedat on mdli.LotID = basedat.LotID 
		
--			LEFT OUTER jOIN STB_MaterialMaster MM WITH(NOLOCK)			ON	MdLI.MaterialCode = MM.MaterialCode
--			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
--			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				ON	PG.ProductGroupCode = MM.ProductGroupCode
--			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)		ON	MW.MaterialWarehouseCode = mdi.TargetMaterialWarehouseCode
--			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)			ON	ML.MaterialLocationCode = MdLI.MaterialLocationCode
--			LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI WITH(NOLOCK)		ON MM.MaterialCode = MSAI.MaterialCode                                            -- 추가부분			
--			LEFT OUTER JOIN Lottachdaxuat LTDX WITH(NOLOCK)		ON mdli.LotID  = LTDX.LotID                                            -- 추가부분			
--		left outer join STB_CustomerInfo ci2  WITH(NOLOCK) on MDi.SourceCustomerCode = ci2.CustomerCode 
--	where  
--			(MLI.CompanyCode = @CompanyCode) 		
--			and (@pMaterialWarehouseCode='TOTAL_MATERIALS'    and isnull(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode) not like 'PROD%'    and  isnull(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode)  not like 'ROUTE%'
--				or isnull(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode) LIKE @MaterialWarehouseCode+'%') 			
--			and (@MaterialCode = '*' OR MLI.MaterialCode LIKE @MaterialCode) 			
--			--and (@LotID = '*' OR MLI.LotID = @LotID)
--			and (MaterialDocType<>'GI' or MaterialDocType is null)
--			AND MLI.MaterialCode LIKE @MaterialCode
--			or mdli.LotID in (select LotID from basedat)
		

--	)select 
--		t1.*
--		,CONCAT(ISNULL(t1.MaterialCode, '') ,';', ISNULL(t1.VC, '') ,';',ISNULL(t1.Qty, ''), ';',ISNULL(t1.MarkingDC, ''), ';',ISNULL(t1.LotNo, ''),';', ISNULL(t1.SN, '') , ';',ISNULL(t1.CC, ''),';',ISNULL(t1.REV, ''),';',ISNULL(t1.[Site], ''),';',ISNULL(t1.PO, '') ,';',ISNULL(t1.DC, ''),';',ISNULL(t1.MakerBatchcode, ''),';' ,ISNULL(t1.MakerPN, ''),';' , ISNULL(t1.MakerName, ''), ';', t1.MiscData, ';') AS  QRCode
--		--,CONCAT(ISNULL(t1.MaterialCode, '') ,';') AS  QRCode
--	from table1 t1 
--	where t1.StockQty>0

-- END COMMENT


	


	
	-- usp_VVTF4_CellMaterialLotInfo_get '' ,'', 'VVT', 'MODULE_BG2_WH', '' ,''




END
