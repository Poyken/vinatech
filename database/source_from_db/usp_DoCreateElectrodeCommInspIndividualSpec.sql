CREATE PROC usp_DoCreateElectrodeCommInspIndividualSpec
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pCompanyCode VARCHAR(20)
   ,@pWorkCenterCode VARCHAR(20)
AS
BEGIN
	Declare @CompanyCode VARCHAR(20) = @pCompanyCode
	       ,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode 
	       ,@IndividualSpecNo VARCHAR(20)
		   ,@ProdCode VARCHAR(20)
	       ,@LSL NUMERIC(10,3)
		   ,@USL NUMERIC(10,3)

	--기존정보 삭제
	DELETE
	  FROM STB_CommInspIndividualSpec
	 WHERE CompanyCode = @CompanyCode
	   AND WorkCenterCode = @WorkCenterCode
	   AND CommInspItemCode IN ('REQ_A01', 'REQ_A02', 'REQ_A03')

	-- 기준정보 커서
	DECLARE cur CURSOR FOR

	SELECT ProdCode 
	      ,ProdConThickStdMin
		  ,ProdConThickStdMax
	  FROM STB_ElectrodeCommon

	OPEN cur

	FETCH NEXT FROM cur INTO @ProdCode, @LSL, @USL

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CommInspIndividualSpec',@IndividualSpecNo OUTPUT

		INSERT INTO STB_CommInspIndividualSpec
			SELECT @IndividualSpecNo, 'REQ_A01', @CompanyCode, @WorkCenterCode, ''
			      ,'', '', '', @ProdCode, ''
				  ,'', NULL, @USL, @LSL, NULL
				  ,GETDATE(), 'eai', NULL, NULL, NULL
				  ,NULL

		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CommInspIndividualSpec',@IndividualSpecNo OUTPUT

		INSERT INTO STB_CommInspIndividualSpec
			SELECT @IndividualSpecNo, 'REQ_A02', @CompanyCode, @WorkCenterCode, ''
			      ,'', '', '', @ProdCode, ''
				  ,'', NULL, @USL, @LSL, NULL
				  ,GETDATE(), 'eai', NULL, NULL, NULL
				  ,NULL

		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CommInspIndividualSpec',@IndividualSpecNo OUTPUT

		INSERT INTO STB_CommInspIndividualSpec
			SELECT @IndividualSpecNo, 'REQ_A03', @CompanyCode, @WorkCenterCode, ''
			      ,'', '', '', @ProdCode, ''
				  ,'', NULL, @USL, @LSL, NULL
				  ,GETDATE(), 'eai', NULL, NULL, NULL
				  ,NULL
	
		FETCH NEXT FROM cur INTO @ProdCode, @LSL, @USL
	END

	CLOSE cur
	DEALLOCATE cur
END