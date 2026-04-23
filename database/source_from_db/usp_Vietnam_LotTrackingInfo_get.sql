
-- ===========================================================================================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2021-04-01
-- Browsable : true
-- Group : 생산관리 > 생산현황 > [B780] Lot생산이력정보
-- Description: 품질 이미정차장 요청화면 + 생산팀 이력정보
--                 2021.03.12 마킹문자 
-- Modified: 
-- 생산부문 요청사항 적용 2020.04.06 By Jackaroe #0406

-- 프로시저실행 (2021-03-30)  :   usp_Vietnam_LotTrackingInfo_get  'VVT', '', '', '', ''

-- usp_Vietnam_LotTrackingInfo_get  1170, 'VVT', '', '', '', ''
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[usp_Vietnam_LotTrackingInfo_get]
						@pUtcOffset INT,                                                -- UTC
						@pCompanyCode VARCHAR(20) = NULL,  
						--@pFromDate DATETIME = NULL,
						--@pToDate DATETIME = NULL,
						@pRouteCode VARCHAR(20) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pLotNo VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(30) = NULL					
AS

	--DECLARE @CompanyCode   VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END

	--DECLARE @FromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	--DECLARE @ToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:30:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    

	DECLARE @FromDate         VARCHAR(19) = CONVERT(VARCHAR(10), Getdate() -1, 121) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, Getdate() )), 121) + ' 08:30:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    

	DECLARE	@RouteCode       VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE	@LineCode         VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo             VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE	@MaterialCode    VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

	--DECLARE	@MarkingLetter    VARCHAR(8) = CASE WHEN ISNULL(@pMarkingLetter, '') = '' THEN '*' ELSE @pMarkingLetter END   --2021.03.12 추가

	

BEGIN


