-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리
-- Description:	전극코팅외관검사정보
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeCoatingVisualInspectionInfo_Dashboard]
	@pFromDate DATE
   ,@pToDate DATE
AS
BEGIN
	DECLARE @FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(CHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'

	;WITH DefaultList AS (
		SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	)
	SELECT   ISNULL(ECVII.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ISNULL(ECVII.SideCode, DL.SideCode) AS SideCode
			,BC2.Description AS SideCodeName
			,ISNULL(ECVII.MeasureTimeCode, DL.MeasureTimeCode) AS MeasureTimeCode
			,BC.Description AS MeasureTimeCodeName
			,ISNULL(ECVII.Seq, DL.Seq) AS Seq
			,ECVII.LeftValue
			,ECVII.MiddleValue
			,ECVII.RightValue
			,ECVII.CreateDateTime
			,ECVII.CreateUserID
			,ECVII.ChangeDateTime
			,ECVII.ChangeUserID		
			,MM.MaterialCode
			,MM.MaterialName
			,ECI.MachineCode  --add MachineCode by Mr.Tung, requested by Mr.Back & Mr.Choi on 14-Dec-2021
			,MacM.MachineName --add MachineCode by Mr.Tung, requested by Mr.Back & Mr.Choi on 14-Dec-2021
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN DefaultList DL	                                    ON 1=1
	  LEFT OUTER JOIN STB_ElectrodeCoatingVisualInspectionInfo ECVII	    ON SI.Barcode = ECVII.ElectrodeLotNumber	   AND DL.SideCode = ECVII.SideCode	   AND DL.MeasureTimeCode = ECVII.MeasureTimeCode	   AND DL.Seq = ECVII.Seq
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC    	            ON BC.CodeGroup = 'MeasureTime'    	           AND ISNULL(ECVII.MeasureTimeCode, DL.MeasureTimeCode) = BC.ItemCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2  	                ON ISNULL(ECVII.SideCode, DL.SideCode) = BC2.ItemCode	   AND BC2.CodeGroup = 'SideCode'
	  LEFT OUTER JOIN STB_MaterialMaster MM                                 ON SI.MaterialCode = MM.MaterialCode
	   LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI	 with(nolock) 			ON ECI.ElectrodeLotNumber = SI.Barcode  --add MachineCode by Mr.Tung, requested by Mr.Back & Mr.Choi on 14-Dec-2021
	   LEFT OUTER JOIN STB_MachineMaster MacM  with(nolock)                 ON MacM.MachineCode = ECI.MachineCode
	
	WHERE ECVII.CreateDateTime BETWEEN @FromDate AND @ToDate
	 ORDER BY CASE WHEN DL.SideCode = 'O' THEN 1
	                      WHEN DL.SideCode = 'B' THEN 2	   ELSE DL.SideCode END
		     ,CASE WHEN DL.MeasureTimeCode = 'FIRST' THEN 1
			       WHEN DL.MeasureTimeCode = 'MIDDLE' THEN 2
				   WHEN DL.MeasureTimeCode = 'LAST' THEN 3	   ELSE 4 END
		     ,DL.Seq
END



--usp_--ElectrodeCoatingVisualInspectionInfo_Dashboard  '2021-01-01','2021-12-31'


