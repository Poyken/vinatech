CREATE PROCEDURE [dbo].[usp_ReportSparePartInfo]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(50) = NULL,
						@pCompanyName VARCHAR(50) = NULL,
						@pSparePartCode VARCHAR(50) = null,
						@pWorkCenterCode VARCHAR(50) = NULL,
						@pWorkCenterName VARCHAR(50) = NULL,
						@pSPWarehouseCode VARCHAR(50) = NULL,
						@pSPWarehouseName VARCHAR(50) = NULL,
						@pSPLocationCode VARCHAR(50) = NULL,
						@pSPLocationName VARCHAR(50) = NULL,
						@pFromDate Date,
						@pToDate Date

AS

BEGIN
		-- concat(spwarehousecode,'-',splocationcode) as location,
				select A.SparePartCode, 
				sparepartname, 
				sparepartspec01 as englishname, 
				sparepartspec02 as code,
				sparepartspec03 as marker,
				sparepartspec04 as process,
				basicunit,
				position,
					B.PositionBG,
					A.WorkCenterCode,
				--COALESCE(sum
				--	(case when A.basicdate < @pFromDate and SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null then ProcessQty
				--	 when   A.basicdate < @pFromDate and SparePartIOTypeCode='GI_REPARE' then  -ProcessQty  
				--	 end),0) +
				--COALESCE(sum
				--	(case when  SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is not null then ProcessQty else 0 end),0)	
				--	as InventoryStart,
				--COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate AND SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null then ProcessQtY end),0)  as SumIn,
				--COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate AND SparePartIOTypeCode='GI_REPARE' then ProcessQty end),0)   as SumOut,
				--COALESCE(sum
				--	(case when A.basicdate < @pFromDate and SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null then ProcessQty
				--	 when   A.basicdate < @pFromDate and SparePartIOTypeCode='GI_REPARE' then  -ProcessQty  
				--	 end),0) +
				--COALESCE(sum
				--	(case when  SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is not null then ProcessQty else 0 end),0)	+ 
				--COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate AND SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null then ProcessQtY end),0) -
				--COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate AND SparePartIOTypeCode='GI_REPARE' then ProcessQty end),0)
				--as InventoryEnd

				COALESCE(sum
					(case when A.basicdate < @pFromDate and SparePartIOTypeCode='GR_NORMAL' and SPwarehousecode='Kho1' and a.attribute1 is  null then ProcessQty
					 when   A.basicdate < @pFromDate and SparePartIOTypeCode='GI_REPARE' and SPwarehousecode='Kho1' then  -ProcessQty  
					 end),0) +
				COALESCE(sum
					(case when  SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is not null and SPwarehousecode='Kho1' then ProcessQty else 0 end),0)	
					as InventoryStartKho1,
				COALESCE(sum
					(case when A.basicdate < @pFromDate and SparePartIOTypeCode='GR_NORMAL' and SPwarehousecode='Kho2' and a.attribute1 is  null then ProcessQty
					 when   A.basicdate < @pFromDate and SparePartIOTypeCode='GI_REPARE' and SPwarehousecode='Kho2' then  -ProcessQty  
					 end),0) +
				COALESCE(sum
					(case when  SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is not null and SPwarehousecode='Kho2' then ProcessQty else 0 end),0)	
					as InventoryStartKho2,
				COALESCE(sum
					(case when A.basicdate < @pFromDate and SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null then ProcessQty
					 when   A.basicdate < @pFromDate and SparePartIOTypeCode='GI_REPARE' then  -ProcessQty  
					 end),0) +
				COALESCE(sum
					(case when  SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is not null then ProcessQty else 0 end),0)	
					as InventoryStart,
                				COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate AND SparePartIOTypeCode='GR_NORMAL' and SPwarehousecode='Kho1' and a.attribute1 is  null then ProcessQtY end),0)  as SumInKho1,
				COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate AND SparePartIOTypeCode='GR_NORMAL' and SPwarehousecode='Kho2' and a.attribute1 is  null then ProcessQtY end),0)  as SumInKho2,
				COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate AND SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null then ProcessQtY end),0)  as SumIn,

				COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate AND SparePartIOTypeCode='GI_REPARE'  and SPwarehousecode='Kho1'  then ProcessQty end),0)   as SumOutKho1,
				COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate AND SparePartIOTypeCode='GI_REPARE'  and SPwarehousecode='Kho2'  then ProcessQty end),0)   as SumOutKho2,
				COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate AND SparePartIOTypeCode='GI_REPARE' then ProcessQty end),0)   as SumOut,
				
				COALESCE(sum
					(case when A.basicdate < @pFromDate and SparePartIOTypeCode='GR_NORMAL' and SPwarehousecode='Kho1'and a.attribute1 is  null then ProcessQty
					 when   A.basicdate < @pFromDate and SparePartIOTypeCode='GI_REPARE' and SPwarehousecode='Kho1' then  -ProcessQty  
					 end),0) +
				COALESCE(sum 
					(case when  SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is not null and SPwarehousecode='Kho1' then ProcessQty else 0 end),0)	+ 
				COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate and SPwarehousecode='Kho1' AND SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null then ProcessQtY end),0) -
				COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate and SPwarehousecode='Kho1' AND SparePartIOTypeCode='GI_REPARE' then ProcessQty end),0)
				as InventoryEndKho1,
				COALESCE(sum
					(case when A.basicdate < @pFromDate and SparePartIOTypeCode='GR_NORMAL'  and SPwarehousecode='Kho2' and a.attribute1 is  null then ProcessQty
					 when   A.basicdate < @pFromDate and SparePartIOTypeCode='GI_REPARE'  and SPwarehousecode='Kho2' then  -ProcessQty  
					 end),0) +
				COALESCE(sum
					(case when  SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is not null  and SPwarehousecode='Kho2' then ProcessQty else 0 end),0)	+ 
				COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate  and SPwarehousecode='Kho2' AND SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null then ProcessQtY end),0) -
				COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate  and SPwarehousecode='Kho2' AND SparePartIOTypeCode='GI_REPARE' then ProcessQty end),0)
				as InventoryEndKho2,


				COALESCE(sum
					(case when A.basicdate < @pFromDate and SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null then ProcessQty
					 when   A.basicdate < @pFromDate and SparePartIOTypeCode='GI_REPARE' then  -ProcessQty  
					 end),0) +
				COALESCE(sum
					(case when  SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is not null then ProcessQty else 0 end),0)	+ 
				COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate AND SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null then ProcessQtY end),0) -
				COALESCE( SUM(case when A.basicdate between @pFromDate and @pToDate AND SparePartIOTypeCode='GI_REPARE' then ProcessQty end),0)
				as InventoryEnd



	
		from     STB_VNSparePartIOHistory A,
				 STB_VNSparePartInfo  B
		where    A.SparePartCode = B.SparePartCode
		         --and A.basicdate between @pFromDate and @pToDate
				 AND (@pSparePartCode IS NULL OR @pSparePartCode= ''  OR A.SparePartCode =@pSparePartCode )
				 AND (@pCompanyCode IS NULL OR @pCompanyCode='' OR A.CompanyCode= @pCompanyCode)
				 AND (@pWorkCenterCode IS NULL OR @pCompanyCode='' OR A.WorkCenterCode = @pWorkCenterCode )
				 AND (@pSPWarehouseCode IS NULL OR @pSPWarehouseCode='' OR A.SPWarehouseCode = @pSPWarehouseCode)
				 AND (@pSPLocationCode IS NULL OR @pSPLocationCode='' OR A.SPLocationCode = @pSPLocationCode)
		GROUP BY 
			--	spwarehousecode,
			--	splocationcode,
				A.SparePartCode, 
				sparepartname,
				sparepartspec01 , 
				sparepartspec02 ,
				sparepartspec03 ,
				sparepartspec04 ,
				basicunit,
				position,
				B.PositionBG,
				A.WorkCenterCode
END