-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-04-01

-- =============================================
CREATE PROCEDURE [dbo].[usp_Size_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)

AS
BEGIN

	SELECT RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2)
					 + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
					 + CASE WHEN CHARINDEX('-L', MBI.ModelName, 0) > 0 THEN 'L' ELSE '' END AS size
	  FROM STB_ModelBasicInfo MBI
	 WHERE MBI.MBISizeW IS NOT NULL
	 GROUP BY RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2)
					 + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
					 + CASE WHEN CHARINDEX('-L', MBI.ModelName, 0) > 0 THEN 'L' ELSE '' END
	 ORDER BY RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2)
					 + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
					 + CASE WHEN CHARINDEX('-L', MBI.ModelName, 0) > 0 THEN 'L' ELSE '' END
--    SELECT distinct
--	case when
--		right (substring(materialname, CHARINDEX('(', materialname),6),1) =')'and 
--		left (substring(materialname, CHARINDEX('(', materialname),6),1)='('
--		and len( substring(materialname, CHARINDEX('(', materialname),6)) = 6
--		and substring(substring(materialname, CHARINDEX('(', materialname),6),2,4) NOT LIKE '%[^0-9]%'
--	then  substring(substring(materialname, CHARINDEX('(', materialname),6),2,4)
--else ''
--end size
--from STB_MaterialMaster
--order by size desc

END
