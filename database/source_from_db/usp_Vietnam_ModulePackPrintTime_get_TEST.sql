--        exec usp_Vietnam_ModulePackPrintTime_get '','','VVT','2024-08-01','2024-08-30','','','MVVOQ126R015501',''
-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2020-08-19
-- Browsable : true
-- Modified: Mr.Tung
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_ModulePackPrintTime_get_TEST]
		@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(30) = NULL
AS
	--DECLARE @FromDate DATETIME = @pFromDate
	--DECLARE @ToDate DATETIME = @pToDate
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    

	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN

	SET NOCOUNT ON;

	-- exec usp_Vietnam_PackPrintTime_get  'nguyentung','Vietnamese','','2020-08-24','2020-08-24','','','VVKR032R733509',''
	


	
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

;with  tung as 
		(
	   		SELECT  id,
			(select top 1 newbarcode from STB_LotChangeMaterialHistory WITH(NOLOCK) where oldBarcode=LotNo) as newLotno
			,LotNo,PackingID,MaterialCode,MaterialName,EmpNo,PrintTime,PackQty, isPrinted,PartNo,
			(RANK() over (partition by LotNo,isPrinted order by  PackQty desc,printtime desc) ) as RankPackQty,
			(ROW_NUMBER() over (partition by LotNo,isPrinted order by PackQty desc,printtime desc) ) as RowPackQty--,
			 
			FROM  [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] DRI  WITH(NOLOCK) 
	
			where 1=1 
			and PrintTime between (case when @LotNo is not null and @LotNo<>'*' then '2020-08-15 10:00:00' else @FromDate end) 
			and (case when @LotNo is not null and @LotNo<>'*' then CONVERT(varchar(19),getdate(),120) else @ToDate end) 
			and PackQty>1 
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
	   join STB_ProdRouteHist c  WITH(NOLOCK) on b.ControlNo=c.ControlNo and c.RouteCode='MV-05'
	  where 1=1 
	  and PackQty>1
	 
		and (RowPackQty=1 /*or RankPackQty in (1,2) and MaterialName like '%35_2%'*/)
		AND (@LineCode = '*' OR InputLineCode   = @LineCode)
		AND (@LotNo = '*' OR LotNo       = @LotNo or newlotno=@LotNo)
	   
	 )
	SELECT DISTINCT  id,
	 newLotno,LotNo,PackingID,MaterialCode,MaterialName,EmpNo,PrintTime,PackQty 
	 , (case when isPrinted is null or isPrinted=0 then 'Hien(show)' else 'An(hide)' end) as isPrinted
	 , PartNo
	 , InputLineCode,ProdDateTime,ControlNo,
	   ISNULL(DRI.PackQty, 0) *  convert(numeric(38,15),ISNULL(vwup.ProcessUnitPriceEA,isnull(vwup1.ProcessUnitPriceEA,0))) /** 1.05*/  as Price,
	   	 (case  when   (datepart(hour, PrintTime)>10)     or    (datepart(hour, PrintTime)=10 and datepart(minute, PrintTime)>30)     
				then     convert(varchar(10),PrintTime,120)    
				else    convert(varchar(10),dateadd(day, -1,  PrintTime),120)       
				end )    as  jobdate
	  FROM tung22  DRI WITH(NOLOCK) 


		left outer join [dbo].[fn_VVT_StagePricesMODULE]() vwup on vwup.model = DRI.MaterialCode  and vwup.routecode='MV-04' --bỏ điều kiện V-28 để biết rằng éo cần đóng gói cũng tính tiền luôn
		outer apply(select top 1 * from [dbo].[fn_VVT_StagePricesMODULE]() vwup1 where  DRI.MaterialName  like '%'+vwup1.model +'%' and vwup1.routecode='V-28' )vwup1
	 
	 where 1=1 
		and PackQty>1
		and  SUBSTRING (LotNo, 1, 1) ='M'
		and (RowPackQty2=1 or RowPackQty2 < (case when @LotNo is not null and @LotNo<>'*' then 50 else 2 end) )

	
	  order by LotNo, PrintTime, EmpNo 

END


--           exec usp_Vietnam_ModulePackPrintTime_get '','','VVT','2023-06-12','2023-06-15','','','',''