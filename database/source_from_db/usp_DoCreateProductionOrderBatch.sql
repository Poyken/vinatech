-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2023-02-27
-- Description : ProductionOrder 생성 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateProductionOrderBatch]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPlanYearMonth VARCHAR(7),
	@pPlanStartDate DATE = NULL,
	@pPlanEndDate DATE = NULL,	
	@pMaterialCode VARCHAR(50),
	@pBomVersion VARCHAR(20),
	@pPOQty NUMERIC(20,5),
	@pIgnoreMaxPlanQty BIT = 0,
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pPONos VARCHAR(MAX) = NULL OUTPUT 
AS
BEGIN
	Declare @PlanYearMonth VARCHAR(7) = @pPlanYearMonth
	       ,@PlanStartDate DATE = @pPlanStartDate
	       ,@PlanEndDate DATE = @pPlanEndDate
	       ,@MaterialCode VARCHAR(50)= @pMaterialCode
	       ,@BomVersion VARCHAR(20) = @pBomVersion
	       ,@POQty NUMERIC(20,5) = @pPOQty
	       ,@IgnoreMaxPlanQty BIT = @pIgnoreMaxPlanQty
	       ,@PONos VARCHAR(MAX) = @pPONos
		   ,@TargetMaterialCode VARCHAR(20) 
		   ,@OrderRate NUMERIC(20, 5)
		   ,@CompanyCode VARCHAR(20) = @pCompanyCode
		   ,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode


	
	Declare @TargetMaterialCodes TABLE (
		TargetMaterialCode VARCHAR(20)
	   ,OrderRate NUMERIC(20,5)
	);

	INSERT INTO @TargetMaterialCodes
		SELECT DISTINCT TargetMaterialCode, OrderRate
		  FROM (
				SELECT TargetMaterialCode, OrderRate
				  FROM STB_ProductionOrderBatchInfo
				 WHERE ParentMaterialCode =  @MaterialCode
				 UNION ALL
				SELECT @MaterialCode, 1.0
		) A
		GROUP BY TargetMaterialCode, OrderRate

	DECLARE cur CURSOR FOR

		SELECT TargetMaterialCode, OrderRate
		  FROM @TargetMaterialCodes

	OPEN cur

	FETCH NEXT FROM cur INTO @TargetMaterialCode, @OrderRate

	PRINT @TargetMaterialCode + ' / ' + CONVERT(VARCHAR, @OrderRate)

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @POQty = @POQty * @OrderRate

		PRINT CONVERT(VARCHAR, @POQty)

		exec usp_DoCreateProductionOrder @pProcessUserID
                                        ,@pProcessLanguage
										,@PlanYearMonth
										,@PlanStartDate
										,@PlanEndDate
										,@TargetMaterialCode
										,@BomVersion
										,@POQty
										,@IgnoreMaxPlanQty
										,@CompanyCode
										,@WorkCenterCode
										,@PONos
	
		FETCH NEXT FROM cur INTO @TargetMaterialCode, @OrderRate
	END

	CLOSE cur
	DEALLOCATE cur
END