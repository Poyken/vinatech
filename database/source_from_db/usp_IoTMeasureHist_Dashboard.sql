-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-03-25
-- Browsable : true
-- Group : 스마트팩토리
-- Description:	IoTMeasureHist
-- Modified: 

--  usp_IoTMeasureHist_Dashboard '', '', 'DHT_02', '', '2020-01-01 00:00:00', '2022-01-01'
-- =============================================

CREATE PROCEDURE [dbo].[usp_IoTMeasureHist_Dashboard]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDeviceID VARCHAR(20) = NULL,
	@pMeasureItemCode VARCHAR(20) = NULL,
	@pFromDate DATE,
	@pToDate DATE
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), DATEADD(month, -1, GETDATE()), 121) + ' 00:00:00'
	       --,@FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'
	       --,@ToDate DATETIME = CONVERT(VARCHAR(10), @pToDate, 121) + ' 23:59:59'
		   ,@ToDate DATETIME = GETDATE()
		   ,@DeviceID VARCHAR(20) = CASE WHEN ISNULL(@pDeviceID, '') = '' THEN '*' ELSE @pDeviceID END
		   ,@MeasureItemCode VARCHAR(20) = CASE WHEN ISNULL(@pMeasureItemCode, '') = '' THEN '*' ELSE @pMeasureItemCode END

	SELECT IMH.DeviceID
	      ,IMH.MeasureItemCode
		  ,BC2.Description AS DeviceLocationName
		  ,BC2.Remark AS DeviceLocationDetail
		  ,BC.Description AS MeasureItemName
		  ,AVG(IMH.MeasureValue) AS MeasureValue
		  ,MAX(IMH.CreateDateTime) AS CreateDateTime
		  ,CASE WHEN IMH.MeasureItemCode = 'Temperature' THEN IDI.TempLSL
		        WHEN IMH.MeasureItemCode = 'Humidity' THEN IDI.HumiLSL
				ELSE NULL END AS LSL
		  ,CASE WHEN IMH.MeasureItemCode = 'Temperature' THEN IDI.TempUSL
		        WHEN IMH.MeasureItemCode = 'Humidity' THEN IDI.HumiUSL
				ELSE NULL END AS USL
	  FROM STB_IoTMeasureHist IMH

	  LEFT OUTER JOIN STB_IoTDeviceInfo IDI	                            ON IMH.DeviceID = IDI.DeviceID
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	    ON IMH.MeasureItemCode = BC.ItemCode	   AND BC.CodeGroup = 'MeasureItemCode'
	   LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	     ON BC2.CodeGroup = 'DeviceLocationCode'		AND BC2.ItemCode = IDI.DeviceLocationCode

	 WHERE (@DeviceID = '*' OR IMH.DeviceID = @DeviceID)
	   AND (@MeasureItemCode = '*' OR IMH.MeasureItemCode = @MeasureItemCode)
	   AND IMH.CreateDateTime BETWEEN @FromDate AND @ToDate
	   AND IDI.IsUsed = CONVERT(BIT, 1)
	   AND IDI.DeviceID IN ('SHT_test_01', 'DHT_04', 'DHT_06')
	 GROUP BY IMH.DeviceID, IMH.MeasureItemCode, BC.Description, BC2.Description, BC2.Remark
	         ,DATEADD(MINUTE, DATEDIFF(MINUTE, '2000', IMH.CreateDateTime) / 10 * 10, '2000')
			 ,IDI.TempLSL, IDI.TempUSL, IDI.HumiLSL, IDI.HumiUSL
	 ORDER BY IMH.DeviceID,DATEADD(MINUTE, DATEDIFF(MINUTE, '2000', IMH.CreateDateTime) / 10 * 10, '2000')
END