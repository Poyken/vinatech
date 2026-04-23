CREATE procedure [dbo].[usp_Reportmaterialwarehouse_get]
@pfromdate date,
@ptodate date
as
begin
if @pfromdate='2021-06-01'
begin
	select distinct case when A1.materialcode is not null then a1.materialcode 
					when a2.MaterialCode is not null then a2.materialcode
					else a3.materialcode end as materialcode,
			   case when A1.materialname is not null then a1.materialname 
					when a2.materialname is not null then a2.materialname
					else a3.materialname end as materialname,
				coalesce( CONVERT(DECIMAL(18, 2),a3.firstInventory),0) + coalesce(a3.sumin,0) -  coalesce(a3.sumout,0)
				as openningInventory,
				   suminput, sumoutput,
				 coalesce( CONVERT(DECIMAL(18, 2),a3.firstInventory),0) + coalesce(a3.sumin,0) -  coalesce(a3.sumout,0) + coalesce(suminput,0) - coalesce(sumoutput,0) as FinishedInventory

	
			from 
			(select materialcode, materialname, sum(suminput) as suminput from VW_InTypeAll
			where basicdate between @pfromdate and @ptodate
			group by materialcode, materialname) A1
			full outer join 
			(select materialcode, materialname, sum(outqty) as sumoutput
			from 
			VW_OutLineHistory where OutDate between @pfromdate and @ptodate
			group by materialcode, materialname)A2
			on a1.materialcode= a2.materialcode
			full outer join 
			(select a.MaterialCode,b.materialname,a.FirstInventory,a.SumIn,a.SumOut from Stb_InventoryMaterialLiquidation a left join STB_MaterialMaster b
			ON a.MaterialCode = b.MaterialCode
			 where Period <@pfromdate) A3
			on A1.materialcode =a3.MaterialCode or a2.MaterialCode = a3.MaterialCode
end
else
begin
	declare @datesub date 
	set @datesub = convert(date,DATEADD(day,-1,@pfromdate) )
	select distinct case when A1.materialcode is not null then a1.materialcode 
					when a2.MaterialCode is not null then a2.materialcode
					else A5.materialcode end as materialcode,
			   case when A1.materialname is not null then a1.materialname 
					when a2.materialname is not null then a2.materialname
					else A5.materialname end as materialname,
				--coalesce( CONVERT(DECIMAL(18, 2),a3.firstInventory),0) + coalesce(a3.sumin,0) -  coalesce(a3.sumout,0)
				--as 
				openningInventory,
				   suminput, sumoutput,
				 --coalesce( CONVERT(DECIMAL(18, 2),a3.firstInventory),0) + coalesce(a3.sumin,0) -  coalesce(a3.sumout,0) + coalesce(suminput,0) - coalesce(sumoutput,0) as FinishedInventory
				 coalesce( CONVERT(DECIMAL(18, 2),openningInventory),0)  + coalesce(suminput,0) - coalesce(sumoutput,0) as FinishedInventory
	
			from 
			(select materialcode, materialname, sum(suminput) as suminput from VW_InTypeAll
			where basicdate between @pfromdate and @ptodate
			group by materialcode, materialname) A1
			full outer join 
			(select materialcode, materialname, sum(outqty) as sumoutput
			from 
			VW_OutLineHistory where OutDate between @pfromdate and @ptodate
			group by materialcode, materialname)A2
			on a1.materialcode= a2.materialcode
			full outer join 
			--(select a.MaterialCode,b.materialname,a.FirstInventory,a.SumIn,a.SumOut from Stb_InventoryMaterialLiquidation a left join STB_MaterialMaster b
			--ON a.MaterialCode = b.MaterialCode
			-- where Period <@pfromdate) A3
			(
				select distinct case when A3.materialcode is not null then a3.materialcode 
					else a4.materialcode end as materialcode,
			   case when A3.materialname is not null then A3.materialname 
					else A4.materialname end as materialname,a3.FirstInventory +a4.suminput -a4.sumoutput as openninginventory
			from 
			(select a.MaterialCode,b.materialname,a.FirstInventory,a.SumIn,a.SumOut from Stb_InventoryMaterialLiquidation a left join STB_MaterialMaster b
						ON a.MaterialCode = b.MaterialCode
						 where Period <'2021-06-01')A3
			full outer join 
			(	select distinct case when A1.materialcode is not null then a1.materialcode 
								else a2.materialcode end as materialcode,
						   case when A1.materialname is not null then a1.materialname 
								else a2.materialname end as materialname,suminput, sumoutput
						from

						(select materialcode, materialname, sum(suminput) as suminput from VW_InTypeAll
						where basicdate between '2021-06-01' and @datesub
						group by materialcode, materialname) A1
						full outer join 
						(select materialcode, materialname, sum(outqty) as sumoutput
						from 
						VW_OutLineHistory where OutDate between '2021-06-01' and @datesub
						group by materialcode, materialname)A2
						on a1.materialcode= a2.materialcode

			) A4 on a3.MaterialCode = a4.materialcode	
			) A5
			on A1.materialcode =A5.MaterialCode or a2.MaterialCode = A5.MaterialCode
	where openninginventory is not null or suminput is not null or sumoutput is not null 
end
end