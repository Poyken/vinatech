
-- =============================================
-- Author : 
-- Group : 
-- Browsable : true
-- Create date : 
-- Description : 
-- Modified :

--exec usp_DoCreateProductionOrder_ReDroping ''
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateProductionOrder_ReDroping]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPlanYearMonth VARCHAR(7),
	@pPlanStartDate DATE = NULL,
	@pPlanEndDate DATE = NULL,	
	@pMaterialCode VARCHAR(50),
	@pBomVersion VARCHAR(20),
	@pPOQty NUMERIC(20,5),
	@pIgnoreMaxPlanQty BIT = 0,
	@pLotNo VARCHAR(50), 
	@pDefectSummaryNo VARCHAR(20)=null,
	@pPONos VARCHAR(MAX) = NULL OUTPUT   -- 생성된 PO 번호를 ','  구분자로 묶어서 RETURN
	--@pCompanyCode VARCHAR(20)                      -- 2020.10.07 추가
	
AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@MaterialCode VARCHAR(50) = @pMaterialCode,
			@PlanYearMonth VARCHAR(7) = @pPlanYearMonth,
			@PlanStartDate DATE = @pPlanStartDate,
			@PlanEndDate DATE = @pPlanEndDate,
			@BomVersion VARCHAR(20) = @pBomVersion,
			@POQty NUMERIC(20,5) = @pPOQty,
			@PONo VARCHAR(20),
			@CompanyCode VARCHAR(20),
			@WorkCenterCode VARCHAR(20),
			@POType VARCHAR(20),			
			@MaxProdPlanQty NUMERIC(20,5),
			@Remain NUMERIC(20,5) = @pPOQty,
			@StartDate DATE,
			@ErrorMessage NVARCHAR(MAX),
			@BasicRoutingCode VARCHAR(20),
			@LotNo VARCHAR(50)= @pLotNo,
			@DefectSummaryNo VARCHAR(20) =@pDefectSummaryNo

	SET @pPONos = ''




	IF ISNULL(@MaterialCode,'') = '' OR ISNULL(@POQty,0) <= 0
		RETURN

	IF ISNULL(@PlanYearMonth,'') <> '' or ISNULL(@PlanYearMonth,'') is not null
	
			BEGIN
				SET @StartDate  = @PlanYearMonth + '-01'
				SET @PlanStartDate = DATEADD(DD, -1 * (DATEPART(DD, @StartDate) - 1), @StartDate)                            --  SELECT DATEADD(DD, -1 * (DATEPART(DD, GETDATE()) - 1), GETDATE())   
				SET @PlanEndDate = DATEADD(DD, -1, DATEADD(MM,1,@PlanStartDate))                                             --  SELECT DATEADD(DD, -1, DATEADD(MM,1,GETDATE())) 
	END

	SELECT
			@POType = MT.BasicMaterialType,
			@MaxProdPlanQty = CASE WHEN ISNULL(MM.MaxProdPlanQty,0) = 0 THEN 999999999 ELSE MM.MaxProdPlanQty  END
	FROM
			STB_MaterialMaster MM
			INNER JOIN STB_MaterialType MT				ON	MT.MaterialTypeCode = MM.MaterialTypeCode
	WHERE
			MM.MaterialCode = @MaterialCode

	IF @pIgnoreMaxPlanQty = 1
		SET @MaxProdPlanQty = POWER(2,30)-1
	
	SELECT
			@CompanyCode = CompanyCode,
			@WorkCenterCode = WorkCenterCode
	FROM
			STB_UserInfo 
	WHERE
			UserID = @ProcessUserID

	IF ISNULL(@CompanyCode, '') = ''
		
	BEGIN
		EXEC usp_RaiseLocalizedError	@ProcessLanguage, '사용자의 사업장 정보가 존재하지 않습니다.'
		RETURN
	END
			
	DECLARE @PORoutingType VARCHAR(50) = dbo.fnGetProcessRule('PROD_POROUTING_TYPE','MODEL')

	IF @PORoutingType = 'BOM' 
	
	BEGIN
			SELECT
					@BasicRoutingCode = BH.BasicRoutingCode
			FROM
					STB_BomHeader BH
			WHERE
					BH.MaterialCode = @MaterialCode AND
					BH.BomVersion = @BomVersion
	END ELSE BEGIN
			SELECT
					@BasicRoutingCode = MM.BasicRoutingCode
			FROM
					STB_MaterialMaster MM
			WHERE
					MM.MaterialCode = @MaterialCode
	END


	--Mr.Tung addition V-23, V-26 Stage for Vietnam Production Routing as Ms.Phuong email 
	select @companycode = companycode  
	from STB_UserInfo 
	where UserID=@ProcessUserID 
	if(@companycode='VVT') begin 
		set @BasicRoutingCode = isnull(dbo.fnVVT_BasicRoutingCode(@MaterialCode),@BasicRoutingCode) 
	end 
	--Mr.Tung addition V-23, V-26 Stage for Vietnam Production Routing 


	DECLARE @ProcessQty NUMERIC(20,5)
	WHILE @Remain > 0 BEGIN
		IF @Remain < @MaxProdPlanQty
			SET @ProcessQty = @Remain
		ELSE
			SET @ProcessQty = @MaxProdPlanQty

		SET @Remain = @Remain - @ProcessQty

		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProductionOrderInfo',		@PONo OUTPUT      -- 프로시저 호출

		PRINT '@PONo ::::: ' + @PONo
		
		IF ISNULL(@pPONos,'') <> ''
			SET @pPONos = @pPONos + ','
		    SET @pPONos = @pPONos + @PONo

		INSERT INTO STB_ProductionOrderInfo
		(
			PONo,
			CompanyCode,
			WorkCenterCode,
			PlanYearMonth,
			ProdPlanStartDate,
			ProdPlanEndDate,
			POType,
			IsReworkPO,
			MaterialCode,
			BomVersion,
			PlanQty,
			ProdOrderQty,
			ProdFinishQty,
			IsFix,
			IsCancel,
			IsFinish,
			BasicRoutingCode,
			CreateDateTime,
			CreateUserID,
			LotBeforeReDroping,
			DefectSummaryNoBeforeDroping
		)
		VALUES
		(
			@PONo,
			@CompanyCode,
			@WorkCenterCode,
			@pPlanYearMonth,
			@PlanStartDate,
			@PlanEndDate,
			@POType,
			0,	-- IsReworkPO
			@MaterialCode,
			@BomVersion,
			@ProcessQty,
			0,	-- ProdOrderQty
			0,	-- ProdFinishQty
			0,	-- IsFix
			0,	-- IsCancel
			0,	-- IsFinish
			@BasicRoutingCode,
			GETDATE(),
			@ProcessUserID,
			@LotNo,
			@DefectSummaryNo
		)

		INSERT INTO STB_ProductionOrderRouting
		(
			PONo,
			RouteCode,
			RouteIndex,
			IsInputRoute,
			IsOutputRoute,
			CreateDateTime,
			CreateUserID
		)
		SELECT
				@PONo,
				BRD.RouteCode,
				BRD.RouteIndex,
				BRD.IsInputRoute,
				BRD.IsOutputRoute,
				GETDATE(),
				@ProcessUserID
		FROM
				STB_BasicRoutingDetail BRD
		WHERE 1=1
		    AND 	BRD.BasicRoutingCode = @BasicRoutingCode
			AND BRD.CompanyCode = @CompanyCode       		-- 사업장코드와 작업장코드 추가 2019.09.27 By Jackaroe
			AND BRD.WorkCenterCode = @WorkCenterCode

		IF @@ROWCOUNT = 0 
		
		BEGIN
			EXEC usp_RaiseLocalizedError	@ProcessLanguage,			'공정라우팅정보가 없습니다.'
			RETURN
		END

		INSERT INTO STB_ProductionOrderBom
		(
			Id,
			ParentId,
			PONo,
			MaterialCode,
			BomVersion,
			ChildMaterialCode,
			ChildBomVersion,
			BomUnit,
			RouteCode,
			UsedQty,			
			TotalUsedQty,			
			MaterialUnitUsedQty,
			MaterialUnitTotalUsedQty,
			IsOptionItem,
			IsUseProduction,
			CreateDateTime,
			CreateUserID
		)
		SELECT
				B.Id,
				B.ParentId,
				@PONo,
				B.ParentMaterialCode,
				B.ParentBomVersion,
				B.MaterialCode,
				B.BomVersion,
				B.BomUnit,
				B.RouteCode,
				B.ParentBomHeaderUnitUsedQty,
				B.ParentBomHeaderUnitTotalQty,	
				B.MaterialUnitUsedQty,
				B.MaterialUnitTotalQty,
				B.IsOptionItem,
				B.IsUseProduction,
				GETDATE(),
				@ProcessUserID
		FROM
				dbo.fnGetBom(@MaterialCode,@BomVersion,@POQty) B
		




		--;WITH BomCTE
		--AS
		--(
		--	SELECT
		--			CONVERT(VARCHAR(50),NEWID()) AS Id,
		--			CONVERT(VARCHAR(50),NULL) AS ParentId,
		--			BD.MaterialCode, 
		--			BD.BomVersion, 
		--			BD.ChildMaterialCode, 
		--			BD.ChildBomVersion,
		--			BD.BomUnit,
		--			CONVERT(VARCHAR(10),NULL) AS BomHeaderUnit,
		--			BD.RouteCode,
		--			CONVERT(NUMERIC(20,5), BD.UsedQty) AS UnitQty,
		--			CONVERT(NUMERIC(20,5), BD.UsedQty * @ProcessQty) AS TotalQty,
		--			BD.IsOptionItem,
		--			CONVERT(BIT, 1) AS IsUseOption,
		--			CASE 
		--				WHEN ISNULL(MM.IsProdPlan,0) = 1 OR ISNULL(MM.IsPurchase,0) = 1 THEN  1
		--				ELSE 0
		--			END AS IsParentUseProduction,
		--			CASE 
		--				WHEN ISNULL(MM.IsProdPlan,0) = 1 OR ISNULL(MM.IsPurchase,0) = 1 THEN  1
		--				ELSE 0
		--			END AS IsUseProduction
		--	FROM
		--			STB_BomDetail BD
		--			INNER JOIN STB_MaterialMaster MM
		--				ON	MM.MaterialCode = BD.ChildMaterialCode
		--	WHERE
		--			BD.MaterialCode = @MaterialCode AND
		--			BD.BomVersion = @BomVersion
		--	UNION ALL
		--	SELECT
		--			CONVERT(VARCHAR(50),NEWID()) AS Id,
		--			CTE.Id AS ParentId,
		--			BD.MaterialCode, 
		--			BD.BomVersion, 
		--			BD.ChildMaterialCode, 
		--			BD.ChildBomVersion,
		--			BD.BomUnit,
		--			(
		--				SELECT
		--						BH.BomUnit
		--				FROM
		--						STB_BomHeader BH
		--				WHERE
		--						BH.MaterialCode = BD.ChildMaterialCode AND
		--						BH.BomVersion = BD.ChildBomVersion
		--			) AS BomHeaderUnit,
		--			BD.RouteCode,
		--			CONVERT(NUMERIC(20,5), BD.UsedQty) AS UnitQty,
		--			-- 자재사용량 * 상위자재의 BOM Header 의 Unit 으로 변환한 사용량
		--			CONVERT(NUMERIC(20,5), SmartFramework.dbo.fnConvertUnit(BD.BomUnit, CTE.BomHeaderUnit,BD.UsedQty * CTE.TotalQty)) AS TotalQty,
		--			BD.IsOptionItem,
		--			CONVERT(BIT, 1) AS IsUseOption,
		--			CASE CTE.IsParentUseProduction
		--				WHEN 1 THEN 1
		--				ELSE 
		--					CASE
		--						WHEN CTE.IsParentUseProduction = 1 THEN 0
		--						ELSE 
		--							CASE 
		--								WHEN ISNULL(MM.IsProdPlan,0) = 1 OR ISNULL(MM.IsPurchase,0) = 1 THEN  1
		--								ELSE 0
		--							END
		--					END
		--			END AS IsParentUseProduction,
		--			CASE
		--				WHEN CTE.IsParentUseProduction = 1 THEN 0
		--				ELSE 
		--					CASE 
		--						WHEN ISNULL(MM.IsProdPlan,0) = 1 OR ISNULL(MM.IsPurchase,0) = 1 THEN  1
		--						ELSE 0
		--					END
		--			END AS IsUseProduction
		--	FROM
		--			STB_BomDetail BD
		--			INNER JOIN BomCTE CTE
		--				ON	BD.MaterialCode = CTE.ChildMaterialCode AND
		--					BD.BomVersion = CTE.ChildBomVersion
		--			INNER JOIN STB_MaterialMaster MM
		--				ON	MM.MaterialCode = BD.ChildMaterialCode
		--)
		--INSERT INTO STB_ProductionOrderBom
		--(
		--	Id,
		--	ParentId,
		--	PONo,
		--	MaterialCode,
		--	BomVersion,
		--	ChildMaterialCode,
		--	ChildBomVersion,
		--	BomUnit,
		--	RouteCode,
		--	UsedQty,
		--	TotalUsedQty,
		--	IsOptionItem,
		--	IsUseProduction,
		--	CreateDateTime,
		--	CreateUserID
		--)
		--SELECT
		--		B.Id,
		--		B.ParentId,
		--		@PONo,
		--		B.MaterialCode,
		--		B.BomVersion,
		--		B.ChildMaterialCode,
		--		B.ChildBomVersion,
		--		B.BomUnit,
		--		B.RouteCode,
		--		B.UnitQty,
		--		--SUM(B.TotalQty),
		--		B.TotalQty,
		--		0,	-- IsOptionItem
		--		B.IsUseProduction,
		--		GETDATE(),
		--		@ProcessUserID
		--FROM
		--		BomCTE B
		--GROUP BY
		--		B.MaterialCode,
		--		B.BomVersion,
		--		B.ChildMaterialCode,
		--		B.ChildBomVersion,
		--		B.BomUnit,
		--		B.RouteCode,
		--		B.UnitQty,
		--		B.IsUseProduction

		
		
		
	END -- WHILE @Remain > 0 BEGIN
END