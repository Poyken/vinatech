-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리
-- Description:	전극코팅외관검사정보
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeCoatingVisualInspectionInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	SET @ElectrodeLotNumber = @pElectrodeLotNumber

	--declare @company varchar(10)='';
	--select @company= companycode
	--from STB_UserInfo
	--where UserID=@pProcessUserID



	--if(@company='VVT') begin   -- Mr.tung on 2022-sep-15 , for Hela Audit
	
	--;WITH DefaultList AS (
	--	SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	--SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	--UNION ALL
	--	--SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	--UNION ALL
	--	--SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	--UNION ALL
	--	SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	--SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	--UNION ALL
	--	--SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	--UNION ALL
	--	--SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	--UNION ALL
	--	SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--)
	--SELECT   ISNULL(ECVII.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
	--		,ISNULL(ECVII.SideCode, DL.SideCode) AS SideCode
	--		, case when BC2.Description='단면' then BC2.Description+N' (1 mặt)'
	--				when BC2.Description='양면' then BC2.Description+N' (2 mặt)' 
	--				else BC2.Description end AS SideCodeName 

	--		,ISNULL(ECVII.MeasureTimeCode, DL.MeasureTimeCode) AS MeasureTimeCode
	--		,BC.Description AS MeasureTimeCodeName
	--		,ISNULL(ECVII.Seq, DL.Seq) AS Seq
	--		,ECVII.LeftValue
	--		,ECVII.MiddleValue
	--		,ECVII.RightValue
	--		,ECVII.CreateDateTime
	--		,ECVII.CreateUserID
	--		,ECVII.ChangeDateTime
	--		,ECVII.ChangeUserID			
	--  FROM STB_SetInfo SI
	--  LEFT OUTER JOIN DefaultList DL	    ON 1=1
	--  LEFT OUTER JOIN STB_ElectrodeCoatingVisualInspectionInfo ECVII	    ON SI.Barcode = ECVII.ElectrodeLotNumber	   AND DL.SideCode = ECVII.SideCode	   AND DL.MeasureTimeCode = ECVII.MeasureTimeCode	   AND DL.Seq = ECVII.Seq
	--  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC    	            ON BC.CodeGroup = 'MeasureTime'    	           AND ISNULL(ECVII.MeasureTimeCode, DL.MeasureTimeCode) = BC.ItemCode
	--  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2  	            ON ISNULL(ECVII.SideCode, DL.SideCode) = BC2.ItemCode	   AND BC2.CodeGroup = 'SideCode'
	-- WHERE SI.Barcode = @ElectrodeLotNumber
	-- ORDER BY CASE WHEN DL.SideCode = 'O' THEN 1
	--                      WHEN DL.SideCode = 'B' THEN 2	   ELSE DL.SideCode END
	--	     ,CASE WHEN DL.MeasureTimeCode = 'FIRST' THEN 1
	--		       --WHEN DL.MeasureTimeCode = 'MIDDLE' THEN 2
	--			   WHEN DL.MeasureTimeCode = 'LAST' THEN 3	   ELSE 4 END
	--	     ,DL.Seq
	--	return;
	--end




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
			, case when BC2.Description='단면' then BC2.Description+N' (1 mặt)'
					when BC2.Description='양면' then BC2.Description+N' (2 mặt)' 
					else BC2.Description end AS SideCodeName 

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
			,EC.OneSideLowerTolerance
			,EC.OneSideUpperTolerance
			,EC.BothSideLowerTolerance
			,EC.BothSideUpperTolerance
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN DefaultList DL	    ON 1=1
	  LEFT OUTER JOIN STB_ElectrodeCoatingVisualInspectionInfo ECVII	    ON SI.Barcode = ECVII.ElectrodeLotNumber	   AND DL.SideCode = ECVII.SideCode	   AND DL.MeasureTimeCode = ECVII.MeasureTimeCode	   AND DL.Seq = ECVII.Seq
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC    	            ON BC.CodeGroup = 'MeasureTime'    	           AND ISNULL(ECVII.MeasureTimeCode, DL.MeasureTimeCode) = BC.ItemCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2  	            ON ISNULL(ECVII.SideCode, DL.SideCode) = BC2.ItemCode	   AND BC2.CodeGroup = 'SideCode'
	  LEFT OUTER JOIN STB_ElectrodeCommon EC ON EC.ProdCode = SI.MaterialCode
	 WHERE SI.Barcode = @ElectrodeLotNumber
	 ORDER BY CASE WHEN DL.SideCode = 'O' THEN 1
	                      WHEN DL.SideCode = 'B' THEN 2	   ELSE DL.SideCode END
		     ,CASE WHEN DL.MeasureTimeCode = 'FIRST' THEN 1
			       WHEN DL.MeasureTimeCode = 'MIDDLE' THEN 2
				   WHEN DL.MeasureTimeCode = 'LAST' THEN 3	   ELSE 4 END
		     ,DL.Seq
END
