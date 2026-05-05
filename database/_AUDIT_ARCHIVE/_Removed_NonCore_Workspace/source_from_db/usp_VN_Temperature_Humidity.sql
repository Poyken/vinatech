CREATE PROC [dbo].[usp_VN_Temperature_Humidity] --EXEC usp_VN_Temperature_Humidity '2021-06-03','2021-06-03'
@pFdate DATETIME = NULL,
@pTdate DATETIME = NULL
AS
BEGIN
--	select * from STB_IoTMeasureHist where DeviceID like '13%'
--  select * from STB_IoTMeasureHist where DeviceID = '11_ELECTRODE_CUT_MATERIAL'

		DECLARE @FromDate DATE = @pFdate
		DECLARE @ToDate DATE = @pTdate

		IF @FromDate IS NULL AND  @ToDate IS NULL
		BEGIN
SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,

		CASE
		WHEN    DeviceID = N'05_WAREHOUSE_DOOR'  THEN 'The device near warehouse door'
		
		ELSE '05'
		END AS Location,

		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '11.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '30.5'
	    WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '005'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
		

WHERE
		DeviceID = '05_WAREHOUSE_DOOR' 


UNION 

SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'06_LINE12_BETWEEN_LI'  THEN 'The device between line 12 and line 13'
		
		ELSE '06'
		END AS Location,

		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '11.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '30.5'

		 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '006'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '06_LINE12_BETWEEN_LI'


UNION

SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'07_LINE17_BETWEEN_LI'  THEN 'Then device between line 17 and line 18'
		ELSE '07'
		END AS Location,

		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '7.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '31.8'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '007'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '07_LINE17_BETWEEN_LI'

UNION

SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'08_LINE4_BETWEEN_LIN'  THEN 'The device between line 4 and line 5'
		ELSE '08'
		END AS Location,

		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '26.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '27.8'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '008'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '08_LINE4_BETWEEN_LIN'

		UNION

SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'09_UTILITY_ROOM'  THEN 'The device in utility room'
		ELSE '09'
		END AS Location,

		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '33.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '31.7'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '009'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '09_UTILITY_ROOM'

UNION
SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'11_ELECTRODE_CUT_MAT'  THEN 'The device electrode cut material'
		ELSE '11'
		END AS Location,
		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '33.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '29.0'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '0011'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '11_ELECTRODE_CUT_MAT'
UNION
SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'10_MANUALLY_LINE_FAC'  THEN 'The device manually line factory 1'
		ELSE '10'
		END AS Location,
		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '25.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '31.0'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '0010'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '10_MANUALLY_LINE_FAC'
UNION
SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'12_MIXING_FACTORY2'  THEN 'The device mixing  factory 2'
		ELSE '12'
		END AS Location,
		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '53.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '23.1'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '0012'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '12_MIXING_FACTORY2'

		UNION
SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'13_WAREHOUSE_FACTORY2'  THEN 'The device warehouse  factory 2'
		ELSE '13'
		END AS Location,
		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '11.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '30.5'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '0013'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '13_WAREHOUSE_FACTORY2'

		
		UNION
SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'14_MANUALLYLINE_FACT'  THEN 'The device manually line in  factory 2'
		ELSE '14'
		END AS Location,
		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '38.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '26.7'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '0014'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '14_MANUALLYLINE_FACT'

	ORDER BY CreateDateTime DESC
END
	-----------------------------------------------------------------------------------------

		IF @FromDate IS NOT NULL AND  @ToDate  IS NOT NULL
		BEGIN
SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,

		CASE
		WHEN    DeviceID = N'05_WAREHOUSE_DOOR'  THEN 'The device near warehouse door'
		
		ELSE '05'
		END AS Location,

		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '11.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '30.5'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '005'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
		

WHERE
		DeviceID = '05_WAREHOUSE_DOOR' 


UNION 

SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'06_LINE12_BETWEEN_LI'  THEN 'The device between line 12 and line 13'
		
		ELSE '06'
		END AS Location,

		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '11.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '30.5'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '006'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '06_LINE12_BETWEEN_LI'


UNION

SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'07_LINE17_BETWEEN_LI'  THEN 'Then device between line 17 and line 18'
		ELSE '07'
		END AS Location,

		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '7.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '31.8'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '007'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '07_LINE17_BETWEEN_LI'

UNION

SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'08_LINE4_BETWEEN_LIN'  THEN 'The device between line 4 and line 5'
		ELSE '08'
		END AS Location,

		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '26.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '27.8'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '008'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '08_LINE4_BETWEEN_LIN'

		UNION

SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'09_UTILITY_ROOM'  THEN 'The device in utility room'
		ELSE '09'
		END AS Location,

		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '33.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '31.7'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '009'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '09_UTILITY_ROOM'

