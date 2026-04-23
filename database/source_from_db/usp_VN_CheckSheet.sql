
CREATE PROC [dbo].[usp_VN_CheckSheet] -- EXEC usp_VN_CheckSheet '2021-12-21' EXEC usp_VN_CheckSheet '2021-12-15' EXEC usp_VN_CheckSheet '2021-12-14'
--@DEATE NVARCHAR(50)
AS
BEGIN

DECLARE @Deates DATETIME
SELECT @Deates =dateadd(mm, -1,dateadd(dd, +1, eomonth(getdate())))

CREATE TABLE #Tb
(
	ItemCode NVARCHAR(50) NULL,
	ValueMesure FLOAT NULL,
	CreateDate DATETIME NULL
)

INSERT INTO #Tb(CreateDate,ValueMesure,ItemCode)
SELECT T1.CreateDateTime, T1.MeasureValue,T1.MeasureItemCode
FROM STB_IoTMeasureHist T1 WITH(NOLOCK)
INNER JOIN
(
    SELECT CONVERT(DATE,CreateDateTime) AS trade_date, MAX(CreateDateTime) AS max_trade_time
    FROM STB_IoTMeasureHist WITH(NOLOCK)
	WHERE DeviceID = '14_MANUALLYLINE_FACT' AND CreateDateTime >= @Deates AND MeasureItemCode ='Humidity'
    GROUP BY CONVERT(DATE,CreateDateTime)
) T2
    ON T2.trade_date = CONVERT(DATE,T1.CreateDateTime) AND
       T2.max_trade_time = T1.CreateDateTime
ORDER BY
    t1.CreateDateTime DESC;

INSERT INTO #Tb(CreateDate,ValueMesure,ItemCode)
SELECT t1.CreateDateTime, t1.MeasureValue,t1.MeasureItemCode
FROM STB_IoTMeasureHist T1 WITH(NOLOCK)

INNER JOIN
(
    SELECT CONVERT(DATE,CreateDateTime) AS trade_date, MAX(CreateDateTime) AS max_trade_time
    FROM STB_IoTMeasureHist WITH(NOLOCK)
	WHERE DeviceID ='14_MANUALLYLINE_FACT' AND CreateDateTime >= @Deates AND MeasureItemCode='Temperature'
    GROUP BY CONVERT(DATE,CreateDateTime)
) t2
    ON t2.trade_date = CONVERT(DATE,T1.CreateDateTime) AND
       t2.max_trade_time = t1.CreateDateTime
ORDER BY
    T1.CreateDateTime DESC;

SELECT
		CONVERT(DATE,CreateDate) AS 'CreateDate' ,ValueMesure, ItemCode, CreateDate as 'adb'
FROM 
		#Tb
--WHERE
--		CONVERT(DATE,CreateDate) = @DEATE

ORDER BY CreateDate DESC

DROP TABLE #Tb

END

-- EXEC usp_VN_CheckSheet '2021-12-18'

--SELECT  MeasureItemCode,MeasureValue,CreateDateTime FROM STB_IoTMeasureHist WHERE DeviceID = '14_MANUALLYLINE_FACT' AND CreateDateTime >= '2021-12-23' AND 
--MeasureItemCode = 'Humidity'

--ORDER BY CreateDateTime DESC