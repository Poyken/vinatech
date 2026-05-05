CREATE PROCEDURE [dbo].[usp_LotTrackingInfo_VVT2_get_test_B781]
(
    @pProcessUserID VARCHAR(20)=NULL,
	@pProcessLanguage VARCHAR(20)=NULL,
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(30) = NULL,
	@pMarkingLetter VARCHAR(30) = NULL,
	@pWorkCenterCode VARCHAR(30) = NULL
	--exec usp_LotTrackingInfo_VVT2_get_test_B781 null,null,'VVT','2025-04-22','2025-04-23',null,null,null,null,null,'VVT_F2'
)
AS
    DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    

	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
	DECLARE	@MarkingLetter VARCHAR(30) = CASE WHEN ISNULL(@pMarkingLetter, '') = '' THEN '*' ELSE @pMarkingLetter END
	DECLARE	@WorkCenterCode VARCHAR(30) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
BEGIN

  
	SET NOCOUNT ON;

	/*IF @pWorkCenterCode = 'VVT_F1'

		BEGIN*/
update  [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT]
set PackQty = -1*PackQty,EmpNo=EmpNo+'.'
where PackQty>0 
and PackingID in (
 SELECT b.PackingID
  FROM [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] a with(nolock) 
  join  [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] b  with(nolock) on a.LotNo = left(b.PackingID,14)
  where a.id>615234
  and b.id>615234
  and a.PackQty>0
  and b.PackQty>0 
  and a.LotNo<>b.LotNo 
  and a.isPrinted=0
  and b.isPrinted=0
)

