-- =============================================
-- Author: Mr.Tung(nguyentung@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- ============================================= usp_Vietnam_ElectrodeRollPressVisualInspect_PowerBi_get '','','2022-01-11','2022-01-12'
CREATE PROCEDURE [dbo].[usp_Vietnam_ElectrodeRollPressVisualInspect_PowerBi_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATETIME,
	@pToDate DATETIME
AS
BEGIN
	
	declare @FromDate varchar(20)= (convert(varchar(10),convert(varchar(10),@pFromDate,120)) + ' 10:00:00')
	declare @ToDate varchar(20) = (convert(varchar(10),convert(varchar(10),Dateadd(DAY,1,@pToDate),120)) + ' 10:00:00')

	;WITH DefaultList AS (
		SELECT 'FIRST' AS MeasureTimeCode, 1 AS Seq UNION ALL
		SELECT 'FIRST' AS MeasureTimeCode, 2 AS Seq UNION ALL
		SELECT 'FIRST' AS MeasureTimeCode, 3 AS Seq UNION ALL
		SELECT 'MIDDLE' AS MeasureTimeCode, 1 AS Seq UNION ALL
		SELECT 'MIDDLE' AS MeasureTimeCode, 2 AS Seq UNION ALL
		SELECT 'MIDDLE' AS MeasureTimeCode, 3 AS Seq UNION ALL
		SELECT 'LAST' AS MeasureTimeCode, 1 AS Seq UNION ALL
		SELECT 'LAST' AS MeasureTimeCode, 2 AS Seq UNION ALL
		SELECT 'LAST' AS MeasureTimeCode, 3 AS Seq UNION ALL
		SELECT 'AUTO' AS MeasureTimeCode, 0 AS Seq  --add by Mr.Tung on 31-July-2021
	)
	SELECT   ISNULL(ERPVII.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ISNULL(ERPVII.MeasureTimeCode, DL.MeasureTimeCode) AS MeasureTimeCode
			,BC.Description AS MeasureTimeCodeName
			,ISNULL(ERPVII.Seq, DL.Seq) AS Seq
			,ERPVII.LeftValue
			,ERPVII.MiddleValue
			,ERPVII.RightValue
			,ERPVII.CreateDateTime
			,ERPVII.CreateUserID
			,ERPVII.ChangeDateTime
			,ERPVII.ChangeUserID
			,si.MaterialCode
			,mm.MaterialName
			,eci.MachineCode
			,mm2.MachineName
	  FROM STB_SetInfo SI with(nolock) 
	  LEFT OUTER JOIN DefaultList DL	    ON 1 = 1
	  left outer join STB_MaterialMaster mm  with(nolock) on si.MaterialCode=mm.MaterialCode
	  OUTER apply (select  distinct ElectrodeLotNumber,MeasureTimeCode,LeftValue,MiddleValue,RightValue,CreateUserID,
					  max(Seq) as Seq,
					  max(CreateDateTime) as CreateDateTime,
					  max(ChangeDateTime) as ChangeDateTime,
					  max(ChangeUserID) as ChangeUserID
						from STB_ElectrodeRollPressingVisualInspectionInfo ERPVII	 with(nolock)    where SI.Barcode = ERPVII.ElectrodeLotNumber	and (MeasureTimeCode<>'AUTO' or MeasureTimeCode='AUTO' and CreateUserID='soft_vvt')
									AND  (
											(DL.MeasureTimeCode = ERPVII.MeasureTimeCode	   AND DL.Seq = ERPVII.Seq) 
											or (DL.MeasureTimeCode = ERPVII.MeasureTimeCode and DL.Seq = 0) --add by Mr.Tung on 31-July-2021
										)
										group by ElectrodeLotNumber,MeasureTimeCode,LeftValue,MiddleValue,RightValue,CreateUserID
					) ERPVII
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	 with(nolock)     ON BC.ItemCode = DL.MeasureTimeCode
	  LEFT OUTER JOIN STB_ElectrodeCoatingInfo eci  with(nolock)  on SI.Barcode = eci.ElectrodeLotNumber
	  LEFT OUTER JOIN STB_MachineMaster mm2  with(nolock)  on mm2.MachineCode = eci.MachineCode
	 WHERE SI.Barcode in (
					select distinct ElectrodeLotNumber 
					from STB_ElectrodeRollPressingVisualInspectionInfo with(nolock) 
					where CreateDateTime between @FromDate and @ToDate
					)
	 ORDER BY ElectrodeLotNumber,CASE WHEN DL.MeasureTimeCode = 'FIRST' THEN 1
	               WHEN DL.MeasureTimeCode = 'MIDDLE' THEN 2
				   WHEN DL.MeasureTimeCode = 'LAST' THEN 3
				   ELSE 4 END
		     ,DL.Seq
			 ,ERPVII.Seq  --add by Mr.Tung on 31-July-2021

END







--usp_Vietnam_ElectrodeRollPressVisualInspect_PowerBi_get '','','2022-01-11','2022-01-12'