CREATE procedure [dbo].[usp_SumReportStationery] --exec usp_SumReportStationery '','VVT_F','2023-04-01','2023-04-30'
	--@pProcessUserID VARCHAR(20),
	--@pProcessLanguage VARCHAR(20),
	@pCompanyCode nvarchar(20) = NULL,
	@pWorkCenterCode nvarchar(20) = NULL,
 @pWarehouseCode nvarchar(50) = null,
 @pStationeryCode nvarchar(50)=null,
 @pFromDate date,
 @pToDate date

as
begin

		DECLARE @toDate_tmp date = DATEADD(day, -1, @pToDate)

		-- update 2025-07-28 following Ms.Thao's request
		IF @pWorkCenterCode = 'VVT_F1'   -- nha may BN
			BEGIN
					-- DinhManh update 2025-04-22 following Ms.Thao request, to select data from 2025-04
					With StationIOHistoryTmp AS (
			
						Select * from Stb_StationeryIOHistory where CreateDateTime >= '2025-04-01 00:00:00.000'
						--and WorkCenterCode = @pWorkCenterCode
						
					)

						---------------
					   			 		  		  		 	  
					select StationeyCode ,
						b.StationeryName,
						b.BasicUnit,
						 sum(case when SIOTypeCode='BALANCE' and SWarehouse=@pWarehouseCode then Quanlity else 0 end)
						 + sum( case   when BasicDate < @pFromDate and SWarehouse=@pWarehouseCode and SIOTypeCode='IN' then Quanlity else 0  end)
						 +	sum(case when SIOTypeCode='TF' and @pWarehouseCode !='KNVL' and ToSWarehouse=@pWarehouseCode  and DateConfirm <@pFromDate and IsConfirm =1 then quanlity else 0 end)

						 - sum (case when SIOTypeCode='TF' and SWarehouse ='VPPBN' and ToSWarehouse='VPPBN' and BasicDate < @pFromDate then quanlity else 0 end) -- update
						 -
								sum(case	when SIOTypeCode='TF' and @pWarehouseCode ='KNVL' and SWarehouse=@pWarehouseCode  and BasicDate <@pFromDate  then quanlity else 0  end)
						 -	sum(case when SIOTypeCode='OUT' and SWarehouse=@pWarehouseCode and basicDate <@pFromDate then quanlity else 0  end) as balanceFirst,

							sum( case   when BasicDate between @pFromDate and @pToDate and SWarehouse=@pWarehouseCode and SIOTypeCode='IN' then Quanlity  else 0  end)
						 +	sum(case when SIOTypeCode='TF' and ToSWarehouse=@pWarehouseCode  and DateConfirm between @pFromDate and @pToDate and IsConfirm =1 then quanlity  else 0 end) as InQuality,

							 sum( case   when BasicDate between @pFromDate and @pToDate and SWarehouse=@pWarehouseCode and SIOTypeCode='Out' then Quanlity  else 0 end)
						 +	sum(case when SIOTypeCode='TF' and SWarehouse=@pWarehouseCode  and basicDate between @pFromDate and @pToDate then quanlity  else 0 end) as OutQuality,

						 sum(case when SIOTypeCode='BALANCE' and SWarehouse=@pWarehouseCode then Quanlity else 0 end)
						 + sum( case   when BasicDate < @pFromDate and SWarehouse=@pWarehouseCode and SIOTypeCode='IN' then Quanlity else 0  end)
						 +	sum(case when SIOTypeCode='TF' and @pWarehouseCode !='KNVL' and ToSWarehouse=@pWarehouseCode  and DateConfirm <@pFromDate and IsConfirm =1 then quanlity else 0 end)
						 - sum (case when SIOTypeCode='TF' and SWarehouse ='VPPBN' and ToSWarehouse='VPPBN' and BasicDate < @pFromDate then quanlity else 0 end) -- update
						 -  sum(case	when SIOTypeCode='TF' and @pWarehouseCode ='KNVL' and SWarehouse=@pWarehouseCode  and BasicDate <@pFromDate  then quanlity else 0  end)
						 -	sum(case when SIOTypeCode='OUT' and SWarehouse=@pWarehouseCode and basicDate <@pFromDate then quanlity else 0  end)
						 +
							sum( case   when BasicDate between @pFromDate and @pToDate and SWarehouse=@pWarehouseCode and SIOTypeCode='IN' then Quanlity  else 0 end)
						 +	sum(case when SIOTypeCode='TF' and ToSWarehouse=@pWarehouseCode  and DateConfirm between @pFromDate and @pToDate and IsConfirm =1 then quanlity  else 0 end) 


						  -   sum( case   when BasicDate between @pFromDate and @pToDate and SWarehouse=@pWarehouseCode and SIOTypeCode='Out' then Quanlity  else 0 end)
						 -	sum(case when SIOTypeCode='TF' and SWarehouse=@pWarehouseCode  and basicDate between @pFromDate and @pToDate then quanlity  else 0 end) as Balance

					--from Stb_StationeryIOHistory a left join STB_StationeryInfo b on a.StationeyCode = b.StationeryCode
					from StationIOHistoryTmp a left join STB_StationeryInfo b on a.StationeyCode = b.StationeryCode  --update 2025-04-22
					where (@pStationeryCode ='' or @pStationeryCode is null or  StationeyCode = @pStationeryCode)
						   --AND
						   --(@pWorkCenterCode ='' or @pWorkCenterCode is null or  a.WorkCenterCode = @pWorkCenterCode)
					group by StationeyCode ,
						b.StationeryName,
						b.BasicUnit
			END


		ELSE  -- nha may khac

			BEGIN 

					-- DinhManh update 2025-04-22 following Ms.Thao request, to select data from 2025-04
				With StationIOHistoryTmp AS (
			
					Select * from Stb_StationeryIOHistory where CreateDateTime >= '2025-04-01 00:00:00.000'
					--and WorkCenterCode = @pWorkCenterCode

				)

					---------------
					   			 		  		  		 	  
				select StationeyCode ,
					b.StationeryName,
					b.BasicUnit,
					 sum(case when SIOTypeCode='BALANCE' and SWarehouse=@pWarehouseCode then Quanlity else 0 end)
					 + sum( case   when BasicDate < @pFromDate and SWarehouse=@pWarehouseCode and SIOTypeCode='IN' then Quanlity else 0  end)
					 +	sum(case when SIOTypeCode='TF' and @pWarehouseCode !='KNVL' and ToSWarehouse=@pWarehouseCode  and DateConfirm <@pFromDate and IsConfirm =1 then quanlity else 0 end)
					 -
							sum(case	when SIOTypeCode='TF' and @pWarehouseCode ='KNVL' and SWarehouse=@pWarehouseCode  and BasicDate <@pFromDate  then quanlity 
								 else 0  end)
					 -	sum(case when SIOTypeCode='OUT' and SWarehouse=@pWarehouseCode and basicDate <@pFromDate then quanlity else 0  end) as balanceFirst,

						sum( case   when BasicDate between @pFromDate and @pToDate and SWarehouse=@pWarehouseCode and SIOTypeCode='IN' then Quanlity  else 0  end)
					 +	sum(case when SIOTypeCode='TF' and ToSWarehouse=@pWarehouseCode  and DateConfirm between @pFromDate and @pToDate and IsConfirm =1 then quanlity  else 0 end) as InQuality,

						 sum( case   when BasicDate between @pFromDate and @pToDate and SWarehouse=@pWarehouseCode and SIOTypeCode='Out' then Quanlity  else 0 end)
					 +	sum(case when SIOTypeCode='TF' and SWarehouse=@pWarehouseCode  and basicDate between @pFromDate and @pToDate then quanlity  else 0 end) as OutQuality,

					 sum(case when SIOTypeCode='BALANCE' and SWarehouse=@pWarehouseCode then Quanlity else 0 end)
					 + sum( case   when BasicDate < @pFromDate and SWarehouse=@pWarehouseCode and SIOTypeCode='IN' then Quanlity else 0  end)
					 +	sum(case when SIOTypeCode='TF' and @pWarehouseCode !='KNVL' and ToSWarehouse=@pWarehouseCode  and DateConfirm <@pFromDate and IsConfirm =1 then quanlity else 0 end)
					 -
							sum(case	when SIOTypeCode='TF' and @pWarehouseCode ='KNVL' and SWarehouse=@pWarehouseCode  and BasicDate <@pFromDate  then quanlity 
								 else 0  end)
					 -	sum(case when SIOTypeCode='OUT' and SWarehouse=@pWarehouseCode and basicDate <@pFromDate then quanlity else 0  end)
					 +
						sum( case   when BasicDate between @pFromDate and @pToDate and SWarehouse=@pWarehouseCode and SIOTypeCode='IN' then Quanlity  else 0 end)
					 +	sum(case when SIOTypeCode='TF' and ToSWarehouse=@pWarehouseCode  and DateConfirm between @pFromDate and @pToDate and IsConfirm =1 then quanlity  else 0 end) 

					  -   sum( case   when BasicDate between @pFromDate and @pToDate and SWarehouse=@pWarehouseCode and SIOTypeCode='Out' then Quanlity  else 0 end)
					 -	sum(case when SIOTypeCode='TF' and SWarehouse=@pWarehouseCode  and basicDate between @pFromDate and @pToDate then quanlity  else 0 end) as Balance

				--from Stb_StationeryIOHistory a left join STB_StationeryInfo b on a.StationeyCode = b.StationeryCode
				from StationIOHistoryTmp a left join STB_StationeryInfo b on a.StationeyCode = b.StationeryCode  --update 2025-04-22
				where (@pStationeryCode ='' or @pStationeryCode is null or  StationeyCode = @pStationeryCode)
					   --AND
					   --(@pWorkCenterCode ='' or @pWorkCenterCode is null or  a.WorkCenterCode = @pWorkCenterCode)
				group by StationeyCode ,
					b.StationeryName,
					b.BasicUnit
			END
end	

--select * from Stb_StationeryIOHistory

--select * from STB_StationeryInfo
