-- =============================================
-- Author:		<Mr.Duy>
-- Create date: <2024-01-29>
-- Description:	<Gộp chung nhà máy bắc ninh và bắc giang để hiển thị lên BI>
--  exec usp_Vietnam_PackPrintTime_get_BI '','','VVT','2026-02-01','2026-02-28','','','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_PackPrintTime_get_BI]
    @pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(30) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    

	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF @pWorkCenterCode = ''

		BEGIN
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
	  join STB_ProdRouteHist c  WITH(NOLOCK) on b.ControlNo=c.ControlNo and c.RouteCode in ('V-28','V-28_BG')
	  where 1=1 
	   and  EmpNo not in ('test_worker','assy_packing' )

		and (RowPackQty=1 /*or RankPackQty in (1,2) and MaterialName like '%35_2%'*/)
		AND (@LineCode = '*' OR InputLineCode   = @LineCode)
		AND (@LotNo = '*' OR LotNo       = @LotNo or newlotno=@LotNo)

	 )
	SELECT  
	DISTINCT
	 DRI.id,
	 newLotno,DRI.LotNo,PackingID,DRI.MaterialCode,
	 --,MaterialName
	 case
	   when DRI.MaterialCode='ECVT30-370' then 'HY-CAP VEC3R0387QG (3562-JIANGHAI)'
		else MaterialName
		end as MaterialName
	 ,
	 
	 EmpNo,PrintTime,PackQty 
	 , (case when isPrinted is null or isPrinted=0 then 'Hien(show)' else 'An(hide)' end) as isPrinted
	 , DRI.PartNo
	 , InputLineCode,ProdDateTime,ControlNo,
	   ISNULL(DRI.PackQty, 0) *  convert(numeric(38,15),ISNULL(vwup.PriceV28,0)) /** 1.05*/  as Price,
	   --case này mới đúng đang sửa cho hợp báo cáo bằng case dưới
	   	 --(case  when   (datepart(hour, PrintTime)>10)     or    (datepart(hour, PrintTime)=10 and datepart(minute, PrintTime)>30)     
				--then     convert(varchar(10),PrintTime,120)    
				--else    convert(varchar(10),dateadd(day, -1,  PrintTime),120)       
				--end )
			(CASE  
            WHEN DRI.LotNo IN (SELECT * FROM stb_Changedate_B781_220924) THEN '2024-09-05'  
            WHEN DATEPART(HOUR, PrintTime) >= 10 THEN CONVERT(VARCHAR(10), PrintTime, 120)
            ELSE CASE WHEN DRI.LotNo IN ('VVNU212R750638') THEN CONVERT(VARCHAR(10), PrintTime, 120)
                 ELSE CONVERT(VARCHAR(10), DATEADD(DAY, -1, PrintTime), 120) END
        END) AS jobdate,
					 SPQBL.SClass, SPQBL.AClass, SPQBL.BClass, SPQBL.CClass, SPQBL.DClass
	  FROM tung22  DRI WITH(NOLOCK) 
--left outer join [dbo].[fn_VVT_StagePrices]() vwup on vwup.model = DRI.MaterialCode and vwup.routecode in ('V-28','V-28_BG')
left outer join STB_VVT_StagePrices vwup on vwup.model = DRI.MaterialCode and ('V-28_BG' like '%'+vwup.RouteV28+'%' or 'V-28' like '%'+vwup.RouteV28+'%')
  LEFT OUTER JOIN STB_SavePackingQtyByLevel_VVT SPQBL ON SPQBL.IDSPT = DRI.id
	LEFT  OUTER JOIN STB_ItemCode T12 ON DRI.MaterialCode = T12.MaterialCode
	  where 1=1 --and MaterialCode ='ECVT30-325' 
	   and  EmpNo not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
		and PackQty>1
		and  SUBSTRING (DRI.LotNo, 1, 1) !='M'
		and (RowPackQty2=1 or RowPackQty2 < (case when @LotNo is not null and @LotNo<>'*' then 50 else 2 end) )
		 --and LotNo='VVQK063R830603'
	  order by LotNo, PrintTime, EmpNo
	  
		END
END