;with tung as 
		(
	   		SELECT  id,
			(select top 1 newbarcode from STB_LotChangeMaterialHistory WITH(NOLOCK) where oldBarcode=LotNo) as newLotno
			,LotNo,PackingID,MaterialCode,MaterialName,EmpNo,PrintTime,PackQty, isPrinted,PartNo,
			(RANK() over (partition by LotNo,isPrinted order by  PackQty desc,printtime desc) ) as RankPackQty,
			(ROW_NUMBER() over (partition by LotNo,isPrinted order by PackQty desc,printtime desc) ) as RowPackQty--,
			  --ISNULL(DRI.PackQty, 0) * ISNULL(vwup.ProcessUnitPriceEA,0)  as Price
			FROM  [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] DRI  WITH(NOLOCK) 

			where 1=1 
			 and  EmpNo not in ('test_worker','assy_packing' )
			and PrintTime between (case when @LotNo is not null and @LotNo<>'*' then '2020-08-15 10:00:00' else @FromDate end) 
			and (case when @LotNo is not null and @LotNo<>'*' then CONVERT(varchar(19),getdate(),120) else @ToDate end) 
			and PackQty>1 --or MaterialName like '%356_%' and PackQty>120)
			and ( isPrinted = 0 or isPrinted = (case when @LotNo is not null and @LotNo<>'*' then 1 else 0 end)  )	
			---and LotNo='VVKQ153R050503'
		)

	 ,
	 tung22 as (
	SELECT  id,
	 newLotno,LotNo,PackingID,a.MaterialCode,MaterialName,EmpNo,PrintTime,
	 PackQty --* (select count(LotNo) from stb_materialLotinfo  WITH(NOLOCK) where LotNo =a.LotNo) as PackQty
	 ,isPrinted,PartNo
	 ,b.InputLineCode,c.ProdDateTime,b.ControlNo,
(ROW_NUMBER() over (partition by LotNo,isPrinted order by PackQty desc,printtime desc) ) as RowPackQty2
	  FROM tung a WITH(NOLOCK) 
	  join STB_SetInfo b WITH(NOLOCK)  on  (a.LotNo=b.Barcode or a.newLotno=b.Barcode)
	  join STB_ProdRouteHist c  WITH(NOLOCK) on b.ControlNo=c.ControlNo and
	  c.RouteCode= 
	  case 
	  when @pWorkCenterCode = 'VVT_F1'then'V-28'
	  when @pWorkCenterCode = 'VVT_F2'then'V-28_BG'
	  when @pWorkCenterCode = 'VVT_F3'then'VE10'
	  else ''
	  end
	  where 1=1 
	   and  EmpNo not in ('test_worker','assy_packing' )

		and (RowPackQty=1 /*or RankPackQty in (1,2) and MaterialName like '%35_2%'*/)
		AND (@LineCode = '*' OR InputLineCode   = @LineCode)
		AND (@LotNo = '*' OR LotNo       = @LotNo or newlotno=@LotNo)

	 )

	SELECT 

	DRI.id ,
	 newLotno,LotNo,PackingID,DRI.MaterialCode,MaterialName,EmpNo,PrintTime,PackQty 
	 
	 , (case when isPrinted is null or isPrinted=0 then 'Hien(show)' else 'An(hide)' end) as isPrinted
	 , PartNo
	 , DRI.InputLineCode,DRI.ProdDateTime,DRI.ControlNo,--RV.DefectQty,
	   ISNULL(DRI.PackQty, 0) *  convert(numeric(38,15),ISNULL(vwup.PriceV28,0)) /** 1.05*/  as Price,
	   --case này mới đúng đang sửa cho hợp báo cáo bằng case dưới
	   	 --(case  when   (datepart(hour, PrintTime)>10)     or    (datepart(hour, PrintTime)=10 and datepart(minute, PrintTime)>30)     
				--then     convert(varchar(10),PrintTime,120)    
				--else    convert(varchar(10),dateadd(day, -1,  PrintTime),120)       
				--end )
			(case  
				when LotNo in (select * from stb_Changedate_B781_220924)  then '2024-09-05'   
				when   (datepart(hour, PrintTime)>10)     or    (datepart(hour, PrintTime)=10 and datepart(minute, PrintTime)>30)     
				then     convert(varchar(10),PrintTime,120)    
				else 
					case 
					when LotNo='VVNU212R750638'
					then
				   convert(varchar(10),dateadd(day, 0,  PrintTime),120)  
				   else
				   	convert(varchar(10),dateadd(day, -1,  PrintTime),120)
				   end       
				end )	
				    as  jobdate,
					SUM(CASE 
            WHEN Y.TypeErrorCode ='PQC'
                 THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0)
            ELSE 0
        END) + SUM(CASE 
            WHEN Y.TypeErrorCode ='Reliability'
                 THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0)
            ELSE 0
        END)+SUM(CASE 
            WHEN Y.TypeErrorCode IS NULL
                 THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0)
            ELSE 0
        END)+SUM(CASE 
            WHEN Y.TypeErrorCode='Production_Inspection'
                 THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0)
            ELSE 0
        END)+SUM(CASE 
            WHEN Y.TypeErrorCode='Production_Defect'
                 THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0)
            ELSE 0
        END)+SUM(CASE 
            WHEN Y.TypeErrorCode='Machine_Repair'
                 THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0)
            ELSE 0
        END)+SUM(CASE 
            WHEN Y.TypeErrorCode='Regular_Production_Checks'
                 THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0)
            ELSE 0
        END)+SUM(CASE 
            WHEN Y.TypeErrorCode='Fixed_Production_Inspection'
                 THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0)
            ELSE 0
        END)


		
		AS DefectQty
					
	  FROM tung22  DRI WITH(NOLOCK) 
--left outer join [dbo].[fn_VVT_StagePrices]() vwup on vwup.model = DRI.MaterialCode and vwup.routecode='V-28'
     left outer join STB_VVT_StagePrices vwup on vwup.model = DRI.MaterialCode and 'V-28' like '%'+vwup.RouteV28+'%'
     left join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=DRI.ControlNo
	 left join  STB_DefectInfo     di   with(nolock)  on  a.DefectCode = di.DefectCode
	  left join STB_TypeErrorGroupOfFactory Y with(nolock)  on  Y.TypeErrorCode = di.DirectlyUnder 
	  where 1=1 
	   and  EmpNo not in ('test_worker','assy_packing' )
		and PackQty>1
		and  SUBSTRING (LotNo, 1, 1) !='M'
		and (RowPackQty2=1 or RowPackQty2 < (case when @LotNo is not null and @LotNo<>'*' then 50 else 2 end) )
		group by DRI.id,newLotno,LotNo,PackingID,DRI.MaterialCode,MaterialName,EmpNo,PrintTime,PackQty ,isPrinted,
		 PartNo, DRI.InputLineCode,DRI.ProdDateTime,DRI.ControlNo,vwup.PriceV28
	
	  order by LotNo,EmpNo, PrintTime 
		
END