-- =============================================
-- Author : Mr.Tung
-- 2021-06-15 
--         exec   usp_RawMaterialNotInput_popup '','','','','',null,null
-- =============================================
CREATE PROCEDURE [dbo].[usp_RawMaterialNotInput_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pVendorLot VARCHAR(50) = NULL,
	@pLotID VARCHAR(50) = NULL,
	@pproductgroupname VARCHAR(50) = NULL,
	@pFromDate datetime = NULL,
	@pToDate datetime = NULL
AS

BEGIN

	SET NOCOUNT ON;
	declare @VendorLot VARCHAR(50) = case when @pVendorLot is null or @pVendorLot='' then NULL else @pVendorLot end
	declare @LotID VARCHAR(50) = case when @pLotID is null or @pLotID='' then '*' else @pLotID end
	declare @productgroupname VARCHAR(50) = case when @pproductgroupname is null or @pproductgroupname='' then NULL else @pproductgroupname end
	declare @FromDate DATETIME = case when @pFromDate is null or @pFromDate='' or @pFromDate<'2001-01-01' then '2021-03-01 00:00:00' else @pFromDate end
	declare @ToDate DATETIME = case when @pToDate is null or @pToDate='' or @pToDate<'2001-01-01' then getdate() else @pToDate end

;with newtable as (
select 
	 mli.lotid--, pg.productgroupname,rmbi.productgroupname
	from
	stb_materiallotinfo mli with(nolock) 
	where mli.MaterialWarehouseCode='ROUTE_VN_WH'
	and ( mli.createdatetime>=@FromDate  )
	and ( mli.createdatetime<=@ToDate  )	
except 
select  
	case when RMIH.RawMaterialBarcode like 'ML%' and RMIH.RawMaterialBarcode like '%~%'
							then SUBSTRING(RMIH.RawMaterialBarcode,1,16)                               --- get string front of ~
						else RMIH.RawMaterialBarcode end
	from STB_RawMaterialInputHist RMIH with(nolock) 
	where (case when RMIH.RawMaterialBarcode like 'ML%' and RMIH.RawMaterialBarcode like '%~%'
							then SUBSTRING(RMIH.RawMaterialBarcode,1,16)                               --- get string front of ~
						else RMIH.RawMaterialBarcode end) like 'ML%'
	 and ( RMIH.createdatetime>=@FromDate  )
	 and ( RMIH.createdatetime<=@ToDate )
)
----select*from newtable
select 
	 mli.lotid, mli.MaterialCode,mm.MaterialName, max(mdd.vendorlotno) as vendorlotno  --pg.productgroupname,rmbi.productgroupname
from
	stb_materiallotinfo mli with(nolock) 
	left outer join STB_MaterialMaster mm  with(nolock) on  mli.materialcode = mm.materialcode
	left outer join STB_MaterialDocLotInfo mdli  with(nolock) on mli.lotid = mdli.lotid
	left outer join STB_MaterialDocDetail mdd  with(nolock) on mdd.MaterialDocDetailNo = mdli.MaterialDocDetailNo
	left outer join stb_productgroup pg  with(nolock)  on  mm.productgroupcode = pg.productgroupcode
	left outer join STB_RawMaterialBaiscInfo rmbi with(nolock)  on rmbi.productgroupname = pg.productgroupname
where ( rmbi.productgroupname = @productgroupname   ) -- or rmbi.productgroupname is null )
 and mli.lotid in (select lotid from newtable)
 group by mli.lotid, mli.MaterialCode,mm.MaterialName

END

