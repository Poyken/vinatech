
CREATE PROCEDURE [dbo].[usp_Vietnam_ProductsReceipt_autoinsert]
		@truedate date = null
AS

BEGIN
declare @startdate varchar(10)= convert(varchar(10),dateadd(month,-1,getdate()),120)
if (@startdate<'2022-08-01') set @startdate= '2022-08-01';
if (@truedate is not null) set @startdate=convert(varchar(10),@truedate,120)

declare @limitid INT=0;
select  @limitid =min(id)  
from STB_VN_FINISHGOODS fish with(nolock) 
where TYPEEXPORT is null or TYPEEXPORT='' --and createdate>=@startdate 


;with	 	ta as (	select top 100000 
				lotno,PackQty,DateExport,CreateDate,SoInVoice
				--id,lotno,materialcode,packqty,partno,ProductionSize,country,PersonExport,DateExport,TYPEEXPORT,TRANSPORT,CUSTOMERNAME 
				from STB_VN_FINISHGOODS with(nolock) 
				where TYPEEXPORT='XB'
				and DateExport>=@startdate
				--group by lotno
				--having count(*)>1
				)
				,tb as (
				select Barcode,ProdQty , PackingDate,InvoiceNo
				from  STB_ProductsReceiptHist with(nolock) 
				where PackingDate>=@startdate --order by PackingDate desc
				--group by Barcode
				--having count(*)>1
				)
				,
				notexist as (
				select*from ta
				full outer  join tb 
				on STUFF(rtrim(ltrim(replace(replace(ta.lotno,'LVJ','VV'),'LVV','VV'))),1,2,'VV')=STUFF(rtrim(ltrim(replace(replace(tb.barcode,'LVJ','VV'),'LVV','VV'))),1,2,'VV') 
				and ta.PackQty=tb.ProdQty 
				and convert(varchar(10),ta.DateExport,120)=convert(varchar(10),tb.PackingDate,120)
				and ta.SoInVoice=tb.InvoiceNo
				where Barcode is null
				--order by isnull(ta.lotno,tb.barcode)
				)
				insert into STB_ProductsReceiptHist (
						Barcode,
						InvoiceNo,
						--BLNo,
						PackingDate,
						ShipmentDate,
						TransportationMethodCode,
						MaterialCode,
						ProdQty,
						VNNameProduct,
						--Remark,
						Nation,
						Customer,
						--Size,
						CreateDateTime,
						CreateUserID
			)
			select
				fish.lotno,
				fish.SOINVOICE,
				convert(varchar(10),fish.DateExport,120),
				convert(varchar(10), case when upper(TRANSPORT)='AIR' then dateadd(day,1,fish.DateExport) else dateadd(day,2,fish.DateExport) end,120)
				,replace(replace(replace(TRANSPORT,'Truck','03'),'AIR','01'),'SEA','02') as TRANSPORT,
				materialcode,
				fish.packqty AS qtypackqty,
				partno,--'' REMARK,
				rtrim(ltrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
				replace(country,'(',''),')',''),N'Kỹ thuật sản phẩm',''),N'Kĩ thuật sản phẩm',
				''),N'Tây Ban Nha',
				''),N'Thổ Nhĩ Kỳ',
				''),N'Trung Quốc',
				''),N'Sản Xuất',
				''),N'Phần Lan',
				''),N'Anh Quốc',
				''),N'Việt Nam',
				''),N'hàn quốc',
				''),N'Hàn Quốc',
				''),N'Thái Lan',
				''),N'Sảnxuất',
				''),N'Đóng gói',
				''),N'đóng gói',
				''),N'Đài loan',
				''),N'Hà lan',
				''),N'Ấn Độ',
				''),N'Bỉ',
				''),N'Đức',
				''),N'Pháp',
				''),N'Mỹ',
				''))),
				CUSTOMERNAME Customer,
				--ProductionSize,
				fish.DateExport,USERID--,TYPEEXPORT
			from STB_VN_FINISHGOODS fish with(nolock) 
			join notexist on fish.LotNo=notexist.LotNo 
			and fish.packqty=notexist.PackQty 
			and fish.DateExport = notexist.DateExport 
			and fish.CreateDate = notexist.CreateDate 
			and fish.SoInVoice = notexist.SoInVoice
			where fish.id >= @limitid 
			and fish.flag=1 
			and  fish.LotNo<>'WEC3R0106QG-B080R(1030)'
			--and fish.TRANSPORT <> 'Truck'

end 



--      [usp_Vietnam_ProductsReceipt_autoinsert] 

-- select *  from STB_VN_FINISHGOODS fish with(nolock) where TYPEEXPORT='XB' and lotno='VVMM012R750633' 

--select  id  from STB_VN_FINISHGOODS fish with(nolock) where  TYPEEXPORT='XB' and createdate>'2022-08-01' 

--select  *from 
--STB_ProductsReceiptHist 

