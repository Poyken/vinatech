-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_getViewCheckEquipment_Addon] --exec usp_getViewCheckEquipment_Addon

AS
BEGIN
--			with  loannt_table as

--(select   distinct a1.LineName, a1.routename, b1.errorname,b1.createdatetime,
--case when b1.status=1 then 'NG'
--		 when	  b1.status=0 then 'OK'
--			  else 'NOT CHECK' end as status
--,STUFF((

--SELECT  '***   '+'Route:'+ CAST(innerTable.routename AS nvarchar(200)) + ' Status :' + CAST(innerTable.errorname AS nvarchar(200))+' Time:'+ CONVERT(VARCHAR(30), innerTable.createdatetime, 21)+'   '

--FROM stb_linesituation_vvt AS innerTable

--WHERE innerTable.id = a1.id

--FOR XML PATH('')

--),1,1,'') AS remark

--from 
--(select distinct a.LineName,b.routename,
	
--			  max(b.id)  as id from 
--STB_LineInfo a
--left join stb_linesituation_vvt b ON a.LineCode = b.linecode
--where a.CompanyCode='VVT' and (a.linecode like 'VV%' or  a.linecode like 'DR%')
--group by a.linename, b.routename
--) a1
--left join stb_linesituation_vvt b1
--ON a1.id=b1.id)



--(select  LINENAME,max([WINDING-권취]) as WINDING,max([BEADING-비딩]) AS BEADING,max([CURLING-커링]) AS CURLING,max([SLEEVE-슬리브]) AS SLEEVE,
--max([AGING-에이징]) AS AGING,max([VISUAL-외관]) AS VISUAL,max([PACKING-포장]) AS PACKING, max([TAPING-테이핑]) AS TAPING,max([BENDING-벤딩]) AS BENDING,max([PQC]) AS PQC,max([OQC]) AS OQC,max([FOQC]) AS FOQC
--,max(remark) as REMARK
--from

--(select   distinct LineName, routename, errorname ,createdatetime,status
--,STUFF((

--SELECT  CHAR(10)+ CAST(innerTable.remark AS nvarchar(200)) 

--FROM loannt_table AS innerTable

--WHERE innerTable.LineName = d3.LineName

--FOR XML PATH('')

--),1,1,'') AS remark
--from loannt_table d3)x
--PIVOT (max(Status) FOR  routename  IN([WINDING-권취],[BEADING-비딩],[CURLING-커링],[SLEEVE-슬리브],[AGING-에이징],[VISUAL-외관],[PACKING-포장], [TAPING-테이핑],[BENDING-벤딩],[PQC],[OQC],[FOQC] )) pvt
-- group by linename
-- ) 


with  loannt_table as

(select   distinct a1.LineName, a1.routename, b1.errorname,b1.createdatetime,
case when b1.status=1 then 'NG'
		 when	  b1.status=0 then 'OK'
			  else 'NOT CHECK' end as status
,STUFF((

SELECT  '***   '+'Route:'+ CAST(innerTable.routename AS nvarchar(200)) + '_' + CAST(innerTable.errorcode AS nvarchar(200))+'   '

FROM stb_linesituation_vvt  AS innerTable with (nolock)

WHERE innerTable.id = a1.id

FOR XML PATH('')

),1,1,'') AS notes
,STUFF((

SELECT  '***   '+'Route:'+ CAST(innerTable.routename AS nvarchar(200)) + ' Status :' + CAST(innerTable.errorname AS nvarchar(200))+' Time:'+ CONVERT(VARCHAR(30), innerTable.createdatetime, 21)+'   '

FROM stb_linesituation_vvt AS innerTable WITH(NOLOCK) 

WHERE innerTable.id = a1.id

FOR XML PATH('')

),1,1,'') AS remark

from 
(select distinct a.LineName,b.routename,
	
			  max(b.id)  as id from 
STB_LineInfo a with (nolock)
left join stb_linesituation_vvt b with (nolock) ON a.LineCode = b.linecode
where a.CompanyCode='VVT' and (a.linecode like 'VV%' or  a.linecode like 'DR%')
group by a.linename, b.routename
) a1
left join stb_linesituation_vvt b1 with (nolock)
ON a1.id=b1.id)



(select  LINENAME,max([WINDING-권취]) as WINDING,max([BEADING-비딩]) AS BEADING,max([CURLING-커링]) AS CURLING,max([SLEEVE-슬리브]) AS SLEEVE,
max([AGING-에이징]) AS AGING,max([VISUAL-외관]) AS VISUAL,max([PACKING-포장]) AS PACKING, max([TAPING-테이핑]) AS TAPING,max([BENDING-벤딩]) AS BENDING,max([PQC]) AS PQC,max([OQC]) AS OQC,max([FOQC]) AS FOQC
,max(Notes) as NOTES,max(remark) as REMARK
from

(select   distinct LineName, routename, errorname ,createdatetime,status
,STUFF((

SELECT  CHAR(10)+ CAST(innerTable.notes AS nvarchar(200)) 

FROM loannt_table AS innerTable  with (nolock)

WHERE innerTable.LineName = d3.LineName

FOR XML PATH('')

),1,1,'') AS notes
,STUFF((

SELECT  CHAR(10)+ CAST(innerTable.remark AS nvarchar(200)) 

FROM loannt_table  AS innerTable with (nolock)

WHERE innerTable.LineName = d3.LineName

FOR XML PATH('')

),1,1,'') AS remark
from loannt_table d3)x
PIVOT (max(Status) FOR  routename  IN([WINDING-권취],[BEADING-비딩],[CURLING-커링],[SLEEVE-슬리브],[AGING-에이징],[VISUAL-외관],[PACKING-포장], [TAPING-테이핑],[BENDING-벤딩],[PQC],[OQC],[FOQC] )) pvt
 group by linename
 ) 

END