UNION
SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'11_ELECTRODE_CUT_MAT'  THEN 'The device electrode cut material'
		ELSE '11'
		END AS Location,
		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '33.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '29.0'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '0011'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '11_ELECTRODE_CUT_MAT'
UNION
SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'10_MANUALLY_LINE_FAC'  THEN 'The device manually line factory 1'
		ELSE '10'
		END AS Location,
		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '25.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '31.0'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '0010'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '10_MANUALLY_LINE_FAC'
UNION
SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'12_MIXING_FACTORY2'  THEN 'The device mixing  factory 2'
		ELSE '12'
		END AS Location,
		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '53.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '23.1'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '0012'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '12_MIXING_FACTORY2'

		UNION
SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'13_WAREHOUSE_FACTORY2'  THEN 'The device warehouse  factory 2'
		ELSE '13'
		END AS Location,
		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '11.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '30.5'


				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '0013'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '13_WAREHOUSE_FACTORY2'

		
		UNION
SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,
		CASE
		WHEN    DeviceID = N'14_MANUALLYLINE_FACT'  THEN 'The device manually line in  factory 2'
		ELSE '14'
		END AS Location,
		CASE
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Humidity' THEN  '38.0' 
		WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Temperature' THEN '26.7'

				 WHEN
				MeasureValue IS NOT NULL AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		ELSE '0014'

		END AS MeasureValue

FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
WHERE
		DeviceID = '14_MANUALLYLINE_FACT'

	ORDER BY CreateDateTime DESC

--SELECT
--		DeviceID,
--		MeasureItemCode,
--		--MeasureValue,
--		CreateDateTime,
--		RIGHT(CreateDateTime,8) AS Times,
--		CASE
--		WHEN    DeviceID = N'05_WAREHOUSE_DOOR'  THEN 'The device near warehouse door'
		
--		ELSE '05'
--		END AS Location 

--FROM 
--		STB_IoTMeasureHist WITH(NOLOCK)
--WHERE
--		DeviceID = '05_WAREHOUSE_DOOR' 
--		AND
--		(
--							((@FromDate IS NULL) OR CONVERT(DATE,CreateDateTime) >= @FromDate)
--		AND
--							((@ToDate IS NULL) OR CONVERT(DATE,CreateDateTime) <= @ToDate)
--		)

--UNION 

--SELECT
--		DeviceID,
--		MeasureItemCode,
--		--MeasureValue,
--		CreateDateTime,
--		RIGHT(CreateDateTime,8) AS Times,
--		CASE
--		WHEN    DeviceID = N'06_LINE12_BETWEEN_LI'  THEN 'The device between line 12 and line 13'
--		ELSE '06'
--		END AS Location 

--FROM 
--		STB_IoTMeasureHist WITH(NOLOCK)
--WHERE
--		DeviceID = '06_LINE12_BETWEEN_LI'
--		AND
--		(
--		((@FromDate IS NULL) OR CONVERT(DATE,CreateDateTime) >= @FromDate)
--		AND
--		((@ToDate IS NULL) OR CONVERT(DATE,CreateDateTime) <= @ToDate)
--		)

--UNION

--SELECT
--		DeviceID,
--		MeasureItemCode,
--		--MeasureValue,
--		CreateDateTime,
--		RIGHT(CreateDateTime,8) AS Times,
--		CASE
--		WHEN    DeviceID = N'07_LINE17_BETWEEN_LI'  THEN 'Then device between line 17 and line 18'
--		ELSE '07'
--		END AS Location 

--FROM 
--		STB_IoTMeasureHist WITH(NOLOCK)
--WHERE
--		DeviceID = '07_LINE17_BETWEEN_LI'
--		AND
--		(
--		((@FromDate IS NULL) OR CONVERT(DATE,CreateDateTime) >= @FromDate)
--		AND
--		((@ToDate IS NULL) OR CONVERT(DATE,CreateDateTime) <= @ToDate)
--		)

--UNION

--SELECT
--		DeviceID,
--		MeasureItemCode,
--		--MeasureValue,
--		CreateDateTime,
--		RIGHT(CreateDateTime,8) AS Times,
--		CASE
--		WHEN    DeviceID = N'08_LINE4_BETWEEN_LIN'  THEN 'The device between line 4 and line 5'
--		ELSE '08'
--		END AS Location 

--FROM 
--		STB_IoTMeasureHist WITH(NOLOCK)
--WHERE
--		DeviceID = '08_LINE4_BETWEEN_LIN'
--		AND
--		(
--		((@FromDate IS NULL) OR CONVERT(DATE,CreateDateTime) >= @FromDate)
--		AND
--		((@ToDate IS NULL) OR CONVERT(DATE,CreateDateTime) <= @ToDate)
--		)

--		UNION

