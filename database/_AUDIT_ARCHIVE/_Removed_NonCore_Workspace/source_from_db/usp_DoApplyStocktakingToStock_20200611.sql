

-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-17
-- Browsable : true
-- Group : 자재관리 > [F750]자재재고실사 >  실사반영처리 버튼처리
-- Description:	실사정보를 재고에 반영합니다.
-- =============================================

CREATE PROCEDURE [dbo].[usp_DoApplyStocktakingToStock_20200611]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pStocktackingDocNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@StocktackingDocNo VARCHAR(20) = @pStocktackingDocNo,
			@CompanyCode VARCHAR(20),
			@WorkCenterCode VARCHAR(20),
			@MaterialWarehouseCode VARCHAR(20),
			@GIMaterialDocNo VARCHAR(20),
			@GRMaterialDocNo VARCHAR(20)
			
			
	DECLARE @SDNSeqNo INT,
			@MaterialLocationCode VARCHAR(20),
			@MaterialLotNo VARCHAR(20),
			@LotID VARCHAR(50),
			@MaterialCode VARCHAR(20),
			@MaterialStockAttribute VARCHAR(20),
			@StockAttrib1 VARCHAR(20),
			@StockAttrib2 VARCHAR(20),
			@StockAttrib3 VARCHAR(20),
			@PackingID VARCHAR(50),
			@BasicQty NUMERIC(20,5),
			@StocktakingQty NUMERIC(20,5),
			@StocktakingMaterialLocationCode VARCHAR(20),
			@GIQty NUMERIC(20,5),
			@GRQty NUMERIC(20,5)
			
	DECLARE @ROW INT,
			@COUNT INT
			
			

	SELECT
			@CompanyCode = SD.CompanyCode,
			@WorkCenterCode = SD.WorkCenterCode,
			@MaterialWarehouseCode = SD.MaterialWarehouseCode
	FROM
			STB_StocktakingDoc SD
	WHERE
			SD.StocktakingDocNo = @StocktackingDocNo


    IF @CompanyCode IS NULL BEGIN
		DECLARE @NotFoundStocktakingError NVARCHAR(MAX)
		EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
										@pName = '^실사 기준정보를 찾을 수 없습니다.^',
										@pValue = @NotFoundStocktakingError OUTPUT
		RAISERROR(@NotFoundStocktakingError,16,1)
		RETURN
	END

	DECLARE @StocktakingGI TABLE
	(
		ROW INT IDENTITY(1,1),
		SDNSeqNo INT,
		MaterialLocationCode VARCHAR(20),
		MaterialLotNo VARCHAR(20),
		LotID VARCHAR(50),
		MaterialCode VARCHAR(20),
		MaterialStockAttribute VARCHAR(20),
		StockAttrib1 VARCHAR(20),
		StockAttrib2 VARCHAR(20),
		StockAttrib3 VARCHAR(20),
		PackingID VARCHAR(50),
		BasicQty NUMERIC(20,5),
		LotAttr01 NVARCHAR(200),
		LotAttr02 NVARCHAR(200),
		LotAttr03 NVARCHAR(200),
		LotAttr04 NVARCHAR(200),
		LotAttr05 NVARCHAR(200),
		LotAttr06 NVARCHAR(200),
		LotAttr07 NVARCHAR(200),
		LotAttr08 NVARCHAR(200),
		LotAttr09 NVARCHAR(200),
		LotAttr10 NVARCHAR(200),
		StocktakingQty NUMERIC(20,5),
		StocktakingMaterialLocationCode VARCHAR(20)
	)
	
	DECLARE @StocktakingGR TABLE
	(
		ROW INT IDENTITY(1,1),
		SDNSeqNo INT,
		MaterialLocationCode VARCHAR(20),
		MaterialLotNo VARCHAR(20),
		LotID VARCHAR(50),
		MaterialCode VARCHAR(20),
		MaterialStockAttribute VARCHAR(20),
		StockAttrib1 VARCHAR(20),
		StockAttrib2 VARCHAR(20),
		StockAttrib3 VARCHAR(20),
		PackingID VARCHAR(50),
		BasicQty NUMERIC(20,5),
		LotAttr01 NVARCHAR(200),
		LotAttr02 NVARCHAR(200),
		LotAttr03 NVARCHAR(200),
		LotAttr04 NVARCHAR(200),
		LotAttr05 NVARCHAR(200),
		LotAttr06 NVARCHAR(200),
		LotAttr07 NVARCHAR(200),
		LotAttr08 NVARCHAR(200),
		LotAttr09 NVARCHAR(200),
		LotAttr10 NVARCHAR(200),
		StocktakingQty NUMERIC(20,5),
		StocktakingMaterialLocationCode VARCHAR(20)
	)	

	UPDATE STB_StocktakingPlanResult
	SET
			StocktakingQty = 0
	WHERE
			StocktakingDocNo = @StocktackingDocNo AND
			ISNULL(MaterialLotNo, '') <> '' AND
			IsStocktaking =  1 AND
			ISNULL(IsApplied,0) = 0 AND
			StocktakingQty IS NULL
	
	-- 재고 실사 GI 처리
	SET CONTEXT_INFO 0x999998
		
	INSERT INTO @StocktakingGI
	SELECT
			SPR.SDNSeqNo,
			SPR.MaterialLocationCode,
			SPR.MaterialLotNo,
			SPR.LotID,
			SPR.MaterialCode,
			SPR.MaterialStockAttribute,
			SPR.StockAttrib1,
			SPR.StockAttrib2,
			SPR.StockAttrib3,
			SPR.PackingID,
			ISNULL(SPR.BasicQty,0) AS BasicQty,
			SPR.LotAttr01,
			SPR.LotAttr02,
			SPR.LotAttr03,
			SPR.LotAttr04,
			SPR.LotAttr05,
			SPR.LotAttr06,
			SPR.LotAttr07,
			SPR.LotAttr08,
			SPR.LotAttr09,
			SPR.LotAttr10,
			ISNULL(SPR.StocktakingQty,0) AS StocktakingQty,
			SPR.StocktakingMaterialLocationCode
	FROM
			STB_StocktakingPlanResult SPR
	WHERE
			SPR.StocktakingDocNo = @StocktackingDocNo AND
			SPR.IsStocktaking =  1 AND
			SPR.IsApplied = 0 AND
			SPR.MaterialLotNo NOT IN ('') AND
			SPR.BasicQty > SPR.StocktakingQty
	
	IF (
			SELECT
					COUNT(*)
			FROM
					@StocktakingGI
		) > 0
	BEGIN
			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocInfo', @GIMaterialDocNo OUTPUT

			INSERT INTO STB_MaterialDocInfo
			(
				MaterialDocNo,
				BasicDate,
				MaterialDocTypeCode,
				MaterialDocType,
				DocStatus,
				SourceCompanyCode,
				SourceWorkCenterCode,
				SourceMaterialWarehouseCode,
				IsSourceFinish,				-- 원본완료여부
				SourceProcessDateTime,		-- 원본완료일시
				SourceProcessUserID,		-- 원본완료 작업자 ID
				IsRequestFix,				-- 요청확정여부
				RequestFixDateTime,			-- 요청확정일시
				RequestFixUserID,			-- 요청확정자 ID
				IsRequestApproval,			-- 요청승인여부
				RequestApprovalDateTime,	-- 요청승인일시
				RequestApprovalUserID,		-- 요청승인자 ID
				IsAssignPicking,			-- 피킹할당여부
				IsPickingFix,				-- 피킹완료여부
				RequestUserID,				-- 요청자ID
				RequestDateTime,			-- 요청일시
				RequestPlanDate,			-- 요청일자
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@GIMaterialDocNo,
				GETDATE(),
				'GI_STOCKTAKING',
				'GI',
				'FINISH',
				@CompanyCode,
				@WorkCenterCode,
				@MaterialWarehouseCode,
				1,				-- 원본완료여부
				GETDATE(),		-- 원본완료일시
				@ProcessUserID,	-- 원본완료 작업자 ID
				1,				-- 요청확정여부
				GETDATE(),		-- 요청확정일시
				@ProcessUserID,	-- 요청확정자ID
				1,				-- 요청승인여부
				GETDATE(),		-- 요청승인일시
				@ProcessUserID,	-- 요청승인자 ID
				0,				-- 피킹할당여부
				0,				-- 피킹완료여부
				@ProcessUserID,	-- 요청자ID
				GETDATE(),
				GETDATE(),
				GETDATE(),
				@ProcessUserID
			)

			SELECT
					@ROW = 1,
					@COUNT = COUNT(*)
			FROM
					@StocktakingGI

			WHILE @ROW <= @COUNT BEGIN
				SELECT
						@SDNSeqNo = S.SDNSeqNo,
						@MaterialLocationCode = S.MaterialLocationCode,						-- NULL 가능
						@MaterialLotNo = S.MaterialLotNo,									-- NULL 가능
						@LotID = S.LotID,													
						@MaterialCode = S.MaterialCode,										
						@MaterialStockAttribute = S.MaterialStockAttribute,					-- NULL 가능
						@StockAttrib1 = S.StockAttrib1,										-- NULL 가능
						@StockAttrib2 = S.StockAttrib2,										-- NULL 가능
						@StockAttrib3 = S.StockAttrib3,										-- NULL 가능
						@PackingID = S.PackingID,										
						@BasicQty = S.BasicQty,												-- NULL 가능
						@StocktakingQty = S.StocktakingQty,									-- 0 가능
						@StocktakingMaterialLocationCode = S.StocktakingMaterialLocationCode
				FROM
						@StocktakingGI S
				WHERE
						S.ROW = @ROW

				-- 바코드 사용 여부에 따른 조치
				-- LOT 사용 여부에 따른 조치 등
				SET @GIQty = @BasicQty - @StocktakingQty

				EXEC usp_DoMakeMaterialDocDetailLotForStocktaking
					@pProcessLanguage = @ProcessLanguage,
					@pProcessUserID = @ProcessUserID,
					@pMaterialDocNo = @GIMaterialDocNo,
					@pMaterialLotNo  = @MaterialLotNo,
					@pMaterialCode = @MaterialCode,					
					@pMaterialStockAttribute = @MaterialStockAttribute,
					@pLotID = @LotID,
					@pStockAttrib1 = @StockAttrib1,
					@pStockAttrib2 = @StockAttrib2,
					@pStockAttrib3 = @StockAttrib3,
					@pMaterialLocationCode = @MaterialLocationCode,
					@pRequestQty = @GIQty

				SET @ROW = @ROW + 1
			END	
	END

	SET CONTEXT_INFO 0 

	-- 2016-08-16 Kim Han Young(hykim@awoo.co.kr)
	-- STB_MaterialDocDetail 의 트리거에서 CREATE 상태가 아닌 상태에서 수량변경이 되지 않도록 되어 있다.
	-- 재고실사를 반영할 경우 수량이 중간에 계속 변경이 되기 때문에 트리거가 동작하지 않도록 플래그를 설정한다.
	SET CONTEXT_INFO 0x999998

	-- 재고 실사 GR 처리
	
	INSERT INTO @StocktakingGR
	SELECT
			SPR.SDNSeqNo,
			SPR.MaterialLocationCode,
			SPR.MaterialLotNo,
			SPR.LotID,
			SPR.MaterialCode,
			SPR.MaterialStockAttribute,
			SPR.StockAttrib1,
			SPR.StockAttrib2,
			SPR.StockAttrib3,
			SPR.PackingID,
			ISNULL(SPR.BasicQty,0) AS BasicQty,
			SPR.LotAttr01,
			SPR.LotAttr02,
			SPR.LotAttr03,
			SPR.LotAttr04,
			SPR.LotAttr05,
			SPR.LotAttr06,
			SPR.LotAttr07,
			SPR.LotAttr08,
			SPR.LotAttr09,
			SPR.LotAttr10,
			ISNULL(SPR.StocktakingQty,0) AS StocktakingQty,
			SPR.StocktakingMaterialLocationCode
	FROM
			STB_StocktakingPlanResult SPR
	WHERE
			SPR.StocktakingDocNo = @StocktackingDocNo AND
			SPR.IsStocktaking =  1 AND
			SPR.IsApplied = 0 AND
			SPR.BasicQty < SPR.StocktakingQty
	
	IF (
			SELECT
					COUNT(*)
			FROM
					@StocktakingGR
		) > 0
	BEGIN
			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialDocInfo', @GRMaterialDocNo OUTPUT

			INSERT INTO STB_MaterialDocInfo
			(
				MaterialDocNo,
				BasicDate,
				MaterialDocTypeCode,
				MaterialDocType,
				DocStatus,
				TargetCompanyCode,
				TargetWorkCenterCode,
				TargetMaterialWarehouseCode,
				IsTargetFinish,				-- 대상완료여부
				TargetProcessDateTime,		-- 대상완료일시
				TargetProcessUserID,		-- 대상완료 작업자 ID
				IsRequestFix,				-- 요청확정여부
				RequestFixDateTime,			-- 요청확정일시
				RequestFixUserID,			-- 요청확정자 ID
				IsRequestApproval,			-- 요청승인여부
				RequestApprovalDateTime,	-- 요청승인일시
				RequestApprovalUserID,		-- 요청승인자 ID
				IsAssignPicking,			-- 피킹할당여부
				IsPickingFix,				-- 피킹완료여부
				RequestUserID,				-- 요청자ID
				RequestDateTime,			-- 요청일시
				RequestPlanDate,			-- 요청일자
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@GRMaterialDocNo,
				GETDATE(),
				'GR_STOCKTAKING',
				'GR',
				'FINISH',
				@CompanyCode,
				@WorkCenterCode,
				@MaterialWarehouseCode,
				1,				-- 대상완료여부
				GETDATE(),		-- 대상완료일시
				@ProcessUserID,	-- 대상완료 작업자 ID
				1,				-- 요청확정여부
				GETDATE(),		-- 요청확정일시
				@ProcessUserID,	-- 요청확정자ID
				1,				-- 요청승인여부
				GETDATE(),		-- 요청승인일시
				@ProcessUserID,	-- 요청승인자 ID
				0,				-- 피킹할당여부
				0,				-- 피킹완료여부
				@ProcessUserID,	-- 요청자ID
				GETDATE(),		-- 요청일시
				GETDATE(),		-- 요청일자
				GETDATE(),
				@ProcessUserID
			)

			SELECT
					@ROW = 1,
					@COUNT = COUNT(*)
			FROM
					@StocktakingGR

			WHILE @ROW <= @COUNT BEGIN
				SELECT
						@SDNSeqNo = S.SDNSeqNo,
						@MaterialLocationCode = S.MaterialLocationCode,						-- NULL 가능
						@MaterialLotNo = S.MaterialLotNo,									-- NULL 가능
						@LotID = S.LotID,													
						@MaterialCode = S.MaterialCode,										
						@MaterialStockAttribute = S.MaterialStockAttribute,					-- NULL 가능
						@StockAttrib1 = S.StockAttrib1,										-- NULL 가능
						@StockAttrib2 = S.StockAttrib2,										-- NULL 가능
						@StockAttrib3 = S.StockAttrib3,										-- NULL 가능
						@PackingID = S.PackingID,										
						@BasicQty = S.BasicQty,												-- NULL 가능
						@StocktakingQty = S.StocktakingQty,									-- 0 가능
						@StocktakingMaterialLocationCode = S.StocktakingMaterialLocationCode
				FROM
						@StocktakingGR S
				WHERE
						S.ROW = @ROW

				-- 바코드 사용 여부에 따른 조치
				-- LOT 사용 여부에 따른 조치 등

				SET @GRQty = @StocktakingQty - @BasicQty 

				EXEC usp_DoMakeMaterialDocDetailLotForStocktaking
					@pProcessLanguage = @ProcessLanguage,
					@pProcessUserID = @ProcessUserID,
					@pMaterialDocNo = @GRMaterialDocNo,
					@pMaterialLotNo  = @MaterialLotNo,
					@pMaterialCode = @MaterialCode,					
					@pMaterialStockAttribute = @MaterialStockAttribute,
					@pLotID = @LotID,
					@pStockAttrib1 = @StockAttrib1,
					@pStockAttrib2 = @StockAttrib2,
					@pStockAttrib3 = @StockAttrib3,
					@pMaterialLocationCode = @MaterialLocationCode,
					@pRequestQty = @GRQty

				SET @ROW = @ROW + 1
			END	
	END

	SET CONTEXT_INFO 0 

	IF ISNULL(@GIMaterialDocNo,'') <> '' BEGIN	
		EXEC usp_DoFixMaterialDoc
				@pProcessUserID = @pProcessUserID,
				@pProcessLanguage = @pProcessLanguage,
				@pMaterialDocNo = @GIMaterialDocNo
	END
		
	IF ISNULL(@GRMaterialDocNo,'') <> '' BEGIN	
		EXEC usp_DoFixMaterialDoc
				@pProcessUserID = @pProcessUserID,
				@pProcessLanguage = @pProcessLanguage,
				@pMaterialDocNo = @GRMaterialDocNo
	END
		

	MERGE STB_MaterialLotInfo MLI
	USING
		(
			SELECT 
					SPR.*,
					ML.MaterialWarehouseCode AS StocktakingMaterailWarehouseCode
			FROM
					STB_StocktakingPlanResult SPR
					LEFT OUTER JOIN STB_MaterialLocation ML
						ON (ML.MaterialLocationCode = SPR.StocktakingMaterialLocationCode)
			WHERE
					StocktakingDocNo = @StocktackingDocNo AND
					IsStocktaking =  1  AND
					ISNULL(SPR.IsApplied,0) = 0
		) SPR
	ON 
		(SPR.LotID = MLI.LotID AND SPR.MaterialLocationCode = MLI.MaterialLocationCode)
	WHEN  MATCHED THEN
		UPDATE SET
			LotAttr01 = SPR.LotAttr01,
			LotAttr02 = SPR.LotAttr02,
			LotAttr03 = SPR.LotAttr03,
			LotAttr04 = SPR.LotAttr04,
			LotAttr05 = SPR.LotAttr05,
			LotAttr06 = SPR.LotAttr06,
			LotAttr07 = SPR.LotAttr07,
			LotAttr08 = SPR.LotAttr08,
			LotAttr09 = SPR.LotAttr09,
			LotAttr10 = SPR.LotAttr10,
			MaterialWarehouseCode = SPR.StocktakingMaterailWarehouseCode,
			MaterialLocationCode = SPR.StocktakingMaterialLocationCode,
			PackingID = SPR.PackingID;


	UPDATE STB_StocktakingPlanResult
	SET
			IsApplied = 1
	WHERE
			StocktakingDocNo = @StocktackingDocNo AND
			IsStocktaking =  1
END