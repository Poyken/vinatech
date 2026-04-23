-- =============================================
-- Author: Mr.Tung
-- Create date: 2022-03-22
-- Browsable : true
-- usp_VVT_ElectrodeRollPressingVisualInspection_VVT_get '','','2022-03-20','2022-03-22'
-- =============================================
CREATE PROCEDURE [dbo].[usp_VVT_ElectrodeRollPressingVisualInspection_VVT_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DAteTime = NULL,
	@pToDate DAteTime = NULL--,
	--@pBarCode VARCHAR(50) = NULL
AS
BEGIN
	
	SET nocount on;

	declare @FromDate VARCHAR(20)= convert(varchar(10),@pFromDate,120) +  ' 08:00:00';
	declare @ToDate VARCHAR(20)= convert(varchar(10),dateadd(day,1,@pToDate),120) + ' 08:00:00';

	;WITH DefaultList AS (
		--SELECT 'FIRST' AS MeasureTimeCode, 1 AS Seq UNION ALL
		--SELECT 'FIRST' AS MeasureTimeCode, 2 AS Seq UNION ALL
		--SELECT 'FIRST' AS MeasureTimeCode, 3 AS Seq UNION ALL
		--SELECT 'MIDDLE' AS MeasureTimeCode, 1 AS Seq UNION ALL
		--SELECT 'MIDDLE' AS MeasureTimeCode, 2 AS Seq UNION ALL
		--SELECT 'MIDDLE' AS MeasureTimeCode, 3 AS Seq UNION ALL
		--SELECT 'LAST' AS MeasureTimeCode, 1 AS Seq UNION ALL
		--SELECT 'LAST' AS MeasureTimeCode, 2 AS Seq UNION ALL
		--SELECT 'LAST' AS MeasureTimeCode, 3 AS Seq UNION ALL
		SELECT 'AUTO' AS MeasureTimeCode, 0 AS Seq  --add by Mr.Tung on 31-July-2021
	),
	lastdata as (
		SELECT   ISNULL(ERPVII.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ISNULL(ERPVII.MeasureTimeCode, DL.MeasureTimeCode) AS MeasureTimeCode
			,BC.Description AS MeasureTimeCodeName
			,ISNULL(ERPVII.Seq, DL.Seq) AS Seq
			,case when ERPVII.MeasureTimeCode like 'AUTO%' then isnull(ERPVII.LeftValue,3)-3 else ERPVII.LeftValue end  as LeftValue
			,case when ERPVII.MeasureTimeCode like 'AUTO%' then isnull(ERPVII.MiddleValue,3)-3 else ERPVII.MiddleValue end  as MiddleValue
			,case when ERPVII.MeasureTimeCode like 'AUTO%' then isnull(ERPVII.RightValue,3)-3 else ERPVII.RightValue end  as RightValue
			,ERPVII.CreateDateTime
			,ERPVII.CreateUserID
			--,ERPVII.ChangeDateTime
			--,ERPVII.ChangeUserID
						--,CONVERT(VARCHAR(10), ERPI.WorkDate, 121) as WorkDate
			, SI.MaterialCode                
			, MM2.MaterialName 

			, IsNull(EC.Batches, 0) as Batches

			-- 2020.10.20 추가
			,EC.OneSide     
			,EC.BothSide  
			,EC.ProdConThickStdMin 
			,EC.ProdConThickStdMax 
			,emi.ViscosityValue
			,emi.ViscosityResult
			,veci.TocDo_Coating
			,veci.ViscosityValue as "Do_Nhot_Rollpress"
			,veci.ViscosityResult as "KQ_Do_Nhot_Rollpress"
	  FROM STB_SetInfo SI with(nolock) 
	  left outer join STB_Viscosity_ElectrodCoatingInfo_VVT veci with(nolock) on si.Barcode=veci.ElectrodeLotNumber
	  left outer join STB_ElectrodeMixInfo emi with(nolock) on si.Barcode = emi.ElectrodeLotNumber
	    LEFT OUTER JOIN STB_ElectrodeCommon EC       with(nolock)   ON EC.ProdCode = SI.MaterialCode 
		  LEFT OUTER JOIN STB_MaterialMaster MM2	 with(nolock) 		ON SI.MaterialCode = MM2.MaterialCode
		  	  -- LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI	  with(nolock)  ON SI.Barcode = ERPI.ElectrodeLotNumber  
	  LEFT OUTER JOIN DefaultList DL	 with(nolock)     ON 1 = 1
	  OUTER apply (select  distinct ElectrodeLotNumber,MeasureTimeCode,LeftValue,MiddleValue,RightValue,CreateUserID,
					  max(Seq) as Seq,
					  max(CreateDateTime) as CreateDateTime,
					  max(ChangeDateTime) as ChangeDateTime,
					  max(ChangeUserID) as ChangeUserID
						from STB_ElectrodeRollPressingVisualInspectionInfo ERPVII with(nolock) 	   where SI.Barcode = ERPVII.ElectrodeLotNumber	and (/*MeasureTimeCode<>'AUTO' or*/ MeasureTimeCode='AUTO' and MeasureTimeCode not like '% %' and CreateUserID='soft_vvt')
									AND  (
											(DL.MeasureTimeCode = ERPVII.MeasureTimeCode	   AND DL.Seq = ERPVII.Seq) 
											or (DL.MeasureTimeCode = ERPVII.MeasureTimeCode and DL.Seq = 0) --add by Mr.Tung on 31-July-2021
										)
										group by ElectrodeLotNumber,MeasureTimeCode,LeftValue,MiddleValue,RightValue,CreateUserID
					) ERPVII
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	 with(nolock)     
	  
	    ON BC.ItemCode = DL.MeasureTimeCode + CONVERT(CHAR(1), DL.seq)
	   AND BC.CodeGroup = 'MeasureTime'
	 WHERE ERPVII.CreateDateTime >= @FromDate and ERPVII.CreateDateTime <= @ToDate
	 ),
	 avgdata as (
	 select   ElectrodeLotNumber,MeasureTimeCode,avg(LeftValue) as AVGLeftValue,avg(MiddleValue) as AVGMiddleValue,avg(RightValue) as AVGRightValue 
	 from lastdata
	 group by ElectrodeLotNumber,MeasureTimeCode
	 )
	 select * from lastdata
	 join avgdata on lastdata.ElectrodeLotNumber = avgdata.ElectrodeLotNumber and lastdata.MeasureTimeCode=avgdata.MeasureTimeCode
	 --ORDER BY ERPVII.ElectrodeLotNumber,
		--		CASE WHEN DL.MeasureTimeCode = 'FIRST' THEN 1
	 --              WHEN DL.MeasureTimeCode = 'MIDDLE' THEN 2
		--		   WHEN DL.MeasureTimeCode = 'LAST' THEN 3
		--		   ELSE 4 END
		--     ,DL.Seq
			 --,ERPVII.Seq  --add by Mr.Tung on 31-July-2021
			 	
END
