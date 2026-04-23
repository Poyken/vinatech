CREATE PROC [dbo].[usp_DoAddCommonInspectionSpec]
	@pCompanyCode VARCHAR(20)
   ,@pWorkCenterCode VARCHAR(20)
   ,@pModelCode VARCHAR(20)
   ,@pCommInspTypeCode VARCHAR(20) 
AS
BEGIN
	Declare @ModelCode VARCHAR(20) = @pModelCode
	Declare @CommInspTypeCode VARCHAR(20) = @pCommInspTypeCode
	Declare @InspCodePrefix VARCHAR(10) = CASE WHEN @pCommInspTypeCode = 'ROUTE_QUALITY' THEN 'RQ_' ELSE '' END

	Declare @IndividualSpecNo VARCHAR(20)
	       ,@CommInspItemCode VARCHAR(20)
           ,@CompanyCode VARCHAR(20) = @pCompanyCode
           ,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode
           ,@LineCode VARCHAR(20)
           ,@RouteCode VARCHAR(20)
           ,@MachineCode VARCHAR(20)
           ,@MoldNumber VARCHAR(20)
           ,@MaterialCode VARCHAR(20)
           ,@CategoryName VARCHAR(20)
           ,@CommInspItemSpec VARCHAR(20)
           ,@CommInspItemDesc VARCHAR(20)
           ,@CommInspUpper VARCHAR(20)
           ,@CommInspLower VARCHAR(20)
           ,@ItemImageFileID VARCHAR(20)
           ,@CreateDateTime DATETIME
           ,@CreateUserID VARCHAR(20)
           ,@ChangeDateTime DATETIME
           ,@ChangeUserID VARCHAR(20)
           ,@FacilityRouteCode VARCHAR(20)
           ,@ProductGroupCode VARCHAR(20)

	-- 기존 품목별 개별스펙정보를 삭제한다.
	IF @CompanyCode = 'VNT' BEGIN
		IF @CommInspTypeCode = 'ROUTE_QUALITY' BEGIN
			DELETE
			  FROM STB_CommInspIndividualSpec
			 WHERE MaterialCode = @ModelCode
			   AND CompanyCode = @CompanyCode
			   AND WorkCenterCode = @WorkCenterCode
			   AND CommInspItemCode LIKE 'RQ_%'
			   --AND CommInspItemCode <> 'RQ_WB2' -- 하단 일괄처리에 'SM0072' 추가
		END ELSE BEGIN
			DELETE
			  FROM STB_CommInspIndividualSpec
			 WHERE MaterialCode = @ModelCode
			   AND CompanyCode = @CompanyCode
			   AND WorkCenterCode = @WorkCenterCode
			   AND CommInspItemCode NOT LIKE 'RQ_%'
			   --AND CommInspItemCode <> 'WB2' -- 하단 일괄처리에 'SM0072' 추가
		END
	END ELSE BEGIN -- VVT
		IF @CommInspTypeCode = 'ROUTE_QUALITY2' BEGIN
			DELETE
			  FROM STB_CommInspIndividualSpec
			 WHERE MaterialCode = @ModelCode
			   AND CompanyCode = @CompanyCode
			   AND WorkCenterCode = @WorkCenterCode
			   AND CommInspItemCode LIKE 'V_RQ_%'
		END ELSE BEGIN
			DELETE
			  FROM STB_CommInspIndividualSpec
			 WHERE MaterialCode = @ModelCode
			   AND CompanyCode = @CompanyCode
			   AND WorkCenterCode = @WorkCenterCode
			   AND CommInspItemCode NOT LIKE 'V_RQ_%'
		END
	END

	--베트남 법인이면, @InspCodePrefix를 다시 세팅한다.
	IF @CompanyCode = 'VVT' BEGIN
		SET @InspCodePrefix = CASE WHEN @pCommInspTypeCode = 'ROUTE_QUALITY2' THEN 'V_RQ_' ELSE 'V_' END
	END


	Declare cur CURSOR FOR
		SELECT CASE WHEN SpecItemCode IN ('SM0003', 'L0003') THEN @InspCodePrefix + 'THICKP'
					WHEN SpecItemCode IN ('SM0004', 'L0004') THEN @InspCodePrefix + 'THICKM'
					WHEN SpecItemCode IN ('SM0014', 'L0015') THEN @InspCodePrefix + 'tP'
					WHEN SpecItemCode IN ('SM0020', 'L0043') THEN @InspCodePrefix + 'D2'
					WHEN SpecItemCode IN ('SM0024') THEN @InspCodePrefix + 'T'
					WHEN SpecItemCode IN ('SM0025', 'L0024') THEN @InspCodePrefix + 'F'
					WHEN SpecItemCode IN ('SM0027', 'L0025') THEN @InspCodePrefix + 'LENGTHP'
					WHEN SpecItemCode IN ('SM0028', 'L0026') THEN @InspCodePrefix + 'LENGTHM'
					WHEN SpecItemCode IN ('SM0031') THEN @InspCodePrefix + 'RH'
					WHEN SpecItemCode IN ('SM0036', 'L0036') THEN @InspCodePrefix + 'WA'
					WHEN SpecItemCode IN ('SM0041', 'L0042') THEN @InspCodePrefix + 'ESR'
					WHEN SpecItemCode IN ('SM0045', 'L0046') THEN @InspCodePrefix + 'A'
					WHEN SpecItemCode IN ('SM0046', 'L0047') THEN @InspCodePrefix + 'B'
					WHEN SpecItemCode IN ('SM0047') THEN @InspCodePrefix + 'H1'
					WHEN SpecItemCode IN ('SM0048') THEN @InspCodePrefix + 'H2'
					WHEN SpecItemCode IN ('SM0049', 'L0048') THEN @InspCodePrefix + 'D1'
					WHEN SpecItemCode IN ('SM0050', 'L0049') THEN @InspCodePrefix + 'L1'
					WHEN SpecItemCode IN ('SM0051', 'L0050') THEN @InspCodePrefix + 'WB' 
					WHEN SpecItemCode IN ('SM0072') THEN @InspCodePrefix + 'WB2'ELSE NULL END
			   ,@CompanyCode, @WorkCenterCode, '', ''
			   ,'', '', ModelCode, '', SpecValue, NULL
			   ,UpperSpec, LowerSpec, NULL, GETDATE(), 'eai'
			   , NULL, NULL, NULL, NULL
		  FROM STB_ModelSpec
		 WHERE ModelCode = @ModelCode
		   AND SpecItemCode IN ('SM0003', 'SM0004', 'SM0014', 'SM0014', 'SM0020'
							   ,'SM0024', 'SM0025', 'SM0027', 'SM0028', 'SM0031'
							   ,'SM0036', 'SM0041', 'SM0045', 'SM0046', 'SM0047'
							   ,'SM0048', 'SM0049', 'SM0050', 'SM0051', 'L0003'
							   ,'L0004','L0015','L0015','L0043','L0024','L0025'
							   ,'L0026','L0036','L0042','L0046','L0047','L0048'
							   ,'L0049','L0050','SM0072')

	OPEN cur

	FETCH NEXT FROM cur INTO @CommInspItemCode, @CompanyCode, @WorkCenterCode, @LineCode, @RouteCode
                            ,@MachineCode, @MoldNumber, @MaterialCode, @CategoryName, @CommInspItemSpec
                            ,@CommInspItemDesc, @CommInspUpper, @CommInspLower, @ItemImageFileID, @CreateDateTime
                            ,@CreateUserID, @ChangeDateTime, @ChangeUserID, @FacilityRouteCode, @ProductGroupCode

	 WHILE @@FETCH_STATUS = 0 BEGIN
		-- 채번
		exec usp_DoCreateSerial 'STB_CommInspIndividualSpec', @IndividualSpecNo OUTPUT

		INSERT INTO STB_CommInspIndividualSpec (IndividualSpecNo, CommInspItemCode, CompanyCode, WorkCenterCode, LineCode
		                                       ,RouteCode, MachineCode, MoldNumber, MaterialCode, CategoryName
											   ,CommInspItemSpec, CommInspItemDesc, CommInspUpper, CommInspLower, ItemImageFileID
											   ,CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, FacilityRouteCode
											   ,ProductGroupCode)
              VALUES (@IndividualSpecNo, @CommInspItemCode, @CompanyCode, @WorkCenterCode, @LineCode
			         ,@RouteCode, @MachineCode, @MoldNumber, @MaterialCode, @CategoryName
					 ,@CommInspItemSpec, @CommInspItemDesc, @CommInspUpper, @CommInspLower, @ItemImageFileID
					 ,@CreateDateTime, @CreateUserID, @ChangeDateTime, @ChangeUserID, @FacilityRouteCode
					 , @ProductGroupCode)

		-- 점철의 경우 음극 값을 한번 더 넣어준다.
		IF @CommInspItemCode = 'RQ_tP' OR @CommInspItemCode = 'tP' OR @CommInspItemCode = 'V_RQ_tP' OR @CommInspItemCode = 'V_tp' BEGIN
			-- 채번
			exec usp_DoCreateSerial 'STB_CommInspIndividualSpec', @IndividualSpecNo OUTPUT

			INSERT INTO STB_CommInspIndividualSpec (IndividualSpecNo, CommInspItemCode, CompanyCode, WorkCenterCode, LineCode
		                                       ,RouteCode, MachineCode, MoldNumber, MaterialCode, CategoryName
											   ,CommInspItemSpec, CommInspItemDesc, CommInspUpper, CommInspLower, ItemImageFileID
											   ,CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, FacilityRouteCode
											   ,ProductGroupCode)
              VALUES (@IndividualSpecNo, CASE WHEN @CommInspItemCode = 'RQ_tP' THEN 'RQ_tM' 
											  WHEN @CommInspItemCode = 'V_RQ_tP' THEN 'V_RQ_tM' 
											  WHEN @CommInspItemCode = 'tP' THEN 'tM' 
											  WHEN @CommInspItemCode = 'V_tP' THEN 'V_tM' 
											  ELSE NULL END, @CompanyCode, @WorkCenterCode, @LineCode
			         ,@RouteCode, @MachineCode, @MoldNumber, @MaterialCode, @CategoryName
					 ,@CommInspItemSpec, @CommInspItemDesc, @CommInspUpper, @CommInspLower, @ItemImageFileID
					 ,@CreateDateTime, @CreateUserID, @ChangeDateTime, @ChangeUserID, @FacilityRouteCode
					 , @ProductGroupCode)
		END

		FETCH NEXT FROM cur INTO @CommInspItemCode, @CompanyCode, @WorkCenterCode, @LineCode, @RouteCode
                            ,@MachineCode, @MoldNumber, @MaterialCode, @CategoryName, @CommInspItemSpec
                            ,@CommInspItemDesc, @CommInspUpper, @CommInspLower, @ItemImageFileID, @CreateDateTime
                            ,@CreateUserID, @ChangeDateTime, @ChangeUserID, @FacilityRouteCode, @ProductGroupCode
	 END

	 CLOSE cur
	 DEALLOCATE cur

	 --SELECT @ModelCode, COUNT(*) FROM STB_CommInspIndividualSpec WHERE MaterialCode = @ModelCode
END