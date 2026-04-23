
-- ED-VJPMTR000000014
-- ===========================================================================================================
-- Author: Jackaroe
-- Create date: 2020-04-06
-- Browsable : true
-- Group : 생산관리 > 생산현황 > [B780] Lot생산이력정보
-- Description: 품질 이미정차장 요청화면 + 생산팀 이력정보
-- Modified: 
-- 생산부문 요청사항 적용 2020.04.06 By Jackaroe #0406
--                 2021.03.12 마킹문자 
-- 시간 기준의 주야 구분 추가 2022.02.22 이부사장님, 채민수 매니저 요청 By Jackaroe #220222
-- 2022-02-24 항목추가 채민수요청

-- 프로시저실행 (2021-12-21)  :  usp_LotTrackingInfo_get  'kilee','Korean', '', 'VNT', 'VNT_F1', '2020-12-20', '2021-12-20', 'E-33', '', 'VJLT203R815708', '', ''
-- 프로시저실행 (2022-01-24)  :  usp_LotTrackingInfo_get 'kilee','Korean', '', 'VNT', 'VNT_F2', '2021-12-01', '2022-01-20', '', '', '', '', ''
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[usp_LotTrackingInfo_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pUtcOffset INT,
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,     -- 2022.01.24 추가
						@pFromDate DATETIME = NULL,
						@pToDate DATETIME = NULL,
						@pRouteCode VARCHAR(20) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pLotNo VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(30) = NULL,
						@pMarkingLetter VARCHAR(8) = Null
AS

	DECLARE @CompanyCode   VARCHAR(20)  = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END             -- 2022.01.24 추가
	DECLARE @FromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	DECLARE @ToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:29:59' 
	DECLARE @RouteCode       VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE @LineCode         VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE @LotNo             VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE @MaterialCode    VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
	DECLARE @MarkingLetter    VARCHAR(8) = CASE WHEN ISNULL(@pMarkingLetter, '') = '' THEN '*' ELSE @pMarkingLetter END


BEGIN


IF @CompanyCode='VNT' or @CompanyCode='*' or @WorkCenterCode = 'VVT_F4' BEGIN
	SELECT FIN.사업장
	      ,FIN.WorkCenterCode
		  ,FIN.WorkCenterName
	      ,FIN.DayPlanNo AS ControlNo
		  ,FIN.Barcode
		  ,FIN.MaterialCode
		  ,FIN.MaterialName
		  ,FIN.InputLineCode
		  ,FIN.LineName
		  ,FIN.RouteCode
		  ,FIN.RouteName		  
		  ,CASE WHEN CONVERT(VARCHAR(8),  FIN.ProdDateTime, 108) BETWEEN '00:00:00' AND '08:29:59' 
				THEN CONVERT(VARCHAR(10),  DATEADD(day, -1, FIN.ProdDateTime), 121) 
				ELSE CONVERT(VARCHAR(10),  FIN.ProdDateTime, 121) 
				END As WorkDateByProdTime   --작업일 추가 --당일 오전 실적을 전일 야간 실적으로 계산함. 컬럼명 변경 (FromTo -> WorkDateByProdTime)
		  ,FIN.ProdDateTime
		  ,FIN.PrevProdDateTime
		  ,FIN.MachineCode
		  ,FIN.MachineName
		  ,FIN.WorkerCode
		  ,FIN.WorkerName
		  ,FIN.RouteInspectionResult
		  ,FIN.InputProdQty
		  ,FIN.DefectQty 
		  ,FIN.ProdQty
		  ,FIN.MarkingLetter
		  ,FIN.IsSelfInspection
		  ,FIN.IsXRayImage
		  ,FIN.JobDate
		  ,CASE WHEN CONVERT(CHAR(8), FIN.ProdDateTime, 108) BETWEEN '08:30:00' AND '20:29:59' THEN '주간' ELSE '야간' END AS TimeShiftNameByTime --#220222
	  FROM (
			SELECT   TOP 100000
			          CASE WHEN PRH.ComPanyCode = 'VNT' THEN '비나텍 본사'
						   WHEN PRH.ComPanyCode = 'VVT' THEN '베트남' ELSE '기타' END   AS 사업장
					 , PRH.WorkCenterCode
					 , WI.WorkCenterName
					 , SI.ControlNo
					 , SI.Barcode
					 , SI.MaterialCode
					 , MM2.MaterialName
					 , SI.InputLineCode
					 , LI.LineName
					 , PRH.RouteCode
					 , RI.RouteName
					 , dbo.fnGetLocalTime(PRH.ProdDateTime, @pUtcOffset) AS ProdDateTime
					 , CASE WHEN PRH.RouteCode IN ('E-22', 'V-22') THEN NULL 
					   ELSE LAG(dbo.fnGetLocalTime(PRH.ProdDateTime, 540)) 
							  OVER(ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28' 
														THEN 'E-99' ELSE PRH.RouteCode END) END AS PrevProdDateTime
					 , PRH.MachineCode
					 , MM.MachineName
					 , PRH.WorkerCode
					 , PWI.WorkerName
					 , CASE WHEN SI.SIExtInt01 IS NULL THEN ''
							  WHEN SI.SIExtInt01 = 1      THEN '검사불합격'
							  WHEN SI.SIExtInt01 = 0      THEN '검사불합격이력'    END AS RouteInspectionResult
					 , PRH.ProdQty AS InputProdQty
					 , ISNULL(DRI.DefectQty, 0) AS DefectQty 
					 , (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty
					 , SIExtText07 AS MarkingLetter
					 --, CASE WHEN MC.MeasureCount > 0      AND PRH.RouteCode IN ('E-25', 'V-25') THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END   AS IsSelfInspection
					 --, CASE WHEN AFM.Barcode is Not Null THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END   AS IsXRayImage
					 , CONVERT(BIT, 0) AS IsSelfInspection
					 , CONVERT(BIT, 0) AS IsXRayImage
					 , PRH.JobDate
					 , DPP.DayPlanNo
			  FROM STB_SetInfo SI WITH(NOLOCK) 
					  LEFT OUTER JOIN STB_ProdRouteHist    PRH	  WITH(NOLOCK)    ON SI.ControlNo = PRH.ControlNo
					  LEFT OUTER JOIN STB_RouteInfo           RI WITH(NOLOCK) 	    ON PRH.RouteCode = RI.RouteCode
					  LEFT OUTER JOIN STB_MachineMaster  MM	    WITH(NOLOCK)  ON PRH.MachineCode = MM.MachineCode
					  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	 WITH(NOLOCK)     ON PRH.WorkerCode = PWI.WorkerCode
					  LEFT OUTER JOIN STB_MaterialMaster  MM2	  WITH(NOLOCK)    ON SI.MaterialCode = MM2.MaterialCode
					  LEFT OUTER JOIN STB_LineInfo              LI WITH(NOLOCK) 	    ON SI.InputLineCode = LI.LineCode
					  LEFT OUTER JOIN ( SELECT ControlNo, FindRouteCode, SUM(DefectQty) AS DefectQty 
												  FROM STB_DefectRepairInfo  WITH(NOLOCK) 
												 WHERE RepairType = 'NONE'
												 GROUP BY ControlNo, FindRouteCode
											  ) DRI	                                              ON PRH.ControlNo = DRI.ControlNo        AND PRH.RouteCode = DRI.FindRouteCode
					  LEFT OUTER JOIN STB_WorkCenterInfo WI ON WI.WorkCenterCode = PRH.WorkCenterCode
					  LEFT OUTER JOIN STB_DayProdPlan DPP ON DPP.DayPlanNo = SI.DayPlanNo

					  --LEFT OUTER JOIN (
							--					SELECT ProdNo, COUNT(*) AS MeasureCount
							--					  FROM STB_CommInspDocHistory CIDH WITH(NOLOCK) 
							--					  LEFT OUTER JOIN STB_CommInspDocItem CIDI					ON CIDH.CommInspDocNo = CIDI.CommInspDocNo
							--					  INNER JOIN STB_CommInspMeasureHist CIMH					ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo
							--					 GROUP BY ProdNo
							--			  ) MC                                                   ON SI.ControlNo = MC.ProdNo     -- #0406
			
					--LEFT OUTER JOIN (
					--							SELECT Barcode
					--							  FROM SmartFramework_File.dbo.STB_AttachedFileMaster WITH(NOLOCK) 
					--							 WHERE 1=1
					--								and (SystemName= 'XRay' Or SystemName= 'STB_XRayImageUploadHist')
					--							 GROUP BY Barcode
					--						 ) AFM ON (SI.Barcode = AFM.Barcode OR AFM.Barcode = (SELECT NewBarcode 
					--																				FROM STB_LotChangeMaterialHistory  WITH(NOLOCK) 
					--																				WHERE OldBarcode = @LotNo))              -- #0406
			 WHERE 1=1
			   AND ((@CompanyCode = '*')    OR (PRH.CompanyCode = @CompanyCode))                                      -- 추가 용은재 (2020.01.23)
			   AND ((@WorkCenterCode = '*') OR (PRH.WorkCenterCode = @WorkCenterCode))                                -- 추가 (2022.01.24)			   

			   AND PRH.ProdDateTime BETWEEN @FromDate AND @ToDate
			   AND (@LineCode = '*' OR PRH.LineCode   = @LineCode)
			   AND (@LotNo = '*' OR SI.Barcode       = @LotNo)
			   AND (@MaterialCode = '*' OR SI.MaterialCode = @MaterialCode)
			   AND  ((@MarkingLetter = '*') OR (SIExtText07 LIKE '%' + @MarkingLetter + '%')) 
			  ORDER BY SI.Barcode
			       ,CASE WHEN PRH.RouteCode = 'E-28' THEN 'E-99' ELSE PRH.RouteCode END
	) FIN
	WHERE 1=1
	  --AND (ABS(DATEDIFF(day, FIN.PrevProdDateTime, FIN.ProdDateTime)) < 20 OR FIN.PrevProdDateTime IS NULL)
	  AND (ABS(DATEDIFF(second, FIN.PrevProdDateTime, FIN.ProdDateTime)) > 10 OR FIN.PrevProdDateTime IS NULL)
	--FIN.ProdDateTime <> FIN.PrevProdDateTime
	  AND (@RouteCode = '*' OR FIN.RouteCode = @RouteCode)
	ORDER BY FIN.JobDate
	        ,FIN.Barcode
			,CASE WHEN FIN.RouteCode = 'E-28' THEN 'E-99' ELSE FIN.RouteCode END
	 
End   



---- // 베트남법인

if @CompanyCode='VVT' and @WorkCenterCode <> 'VVT_F4'

Begin
		
	select @FromDate    = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:29:59'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	select @ToDate      = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:30:01'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    
	
	; with tung as (
		 select  c.Barcode--,b.RouteCode,RouteCode as FindRouteCode,min(b.ProdQty) as ProdQty,0 as DefectQty,max(ProdDateTime) as ProdDateTime 
		 from 
		 STB_SetInfo c WITH(NOLOCK) 
		 left outer join  STB_ProdRouteHist b	 WITH(NOLOCK) on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode='VVT'  and b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
	
	 ),
	 tungfinished as (
	  	 select  c.Barcode,count(b.RouteCode) as totalcount
		 from 
		 STB_SetInfo c WITH(NOLOCK) 
		 left outer join  STB_ProdRouteHist b	 WITH(NOLOCK) on c.ControlNo=b.ControlNo	 
		 where  c.Barcode in (select Barcode from tung WITH(NOLOCK) )
		 group by c.Barcode
	 ),
	 tungfinished2 as (		
		 select  c.Barcode,b.RouteCode	, (row_number() over (partition by c.Barcode order by b.Routecode ASC)-tungfinished.totalcount )	  as ProdQtyFinishYn 	 
		 from 
		 STB_SetInfo c WITH(NOLOCK) 
		 left outer join tungfinished  WITH(NOLOCK) on tungfinished.Barcode=c.Barcode
		 left outer join  STB_ProdRouteHist b	 WITH(NOLOCK) on c.ControlNo=b.ControlNo	 
		 where  c.Barcode in (select Barcode from tung WITH(NOLOCK) )
		 --group by c.Barcode,b.RouteCode--,tungfinished.totalcount	 
	 ),
	  tung0 as (
	 	select  c.Barcode,b.RouteCode,RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
		min(b.ProdQty) as ProdQty,0 as DefectQty,max(ProdDateTime) as ProdDateTime 
		from  STB_SetInfo c WITH(NOLOCK) 
		 left outer join  STB_ProdRouteHist b WITH(NOLOCK) 	on c.ControlNo=b.ControlNo	 
		 where c.Barcode in (select Barcode from tung WITH(NOLOCK) )
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
		group by Barcode,RouteCode,FindRouteCode
	
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
				select *from tung22 WITH(NOLOCK) 
				union
				select tung23.* from tung23 WITH(NOLOCK) 
				union  																	
				select tung40.* from tung40 WITH(NOLOCK) 
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
					Select Barcode,(RouteCode),(FindRouteCode),ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01, ProdQty, DefectQty,/*soluongOut,*/ 
					CONVERT(varchar(19),ProdDateTime,120) as ProdDateTime
					from tlast WITH(NOLOCK) 
					),
	DRI as (
				select * from last2 WITH(NOLOCK) 
				where  ProdDateTime>@FromDate  and ProdDateTime<@ToDate
				)
	select
		   'VVT'   AS 사업장
		  ,'' AS WorkCenterCode  -- I don't understand the query how to get this column. but I add an empty value because the contents of the HQ query have changed.
		  ,'' AS WorkCenterName  -- I don't understand the query how to get this column. but I add an empty value because the contents of the HQ query have changed.
		  ,DRI.ControlNo
	      ,DRI.Barcode
		  ,DRI.MaterialCode
		  ,MM2.MaterialName
		  ,DRI.InputLineCode
		  ,LI.LineName
		  ,DRI.RouteCode as RouteCode
		  ,RI.RouteName

		  ,dbo.fnGetLocalTime (convert(datetime,DRI.ProdDateTime,120), @pUtcOffset) as ProdDateTime
		  ,DRI.MachineCode
		  ,MM.MachineName
		  ,DRI.WorkerCode
		  ,PWI.WorkerName
		  ,CASE WHEN DRI.SIExtInt01 IS NULL THEN ''
		          WHEN DRI.SIExtInt01 = 1      THEN '검사불합격'
				  WHEN DRI.SIExtInt01 = 0       THEN '검사불합격이력'    END                    AS RouteInspectionResult

		  , DRI.ProdQty                                   AS InputProdQty    -- 투입수량
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
end



END