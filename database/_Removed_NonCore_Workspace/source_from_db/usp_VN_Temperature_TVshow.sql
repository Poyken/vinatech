CREATE PROC usp_VN_Temperature_TVshow --- exec usp_VN_Temperature_TVshow '2021-11-25','2021-11-26'
@FromDate DATETIME,
@ToDate DATETIME
AS
BEGIN

--SET @FromDate ='2021-11-25'
--SET @ToDate ='2021-11-26'

SELECT TOP(3) MeasureItemCode,LEFT(MeasureValue,2) AS MeasureValue
--CASE
--	WHEN
--				DeviceID = N'12_MIXING_FACTORY2' AND MeasureItemCode = N'Humidity' THEN  '53.0' 
--		WHEN
--				DeviceID = N'12_MIXING_FACTORY2' AND MeasureItemCode = N'Temperature' THEN '23.1'

--				 WHEN
--				DeviceID = N'12_MIXING_FACTORY2' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

--				ELSE ''

--		END AS MeasureValue
FROM STB_IoTMeasureHist
WHERE CreateDateTime >= @FromDate AND   CreateDateTime  <= @ToDate  AND   DeviceID = '12_MIXING_FACTORY2'
ORDER BY CreateDateTime DESC

END

 