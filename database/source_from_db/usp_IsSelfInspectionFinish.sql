CREATE PROC [dbo].[usp_IsSelfInspectionFinish]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pCommInspTypeCode VARCHAR(20) = NULL,
				@pRouteCode VARCHAR(20) = NULL,
				@pBarcode VARCHAR(20) = NULL,
				@pIsSelfInspectionFinish BIT = NULL OUTPUT

AS 
BEGIN
	Declare @CommInspTypeCode VARCHAR(20) = CASE WHEN @pCommInspTypeCode IS NULL THEN 'ROUTE_TEST' ELSE @pCommInspTypeCode END
		   ,@Barcode VARCHAR(20) = @pBarcode
		   ,@RouteCode VARCHAR(20) = @pRouteCode
		   ,@SizeCode VARCHAR(20)
		   ,@SizeW NUMERIC(20,4)
		   ,@ConditionString VARCHAR(MAX)

	SELECT @SizeCode = CASE WHEN MBISizeW NOT IN (22, 25, 27, 30, 35) THEN '%SML%' ELSE '%L%' END
	         ,@SizeW = MBISizeW
	  FROM STB_ModelBasicInfo
	 WHERE ModelCode IN (
						SELECT MaterialCode 
						  FROM STB_SetInfo
						 WHERE Barcode = @Barcode
						)

	IF @SizeW = 35 
	
	BEGIN
		SET @ConditionString = 'T,RH,RV,A,H1,H2,B'
	END ELSE IF @SizeW = 22 BEGIN
		SET @ConditionString = 'T,RH,RV,H1,H2'
	END ELSE BEGIN
		SET @ConditionString = NULL
	END

	     SELECT @pIsSelfInspectionFinish = CONVERT(BIT, CASE WHEN SUM(CASE WHEN CIDI.ItemTargetQty > CIDI.ItemQty THEN 1 ELSE 0 END) > 0 THEN 0 ELSE 1 END)
		  FROM                       STB_CommInspDocItem CIDI
				  LEFT OUTER JOIN STB_CommInspItem     CII	ON CIDI.CommInspItemCode = CII.CommInspItemCode
		 WHERE CommInspDocNo IN (
													SELECT CommInspDocNo
													  FROM STB_CommInspDocHistory CIDH
															  LEFT OUTER JOIN STB_SetInfo SI
														ON CIDH.ProdNo = SI.ControlNo
													 WHERE CIDH.CommInspTypeCode = @CommInspTypeCode
													   AND SI.Barcode = @Barcode
										   )
		AND CII.CommInspItemGroup3 LIKE @SizeCode
		AND CII.CommInspItemGroup1 = @RouteCode
		AND (@ConditionString IS NULL OR CII.CommInspItemCode NOT IN (SELECT Item FROM dbo.fnSplitToTable(',', @ConditionString)))

	-- STB_CommInspDocHistory 자체가 생성이 안된 경우 0 처리
	IF @pIsSelfInspectionFinish IS NULL 
		BEGIN
			SET @pIsSelfInspectionFinish = 0
		END
END