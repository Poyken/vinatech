-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-29
-- Browsable : true
-- Group : 금형관리
-- Description:	금형온도이력조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMoldTemperatureHistory]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pFromMeasureDateTime DATETIME = NULL,
	@pToMeasureDateTime DATETIME = NULL 
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '*' ELSE @pMachineCode END
    DECLARE @FromMeasureDateTime DATETIME = CASE WHEN ISNULL(@pFromMeasureDateTime,'') = '' THEN GETDATE() ELSE @pFromMeasureDateTime END
	DECLARE @ToMeasureDateTime DATETIME = CASE WHEN ISNULL(@pToMeasureDateTime,'') = '' THEN GETDATE() ELSE @pToMeasureDateTime END
	
	
	--Table1	
	SELECT
			CDH.MeasureSeq AS OldMeasureSeq,
			CDH.MeasureSeq,
			CDH.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			CDH.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			CDH.MachineCode,
			MPM.MachineName,
			CDH.MeasureDateTime,
			CDH.OptionField,
			--MBI.MoldCategory1,
			--MBI.MoldCategory2,
			--MBI.MoldCategory3,
			ISNULL(CDH.IsAlarm,0) AS IsAlarm,
			ISNULL(CDH.IsAlarmStart,0) AS IsAlarmStart,
			CDH.AlarmEndDateTime,
			CDH.AlarmRemark,
			CDH.AlarmRemarkUserID,
			CDH.AlarmRemarkDateTime,
			
			CASE WHEN Data1.MeasureData = -999 THEN NULL ELSE Data1.MeasureData END AS MoldTemp1,
			CASE WHEN Data2.MeasureData = -999 THEN NULL ELSE Data2.MeasureData END AS MoldTemp2,
			CASE WHEN Data3.MeasureData = -999 THEN NULL ELSE Data3.MeasureData END AS MoldTemp3,
			CASE WHEN Data4.MeasureData = -999 THEN NULL ELSE Data4.MeasureData END AS MoldTemp4,
			CASE WHEN Data5.MeasureData = -999 THEN NULL ELSE Data5.MeasureData END AS MoldTemp5,
			CASE WHEN Data6.MeasureData = -999 THEN NULL ELSE Data6.MeasureData END AS MoldTemp6,
			CASE WHEN Data7.MeasureData = -999 THEN NULL ELSE Data7.MeasureData END AS MoldTemp7,
			CASE WHEN Data8.MeasureData = -999 THEN NULL ELSE Data8.MeasureData END AS MoldTemp8,
			CASE WHEN Data9.MeasureData = -999 THEN NULL ELSE Data9.MeasureData END AS MoldTemp9,
			CASE WHEN Data10.MeasureData = -999 THEN NULL ELSE Data10.MeasureData END AS MoldTemp10,
			
			Data1.IsAlarm AS IsMoldTempAlarm1,
			Data2.IsAlarm AS IsMoldTempAlarm2,
			Data3.IsAlarm AS IsMoldTempAlarm3,
			Data4.IsAlarm AS IsMoldTempAlarm4,
			Data5.IsAlarm AS IsMoldTempAlarm5,
			Data6.IsAlarm AS IsMoldTempAlarm6,
			Data7.IsAlarm AS IsMoldTempAlarm7,
			Data8.IsAlarm AS IsMoldTempAlarm8,
			Data9.IsAlarm AS IsMoldTempAlarm9,
			Data10.IsAlarm AS IsMoldTempAlarm10,
			
			Data1.SetingData AS MoldTemperatureSet1,
			Data2.SetingData AS MoldTemperatureSet2,
			Data3.SetingData AS MoldTemperatureSet3,
			Data4.SetingData AS MoldTemperatureSet4,
			Data5.SetingData AS MoldTemperatureSet5,
			Data6.SetingData AS MoldTemperatureSet6,
			Data7.SetingData AS MoldTemperatureSet7,
			Data8.SetingData AS MoldTemperatureSet8,
			Data9.SetingData AS MoldTemperatureSet9,
			Data10.SetingData AS MoldTemperatureSet10
			
			
	FROM
			STB_ContinueDataHistory CDH WITH(NOLOCK)
			LEFT OUTER JOIN STB_MoldProductMachine MPM WITH(NOLOCK)
				ON MPM.MachineCode = CDH.MachineCode
			--LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)
			--	ON MBI.MoldNumber = CDH.OptionField
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON WCI.WorkCenterCode = CDH.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON CI.CompanyCode = CDH.CompanyCode
			LEFT OUTER JOIN
			(
				SELECT
						CDD.MeasureSeq,
						CDD.MeasureData,
						ISNULL(CDD.IsAlarm,0) AS IsAlarm,
						CDD.SetingData
				FROM
						STB_ContinueDataDetail CDD WITH(NOLOCK)
				WHERE
						CDD.DataSeq = 1
			)Data1
				ON Data1.MeasureSeq = CDH.MeasureSeq
			LEFT OUTER JOIN
			(
				SELECT
						CDD.MeasureSeq,
						CDD.MeasureData,
						ISNULL(CDD.IsAlarm,0) AS IsAlarm,
						CDD.SetingData
				FROM
						STB_ContinueDataDetail CDD WITH(NOLOCK)
				WHERE
						CDD.DataSeq = 2
			)Data2
				ON Data2.MeasureSeq = CDH.MeasureSeq
			LEFT OUTER JOIN
			(
				SELECT
						CDD.MeasureSeq,
						CDD.MeasureData,
						ISNULL(CDD.IsAlarm,0) AS IsAlarm,
						CDD.SetingData
				FROM
						STB_ContinueDataDetail CDD WITH(NOLOCK)
				WHERE
						CDD.DataSeq = 3
			)Data3
				ON Data3.MeasureSeq = CDH.MeasureSeq
			LEFT OUTER JOIN
			(
				SELECT
						CDD.MeasureSeq,
						CDD.MeasureData,
						ISNULL(CDD.IsAlarm,0) AS IsAlarm,
						CDD.SetingData
				FROM
						STB_ContinueDataDetail CDD WITH(NOLOCK)
				WHERE
						CDD.DataSeq = 4
			)Data4
				ON Data4.MeasureSeq = CDH.MeasureSeq
			LEFT OUTER JOIN
			(
				SELECT
						CDD.MeasureSeq,
						CDD.MeasureData,
						ISNULL(CDD.IsAlarm,0) AS IsAlarm,
						CDD.SetingData
				FROM
						STB_ContinueDataDetail CDD WITH(NOLOCK)
				WHERE
						CDD.DataSeq = 5
			)Data5
				ON Data5.MeasureSeq = CDH.MeasureSeq
			LEFT OUTER JOIN
			(
				SELECT
						CDD.MeasureSeq,
						CDD.MeasureData,
						ISNULL(CDD.IsAlarm,0) AS IsAlarm,
						CDD.SetingData
				FROM
						STB_ContinueDataDetail CDD WITH(NOLOCK)
				WHERE
						CDD.DataSeq = 6
			)Data6
				ON Data6.MeasureSeq = CDH.MeasureSeq
			LEFT OUTER JOIN
			(
				SELECT
						CDD.MeasureSeq,
						CDD.MeasureData,
						ISNULL(CDD.IsAlarm,0) AS IsAlarm,
						CDD.SetingData
				FROM
						STB_ContinueDataDetail CDD WITH(NOLOCK)
				WHERE
						CDD.DataSeq = 7
			)Data7
				ON Data7.MeasureSeq = CDH.MeasureSeq
			LEFT OUTER JOIN
			(
				SELECT
						CDD.MeasureSeq,
						CDD.MeasureData,
						ISNULL(CDD.IsAlarm,0) AS IsAlarm,
						CDD.SetingData
				FROM
						STB_ContinueDataDetail CDD WITH(NOLOCK)
				WHERE
						CDD.DataSeq = 8
			)Data8
				ON Data8.MeasureSeq = CDH.MeasureSeq
			LEFT OUTER JOIN
			(
				SELECT
						CDD.MeasureSeq,
						CDD.MeasureData,
						ISNULL(CDD.IsAlarm,0) AS IsAlarm,
						CDD.SetingData
				FROM
						STB_ContinueDataDetail CDD WITH(NOLOCK)
				WHERE
						CDD.DataSeq = 9
			)Data9
				ON Data9.MeasureSeq = CDH.MeasureSeq
			LEFT OUTER JOIN
			(
				SELECT
						CDD.MeasureSeq,
						CDD.MeasureData,
						ISNULL(CDD.IsAlarm,0) AS IsAlarm,
						CDD.SetingData
				FROM
						STB_ContinueDataDetail CDD WITH(NOLOCK)
				WHERE
						CDD.DataSeq = 10
			)Data10
				ON Data10.MeasureSeq = CDH.MeasureSeq
	WHERE
			CDH.DataGroup = 'MOLD-TEMPERATURE' AND
			(CDH.CompanyCode = @CompanyCode)
			AND (CDH.WorkCenterCode = @WorkCenterCode)
			AND (CDH.MachineCode = @MachineCode)
			AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
			
	/*		
	--Table2		
	SELECT
			MTH.MeasureDateTime AS MeasureDateTime,
			'금형이동측' AS Gubun,
			MTH.MoldTemp1 AS Value
	FROM
			STB_MoldTemperatureHistory MTH WITH(NOLOCK)
	WHERE
			((MTH.CompanyNo = @pCompanyNo))
			AND ((MTH.WorkCenterNo = @pWorkCenterNo))
			AND ((MTH.MachineNo = @pMachineNo))
			AND ((@pFromMeasureDateTime <= MTH.MeasureDateTime) AND (@pToMeasureDateTime >= MTH.MeasureDateTime))
	UNION ALL
	SELECT
			MTH.MeasureDateTime AS MeasureDateTime,
			'금형이동측 설정온도' AS Gubun,
			MTH.MoldTemperatureSet1 AS Value
	FROM
			STB_MoldTemperatureHistory MTH WITH(NOLOCK)
	WHERE		
			((MTH.CompanyNo = @pCompanyNo))
			AND ((MTH.WorkCenterNo = @pWorkCenterNo))
			AND ((MTH.MachineNo = @pMachineNo))
			AND ((@pFromMeasureDateTime <= MTH.MeasureDateTime) AND (@pToMeasureDateTime >= MTH.MeasureDateTime))
	
	
	--Table3		
	SELECT
			MTH.MeasureDateTime AS MeasureDateTime,
			'금형고정측' AS Gubun,
			MTH.MoldTemp2 AS Value
	FROM
			STB_MoldTemperatureHistory MTH WITH(NOLOCK)
	WHERE
			((MTH.CompanyNo = @pCompanyNo))
			AND ((MTH.WorkCenterNo = @pWorkCenterNo))
			AND ((MTH.MachineNo = @pMachineNo))
			AND ((@pFromMeasureDateTime <= MTH.MeasureDateTime) AND (@pToMeasureDateTime >= MTH.MeasureDateTime))
	UNION ALL
	SELECT
			MTH.MeasureDateTime AS MeasureDateTime,
			'금형고정측 설정온도' AS Gubun,
			MTH.MoldTemperatureSet2 AS Value
	FROM
			STB_MoldTemperatureHistory MTH WITH(NOLOCK)
	WHERE		
			((MTH.CompanyNo = @pCompanyNo))
			AND ((MTH.WorkCenterNo = @pWorkCenterNo))
			AND ((MTH.MachineNo = @pMachineNo))
			AND ((@pFromMeasureDateTime <= MTH.MeasureDateTime) AND (@pToMeasureDateTime >= MTH.MeasureDateTime))
			
			
	--Table4		
	SELECT
			MTH.MeasureDateTime AS MeasureDateTime,
			'냉각IN' AS Gubun,
			MTH.MoldTemp3 AS Value
	FROM
			STB_MoldTemperatureHistory MTH WITH(NOLOCK)
	WHERE
			((MTH.CompanyNo = @pCompanyNo))
			AND ((MTH.WorkCenterNo = @pWorkCenterNo))
			AND ((MTH.MachineNo = @pMachineNo))
			AND ((@pFromMeasureDateTime <= MTH.MeasureDateTime) AND (@pToMeasureDateTime >= MTH.MeasureDateTime))
	UNION ALL
	SELECT
			MTH.MeasureDateTime AS MeasureDateTime,
			'냉각IN 설정온도' AS Gubun,
			MTH.MoldTemperatureSet3 AS Value
	FROM
			STB_MoldTemperatureHistory MTH WITH(NOLOCK)
	WHERE		
			((MTH.CompanyNo = @pCompanyNo))
			AND ((MTH.WorkCenterNo = @pWorkCenterNo))
			AND ((MTH.MachineNo = @pMachineNo))
			AND ((@pFromMeasureDateTime <= MTH.MeasureDateTime) AND (@pToMeasureDateTime >= MTH.MeasureDateTime))
			
			
			
	--Table5		
	SELECT
			MTH.MeasureDateTime AS MeasureDateTime,
			'냉각OUT' AS Gubun,
			MTH.MoldTemp4 AS Value
	FROM
			STB_MoldTemperatureHistory MTH WITH(NOLOCK)
	WHERE
			((MTH.CompanyNo = @pCompanyNo))
			AND ((MTH.WorkCenterNo = @pWorkCenterNo))
			AND ((MTH.MachineNo = @pMachineNo))
			AND ((@pFromMeasureDateTime <= MTH.MeasureDateTime) AND (@pToMeasureDateTime >= MTH.MeasureDateTime))
	UNION ALL
	SELECT
			MTH.MeasureDateTime AS MeasureDateTime,
			'냉각OUT 설정온도' AS Gubun,
			MTH.MoldTemperatureSet4 AS Value
	FROM
			STB_MoldTemperatureHistory MTH WITH(NOLOCK)
	WHERE		
			((MTH.CompanyNo = @pCompanyNo))
			AND ((MTH.WorkCenterNo = @pWorkCenterNo))
			AND ((MTH.MachineNo = @pMachineNo))
			AND ((@pFromMeasureDateTime <= MTH.MeasureDateTime) AND (@pToMeasureDateTime >= MTH.MeasureDateTime))
		
	
	*/
END