--SELECT
--		DeviceID,
--		MeasureItemCode,
--		--MeasureValue,
--		CreateDateTime,
--		RIGHT(CreateDateTime,8) AS Times,
--		CASE
--		WHEN    DeviceID = N'09_UTILITY_ROOM'  THEN 'The device in utility room'
--		ELSE '09'
--		END AS Location 

--FROM 
--		STB_IoTMeasureHist WITH(NOLOCK)
--WHERE
--		DeviceID = '09_UTILITY_ROOM'
--		AND
--		(
--		((@FromDate IS NULL) OR CONVERT(DATE,CreateDateTime) >= @FromDate)
--		AND
--		((@ToDate IS NULL) OR CONVERT(DATE,CreateDateTime) <= @ToDate)
--		)

--UNION
--SELECT
--		DeviceID,
--		MeasureItemCode,
--		--MeasureValue,
--		CreateDateTime,
--		RIGHT(CreateDateTime,8) AS Times,
--		CASE
--		WHEN    DeviceID = N'11_ELECTRODE_CUT_MAT'  THEN 'The device electrode cut material'
--		ELSE '11'
--		END AS Location 

--FROM 
--		STB_IoTMeasureHist WITH(NOLOCK)
--WHERE
--		DeviceID = '11_ELECTRODE_CUT_MAT'
--		AND
--		(
--		((@FromDate IS NULL) OR CONVERT(DATE,CreateDateTime) >= @FromDate)
--		AND
--		((@ToDate IS NULL) OR CONVERT(DATE,CreateDateTime) <= @ToDate)
--		)
--UNION
--SELECT
--		DeviceID,
--		MeasureItemCode,
--		--MeasureValue,
--		CreateDateTime,
--		RIGHT(CreateDateTime,8) AS Times,
--		CASE
--		WHEN    DeviceID = N'10_MANUALLY_LINE_FAC'  THEN 'The device manually line factory 1'
--		ELSE '10'
--		END AS Location 

--FROM 
--		STB_IoTMeasureHist WITH(NOLOCK)
--WHERE
--		DeviceID = '10_MANUALLY_LINE_FAC'
--		AND
--		(
--		((@FromDate IS NULL) OR CONVERT(DATE,CreateDateTime) >= @FromDate)
--		AND
--		((@ToDate IS NULL) OR CONVERT(DATE,CreateDateTime) <= @ToDate)
--		)
--UNION
--SELECT
--		DeviceID,
--		MeasureItemCode,
--		--MeasureValue,
--		CreateDateTime,
--		RIGHT(CreateDateTime,8) AS Times,
--		CASE
--		WHEN    DeviceID = N'12_MIXING_FACTORY2'  THEN 'The device mixing  factory 2'
--		ELSE '12'
--		END AS Location 

--FROM 
--		STB_IoTMeasureHist WITH(NOLOCK)
--WHERE
--		DeviceID = '12_MIXING_FACTORY2'
--		AND
--		(
--		((@FromDate IS NULL) OR CONVERT(DATE,CreateDateTime) >= @FromDate)
--		AND
--		((@ToDate IS NULL) OR CONVERT(DATE,CreateDateTime) <= @ToDate)
--		)

--		UNION
--SELECT
--		DeviceID,
--		MeasureItemCode,
--		--MeasureValue,
--		CreateDateTime,
--		RIGHT(CreateDateTime,8) AS Times,
--		CASE
--		WHEN    DeviceID = N'13_WAREHOUSE_FACTORY'  THEN 'The device warehouse  factory 2'
--		ELSE '13'
--		END AS Location 

--FROM 
--		STB_IoTMeasureHist WITH(NOLOCK)
--WHERE
--		DeviceID = '13_WAREHOUSE_FACTORY'
--		AND
--		(
--		((@FromDate IS NULL) OR CONVERT(DATE,CreateDateTime) >= @FromDate)
--		AND
--		((@ToDate IS NULL) OR CONVERT(DATE,CreateDateTime) <= @ToDate)
--		)

		
--		UNION
--SELECT
--		DeviceID,
--		MeasureItemCode,
--		--MeasureValue,
--		CreateDateTime,
--		RIGHT(CreateDateTime,8) AS Times,
--		CASE
--		WHEN    DeviceID = N'14_MANUALLYLINE_FACT'  THEN 'The device manually line in  factory 2'
--		ELSE '14'
--		END AS Location 

--FROM 
--		STB_IoTMeasureHist WITH(NOLOCK)
--WHERE
--		DeviceID = '14_MANUALLYLINE_FACT'
--		AND
--		(
--		((@FromDate IS NULL) OR CONVERT(DATE,CreateDateTime) >= @FromDate)
--		AND
--		((@ToDate IS NULL) OR CONVERT(DATE,CreateDateTime) <= @ToDate)
--		)

--		ORDER BY CreateDateTime DESC
END
END