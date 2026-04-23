-- =============================================
-- Author:	Jackaroe(yjyu@vina.co.kr)
-- Create date: 2025-10-18
-- Browsable : true
-- Group : 생산관리
-- Description:	전극 L/W 측정 정보를 조회합니다.
-- Modified:
-- =============================================
CREATE PROC usp_ElectrodeLWMeasureHist_get
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pElectrodeLotNumber VARCHAR(20)
AS
BEGIN
	Declare @ElectrodeLotNumber VARCHAR(20) = @pElectrodeLotNumber

	;WITH DummyCTE AS (
		SELECT @ElectrodeLotNumber AS ElectrodeLotNumber
		     , 'O' AS SideCode
			 , 'FIRST' AS MeasureTimeCode
			 , 1 AS Seq
			 , NULL AS MeasureValue1
			 , NULL AS MeasureValue2
			 , NULL AS MeasureValue3
			 , NULL AS MeasureValue4
			 , NULL AS MeasureValue5
			 , GETDATE() AS CreateDateTime
			 , '' AS CreateUserID
			 , NULL AS ChangeDateTime
			 , NULL AS ChangeUserID
		UNION ALL
		SELECT @ElectrodeLotNumber AS ElectrodeLotNumber
		     , 'B' AS SideCode
			 , 'LAST' AS MeasureTimeCode
			 , 2 AS Seq
			 , NULL AS MeasureValue1
			 , NULL AS MeasureValue2
			 , NULL AS MeasureValue3
			 , NULL AS MeasureValue4
			 , NULL AS MeasureValue5
			 , GETDATE() AS CreateDateTime
			 , '' AS CreateUserID
			 , NULL AS ChangeDateTime
			 , NULL AS ChangeUserID
    ) 
	SELECT DC.ElectrodeLotNumber
	      ,DC.SideCode
		  ,DC.MeasureTimeCode
		  ,DC.Seq
		  ,DC.ElectrodeLotNumber AS OldElectrodeLotNumber
	      ,DC.SideCode AS OldSideCode
		  ,DC.MeasureTimeCode AS OldMeasureTimeCode
		  ,DC.Seq AS OldSeq
		  ,ELWMH.MeasureValue1
		  ,ELWMH.MeasureValue2
		  ,ELWMH.MeasureValue3
		  ,ELWMH.MeasureValue4
		  ,ELWMH.MeasureValue5
		  ,ELWMH.CreateDateTime
		  ,ELWMH.CreateUserID
		  ,ELWMH.ChangeDateTime
		  ,ELWMH.ChangeUserID
	  FROM DummyCTE DC
	  LEFT OUTER JOIN STB_ElectrodeLWMeasureHist ELWMH
	    ON DC.ElectrodeLotNumber = ELWMH.ElectrodeLotNumber
	   AND DC.SideCode = ELWMH.SideCode
	   AND DC.MeasureTimeCode = ELWMH.MeasureTimeCode
	   AND DC.Seq = ELWMH.Seq
	   AND ELWMH.ElectrodeLotNumber = @ElectrodeLotNumber
END