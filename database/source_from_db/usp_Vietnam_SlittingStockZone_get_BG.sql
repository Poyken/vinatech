-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================usp_Vietnam_SlittingStockZone_get_BG 'kho1'
CREATE PROCEDURE [dbo].[usp_Vietnam_SlittingStockZone_get_BG]
						@pProcessUserID VARCHAR(20)=null, 
						@pProcessLanguage VARCHAR(20)=null, 
						@pCompanyCode VARCHAR(20) = NULL  ,
						@pLocation VARCHAR(50)=NULL,
						@pBarcode  VARCHAR(50)=NULL
						
AS

BEGIN
		
	


;with based as (
	 
    SELECT   --ESR.ElectrodeLotNumber
        --,ESR.Barcode	
        count(*) as totalstock, 
        isnull(slc.RollQty,ss.RollQty) as RollQty,
        MM.MaterialName
        ,SI.Materialcode
        --,ESR.Seq
        --,ESR.ElectrodeThick
        --,ESR.SlittingWidth
        --,ESR.ProductionQty
        --,ESR.GoodQtyLength
        --,isnull(ss.CreateDateTime,ESR.CreateDateTime) CreateDateTime
        --,isnull(ss.CreateUserID,ESR.CreateUserID) CreateUserID
        --,ESR.ChangeDateTime
        --,ESR.ChangeUserID
        --,'Report' AS CommandType			
        --,ESR.LotUniqueNumber
        --,SVEOH.CreateUserId as EmpCreate
        --,SVEOH.VCMLine as VCMLine
        --,RIGHT(ESR.Barcode, 3) AS CutNo
		 ,mm.materialsource   
		 ,mm.MaterialThickness
		 ,ss.partno           
        --,case when ss.Location='NG' then '-' else mm.materialsource    end as materialsource
        --,case when ss.Location='NG' then '-' else mm.MaterialThickness end as MaterialThickness
        --,case when ss.Location='NG' then '-' else ss.partno             end as partno, 
        ,ss.Farad, 
        --ss.RollQty, 
        ss.Location  
		,slc.lengthactive
		,slc.lengthpassive
        --,ss.MaterialSource, ss. ElectrodeThick, ss.SlittingWidth ,ss.GoodQtyLength
        --, ss.CreateDateTime, ss.CreateUserID 
        ,isnull(ss.WarehouseCode,'ELEC_VN_WH') as WarehouseCode,
        --,ss.ListUsed, ss.ListDate, ss.LotCount
		sum(esr.GoodQtyLength) as GoodQtyLength,
		--,lengthactive ,lengthpassive--,
				sum(esr.GoodQtyLength*1000/lengthactive) as duong ,
		sum(esr.GoodQtyLength*1000/lengthpassive) as aam,
		sum(case when  mm.MaterialName like '%(-)%' or mm.MaterialName like '%Forming%' then  esr.GoodQtyLength*1000/lengthpassive else esr.GoodQtyLength*1000/lengthactive end) as  tieuchuan
      FROM stb_slittingStock_VVT ss  WITH(NOLOCK) 
     
      left outer join STB_ElectrodeSlittingResult ESR WITH(NOLOCK)  on ESR.Barcode = ss.Barcode
      LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)   ON ESR.ElectrodeLotNumber = SI.Barcode
      LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode = SI.MaterialCode
       left outer join STB_SlittingLocationConfig_VVT slc  WITH(NOLOCK) on mm.MaterialName like 	 '%'+replace(slc.SlittingCode,	slc.SlittingSize,'') +'%'+slc.SlittingSize +'%'
       and ss.CreateUserID = slc.LocationWarehouse and(ss.Location=slc.NegativeLocation or ss.Location=slc.PositiveLocation)
      --LEFT OUTER JOIN STB_Vietnam_ElectrodeOutHist SVEOH WITH(NOLOCK) on ESR.LotUniqueNumber = SVEOH.LotUniqueNumber
    where 
    ESR.CreateDateTime>='2022-01-01'  
    and ESR.CreateDateTime<=getdate()
	and ESR.WorkCenterCode ='VVT_F2'
    and WarehouseCode='ELEC_VN_WH'
    and slc.LocationWarehouse = @pProcessUserID
    --and (@WHCode='*' or isnull(ss.WarehouseCode,'ELEC_VN_WH') = @WHCode)
     --WHERE ESR.ElectrodeLotNumber = @ElectrodeLotNumber
     and location is not null --and location <>'NoInput'
     group by  isnull(slc.RollQty,ss.RollQty),MM.MaterialName
        ,SI.Materialcode			,MM.MaterialSource,mm.MaterialThickness
        ,ss.PartNo, 
        ss.Farad, 
        --ss.RollQty, 
        ss.Location  ,isnull(ss.WarehouseCode,'ELEC_VN_WH')		
		,slc.lengthactive
		,slc.lengthpassive
     --and si.MaterialCode='CRYHK0-020'
     --ORDER BY location,PartNo,SI.Materialcode,ESR.CreateDateTime, ESR.ElectrodeLotNumber,ESR.Barcode	,ESR.Seq
  
  )
    ,newtable as (SELECT   esr.electrodelotnumber
        ,esr.barcode	
        ,mm.materialname
        ,si.materialcode
        --,esr.seq
        --,esr.electrodethick
        --,esr.slittingwidth
        --,esr.productionqty
        --,esr.goodqtylength
        ,isnull(ss.createdatetime,esr.createdatetime) createdatetime
        ,isnull(ss.createuserid,esr.createuserid) createuserid
        ,esr.changedatetime
        ,esr.changeuserid
        --,'report' as commandtype			
        --,esr.lotuniquenumber
        --,sveoh.createuserid as empcreate
        --,sveoh.vcmline as vcmline
        --,right(esr.barcode, 3) as cutno
        ,case when ss.Location='NG' then ' NG' else mm.materialsource end as materialsource
        ,case when ss.Location='NG' then ' NG' else mm.MaterialThickness end as MaterialThickness
        ,case when ss.Location='NG' then ' NG' else ' '+ss.partno+'  ('+convert(varchar(5),ss.Farad)+'F)' end as partno

        ,ss.farad
        --ss.rollqty, 
        ,case when ss.location='NG' then 'NG' when mm.MaterialName like '%(-)%' or mm.MaterialName like '%Forming%' then  ss.location  + ' (-)' else  ss.location  + ' (+)' end as [location]
        --,ss.materialsource, ss. electrodethick, ss.slittingwidth ,ss.goodqtylength
        --, ss.createdatetime, ss.createuserid 
        ,isnull(ss.warehousecode,'ELEC_VN_WH') as warehousecode
        --,ss.listused, ss.listdate, ss.lotcount
        ,case when ss.Location='NG' then 56 else based.rollqty end as rollqty
		,case when ss.Location='NG' then null else based.totalstock end as tts

		,lengthactive 
		,lengthpassive--,
		,round(based.duong,1) as duong
		,round(based.aam,1) as aam
		
		,convert(float,based.GoodQtyLength) as tmpgoodlength
		,round(based.tieuchuan,1) as tieuchuan
		--,case when  mm.MaterialName like '%(-)%' or mm.MaterialName like '%Forming%' then  lengthpassive else lengthactive end as  donvi		
		,'' as donvi
		--esr.GoodQtyLength*1000/lengthactive as duong ,
		--esr.GoodQtyLength*1000/lengthpassive as aam,
		--case when  mm.MaterialName like '%(-)%' or mm.MaterialName like '%Forming%' then  esr.GoodQtyLength*1000/lengthpassive else esr.GoodQtyLength*1000/lengthactive end as  tieuchuan
		--case when  mm.MaterialName like '%(-)%' or mm.MaterialName like '%Forming%' then  ss.location  + ' (-)' else  ss.location  + ' (+)' end as  counter2
      FROM stb_slittingStock_VVT ss WITH(NOLOCK) 
      
      left outer join STB_ElectrodeSlittingResult ESR WITH(NOLOCK)  on ESR.Barcode = ss.Barcode
      LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)   ON ESR.ElectrodeLotNumber = SI.Barcode
      LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode = SI.MaterialCode
      left outer join based on based.MaterialCode=si.MaterialCode and based.Location = ss.Location 
      and based.PartNo=ss.PartNo	  and based.MaterialSource = ss.MaterialSource
      --LEFT OUTER JOIN STB_Vietnam_ElectrodeOutHist SVEOH WITH(NOLOCK) on ESR.LotUniqueNumber = SVEOH.LotUniqueNumber
    where 
    ESR.CreateDateTime>='2022-01-01'  
    and ESR.CreateDateTime<=getdate()
	and ESR.WorkCenterCode ='VVT_F2'
    and ss.WarehouseCode='ELEC_VN_WH'
    and based.location is not null
    --and (@WHCode='*' or isnull(ss.WarehouseCode,'ELEC_VN_WH') = @WHCode)
     --WHERE ESR.ElectrodeLotNumber = @ElectrodeLotNumber
     and ss.location is not null --and location <>'NoInput'
     --group by 
     --and si.MaterialCode='CRYHK0-020'
	 )
	-- ,
	-- newtablesum as (
	--	select MaterialCode,materialsource,MaterialThickness,partno,Farad,location,warehousecode,rollqty from newtable
	-- )
	 select*, 		isnull(tts,(select count(*)from newtable where Location='NG')) as totalstock
	 ,case when tts is null then (select sum(tmpgoodlength) from newtable where Location='NG') else tmpgoodlength end as goodlength 
	 from newtable
     ORDER BY PartNo,MaterialSource,MaterialCode,location,MaterialThickness,CreateDateTime, ElectrodeLotNumber,Barcode	
	 
	-- select top 1000*from STB_ElectrodeSlittingResult

end

