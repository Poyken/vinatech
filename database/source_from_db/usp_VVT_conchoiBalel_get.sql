
/* exec usp_VVT_ProductionResult_get '','','VVT','2021-03-01','','','','',1    */

CREATE  PROCEDURE [dbo].[usp_VVT_conchoiBalel_get]
	@rutgon VARCHAR(20)=null
AS	
	

BEGIN
		if(isnull(@rutgon,'')<>'') begin
			 select   distinct top 10 
				  [ComputerName]
					  ,case when mac like '%Ethernet%' then REPLACE(replace(SUBSTRING( isnull(mac,'') ,CHARINDEX('Ethernet',mac),26),'<b',''),'Ethernet','' )
     when mac like '%로컬 영역 연결%' then REPLACE(replace(SUBSTRING( isnull(mac,'') ,CHARINDEX('로컬 영역 연결',mac),24),'<b','') ,'로컬 영역 연결','' )
	 when mac like '%Local Area Connection%' then REPLACE(replace(SUBSTRING( isnull(mac,'') ,CHARINDEX('Local Area Connection',mac),38),'<b',''),'Local Area Connection','' ) else ' ' end 
	 -- +'__'+
	 --case when mac like '%Ethernet%' then REPLACE(replace(SUBSTRING( isnull(mac,'') ,CHARINDEX('Ethernet',mac),24),'<b','') ,'Ethernet','' )
  --   when mac like '%이더넷%' then REPLACE(replace(SUBSTRING( isnull(mac,'') ,CHARINDEX('이더넷',mac),19),'<b','') ,'이더넷','' )
	 --when mac like '%Local Area Connection%' then REPLACE(replace(SUBSTRING( isnull(mac,'') ,CHARINDEX('Local Area Connection',mac),38),'<b',''),'','' )  else ' ' end
	 --+ '__'+
	 --case when mac like '%Wi-Fi%' then REPLACE(replace(SUBSTRING( isnull(mac,'') ,CHARINDEX('Wi-Fi',mac),21),'<b',''),'','' ) else ' ' end  
	 as mac40
	 ,  (select max(mac) as mac from SmartFactoryV2.dbo.stb_Vietnam_controlpanel   with(nolock) where ComputerName=vcp.ComputerName and len(mac)>20) as mac
					  ,[Windows]
					  ,[Offices]
					  ,
					  case when Programs like '%siemen%' then '_siemen' else ' ' end
						+case when Programs like '%mitsu%' then'_mitsu'  else ' ' end
						+case when Programs like '%XDesignerPlus%' then'_XDesignerPlus' else ' ' end
						+case when Programs like '%Design StudiO%' then'_Design StudiO' else ' ' end
						+case when Programs like '%AutoShop%' then'_AutoShop' else ' ' end
						+case when Programs like '%AutoCAD%' then'_AutoCAD' else ' ' end
						+case when Programs like '%FX-TRN-BEG-E%' then'_FX-TRN-BEG-E' else ' ' end
						+case when Programs like '%CX-Server%' then'_CX-Server' else ' ' end
						+case when Programs like '%EBpro V%' then'_EBpro V' else ' ' end
						+case when Programs like '%GP-Pro%' then'_GP-Pro' else ' ' end
						+case when Programs like '%GX Works%' then'_GX Works' else ' ' end
						+case when Programs like '%Panasonic%' then'_Panasonic' else ' ' end
						+case when Programs like '%for Microsoft Excel%'  then '_Ablebits Ultimate Suite for Microsoft Excel'else ' ' end
						+case when Programs like '%WinPcap%'  then'_WinPcap' else ' ' end
						+case when Programs like '%WPLSoft%'  then'_WPLSoft' else ' ' end
						+case when Programs like '%XG5000%'  then'_XG5000' else ' ' end
						+case when Programs like '%ShihlinINV%'  then'_ShihlinINV' else ' ' end
						+case when Programs like '%PANATERM%' then '_PANATERM' else ' ' end
					  as Violated
					  ,[Programs]
				from SmartFactoryV2.dbo.stb_Vietnam_controlpanel  vcp with(nolock) 
				where Windows like 'NG%' or 	
				Programs like '%siemen%' or	
				Programs like '%mitsu%' or
				Programs like '%XDesignerPlus%' or
				Programs like '%Design StudiO%' or
				Programs like '%AutoShop%' or
				Programs like '%AutoCAD%' or
				Programs like '%FX-TRN-BEG-E%' or
				Programs like '%CX-Server%' or
				Programs like '%EBpro V%' or
				Programs like '%GP-Pro%' or
				Programs like '%GX Works%' or
				Programs like '%Panasonic%' or
				Programs like '%for Microsoft Excel%'  or
				Programs like '%WinPcap%'  or
				Programs like '%WPLSoft%'  or
				Programs like '%XG5000%'  or
				Programs like '%ShihlinINV%'  or
				Programs like '%PANATERM%' 
				order by ComputerName
		end
		else
		begin
				 ;with tb1 as (
					select '' as ComputerName,''  as mac40,'' as mac, ''as Violated,'<tr>' + '<td style="border: 1px solid gray;">'+' ComputerName'+ '</td>'+ '<td style="border: 1px solid gray;">'+	'IP'+ '</td>'+ '<td style="border: 1px solid gray;">'+	'MAC'	+ '</td>'+ 
					'<td style="border: 1px solid gray;">'+'CreateDateTime'+ '</td>'+ '<td style="border: 1px solid gray;">'+	'Windows'+ 
					'</td>'+ '<td style="border: 1px solid gray;">'+	'Offices'+ '</td>'+ '<td style="border: 1px solid gray;">'+'Programs' + '</td>'+'</tr>' as duleu
					union all
					select  
					distinct  top 10 ComputerName,
					case when mac like '%Ethernet%' then REPLACE(replace(SUBSTRING( isnull(mac,'') ,CHARINDEX('Ethernet',mac),26),'<b',''),'Ethernet','' )
     when mac like '%로컬 영역 연결%' then REPLACE(replace(SUBSTRING( isnull(mac,'') ,CHARINDEX('로컬 영역 연결',mac),24),'<b','') ,'로컬 영역 연결','' )
	 when mac like '%Local Area Connection%' then REPLACE(replace(SUBSTRING( isnull(mac,'') ,CHARINDEX('Local Area Connection',mac),38),'<b',''),'Local Area Connection','' )  else ' ' end 
	 -- +'__'+
	 --case when mac like '%Ethernet%' then REPLACE(replace(SUBSTRING( isnull(mac,'') ,CHARINDEX('Ethernet',mac),24),'<b','') ,'Ethernet','' )
  --   when mac like '%이더넷%' then REPLACE(replace(SUBSTRING( isnull(mac,'') ,CHARINDEX('이더넷',mac),19),'<b','') ,'이더넷','' )
	 --when mac like '%Local Area Connection%' then REPLACE(replace(SUBSTRING( isnull(mac,'') ,CHARINDEX('Local Area Connection',mac),38),'<b',''),'','' )  else ' ' end
	 --+ '__'+
	 --case when mac like '%Wi-Fi%' then REPLACE(replace(SUBSTRING( isnull(mac,'') ,CHARINDEX('Wi-Fi',mac),21),'<b',''),'','' )   else ' ' end 
	  ,  (select max(mac) as mac from SmartFactoryV2.dbo.stb_Vietnam_controlpanel   with(nolock) where ComputerName=vcp.ComputerName and len(mac)>20) as mac
	 , 					  case when Programs like '%siemen%' then '_siemen' else ' ' end
						+case when Programs like '%mitsu%' then'_mitsu'  else ' ' end
						+case when Programs like '%XDesignerPlus%' then'_XDesignerPlus' else ' ' end
						+case when Programs like '%Design StudiO%' then'_Design StudiO' else ' ' end
						+case when Programs like '%AutoShop%' then'_AutoShop' else ' ' end
						+case when Programs like '%AutoCAD%' then'_AutoCAD' else ' ' end
						+case when Programs like '%FX-TRN-BEG-E%' then'_FX-TRN-BEG-E' else ' ' end
						+case when Programs like '%CX-Server%' then'_CX-Server' else ' ' end
						+case when Programs like '%EBpro V%' then'_EBpro V' else ' ' end
						+case when Programs like '%GP-Pro%' then'_GP-Pro' else ' ' end
						+case when Programs like '%GX Works%' then'_GX Works' else ' ' end
						+case when Programs like '%Panasonic%' then'_Panasonic' else ' ' end
						+case when Programs like '%for Microsoft Excel%'  then '_Ablebits Ultimate Suite for Microsoft Excel'else ' ' end
						+case when Programs like '%WinPcap%'  then'_WinPcap' else ' ' end
						+case when Programs like '%WPLSoft%'  then'_WPLSoft' else ' ' end
						+case when Programs like '%XG5000%'  then'_XG5000' else ' ' end
						+case when Programs like '%ShihlinINV%'  then'_ShihlinINV' else ' ' end
						+case when Programs like '%PANATERM%' then '_PANATERM' else ' ' end
					  as Violated
	 ,'<tr>' + '<td style="border: 1px solid gray;">'+ComputerName+ '</td>'+ '<td style="border: 1px solid gray;">.</td>'+ '<td style="border: 1px solid gray;">'+	substring( isnull(mac,'') ,1,40)	+ '</td>'+ 
					'<td style="border: 1px solid gray;">.</td>'+ '<td style="border: 1px solid gray;">'+	isnull(Windows,' ')+ 
					'</td>'+ '<td style="border: 1px solid gray;">'+	isnull(Offices,' ')+ '</td>'+ '<td style="border: 1px solid gray;">'+isnull(Programs,' ') + '</td>'+'</tr>' as duleu
					from SmartFactoryV2.dbo.stb_Vietnam_controlpanel  vcp with(nolock) 
					where Windows like 'NG%' or 
					--Programs like '%camcad%' or
					--Programs like '%PLC%' or
					Programs like '%siemen%' or
					--Programs like '%proex%' or
					Programs like '%mitsu%' or
					Programs like '%XDesignerPlus%' or
										Programs like '%Design StudiO%' or
																				Programs like '%TeamViewer%' or
					Programs like '%AutoShop%' or
					Programs like '%AutoCAD%' or
					Programs like '%FX-TRN-BEG-E%' or
					Programs like '%CX-Server%' or
					Programs like '%EBpro V%' or
					Programs like '%GP-Pro%' or
					Programs like '%GX Works%' or
					Programs like '%Panasonic%' or
					Programs like '%for Microsoft Excel%' OR
									Programs like '%WinPcap%'  or
				Programs like '%WPLSoft%'  or
				Programs like '%XG5000%'  or
				Programs like '%ShihlinINV%'  or
				Programs like '%PANATERM%' 
					)
					select '' as ComputerName,''  as mac40,'<table style="border: 1px solid gray; border-collapse: collapse;">'  as duleu
					union all
					select '' as ComputerName,''  as mac40,N'<video style="display:none"> </video></table>'  as duleu
					union all
					select ComputerName,mac40,duleu from tb1 
					order by ComputerName
		end
END







	