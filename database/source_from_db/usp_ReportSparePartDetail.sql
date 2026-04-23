CREATE PROCEDURE [dbo].[usp_ReportSparePartDetail]
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
	select A2.*,A1.InventoryStartKho1,A1.InventoryEndKho2, A1.InventoryStart,A1.InventoryEndKho1,A1.InventoryEndKho2, A1.InventoryEnd from (		select 
				A.SparePartCode, 
				--concat(spwarehousecode,'-',splocationcode) as position,
				spwarehousecode as position,
			    COALESCE(sum
					(case when A.createdatetime < @pFromDate and SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null and SPWarehouseCode='Kho1' then ProcessQty
					 when   A.createdatetime < @pFromDate and SparePartIOTypeCode='GI_REPARE' and SPWarehouseCode='Kho1' then  -ProcessQty  
					 end),0) +
				COALESCE(sum
					(case when  SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is not null and SPWarehouseCode='Kho1' then ProcessQty else 0 end),0)	
					as InventoryStartKho1,

				COALESCE(sum
					(case when A.createdatetime < @pFromDate and SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null and SPWarehouseCode='Kho2' then ProcessQty
					 when   A.createdatetime < @pFromDate and SparePartIOTypeCode='GI_REPARE' and SPWarehouseCode='Kho2' then  -ProcessQty  
					 end),0) +
				COALESCE(sum
					(case when  SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is not null and SPWarehouseCode='Kho2' then ProcessQty else 0 end),0)	
					as InventoryStartKho2,
			   
			   COALESCE(sum
					(case when A.createdatetime < @pFromDate and SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null then ProcessQty
					 when   A.createdatetime < @pFromDate and SparePartIOTypeCode='GI_REPARE' then  -ProcessQty  
					 end),0) +
				COALESCE(sum
					(case when  SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is not null then ProcessQty else 0 end),0)	
					as InventoryStart,
				sum(case when SparePartIOTypeCode='GR_NORMAL'  and A.CreateDateTime between @pFromDate and @pToDate and A.Attribute1 is null then ProcessQty end) as SumIn,
				sum(case when SparePartIOTypeCode='GI_REPARE'  and A.CreateDateTime between @pFromDate and @pToDate then ProcessQty end )as SumOut,
				COALESCE(sum
					(case when A.createdatetime < @pFromDate and SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null and SPWarehouseCode='Kho1' then ProcessQty
					 when   A.createdatetime < @pFromDate and SparePartIOTypeCode='GI_REPARE' and SPWarehouseCode='Kho1' then  -ProcessQty  
					 end),0) +
				COALESCE(sum
					(case when  SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is not null and SPWarehouseCode='Kho1' then ProcessQty else 0 end),0)	 + COALESCE(sum(case when SparePartIOTypeCode='GR_NORMAL'  and SPWarehouseCode='Kho1' and A.CreateDateTime between @pFromDate and @pToDate  and a.attribute1 is  null  then ProcessQty end),0)- COALESCE(sum(case when SparePartIOTypeCode='GI_REPARE' and SPWarehouseCode='Kho1' and A.CreateDateTime between @pFromDate and @pToDate then ProcessQty end ),0) as InventoryEndKho1,


				COALESCE(sum
					(case when A.createdatetime < @pFromDate and SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null and SPWarehouseCode='Kho2' then ProcessQty
					 when   A.createdatetime < @pFromDate and SparePartIOTypeCode='GI_REPARE' and SPWarehouseCode='Kho2' then  -ProcessQty  
					 end),0) +
				COALESCE(sum
					(case when  SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is not null and SPWarehouseCode='Kho2' then ProcessQty else 0 end),0)	 + COALESCE(sum(case when SparePartIOTypeCode='GR_NORMAL'  and SPWarehouseCode='Kho2' and A.CreateDateTime between @pFromDate and @pToDate  and a.attribute1 is  null  then ProcessQty end),0)- COALESCE(sum(case when SparePartIOTypeCode='GI_REPARE' and SPWarehouseCode='Kho2' and A.CreateDateTime between @pFromDate and @pToDate then ProcessQty end ),0) as InventoryEndKho2,
				COALESCE(sum
					(case when A.createdatetime < @pFromDate and SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is  null then ProcessQty
					 when   A.createdatetime < @pFromDate and SparePartIOTypeCode='GI_REPARE' then  -ProcessQty  
					 end),0) +
				COALESCE(sum
					(case when  SparePartIOTypeCode='GR_NORMAL' and a.attribute1 is not null then ProcessQty else 0 end),0)	 + COALESCE(sum(case when SparePartIOTypeCode='GR_NORMAL'  and A.CreateDateTime between @pFromDate and @pToDate  and a.attribute1 is  null  then ProcessQty end),0)- COALESCE(sum(case when SparePartIOTypeCode='GI_REPARE'  and A.CreateDateTime between @pFromDate and @pToDate then ProcessQty end ),0) as InventoryEnd
 

	
		from     STB_VNSparePartIOHistory A,
				 STB_VNSparePartInfo  B
			where    A.SparePartCode = B.SparePartCode
					--and A.CreateDateTime between @pFromDate and @pToDate
				 AND (@pSparePartCode IS NULL OR @pSparePartCode= ''  OR A.SparePartCode =@pSparePartCode )
				 AND (@pCompanyCode IS NULL OR @pCompanyCode='' OR A.CompanyCode= @pCompanyCode)
				  AND (@pWorkCenterCode IS NULL OR @pWorkCenterCode='' OR A.WorkCenterCode= @pWorkCenterCode)
				 AND (@pSPWarehouseCode IS NULL OR @pSPWarehouseCode='' OR A.SPWarehouseCode = @pSPWarehouseCode)
				 AND (@pSPLocationCode IS NULL OR @pSPLocationCode='' OR A.SPLocationCode = @pSPLocationCode)
		GROUP BY 
				spwarehousecode,
				splocationcode,
				A.SparePartCode, 
				sparepartname,
				sparepartspec01 , 
				sparepartspec02 ,
				sparepartspec03 ,
				sparepartspec04 ,
				basicunit
) A1,


