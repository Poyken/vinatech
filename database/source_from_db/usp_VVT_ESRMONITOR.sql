
CREATE PROCEDURE [dbo].[usp_VVT_ESRMONITOR]	(
@load int = 1
)	
AS

BEGIN 


if(isnull(@load,0)= 0) return;



select  CellLine 
		,machinecode 
		,COMPort
		,max(CompanyCode) as CompanyCode
		,max(ip) as ip
		,max(CreateDateTime) as CreateDateTime
		,case when datediff(minute,max(CreateDateTime),getdate())>60*12 then 'Off / Changed Line & Port' 
		when datediff(minute,max(CreateDateTime),getdate())>3 then 'Need to Check' 
		else 'OK' end as Status_Online
from  (
	select replace(replace(CellLine,'·',''),'.','') as machinecode
		,replace(replace(machinecode,'·',''),'.','') as CellLine
		,replace(replace(COMPort,'·',''),'.','') as COMPort
		,CompanyCode
		,ip
		,CreateDateTime
	from STB_VVT_ESR_MONITOR
	where CreateDateTime > convert(varchar(10),dateadd(day,-5,getdate())) and machinecode not like '%·' 
	) newtb1
	where CreateDateTime > convert(varchar(10),dateadd(day,-5,getdate())) and machinecode not like '%·' 
	group by CellLine 
		,machinecode 
		,COMPort
	order by machinecode , CreateDateTime desc
	
END
