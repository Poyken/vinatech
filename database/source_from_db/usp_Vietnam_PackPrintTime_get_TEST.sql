
-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2020-08-19
-- Browsable : true
-- Modified: Mr.Tung         usp_Vietnam_PackPrintTime_get_TEST '','','','2024-08-01','2024-08-31','','VVON263R810706','','VVT_F2'
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_PackPrintTime_get_TEST]
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

	SET NOCOUNT ON;



		BEGIN



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
			 and  EmpNo not in ('test_worker','assy_packing','vvt_worker' )
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
	  join STB_ProdRouteHist c  WITH(NOLOCK) on b.ControlNo=c.ControlNo and c.RouteCode='V-28_BG'
	  where 1=1 
	   and  EmpNo not in ('test_worker','assy_packing')

		and (RowPackQty=1 /*or RankPackQty in (1,2) and MaterialName like '%35_2%'*/)
		AND (@LineCode = '*' OR InputLineCode   = @LineCode)
		AND (@LotNo = '*' OR LotNo       = @LotNo or newlotno=@LotNo)

	 )
	SELECT   id,
	 newLotno,LotNo,PackingID,MaterialCode,MaterialName,EmpNo,PrintTime,PackQty 
	 , (case when isPrinted is null or isPrinted=0 then 'Hien(show)' else 'An(hide)' end) as isPrinted
	 , PartNo
	 , InputLineCode,ProdDateTime,ControlNo,
	   ISNULL(DRI.PackQty, 0) *  convert(numeric(38,15),ISNULL(vwup.ProcessUnitPriceEA,0)) /** 1.05*/  as Price,
	   --case này mới đúng đang sửa cho hợp báo cáo bằng case dưới
	   	 --(case  when   (datepart(hour, PrintTime)>10)     or    (datepart(hour, PrintTime)=10 and datepart(minute, PrintTime)>30)     
				--then     convert(varchar(10),PrintTime,120)    
				--else    convert(varchar(10),dateadd(day, -1,  PrintTime),120)       
				--end )
			(case  when   (datepart(hour, PrintTime)>10)     or    (datepart(hour, PrintTime)=10 and datepart(minute, PrintTime)>30)     
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
				    as  jobdate
	  FROM tung22  DRI WITH(NOLOCK) 
left outer join [dbo].[fn_VVT_StagePrices]() vwup on vwup.model = DRI.MaterialCode and vwup.routecode='V-28_BG'

	  where 1=1 
	   and  EmpNo not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
		and PackQty>1
		and  SUBSTRING (LotNo, 1, 1) !='M'
		and (RowPackQty2=1 or RowPackQty2 < (case when @LotNo is not null and @LotNo<>'*' then 50 else 2 end) )
		--and LotNo ='VVON263R810706'
	  order by LotNo, PrintTime, EmpNo 


	end

END



-- exec usp_Vietnam_PackPrintTime_get  'nguyentung','Vietnamese','','2020-08-24','2020-08-24','','','VVKR032R733509',''
-- select * from STB_SavePackingTime_VVT where LotNo= 'VVOJ203R018653'
--SELECT * FROM STB_ProdRouteHist WHERE CREATEUSERID = 'VVTWORKER_BG' 
--SELECT * FROM STB_SetInfo


-- select * from STB_SavePackingTime_VVT WHERE LotNo = 'VVOM103R033519'


--update STB_SavePackingTime_VVT SET PrintTime = '2024-04-09 23:35:04.290' WHERE   LotNo IN
--(
--'VVOM082R718615',
--'VVOM082R718616',
--'VVOM082R718617',
--'VVOM082R718618',
--'VVOM082R718619',
--'VVOM082R718620',
--'VVOM082R718621',
--'VVOM082R718622',
--'VVOM092R718614',
--'VVOM092R718615',
--'VVOM092R718616',
--'VVOM092R718617',
--'VVOM092R718618',
--'VVOM092R718619',
--'VVOM092R718620',
--'VVOM092R718621',
--'VVOM082R718615',
--'VVOM082R718616',
--'VVOM082R718617',
--'VVOM082R718618',
--'VVOM082R718619',
--'VVOM082R718620',
--'VVOM082R718621',
--'VVOM082R718622',
--'VVOM082R718615',
--'VVOM082R718616',
--'VVOM082R718617',
--'VVOM082R718618',
--'VVOM082R718619',
--'VVOM082R718620',
--'VVOM082R718621',
--'VVOM082R718622',
--'VVOM082R718615',
--'VVOM082R718616',
--'VVOM082R718617',
--'VVOM082R718618',
--'VVOM082R718619',
--'VVOM082R718620',
--'VVOM082R718621',
--'VVOM082R718622',
--'VVOM082R718615',
--'VVOM082R718616',
--'VVOM082R718617',
--'VVOM082R718618',
--'VVOM082R718619',
--'VVOM082R718620',
--'VVOM082R718621',
--'VVOM082R718622',
--'VVOM083R018611',
--'VVOM083R018612',
--'VVOM083R018613',
--'VVOM083R018614',
--'VVOM083R018615',
--'VVOM083R018616',
--'VVOM083R018617',
--'VVOM083R018618',
--'VVOM083R018619',
--'VVOM083R018620',
--'VVOM093R018617',
--'VVOM093R018618',
--'VVOM093R018620',
--'VVOM093R018621',
--'VVOM083R018611',
--'VVOM083R018612',
--'VVOM083R018613',
--'VVOM083R018614',
--'VVOM083R018615',
--'VVOM083R018616',
--'VVOM083R018617',
--'VVOM083R018618',
--'VVOM083R018619',
--'VVOM083R018620',
--'VVOM083R018611',
--'VVOM083R018612',
--'VVOM083R018613',
--'VVOM083R018614',
--'VVOM083R018615',
--'VVOM083R018616',
--'VVOM083R018617',
--'VVOM083R018618',
--'VVOM083R018619',
--'VVOM083R018620',
--'VVOM083R018611',
--'VVOM083R018612',
--'VVOM083R018613',
--'VVOM083R018614',
--'VVOM083R018615',
--'VVOM083R018616',
--'VVOM083R018617',
--'VVOM083R018618',
--'VVOM083R018619',
--'VVOM083R018620',
--'VVOM083R018611',
--'VVOM083R018612',
--'VVOM083R018613',
--'VVOM083R018614',
--'VVOM083R018615',
--'VVOM083R018616',
--'VVOM083R018617',
--'VVOM083R018618',
--'VVOM083R018619',
--'VVOM083R018620',
--'VVOM092R740614',
--'VVOM092R740615',
--'VVOM092R740616',
--'VVOM092R740617',
--'VVOM092R740618',
--'VVOM092R740619',
--'VVOM092R740620',
--'VVOM092R750626',
--'VVOM092R750636',
--'VVOM092R750637',
--'VVOM092R750638',
--'VVOM092R750639',
--'VVOM092R750640',
--'VVOM093R025627',
--'VVOM093R025628',
--'VVOM093R025630',
--'VVOM093R025631',
--'VVOM093R025633',
--'VVOM093R025634',
--'VVOM093R025635',
--'VVOM093R025636',
--'VVOM082R718614',
--'VVOM082R718615',
--'VVOM082R718617',
--'VVOM082R718620',
--'VVOM082R718621',
--'VVOM083R018612',
--'VVOM083R018614',
--'VVOM083R018615',
--'VVOM083R018618',
--'VVOM093R018601',
--'VVOM032R740641',
--'VVOM042R740612',
--'VVOM042R740630',
--'VVOM042R740631',
--'VVOM052R740615',
--'VVOM052R740620',
--'VVOM072R750626',
--'VVOM072R750628',
--'VVOM082R750602',
--'VVOM082R750604',
--'VVOM082R750605',
--'VVOM082R750606',
--'VVOM082R750607',
--'VVOM082R750609',
--'VVOM082R750611',
--'VVOM082R750613',
--'VVOM083R025601',
--'VVOM083R025604',
--'VVOM083R025608',
--'VVOM083R025609',
--'VVOM083R025614',
--'VVOM083R025616'
--)