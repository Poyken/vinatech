
-- exec usp_Vietnam_LocateOfRawMaterials
-- Author: Nguyễn Hải Triều(Mr.Dev)
-- Description: Hiển thi tất cả các vị trí tồn kho kho nguyên vật liệu cho nhà máy Bắc Ninh
CREATE PROCEDURE [dbo].[usp_Vietnam_LocateOfRawMaterials] 

AS 
BEGIN 

	SET NOCOUNT ON; 
	;with bomver as (
    select MaterialCode,max(bomversion) as bomversion
    from STB_BomDetail with(nolock) 
    where bomversion <> '1000'  and (MaterialCode like 'E%' or MaterialCode like 'SR%' or MaterialCode like 'C%')
    group by MaterialCode
    )
  ,baseMatchMaterial as (
    select 	right('0'+convert(varchar(2),convert(int,mbi.MBISizew)),2) + right('0'+convert(varchar(2),convert(int,mbi.MBISizeh)),2) as size  ,
    bd.MaterialCode, MaterialName, bd.BomVersion, ChildMaterialCode, ChildBomVersion, BomUnit, UsedQty, 
    RouteCode, bd.CreateUserID, bd.CreateDateTime, bd.ChangeUserID, bd.ChangeDateTime 	
    from STB_BomDetail  bd with(nolock) 
    join bomver on bd.MaterialCode=bomver.MaterialCode and bd.BomVersion=bomver.bomversion
    left outer join STB_MaterialMaster mm  with(nolock) on bd.MaterialCode=mm.MaterialCode
    left outer join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode=mbi.ModelCode
    where RouteCode not like 'E%' 
  )
    , data1 as (
      select materiallotno, lotid as barcode, materialcode, materialcode as materialsource,' ' as MaterialThickness, materialstockattribute, 	stockattrib1, stockattrib2, 
    stockattrib3, currentqty, materiallocationcode, packingid, lotno, vendorlotno, lotattr01, lotattr02, lotattr03, 	lotattr04, lotattr05, lotattr06, lotattr07, lotattr08, 
    stuff(( select distinct ' ~ '+ (size)  from baseMatchMaterial where ChildMaterialCode=mli.MaterialCode  for xml path('') ), 1, 2, '') as partno,
    case 
    when upper(MaterialLocationCode) like '%HOLD%' 
        then 'NG' 
    when isnull(lotattr09,'')='' 
        then 'Not input' 
    else lotattr09 COLLATE Latin1_General_CS_AS  
end as [location]
, 
    lotattr10, createdatetime, createuserid, changedatetime, changeuserid ,56 as rollqty
       from stb_materiallotinfo mli with(nolock) 
      where materialwarehousecode in ('ROH_VN_WH','HOLDING_VN_WH') and lotid>'ML201911' and createuserid<>'kilee'
	   and  ltrim(isnull(lotattr09,''))<>'' 
	   --and LotAttr09 COLLATE Latin1_General_CS_AS in('H2-3')
      union 
      select materiallotno, lotid as barcode, materialcode, materialcode as materialsource,' ' as MaterialThickness, materialstockattribute, 	stockattrib1, stockattrib2, 
    stockattrib3, stockqty  , materiallocationcode, packingid, lotno, vendorlotno, lotattr01, lotattr02, lotattr03, 	lotattr04, lotattr05, lotattr06, lotattr07, lotattr08, 
    stuff(( select distinct ' ~ '+ (size)  from baseMatchMaterial where ChildMaterialCode=mdli.MaterialCode for xml path('') ), 1, 2, '') as partno,
    case 
    when upper(MaterialLocationCode) like '%HOLD%' 
        then 'NG' 
    when isnull(lotattr09,'')='' 
        then 'Not input' 
    else lotattr09 COLLATE Latin1_General_CS_AS  
end as [location],

    lotattr10, createdatetime, createuserid, changedatetime, changeuserid ,56 as rollqty
       from stb_materialdoclotinfo  mdli with(nolock) 
      where materiallocationcode in ('ROH_VN_WH_01','HOLDING_VN_WH_01') 
      and lotid not in (select lotid from stb_materiallotinfo with(nolock) ) 
      and lotid>'ML201911' and createuserid<>'kilee'
	  and  ltrim(isnull(lotattr09,''))<>'' 
	
      ), 
      data2 as(
      select  partno, location ,materiallocationcode,materialsource,count(*) as totalstock,sum(CurrentQty) as totalqty
      from data1 where data1.materiallotno not in ('20251229003289')

      group by partno,location,materiallocationcode,materialsource
      )
      select  data1.*,data2.totalqty,data2.totalstock,mm.materialname,mm.MaterialUnit from data1
      join data2 on data1.location=data2.location and data1.materiallocationcode=data2.materiallocationcode and data1.materialsource=data2.materialsource
      join STB_MaterialMaster mm  with(nolock) on data1.MaterialCode = mm.MaterialCode   
	 where data1.MaterialCode not in ('GBAKAC-068', 'GBAKAC-060','GBRBPL-003','GBAKAC-036') and data1.location not in ('A1-8','A1-6')
     and data1.materiallotno not in ('20251229003289')
            
            
    order by [location],partno,MaterialCode  
	

END