BEGIN
		
					select @FromDate    = CONVERT(VARCHAR(10), GetDate()-1, 120) + ' 10:29:59'                                                          
					select @ToDate      = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, GetDate())), 120) + ' 10:30:01'         

					; with tung as (
											 select  c.Barcode--,b.RouteCode,RouteCode as FindRouteCode,min(b.ProdQty) as ProdQty,0 as DefectQty,max(ProdDateTime) as ProdDateTime 
											 from 
											 STB_SetInfo c WITH(NOLOCK) 
											 left outer join  STB_ProdRouteHist b	 WITH(NOLOCK) on c.ControlNo=b.ControlNo	 
											 where b.CompanyCode='VVT'  and b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
		 and  b.CreateUserID not in ('test_worker','assy_packing' )
										 ),	
					 tungfinished as (
	  					 select  c.Barcode,count(b.RouteCode) as totalcount
						 from 
						 STB_SetInfo c WITH(NOLOCK) 
						 left outer join  STB_ProdRouteHist b	 WITH(NOLOCK) on c.ControlNo=b.ControlNo	 
						 where  c.Barcode in (select Barcode from tung WITH(NOLOCK) )
						  and  b.CreateUserID not in ('test_worker','assy_packing' )
						 group by c.Barcode
					 ),
					 tungfinished2 as (		
						 select  c.Barcode,b.RouteCode	, (row_number() over (partition by c.Barcode order by b.Routecode ASC)-tungfinished.totalcount )	  as ProdQtyFinishYn 	 
						 from 
						 STB_SetInfo c WITH(NOLOCK) 
						 left outer join tungfinished  WITH(NOLOCK) on tungfinished.Barcode=c.Barcode
						 left outer join  STB_ProdRouteHist b	 WITH(NOLOCK) on c.ControlNo=b.ControlNo	 
						 where  c.Barcode in (select Barcode from tung WITH(NOLOCK) )
	 and  b.CreateUserID not in ('test_worker','assy_packing' )
					 ),
					  tung0 as (
	 					select  c.Barcode,b.RouteCode,RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
						min(b.ProdQty) as ProdQty,0 as DefectQty,max(ProdDateTime) as ProdDateTime 
						from  STB_SetInfo c WITH(NOLOCK) 
						 left outer join  STB_ProdRouteHist b WITH(NOLOCK) 	on c.ControlNo=b.ControlNo	 
						 where c.Barcode in (select Barcode from tung WITH(NOLOCK) )
						  and  b.CreateUserID not in ('test_worker','assy_packing' )
						 group by c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01
						 union

						 select  c.Barcode, FindRouteCode as RouteCode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,'' as MachineCode,'' as WorkerCode,SIExtText07,SIExtInt01,
						 0 as ProdQty,sum(a.DefectQty) as DefectQty,max(FindDateTime) as ProdDateTime 
						 from  STB_SetInfo c WITH(NOLOCK) 
						 full outer join  STB_DefectRepairInfo a  WITH(NOLOCK) on  a.ControlNo=c.ControlNo
						 where   c.Barcode in (select Barcode from tung WITH(NOLOCK) )
						 group by c.Barcode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,/*c.MachineCode,c.WorkerCode,*/SIExtText07,SIExtInt01
					 ),
					 tung11 as (
					 select Barcode,RouteCode,FindRouteCode,max(ControlNo) as ControlNo,max(MaterialCode) as MaterialCode,max(InputLineCode) as InputLineCode,max(MachineCode) as MachineCode,
					 max(WorkerCode) as WorkerCode,max(SIExtText07) as SIExtText07,max(SIExtInt01) as SIExtInt01,sum(ProdQty)as ProdQty,sum(DefectQty) as DefectQty,
					 /*sum(ProdQty)-sum(DefectQty) as soluongOut,*/max(ProdDateTime) as ProdDateTime
					 from tung0 WITH(NOLOCK) 
						group by Barcode,RouteCode,FindRouteCode--,ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01
					 --	order by RouteCode
					),
					tung1 as (
					select 
					tung11.*, isnull(ProdQtyFinishYn,0) as ProdQtyFinishYn
					 from tung11 WITH(NOLOCK) 
					 left outer join tungfinished2  WITH(NOLOCK) 
					 on tung11.Barcode = tungfinished2.Barcode and tung11.RouteCode = tungfinished2.RouteCode	 
					 ),
					tung22 as (
					select *
					from tung1 WITH(NOLOCK)  where RouteCode='V-22'
					),
					tung23 as (
					select *
					from tung1 WITH(NOLOCK)  where RouteCode='V-23'
					)
					,
					tung24 as (
					select *
					from tung1 WITH(NOLOCK)  where RouteCode='V-24'
					)
					,
					tung25 as (
					select *
					from tung1 WITH(NOLOCK)  where RouteCode='V-25'
					)
					,
					tung27 as (
					select *
					from tung1 WITH(NOLOCK)  where RouteCode='V-27'
					)
					,
					tung28 as (
					select *
					from tung1 WITH(NOLOCK)  where RouteCode='V-28'
					)
					,
					tung40 as (
					select *
					from tung1 WITH(NOLOCK)  where RouteCode='V-40'
					),
					tlast as (
					select *from tung22 WITH(NOLOCK)  --where  ProdDateTime>'2020-07-01'
					union
					select tung23.* from tung23 WITH(NOLOCK) --,tung22  where tung23.Barcode = tung22.Barcode --and ( tung23.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) )
					union  																	
					select tung40.* from tung40 WITH(NOLOCK) --,tung22  where tung40.Barcode = tung22.Barcode --and ( tung40.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) )
					union									 								
					select tung24.* from tung24 WITH(NOLOCK) ,tung22 WITH(NOLOCK)   where tung24.Barcode = tung22.Barcode and ( tung24.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) or tung24.ProdQtyFinishYn<0)
					union  									  									
					select tung25.* from tung25 WITH(NOLOCK) ,tung24 WITH(NOLOCK)   where tung25.Barcode = tung24.Barcode and ( tung25.ProdDateTime >= DATEADD(ss,5,tung24.ProdDateTime) or tung25.ProdQtyFinishYn<0)
					union  									 									
					select tung27.* from tung27 WITH(NOLOCK) ,tung25 WITH(NOLOCK)   where tung27.Barcode = tung25.Barcode and ( tung27.ProdDateTime >= DATEADD(ss,5,tung25.ProdDateTime) or tung27.ProdQtyFinishYn<0)
					union  									 									
					select tung28.* from tung28 WITH(NOLOCK) ,tung27 WITH(NOLOCK)   where tung28.Barcode = tung27.Barcode and ( tung28.ProdDateTime >= DATEADD(ss,5,tung27.ProdDateTime) or tung28.ProdQtyFinishYn<0)
					),
					last2 as (
					select Barcode,(RouteCode),(FindRouteCode),ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01, ProdQty, DefectQty,/*soluongOut,*/ 
					CONVERT(varchar(19),ProdDateTime,120) as ProdDateTime
					from tlast WITH(NOLOCK) 
					),
					DRI as (
								select * from last2 WITH(NOLOCK) 
								where  ProdDateTime>@FromDate  and ProdDateTime<@ToDate
								)

			   -- 주요 SELECT문
					select
						   'VVT'   AS 사업장
						  ,DRI.ControlNo
						  ,DRI.Barcode
						  ,DRI.MaterialCode
						  ,MM2.MaterialName
						  ,DRI.InputLineCode
						  ,LI.LineName
						  ,DRI.RouteCode as RouteCode
						  ,RI.RouteName
						  ,dbo.fnGetLocalTime (convert(datetime,DRI.ProdDateTime,120), @pUtcOffset) as ProdDateTime         -- [시차 중요부분]    SELECT dbo.fnGetLocalTime (convert(datetime, GetDate(),120), 510) 
						--   ,dbo.fnGetLocalTime (convert(datetime,DRI.ProdDateTime,120), 1170) as ProdDateTime         -- [시차 중요부분]    SELECT dbo.fnGetLocalTime (convert(datetime, GetDate(),120), 510) 
						  ,DRI.MachineCode
						  ,MM.MachineName
						  ,DRI.WorkerCode
						  ,PWI.WorkerName
						  ,CASE WHEN DRI.SIExtInt01 IS NULL THEN ''
								  WHEN DRI.SIExtInt01 = 1      THEN '검사불합격'
								  WHEN DRI.SIExtInt01 = 0       THEN '검사불합격이력'    END                    AS RouteInspectionResult
						  --,CONVERT(BIT,CASE WHEN ISNULL(DRI.AftProdQty,0) > 0 THEN 1	ELSE 0 	END)   AS IsHasNextProd*/
						  , DRI.ProdQty                                   AS InputProdQty       -- 투입수량
						  , ISNULL(DRI.DefectQty, 0)                    AS DefectQty          -- 불량수량 		  
						  , (DRI.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty           -- 생산수량		  
						  , SIExtText07 AS MarkingLetter   

					from DRI  WITH(NOLOCK) 
							LEFT OUTER JOIN STB_RouteInfo          RI	  WITH(NOLOCK)    ON DRI.FindRouteCode = RI.RouteCode
							  LEFT OUTER JOIN STB_MaterialMaster   MM2	  WITH(NOLOCK)    ON DRI.MaterialCode = MM2.MaterialCode
							  LEFT OUTER JOIN STB_LineInfo         LI	  WITH(NOLOCK)    ON DRI.InputLineCode = LI.LineCode			 
							  LEFT OUTER JOIN STB_MachineMaster    MM	  WITH(NOLOCK)    ON DRI.MachineCode = MM.MachineCode
							  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	   WITH(NOLOCK)   ON DRI.WorkerCode = PWI.WorkerCode

					 where 1=1
	 					   AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
						   AND (@LineCode = '*' OR DRI.InputLineCode   = @LineCode)
						  AND (@LotNo = '*' OR DRI.Barcode       = @LotNo)
					   --AND (@MaterialCode = '*' OR DRI.MaterialCode = @MaterialCode)
					  -- Order by ProdDateTime DESC


					   END



END