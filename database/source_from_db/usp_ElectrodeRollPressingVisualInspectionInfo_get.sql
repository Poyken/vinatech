-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리 > 실적등록> [B550] 전극측정결과 > 롤프레싱 버튼 > 전극롤프레싱정보
-- Description:	전극롤프레싱외관검사정보
-- Modified: Mr.Tung on 31-July-2021
-- usp_ElectrodeRollPressingVisualInspectionInfo_get '','','VJNS2020001E01'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeRollPressingVisualInspectionInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	SET @ElectrodeLotNumber = @pElectrodeLotNumber

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
			,case when ERPVII.MeasureTimeCode like 'AUTO%' then isnull(ERPVII.LeftValue,3)-3 else ERPVII.LeftValue end  as LeftValue
			,case when ERPVII.MeasureTimeCode like 'AUTO%' then isnull(ERPVII.MiddleValue,3)-3 else ERPVII.MiddleValue end  as MiddleValue
			,case when ERPVII.MeasureTimeCode like 'AUTO%' then isnull(ERPVII.RightValue,3)-3 else ERPVII.RightValue end  as RightValue
			,ERPVII.CreateDateTime
			,ERPVII.CreateUserID
			,ERPVII.ChangeDateTime
			,ERPVII.ChangeUserID
			,EC.OneSideLowerTolerance
			,EC.OneSideUpperTolerance
			,EC.BothSideLowerTolerance
			,EC.BothSideUpperTolerance
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN DefaultList DL	    ON 1 = 1
	  OUTER apply (select  distinct ElectrodeLotNumber,MeasureTimeCode,LeftValue,MiddleValue,RightValue,CreateUserID,
					  max(Seq) as Seq,
					  max(CreateDateTime) as CreateDateTime,
					  (datepart(minute,CreateDateTime))/6 as maxminute,
					  max(ChangeDateTime) as ChangeDateTime,
					  max(ChangeUserID) as ChangeUserID
						from STB_ElectrodeRollPressingVisualInspectionInfo ERPVII	   where SI.Barcode = ERPVII.ElectrodeLotNumber	and (MeasureTimeCode<>'AUTO' or MeasureTimeCode='AUTO' and MeasureTimeCode not like '% %' and CreateUserID='soft_vvt')
									AND  (
											(DL.MeasureTimeCode = ERPVII.MeasureTimeCode	   AND DL.Seq = ERPVII.Seq) 
											or (DL.MeasureTimeCode = ERPVII.MeasureTimeCode and DL.Seq = 0) --add by Mr.Tung on 31-July-2021
										)
										group by ElectrodeLotNumber,MeasureTimeCode,LeftValue,MiddleValue,RightValue,CreateUserID,(datepart(minute,CreateDateTime))/6
					) ERPVII
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	    
	    ON BC.ItemCode = DL.MeasureTimeCode + CONVERT(CHAR(1), DL.seq)
	   AND BC.CodeGroup = 'MeasureTime'
	  LEFT OUTER JOIN STB_ElectrodeCommon EC ON EC.ProdCode = SI.MaterialCode
	 WHERE SI.Barcode = @ElectrodeLotNumber 
	 
	 -- if  MeasureTimeCode=AUTO then only show value > 0 , Mr.Tung modify because PLC of automatic team send 0 value
	 and ( DL.MeasureTimeCode not like 'AUTO%' or  isnull(ERPVII.LeftValue,0)>0 or	 isnull(ERPVII.MiddleValue,0)>0 or	 isnull(ERPVII.RightValue,0)>0 )
	 -- if  MeasureTimeCode=AUTO then only show value > 0

	 ORDER BY CASE WHEN DL.MeasureTimeCode = 'FIRST' THEN 1
	               WHEN DL.MeasureTimeCode = 'MIDDLE' THEN 2
				   WHEN DL.MeasureTimeCode = 'LAST' THEN 3
				   ELSE 4 END
		     ,DL.Seq
			 ,ERPVII.Seq  --add by Mr.Tung on 31-July-2021
			 	
END
