-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-03-25
-- Browsable : true
-- Group : 스마트팩토리
-- Description:	IoTMeasureHist
-- Modified: DHT_04 : +2.3
-- =============================================

CREATE PROCEDURE [dbo].[usp_IoTMeasureHist_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDeviceID VARCHAR(20) = NULL,
	@pMeasureItemCode VARCHAR(20) = NULL,
	@pFromDate DATE,
	@pToDate DATE
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), @pToDate, 121) + ' 23:59:59'
		   ,@DeviceID VARCHAR(20) = CASE WHEN ISNULL(@pDeviceID, '') = '' THEN '*' ELSE @pDeviceID END
		   ,@MeasureItemCode VARCHAR(20) = CASE WHEN ISNULL(@pMeasureItemCode, '') = '' THEN '*' ELSE @pMeasureItemCode END

	IF @MeasureItemCode = '*' BEGIN
		SELECT '습도' AS MeasureItemName
			  ,MAX(IMH.MeasureValue) AS MeasureValue
			  ,CONVERT(VARCHAR(19), MAX(IMH.CreateDateTime), 121) AS CreateDateTime
			  ,MAX(IDI.TempLSL) AS TempLSL
			  ,MAX(IDI.TempUSL) AS TempUSL
			  ,MAX(IDI.HumiLSL) AS HumiLSL
			  ,MAX(IDI.HumiUSL) AS HumiUSL
		  FROM STB_IoTMeasureHist IMH
		  LEFT OUTER JOIN STB_IoTDeviceInfo IDI	    ON IMH.DeviceID = IDI.DeviceID
		  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	    ON IMH.MeasureItemCode = BC.ItemCode	   AND BC.CodeGroup = 'MeasureItemCode'
		 WHERE (@DeviceID = '*' OR IMH.DeviceID = @DeviceID)
		   AND IMH.MeasureItemCode = 'Humidity'
		   AND IMH.CreateDateTime BETWEEN @FromDate AND @ToDate
		GROUP BY DATEPART(YEAR, IMH.CreateDateTime),
			      DATEPART(MONTH, IMH.CreateDateTime),
			      DATEPART(DAY, IMH.CreateDateTime),
			      DATEPART(HOUR, IMH.CreateDateTime),
			     (DATEPART(MINUTE, IMH.CreateDateTime) / 10)
		ORDER BY CONVERT(VARCHAR(19), MAX(IMH.CreateDateTime), 121)
	END ELSE BEGIN
		SELECT MAX(IMH.MeasureValue) AS MeasureValue
			  ,CONVERT(VARCHAR(19), MAX(IMH.CreateDateTime), 121) AS CreateDateTime
			  ,MAX(IDI.TempLSL) AS TempLSL
			  ,MAX(IDI.TempUSL) AS TempUSL
			  ,MAX(IDI.HumiLSL) AS HumiLSL
			  ,MAX(IDI.HumiUSL) AS HumiUSL
		  FROM STB_IoTMeasureHist IMH
		  LEFT OUTER JOIN STB_IoTDeviceInfo IDI	    ON IMH.DeviceID = IDI.DeviceID
		  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	    ON IMH.MeasureItemCode = BC.ItemCode	   AND BC.CodeGroup = 'MeasureItemCode'
		 WHERE (@DeviceID = '*' OR IMH.DeviceID = @DeviceID)
		   AND (@MeasureItemCode = '*' OR IMH.MeasureItemCode = @MeasureItemCode)
		   AND IMH.CreateDateTime BETWEEN @FromDate AND @ToDate
		 GROUP BY DATEPART(YEAR, IMH.CreateDateTime),
			      DATEPART(MONTH, IMH.CreateDateTime),
			      DATEPART(DAY, IMH.CreateDateTime),
			      DATEPART(HOUR, IMH.CreateDateTime),
			     (DATEPART(MINUTE, IMH.CreateDateTime) / 10)
		 ORDER BY CONVERT(VARCHAR(19), MAX(IMH.CreateDateTime), 121)
	END
END