CREATE procedure [dbo].[usp_ReportDetailStationery] --exec usp_ReportDetailStationery 'KSX','Loannt test 3','2023-04-01','2023-04-30'
 	@pCompanyCode nvarchar(20) = NULL,
	@pWorkCenterCode nvarchar(20) = NULL,
 @pWarehouseCode nvarchar(50) = null,
 @pStationeryCode nvarchar(50)=null,
 @pFromDate date,
 @pToDate date

as
begin

	 ;with table1(num_row,stationerycode,basicdate, quanlity, type, balance)
	as
	(
		select cast( 0 as numeric) AS num_row ,StationeyCode,cast('' as date) as BasicDate,cast('0' as numeric) as quanlity,CAST('Ton Dau Ky' AS NVARCHAR(255))  Type,
		cast( sum(case when SIOTypeCode='BALANCE' and SWarehouse=@pWarehouseCode then Quanlity else 0 end)
		 + sum( case   when BasicDate < @pFromDate and SWarehouse=@pWarehouseCode and SIOTypeCode='IN' then Quanlity else 0  end)
		 +	sum(case when SIOTypeCode='TF' and ToSWarehouse=@pWarehouseCode  and DateConfirm <@pFromDate and isconfirm=1 then quanlity else 0  end)
		 -	sum(case when SIOTypeCode='OUT' and SWarehouse=@pWarehouseCode and basicDate <@pFromDate then quanlity else 0  end) as numeric) as balance
		from Stb_StationeryIOHistory a where StationeyCode=@pStationeryCode AND WorkCenterCode = @pWorkCenterCode
		group by StationeyCode
		

		union all


		select  cast(ROW_NUMBER() OVER(order by a.BasicDate) as numeric) AS num_row ,a.StationeyCode,a.BasicDate, cast (a.quanlity as numeric) as quanlity,
		cast (   case   when a.BasicDate between @pFromDate and @pToDate and SWarehouse=@pWarehouseCode and SIOTypeCode='IN' then 'Nhap'
	              when SIOTypeCode='TF' and ToSWarehouse=@pWarehouseCode  and a.dateconfirm between @pFromDate and @pToDate and isconfirm=1 then 'Nhap'
				  when a.BasicDate between @pFromDate and @pToDate and SWarehouse=@pWarehouseCode and SIOTypeCode='Out' then 'Xuat'
	              when SIOTypeCode='TF' and SWarehouse=@pWarehouseCode  and a.BasicDate between @pFromDate and @pToDate then 'Xuat'
				  end as nvarchar(255))  as Type,
			
		cast(0 as numeric) balance 
		from Stb_StationeryIOHistory a  where StationeyCode=@pStationeryCode  AND WorkCenterCode = @pWorkCenterCode
		and ((SWarehouse=@pWarehouseCode and SIOTypeCode='IN') or (SIOTypeCode='TF' and ToSWarehouse=@pWarehouseCode) or (SWarehouse=@pWarehouseCode and SIOTypeCode='Out') or (SIOTypeCode='TF' and SWarehouse=@pWarehouseCode ))
		
	)

	 ,table2 (num_row,stationerycode,basicdate, quanlity, type, balance) as
	(
		select num_row,StationeryCode,BasicDate,quanlity,type,balance from table1 where num_row =0 
		union all
		select table1.num_row num_row,table1.stationerycode,table1.basicdate,table1.quanlity,table1.type,
		case   when table1.type='Nhap' then cast(table2.balance + table1.quanlity as numeric)
			   when table1.type='Xuat'  then cast(table2.balance - table1.quanlity as numeric)
	            
		end balance 
		from table2, table1 where  table2.num_row = table1.num_row - 1 
		
	)

	--select num_row,StationeryCode,BasicDate,type,quanlity,balance from table1 where num_row =0

select num_row,a2.StationeryCode,a2.StationeryName,a2.BasicUnit, 
	convert(varchar, BasicDate, 111) as  BasicDate,  
	type, quanlity,balance
	from table2 a1 left join STB_StationeryInfo a2 on a1.stationerycode = a2.StationeryCode 
	where type is not null

end

-- select * from Stb_StationeryIOHistory