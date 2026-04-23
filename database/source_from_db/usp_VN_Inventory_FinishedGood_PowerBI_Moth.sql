CREATE PROC [dbo].[usp_VN_Inventory_FinishedGood_PowerBI_Moth] -- EXEC usp_VN_Inventory_FinishedGood_PowerBI_Moth

AS
BEGIN


DECLARE @mydate DATETIME
DECLARE @Todate DATETIME
DECLARE @Fromdate DATETIME

SELECT @mydate = GETDATE()

--SELECT CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@mydate)),@mydate),23) ,
----N'Ngày cuối tháng trước'
--UNION
SET @Fromdate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@mydate)-1),@mydate),23)
SET @Todate = CONVERT(VARCHAR(25),@mydate,23)

--SELECT @Fromdate, @Todate

 --AS Date_Value, 'hôm nay' AS Date_Type
--UNION
--SELECT CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,@mydate))),DATEADD(mm,1,@mydate)),23) ,
--N'Ngày cuối tháng này'
--UNION
--SELECT CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,@mydate))-1),DATEADD(mm,1,@mydate)),23) ,
--N'Ngày đầu tháng tiếp theo'

--- FORMAT(QtyInput, 'N0') AS QtyInput,


SELECT

		'' + replace(PUBLICCODE, ' ', '') + '' AS PUBLICCODE,
		'' + replace(PartNo, ' ', '') + '' AS PARTNO,
		UNIT
		,SUM(case WHEN CONVERT(DATE,CAPUTER_DATE) = @FromDate THEN qtyinput  ELSE 0 END) AS  tongnhapdauky
	    ,SUM(case WHEN CONVERT(DATE,CAPUTER_DATE) = @FromDate THEN qtyout ELSE 0 END) AS tongxuatpdauky
		,SUM(case WHEN CONVERT(DATE,CAPUTER_DATE) = @FromDate THEN totalcurrently ELSE 0 END) AS tondauky
		,SUM(case WHEN CONVERT(DATE,CAPUTER_DATE) = @ToDate  THEN qtyinput ELSE 0 END  - CASE WHEN CONVERT(DATE,CAPUTER_DATE) = @FromDate THEN qtyinput  else 0 END ) AS tongnhaptrongky
		,SUM(case WHEN CONVERT(DATE,CAPUTER_DATE) = @ToDate  THEN qtyout  ELSE 0 END  - CASE WHEN CONVERT(DATE,CAPUTER_DATE) = @FromDate THEN  qtyout  else 0 END ) AS tongxuattrongky
		,SUM(case WHEN CONVERT(DATE,CAPUTER_DATE) = @ToDate THEN qtyinput  ELSE 0 END) AS tongnhapcuoiky
		,SUM(case WHEN CONVERT(DATE,CAPUTER_DATE) = @ToDate  THEN qtyout  ELSE 0 END) AS tonxuatpcuoiky
		,SUM(case WHEN CONVERT(DATE,CAPUTER_DATE) = @ToDate  THEN totalcurrently  ELSE 0 END) AS toncuoiky
		
FROM
		STB_VN_CAPTURE_FINSHEDGOOD WITH(NOLOCK)

WHERE 1=1 

 AND CONVERT(DATE,CAPUTER_DATE) BETWEEN @FromDate AND @ToDate
 GROUP BY PUBLICCODE, PARTNO, UNIT,TOTALCURRENTLY

END
