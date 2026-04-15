CREATE PROC [dbo].[usp_DoCreateTaktTimeForRoute]
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pCompanyCode VARCHAR(20)
   ,@pWorkCenterCode VARCHAR(20)
   ,@pBarcode VARCHAR(20)
   ,@pRouteCode VARCHAR(20) = NULL
   ,@pProdQty BIGINT = 0
AS
BEGIN
	Declare @CompanyCode VARCHAR(20) = @pCompanyCode
	       ,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode
		   ,@Barcode VARCHAR(20) = @pBarcode
		   ,@RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = '' THEN 'StartRoute' ELSE @pRouteCode END
		   ,@ProdQty BIGINT = @pProdQty
		   ,@BefRouteCode VARCHAR(20)
		   ,@TotActualTaktTime NUMERIC(20,5)
		   ,@RouteIndex INT
		   ,@BefProdDateTime DATETIME
		   ,@AftProdDateTime DATETIME

	IF @RouteCode = 'StartRoute' BEGIN
		INSERT INTO STB_TaktTimeForRoute (
			CompanyCode
           ,WorkCenterCode
           ,Barcode
           ,RouteCode
           ,ProdQty
           ,ProdDateTime
           ,StandardTaktTime
           ,TotActualTaktTime
           ,Remark
           ,CreateDateTime
           ,CreateUserID
           ,ChangeDateTime
           ,ChangeUserID
		) VALUES (
			@CompanyCode
           ,@WorkCenterCode
           ,@Barcode
           ,@RouteCode
           ,@ProdQty
		   ,GETDATE()
		   ,0
		   ,0
		   ,NULL
		   ,GETDATE()
		   ,@pProcessUserID
		   ,NULL
		   ,NULL
		)
	END ELSE BEGIN
		-- Get Previous RouteCode
		SELECT @RouteIndex = RouteIndex 
		  FROM STB_ProductionOrderRouting 
		 WHERE RouteCode = @RouteCode 
		   AND PONo = (SELECT PONo 
		                FROM STB_SetInfo 
					   WHERE Barcode = @Barcode)

		IF @RouteIndex = 1 BEGIN
			-- 투입공정이면, 작업 시작시간에서 실제 택타임을 구한다.
			SELECT @BefProdDateTime = ProdDateTime 
			  FROM STB_TaktTimeForRoute 
			 WHERE CompanyCode = @CompanyCode
			   AND WorkCenterCode = @WorkCenterCode
			   AND Barcode = @Barcode
               AND RouteCode = 'StartRoute'

			-- 해당 Lot의 시작 시간을 입력하지 않았으면(StartRoute가 없으면) 현재 시간에서 50000 초를 차감하여 계산한다.
			IF @BefProdDateTime IS NULL BEGIN
				SELECT @BefProdDateTime = DATEADD(second, -5000, GETDATE())
			END

			SELECT @TotActualTaktTime = DATEDIFF(second, @BefProdDateTime, GETDATE())
		END ELSE BEGIN
			SELECT @BefRouteCode = RouteCode 
			  FROM STB_ProductionOrderRouting 
			 WHERE RouteIndex = @RouteIndex - 1
			   AND PONo = (SELECT PONo 
							 FROM STB_SetInfo 
						    WHERE Barcode = @Barcode)

			SELECT @BefProdDateTime = ProdDateTime 
			  FROM STB_TaktTimeForRoute 
			 WHERE CompanyCode = @CompanyCode
			   AND WorkCenterCode = @WorkCenterCode
			   AND Barcode = @Barcode
               AND RouteCode = @BefRouteCode

			SELECT @TotActualTaktTime = DATEDIFF(second, @BefProdDateTime, GETDATE())

			PRINT '@BefRouteCode ::::: ' + @BefRouteCode
			PRINT '@TotActualTaktTime ::::: ' + CONVERT(VARCHAR(50), @TotActualTaktTime)
		END

		IF EXISTS (SELECT 1 
		             FROM STB_TaktTimeForRoute 
					WHERE CompanyCode = @CompanyCode
					  AND WorkCenterCode = @WorkCenterCode
					  AND Barcode = @Barcode
                      AND RouteCode = @RouteCode
				) BEGIN
			-- UPDATE
			UPDATE STB_TaktTimeForRoute
			   SET  ProdQty = @ProdQty
				   ,ProdDateTime = GETDATE()
				   ,TotActualTaktTime = @TotActualTaktTime
				   ,ChangeDateTime = GETDATE()
				   ,ChangeUserID = @pProcessUserID
			 WHERE CompanyCode = @CompanyCode
			   AND WorkCenterCode = @WorkCenterCode
			   AND Barcode = @Barcode
               AND RouteCode = @RouteCode
		END ELSE BEGIN
			-- INSERT
			INSERT INTO STB_TaktTimeForRoute (
				CompanyCode
			   ,WorkCenterCode
			   ,Barcode
			   ,RouteCode
			   ,ProdQty
			   ,ProdDateTime
			   ,StandardTaktTime
			   ,TotActualTaktTime
			   ,CreateDateTime
			   ,CreateUserID
			   ,ChangeDateTime
			   ,ChangeUserID
			) VALUES (
				@CompanyCode
			   ,@WorkCenterCode
			   ,@Barcode
			   ,@RouteCode
			   ,@ProdQty
			   ,GETDATE()
			   ,(SELECT StandardTaktTime 
			       FROM STB_RouteInfo 
				  WHERE CompanyCode = @CompanyCode 
				    AND WorkCenterCode = @WorkCenterCode 
					AND RouteCode = @RouteCode)
			   ,@TotActualTaktTime
			   ,GETDATE()
			   ,@pProcessUserID
			   ,NULL
			   ,NULL
			)
		END
	END
END