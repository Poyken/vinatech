-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_getViewCheckEquipment]

AS
BEGIN
				(select LineName,[Winding],[Riveting],[Impregnation],[Beading],[Curling],[ESR],[Sleeving],[Remark]
			FROM (
			select distinct B1.Linecode, b1.LineName,b2.RouteCode,b2.Status from  STB_LineInfo b1 left join 
			(select distinct a2.linecode,
			case when a4.RouteCode = 'V-22' then 'Winding'
				 WHEN a4.RouteCode ='V-24' then 'Winding'
				 WHEN a4.RouteCode='V-25' then 'Sleeving'
				 else a4.RouteCode end as RouteCode ,a2.CheckStandardNo,
			CASE WHEN a3.CheckYn = 0 THEN 'NG'
				 WHEN a3.CheckYn = 1 THEN 'OK' else 'NOT CHECK' end as Status
	 
			from 
			 STB_CheckStandardInfo a2 
			left join STB_CheckScheduleInfo a3 ON a2.CheckStandardNo = a3.CheckStandardNo
			left join STB_ProductMachine a4 ON a2.MachineCode = a4.MachineCode
			where 
			a3.CheckDate=CONVERT(char(10), GetDate(),126)
			 ) b2
			 ON b1.linecode = b2.LineCode
			 where b1.CompanyCode='VVT' and (b1.linecode like 'VV%' or  b1.linecode like 'DR%')) x
			  PIVOT (max(Status) FOR  RouteCode  IN([Winding],[Riveting],[Impregnation],[Beading],[Curling],[ESR],[Sleeving],[Remark])
			) pvt) 
			order by LineCode
END