(select			
				--concat(spwarehousecode,'-',splocationcode) as position,
				spwarehousecode as position,
				A.sparepartIOHistoryNo,
				A.SparePartCode, 
				sparepartname, 
				sparepartspec01 as englishname, 
				sparepartspec02 as code,
				sparepartspec03 as marker,
				sparepartspec04 as process,
				basicunit,
				A.UnitPrice,
				sum(A.ProcessQty) as ProcessQty,
				A.BasicDate,
				C.MachineCode,
				case when SparePartIOTypeCode='GR_NORMAL' and A.Attribute1 is null  then 'NHAP'
				else 'XUAT' end as TypeInout,
				historytext,
				Position as location

	
		from     STB_VNSparePartIOHistory A 
				 left join STB_VNSparePartInfo  B ON  A.SparePartCode = B.SparePartCode
				 left join STB_VNSparePartChangeHistory C ON  A.SparePartIOHistoryNo = C.SparePartIOHistoryNo
		where   1=1
				  and A.Attribute1 is null 
		         and A.CreateDateTime between @pFromDate and @pToDate
				 AND (@pSparePartCode IS NULL OR @pSparePartCode= ''  OR A.SparePartCode =@pSparePartCode )
				 AND (@pCompanyCode IS NULL OR @pCompanyCode='' OR A.CompanyCode= @pCompanyCode)
				 AND (@pWorkCenterCode IS NULL OR @pWorkCenterCode='' OR A.WorkCenterCode= @pWorkCenterCode)
				 AND (@pSPWarehouseCode IS NULL OR @pSPWarehouseCode='' OR A.SPWarehouseCode = @pSPWarehouseCode)
				 AND (@pSPLocationCode IS NULL OR @pSPLocationCode='' OR A.SPLocationCode = @pSPLocationCode)
		GROUP BY A.sparepartIOHistoryNo,
				spwarehousecode,
				splocationcode,
				A.SparePartCode, 
				sparepartname,
				sparepartspec01 , 
				sparepartspec02 ,
				sparepartspec03 ,
				sparepartspec04 ,
				basicunit,
				A.UnitPrice,
				A.BasicDate,
				MachineCode,
				SparePartIOTypeCode,
				historytext,
				B.position,
				A.Attribute1

		) A2 
	where a1.SparePartCode = a2.SparePartCode and a1.position = a2.position
	order by position, SparePartCode, BasicDate
END