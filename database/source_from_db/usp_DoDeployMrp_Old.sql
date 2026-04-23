
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-29
-- Description:	MRP 를 전개합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeployMrp_Old]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMrpNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,	
			@MrpNo VARCHAR(20) = @pMrpNo,
			@IsFix BIT,
			@IsRun BIT

	DECLARE @IsUseMrpProdDate BIT,		-- 이 값이 1 이면 생산계획일자를 사용하지 않고 MRP 생산기준일자를 사용하여 발주예정일자를 계산한다.
			@MrpProdDate DATE,			-- MRP 생산기준일자
			@MrpTargetNo VARCHAR(20)

	SELECT
			 @IsUseMrpProdDate = MM.IsUseMrpProdDate,
			 @MrpProdDate = MM.MrpProdDate,
			 @IsFix = MM.IsFixedMRP,
			 @IsRun = MM.IsRunMrp

	FROM
			STB_MrpMaster MM
	WHERE
			MM.MrpNo = @MrpNo


	IF ISNULL(@IsFix, CONVERT(BIT, 0)) = CONVERT(BIT, 1)
	BEGIN
			RAISERROR('이미 확정된 MRP 입니다', 16, 1)
			RETURN		
	END



	DECLARE @Level INT = 1

	DECLARE @Target TABLE
	(
		ROW INT IDENTITY(1,1),
		Level INT,
		MaterialCode VARCHAR(50),
		BomVersion VARCHAR(20),
		BomUnit VARCHAR(10),
		MainProdPlanDate DATE,
		MainFixedQty INT,
		CalcQty NUMERIC(20,5),
		AdjustQty NUMERIC(20,5),
		FixedQty NUMERIC(20,5),		
		ProdPlanDate DATE,
		AgvGrDay INT,
		TotalGrDay INT,
		PlanOrderDate DATE,
		PlanGrDate DATE,
		CustomerCode VARCHAR(20)
	)

	DECLARE @Target_Purchase TABLE
	(
		ROW INT IDENTITY(1,1),
		MaterialCode VARCHAR(50),
		BomVersion VARCHAR(20),
		BomUnit VARCHAR(10),
		--MainProdPlanDate DATE,
		--MainFixedQty INT,
		CalcQty NUMERIC(20,5),
		AdjustQty NUMERIC(20,5),
		FixedQty NUMERIC(20,5),		
		ProdPlanDate DATE,
		AgvGrDay INT,
		TotalGrDay INT,
		PlanOrderDate DATE,
		PlanGrDate DATE,
		CustomerCode VARCHAR(20)
	)

	INSERT INTO @Target
	(
		Level,
		MaterialCode,
		BomVersion,
		BomUnit,
		MainProdPlanDate,
		MainFixedQty,
		FixedQty,
		AgvGrDay,
		TotalGrDay
	)
	SELECT
			@Level,
			MSM.MaterialCode,
			ISNULL(MSM.BomVersion,''),
			BH.BomUnit,
			MSM.ProdPlanDate,
			MSM.FixedQty,
			MSM.FixedQty,
			0,	-- AgvGrDay
			0	-- TotalGrDay
	FROM
			STB_MrpSourceMaterial MSM WITH(NOLOCK)
			INNER JOIN STB_BomHeader BH
				ON	BH.MaterialCode = MSM.MaterialCode AND
					BH.BomVersion = MSM.BomVersion
	WHERE
			MSM.MrpNo = @MrpNo

	
	WHILE 1 = 1 BEGIN
	
		INSERT INTO @Target
		(
			Level,
			MaterialCode,
			BomVersion,
			BomUnit,
			MainProdPlanDate,
			MainFixedQty,
			CalcQty,
			AdjustQty,
			FixedQty,
			ProdPlanDate,
			AgvGrDay,
			TotalGrDay,
			PlanOrderDate,
			PlanGrDate,
			CustomerCode
		)
		SELECT
				@Level + 1,
				BD.ChildMaterialCode,
				ISNULL(BD.ChildBomVersion,''),
				BD.BomUnit,
				P.MainProdPlanDate,
				P.MainFixedQty,
				BD.UsedQty * SmartFramework.dbo.fnConvertUnit(BD.BomUnit, MM.MaterialUnit,P.FixedQty),	-- CalcQty
				0,								-- AdjustQty
				BD.UsedQty * SmartFramework.dbo.fnConvertUnit(BD.BomUnit, MM.MaterialUnit,P.FixedQty),	-- FixedQty		
				CASE @IsUseMrpProdDate
					WHEN 1 THEN @MrpProdDate	-- MRP에 설정된 생산계획일자 사용
					ELSE P.MainProdPlanDate		-- 제품의 생산계획일자 사용
				END,							-- ProdPlanDate
				ISNULL(MM.RequestGrDay,0),					-- AgvGrDay
				ISNULL(MM.RequestGrDay,0) + ISNULL(P.TotalGrDay,0),		-- TotalGrDay (평균입고소요일 + 상위입고소요일합계)
				CASE @IsUseMrpProdDate
					WHEN 1 THEN DATEADD(DD, -1 * (ISNULL(MM.RequestGrDay,0) + ISNULL(P.TotalGrDay,0)), @MrpProdDate)	-- MRP 에 설정된 생산일자 - 총입고소요일
					ELSE DATEADD(DD, -1 * (ISNULL(MM.RequestGrDay,0) + ISNULL(P.TotalGrDay,0)), P.MainProdPlanDate)			-- 제품에 설정된 생산일자 - 총입고소요일
				END,							-- PlanOrderDate

				CASE @IsUseMrpProdDate
					WHEN 1 THEN DATEADD(DD, -1 * (ISNULL(P.TotalGrDay,0)) - 1, @MrpProdDate)	
					ELSE DATEADD(DD, -1 * (ISNULL(P.TotalGrDay,0)) - 1, P.MainProdPlanDate)			
				END,							-- PlanGrDate
				-- 납품업체가 한군데만 있을 경우 납품업체 지정
				CASE				
					WHEN (
							SELECT
									COUNT(*)
							FROM
									STB_MaterialVendorMapping MVM
							WHERE
									MVM.MaterialCode = BD.ChildMaterialCode AND
									MVM.IsUsed = 1
						) = 1 THEN
						(
							SELECT
									MVM.CustomerCode
							FROM
									STB_MaterialVendorMapping MVM
							WHERE
									MVM.MaterialCode = BD.ChildMaterialCode AND
									MVM.IsUsed = 1
						)
					ELSE ''
				END							-- CustomerCode
		FROM
				@Target P
				INNER JOIN STB_BomDetail BD
					ON	BD.MaterialCode = P.MaterialCode AND
						((BD.BomVersion IS NULL AND P.BomVersion IS NULL) OR
						 (BD.BomVersion = '' AND P.BomVersion = '') OR
						 (BD.BomVersion = P.BomVersion))
				INNER JOIN STB_MaterialMaster MM
					ON	MM.MaterialCode = BD.ChildMaterialCode
		WHERE
				P.Level = @Level
		
		IF @@ROWCOUNT = 0 BEGIN
			BREAK
		END

		SET @Level = @Level + 1
	END

	--SELECT * FROM @Target


	INSERT INTO @Target_Purchase
	SELECT
			T.MaterialCode,
			T.BomVersion,
			T.BomUnit,
			--T.MainProdPlanDate,
			--T.MainFixedQty,
			SUM(ISNULL(CalcQty,0)),
			SUM(ISNULL(AdjustQty,0)),
			SUM(ISNULL(FixedQty, 0)),
			ProdPlanDate,
			ISNULL(AgvGrDay,0),
			ISNULL(TotalGrDay,0),
			PlanOrderDate,
			PlanGrDate,
			CustomerCode
	FROM
			@Target T
			LEFT OUTER JOIN STB_MaterialMaster MM WITH (NOLOCK)
				ON (MM.MaterialCode = T.MaterialCode)
	WHERE
			MM.IsPurchase = 1 AND
			MM.IsOrder = 1
	GROUP BY
			T.MaterialCode,
			T.BomVersion,
			T.BomUnit,
			--T.MainProdPlanDate,
			--T.MainFixedQty,
			ProdPlanDate,
			ISNULL(AgvGrDay,0),
			ISNULL(TotalGrDay,0),
			PlanOrderDate,
			PlanGrDate,
			CustomerCode

	--SELECT * FROM @Target_Purchase



	DECLARE @Row INT = 1,
			@COUNT INT

	SELECT
			@COUNT = COUNT(*)
	FROM
			@Target_Purchase T

	DELETE FROM STB_MrpTargetMaterial
	WHERE
			MrpNo = @MrpNo

	WHILE @Row <= @COUNT BEGIN
		EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MrpTargetMaterial',
													@pSerialNo = @MrpTargetNo OUTPUT

		INSERT INTO STB_MrpTargetMaterial
		(
			MrpTargetNo,
			MrpNo,
			MaterialCode,
			CalcQty,
			AdjustQty,
			FixedQty,
			ProdPlanDate,
			AgvGrDay,
			PlanOrderDate,
			PlanGrDate,
			CustomerCode,
			CreateDateTime,
			CreateUserID
		)
		SELECT
				@MrpTargetNo,
				@MrpNo,
				T.MaterialCode,
				CASE
					WHEN T.BomUnit <> MM.MaterialUnit THEN SmartFramework.dbo.fnConvertUnit(T.BomUnit,MM.MaterialUnit, T.CalcQty)
					ELSE T.CalcQty
				END,
				T.AdjustQty,			
				CASE
					WHEN T.BomUnit <> MM.MaterialUnit THEN SmartFramework.dbo.fnConvertUnit(T.BomUnit,MM.MaterialUnit, T.FixedQty)
					ELSE T.FixedQty
				END,
				T.ProdPlanDate,
				T.TotalGrDay,
				T.PlanOrderDate,
				T.PlanGrDate,
				T.CustomerCode,
				GETDATE(),
				@ProcessUserID
		FROM
				@Target_Purchase T
				INNER JOIN STB_MaterialMaster MM
					ON	MM.MaterialCode = T.MaterialCode
		WHERE
				T.ROW = @Row

		SET @Row = @Row + 1
	END

	UPDATE STB_MrpMaster
	SET
			IsRunMrp = 1,
			MrpRunDateTime = GETDATE(),
			MrpRunUserID = @pProcessUserID
	WHERE
			MrpNo = @MrpNo
END

