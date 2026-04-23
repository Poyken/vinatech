-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	cái này dùng để khi chuyển từ kho bắc ninh sang bg hoặc ngược lại nó sẽ tự chuyển
-- =============================================
CREATE PROCEDURE usp_PDADoPutaway_AddDateConfirmEX_new
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialLocationCode VARCHAR(50),	-- 제품바코드가 입력될 수 있음
	@pMaterialLotNo VARCHAR(20),
	@pLotID VARCHAR(500) = NULL,
	@pDateConfirmEX varchar(20),
	@pIsWithoutPallet VARCHAR(1) = 'N'
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@MaterialLotNo VARCHAR(20) = @pMaterialLotNo,
			@MaterialLocationCode VARCHAR(50) = @pMaterialLocationCode,
			@RealLocationCode VARCHAR(20),
			@MaterialWarehouseCode VARCHAR(20),
			@IsToRouteMaterial BIT,
			@LotID VARCHAR(50),
			@pLocationMaterialCode1 VARCHAR(20)



	SELECT
			@RealLocationCode = ML.MaterialLocationCode,
			@MaterialWarehouseCode = ML.MaterialWarehouseCode,
			@IsToRouteMaterial = CASE 
									WHEN ISNULL(ML.IsUseLotID, 0) = 1 THEN 0
									ELSE 1
								END
	FROM
			STB_MaterialLocation ML
	WHERE
			ML.MaterialLocationCode = @MaterialLocationCode

	IF @RealLocationCode IS NULL BEGIN
		SELECT
				@RealLocationCode = MLI.MaterialLocationCode,
				@MaterialWarehouseCode = MLI.MaterialWarehouseCode,
				@IsToRouteMaterial = CASE 
										WHEN ISNULL(ML.IsUseLotID, 0) = 1 THEN 0
										ELSE 1
									END
		FROM
				STB_MaterialLotInfo MLI
				LEFT OUTER JOIN STB_MaterialLocation ML WITH (NOLOCK)
					ON (ML.MaterialLocationCode = MLI.MaterialLocationCode)
		WHERE
				MLI.LotID = @MaterialLocationCode
	END

	IF @RealLocationCode IS NULL BEGIN
		DECLARE @NotFoundLocation NVARCHAR(MAX)
		EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
													@pName = '^Cannot Found Location.^',
													@pValue = @NotFoundLocation OUTPUT
		RAISERROR(@NotFoundLocation,16,1)
		RETURN
	END

	-- RouteMaterialLotInfo 에 있는경우 MaterialLotInfo 로 이동
	EXEC usp_RouteMaterialLotInfoToMaterialLotInfo @pMaterialLotNo = @MaterialLotNo

	EXEC usp_DoAddMaterialMoveHistory 
			@pMaterialLotNo                  = @MaterialLotNo,
			@pTargetMaterialLocationCode = @RealLocationCode,
			@pProcessUserID                 = @ProcessUserID

	IF @pIsWithoutPallet = 'Y'
	BEGIN
			SELECT
					@LotID = MLI.LotID
			FROM
					STB_MaterialLotInfo MLI 
			WHERE
					MaterialLotNo = @MaterialLotNo
			


			-- 바코드를 사용하는 제품은 패킹정보가 있을 수 있다.
			-- PackingID 는 동일 패킹의 첫 번째 박스의 바코드(LotID)를 사용하기 때문에
			-- 첫 번째 박스가 세트출고가 될 때는 기존 제품들의 패킹아이디를 다른 제품의 바코드중 하나를 선정해서 업데이트 해준다.
			--IF @IsUseBarcoe = 1 AND @pIsRemovePacking = 1 BEGIN
				-- 피킹하는 바코드로 패킹을 사용하는 다른 제품들이 있으면
				-- 그 중에 한 바코드로 패킹번호를 업데이트	
			DECLARE @AnotherPackingID VARCHAR(50)
			SELECT 
					TOP 1
					@AnotherPackingID = MLI.LotID
			FROM 
					STB_MaterialLotInfo MLI
			WHERE
					MLI.PackingID = @LotID AND
					MLI.LotID <> @LotID
			IF @AnotherPackingID IS NOT NULL BEGIN
				UPDATE
						STB_MaterialLotInfo
				SET
						PackingID = @AnotherPackingID
				WHERE
						PackingID = @LotID AND
						LotID <> @LotID
			END

			-- 피킹된 제품의 패킹아이디는 바코드로 업데이트

			update STB_MaterialDocLotInfo
			set MaterialLocationCode=@RealLocationCode
			where LotID = @pLotID

			UPDATE
					STB_MaterialLotInfo
			SET
					PackingID = LotID,
					MaterialWarehouseCode = @MaterialWarehouseCode,
					MaterialLocationCode = @RealLocationCode,
					ChangeDateTime = GETDATE(),
					 DateConfirmEx = @pDateConfirmEX,
					ChangeUserID = @ProcessUserID
			WHERE
					MaterialLotNo = @MaterialLotNo
			-- Update

		
			--SET @PackingID = @LotID
			--END
	END 
	ELSE 
	BEGIN 
		SELECT
					@LotID = MLI.LotID
			FROM
					STB_MaterialLotInfo MLI 
			WHERE
					MaterialLotNo = @MaterialLotNo   
					                      --> 반납부분인듯

			update STB_MaterialDocLotInfo
			set MaterialLocationCode=@RealLocationCode
			where LotID = @pLotID


			UPDATE STB_MaterialLotInfo
			     SET MaterialWarehouseCode = @MaterialWarehouseCode,
					  MaterialLocationCode = @RealLocationCode,
					  ChangeDateTime = GETDATE(),
					  DateConfirmEx = @pDateConfirmEX,
					  ChangeUserID = @ProcessUserID
			WHERE
					MaterialLotNo = @MaterialLotNo
		-- Update
		
	   --  --2020.04.16 추가부분 (반납의 경우는 ProcessedLotID를 없애준다!!!)
    --      UPDATE STB_MaterialWarehouseInOutHist
			 -- SET ProcessedLotID = ''
		  --WHERE LotID = @LotID 


	END

	IF @IsToRouteMaterial = 1
		BEGIN
				EXEC usp_MaterialLotInfoToRouteMaterialLotInfo @pMaterialLotNo = @MaterialLotNo
		END
	-- 대상이 LotID 사용 안하는 로케이션이면 RouteMaterialLotInfo
END

