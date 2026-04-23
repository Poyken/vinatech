
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-29
-- Description:	MRP 를 전개합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeployMrp]
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

	DECLARE @Source TABLE
	(
		ROW INT IDENTITY(1,1),
		MaterialCode VARCHAR(50),
		BomVersion VARCHAR(20),
		ProdPlanDate DATE,
		FixedQty NUMERIC(20,5)
	)
	INSERT INTO @Source
	(
		MaterialCode,
		BomVersion,
		ProdPlanDate,
		FixedQty
	)
	SELECT
			MSM.MaterialCode,
			ISNULL(MSM.BomVersion,''),
			MSM.ProdPlanDate,
			MSM.FixedQty
	FROM
			STB_MrpSourceMaterial MSM
	WHERE
			MSM.MrpNo = @MrpNo AND
			(MSM.IsNotInclude IS NULL OR MSM.IsNotInclude = 0)
	
	DECLARE @SROW INT = 1,
			@SCOUNT INT = (SELECT COUNT(*) FROM @Source),
			@MaterialCode VARCHAR(20),
			@BomVersion VARCHAR(20),
			@ProdPlanDate DATE,
			@FixedQty NUMERIC(20,5)

	WHILE @SROW <= @SCOUNT BEGIN
		SELECT
				@MaterialCode = S.MaterialCode,
				@BomVersion = S.BomVersion,
				@ProdPlanDate = S.ProdPlanDate,
				@FixedQty = S.FixedQty
		FROM
				@Source S
		WHERE
				S.ROW = @SROW

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
				B.MaterialCode,
				ISNULL(B.BomVersion,''),
				B.BomUnit,
				@ProdPlanDate,
				@FixedQty,
				B.MaterialUnitTotalQty,	-- CalcQty
				0,								-- AdjustQty
				B.MaterialUnitTotalQty,	-- FixedQty		
				CASE @IsUseMrpProdDate
					WHEN 1 THEN @MrpProdDate	-- MRP에 설정된 생산계획일자 사용
					ELSE @ProdPlanDate		-- 제품의 생산계획일자 사용
				END,							-- ProdPlanDate
				ISNULL(B.RequestGrDay,0),					-- AgvGrDay
				ISNULL(B.TotalGrDay,0),		-- TotalGrDay (평균입고소요일 + 상위입고소요일합계)
				CASE @IsUseMrpProdDate
					WHEN 1 THEN DATEADD(DD, -1 * B.TotalGrDay, @MrpProdDate)	-- MRP 에 설정된 생산일자 - 총입고소요일
					ELSE DATEADD(DD, -1 * B.TotalGrDay, @ProdPlanDate)			-- 제품에 설정된 생산일자 - 총입고소요일
				END,							-- PlanOrderDate
				DATEADD(DAY,B.RequestGrDay, (
					CASE @IsUseMrpProdDate
						WHEN 1 THEN DATEADD(DD, -1 * B.TotalGrDay, @MrpProdDate)	-- MRP 에 설정된 생산일자 - 총입고소요일
						ELSE DATEADD(DD, -1 * B.TotalGrDay, @ProdPlanDate)			-- 제품에 설정된 생산일자 - 총입고소요일
					END
				)),							-- PlanGrDate
				-- 납품업체가 한군데만 있을 경우 납품업체 지정
				CASE				
					WHEN (
							SELECT
									COUNT(*)
							FROM
									STB_MaterialVendorMapping MVM
							WHERE
									MVM.MaterialCode = B.MaterialCode AND
									MVM.IsUsed = 1
						) = 1 THEN
						(
							SELECT
									MVM.CustomerCode
							FROM
									STB_MaterialVendorMapping MVM
							WHERE
									MVM.MaterialCode = B.MaterialCode AND
									MVM.IsUsed = 1
						)
					ELSE ''
				END							-- CustomerCode
		FROM
				dbo.fnGetBom(@MaterialCode,@BomVersion,@FixedQty) B
				INNER JOIN STB_MaterialMaster MM
					ON	MM.MaterialCode = B.MaterialCode
				LEFT OUTER JOIN STB_MaterialMaster PMM
					ON	PMM.MaterialCode = B.ParentMaterialCode
		WHERE
				B.IsPurchse = 1 AND
				B.IsOrder = 1

		SET @SROW = @SROW + 1
	END


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
				T.CalcQty,
				T.AdjustQty,			
				T.FixedQty,
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

