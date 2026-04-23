-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-23
-- Description:	설비수리자재정보, 스페어파트입출고이력, 스페어파트교체이력정보 IUD
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMachineRepairMaterialHistSub_iud]
	 @pOldMachineRepairHistoryNo VARCHAR(20),
	 @pOldMachineRepairMaterialSeq VARCHAR(20),
	 @pMachineRepairHistoryNo VARCHAR(20),
	 @pMachineRepairMaterialSeq VARCHAR(20),
	 @pSparePartChangeHistoryNo VARCHAR(20),
	 @pCompanyCode VARCHAR(20),
	 @pWorkCenterCode VARCHAR(20),
	 @pSparePartCode VARCHAR(20),
	 @pChangeQty NUMERIC(20,5),
	 @pSPWarehouseCode VARCHAR(20),
	 @pSPLocationCode VARCHAR(20),
	 @pBasicUnitPrice NUMERIC(20,5),
	 @pMachineCode VARCHAR(20),
	 @pSparePartIOHistoryNo VARCHAR(20),
	 
	 @pMachineRepairMaterialHist_PrefixString VARCHAR(20),
	 @pMachineRepairMaterialHist_SerialLen INT,
	 
	 @pSparePartIOHist_PrefixString VARCHAR(20),
	 @pSparePartIOHist_SerialLen INT,
	 
	 @pSparePartChangeHist_PrefixString VARCHAR(20),
	 @pSparePartChangeHist_SerialLen INT,
	 
	 @pIUD_FLAG VARCHAR(20)
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @MaxKeyField VARCHAR(20)
	
	
	DECLARE @OldSPWarehouseCode VARCHAR(20)
	DECLARE @OldSPLocationCode VARCHAR(20)
	DECLARE @OldSparePartCode VARCHAR(20)
	DECLARE @OldChangeQty NUMERIC(20,5)
	
	DECLARE @SpareChangeDate DATE
	
	DECLARE @SparePartIOTypeCode VARCHAR(20)
	
	SELECT
			@OldSPWarehouseCode = SPIOH.SPWarehouseCode,
			@OLdSPLocationCode = SPIOH.SPLocationCode,
			@OldSparePartCode = SPCH.SparePartCode,
			@OldChangeQty = ISNULL(SPCH.ChangeQty,0)
	FROM
			STB_MachineRepairMaterialHist MRMH
			LEFT OUTER JOIN STB_SparePartChangeHistory SPCH 
				ON MRMH.SparePartChangeHistoryNo = SPCH.SparePartChangeHistoryNo
			LEFT OUTER JOIN STB_SparePartIOHistory SPIOH 
				ON SPCH.SparePartIOHistoryNo = SPIOH.SparePartIOHistoryNo
	WHERE
			MachineRepairHistoryNo = @pOldMachineRepairHistoryNo
			AND MachineRepairMaterialSeq = @pOldMachineRepairMaterialSeq
			
			
	--기본수리출고타입을 가져와 스페어파트 입출고 이력에 넣어준다...		
	SELECT
			TOP 1
			@SparePartIOTypeCode = SPIOTC.SparePartIOTypeCode
	FROM
			STB_SparePartIOTypeCode SPIOTC 
	WHERE
			SPIOTC.IOType = 'O' 
			AND SPIOTC.IsDefaultRepairGI = 1
			AND SPIOTC.IsUsed = 1
	
	
	
	IF @pIUD_FLAG = 'INSERT' BEGIN

		-- 임시 SEQUENCE TABLE 사용 버젼
		SET @pOldMachineRepairHistoryNo = @pMachineRepairHistoryNo 
		
		SET @pMachineRepairHistoryNo = NULL
		
		SELECT
				@pMachineRepairHistoryNo = KeyValue
		FROM
				#SEQUENCE_TABLE
		WHERE
				UID_KEY = @pOldMachineRepairHistoryNo
		
		IF @pMachineRepairHistoryNo IS NULL
		BEGIN
				SET @pMachineRepairHistoryNo = @pOldMachineRepairHistoryNo
		END
		--		
	
	
		IF EXISTS (SELECT 1 FROM STB_MachineRepairMaterialHist WHERE MachineRepairHistoryNo = @pMachineRepairHistoryNo AND MachineRepairMaterialSeq = @pMachineRepairMaterialSeq) BEGIN
			RAISERROR('Duplicate Data : KeyField = %s , %s', 16, 1, @pMachineRepairHistoryNo, @pMachineRepairMaterialSeq)
		END
		
		--설비수리자재이력 생성
		SELECT
				@MaxKeyField = MAX(MachineRepairMaterialSeq)
		FROM
				STB_MachineRepairMaterialHist 
		WHERE
				MachineRepairHistoryNo = @pMachineRepairHistoryNo
									
		IF @MaxKeyField IS NULL BEGIN
		    SET @pMachineRepairMaterialSeq = @pMachineRepairMaterialHist_PrefixString + RIGHT(REPLICATE('0',@pMachineRepairMaterialHist_SerialLen) + '1', @pMachineRepairMaterialHist_SerialLen)
		END ELSE BEGIN
		    SET @pMachineRepairMaterialSeq = @pMachineRepairMaterialHist_PrefixString + RIGHT(REPLICATE('0',@pMachineRepairMaterialHist_SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@pMachineRepairMaterialHist_PrefixString))) + 1), @pMachineRepairMaterialHist_SerialLen)
		END
		
		INSERT INTO STB_MachineRepairMaterialHist
		(
		    MachineRepairHistoryNo,
		    MachineRepairMaterialSeq
		)
		VALUES
		(
		    @pMachineRepairHistoryNo,
		    @pMachineRepairMaterialSeq   
		)
		
		
		
		--스페어파트 입출고 이력 생성
		SELECT
				@MaxKeyField = MAX(SparePartIOHistoryNo)
		FROM
				STB_SparePartIOHistory 
		WHERE
				SparePartIOHistoryNo LIKE @pSparePartIOHist_PrefixString + '%'
									
		IF @MaxKeyField IS NULL BEGIN
		    SET @pSparePartIOHistoryNo = @pSparePartIOHist_PrefixString + RIGHT(REPLICATE('0',@pSparePartIOHist_SerialLen) + '1', @pSparePartIOHist_SerialLen)
		END ELSE BEGIN
		    SET @pSparePartIOHistoryNo = @pSparePartIOHist_PrefixString + RIGHT(REPLICATE('0',@pSparePartIOHist_SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@pSparePartIOHist_PrefixString))) + 1), @pSparePartIOHist_SerialLen)
		END
		
		INSERT INTO STB_SparePartIOHistory 
		(
			SparePartIOHistoryNo,
			CompanyCode,
			WorkCenterCode,
			SPWarehouseCode,
			SPLocationCode,
			SparePartIOTypeCode,
			SparePartCode,
			ProcessQty
		)
		VALUES
		(
			@pSparePartIOHistoryNo,
			@pCompanyCode,
			@pWorkCenterCode,
			@pSPWarehouseCode,
			@pSPLocationCode,
			@SparePartIOTypeCode,
			@pSparePartCode,
			@pChangeQty
		)
		
		
		--스페어파트 교체 이력 정보 생성
		SELECT
				@MaxKeyField = MAX(SparePartChangeHistoryNo)
		FROM
				STB_SparePartChangeHistory 
		WHERE
				SparePartChangeHistoryNo LIKE @pSparePartChangeHist_PrefixString + '%'
									
		IF @MaxKeyField IS NULL BEGIN
		    SET @pSparePartChangeHistoryNo = @pSparePartChangeHist_PrefixString + RIGHT(REPLICATE('0',@pSparePartChangeHist_SerialLen) + '1', @pSparePartChangeHist_SerialLen)
		END ELSE BEGIN
		    SET @pSparePartChangeHistoryNo = @pSparePartChangeHist_PrefixString + RIGHT(REPLICATE('0',@pSparePartChangeHist_SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@pSparePartChangeHist_PrefixString))) + 1), @pSparePartChangeHist_SerialLen)
		END
					
		INSERT INTO STB_SparePartChangeHistory 
		(
			SparePartChangeHistoryNo,
			CompanyCode,
			WorkCenterCode,
			MachineCode,
			SparePartCode,
			ChangeQty,
			BasicUnitPrice,
			SpareChangeDate,
			SpareChangeDateTime,
			IsMachineRepair,
			SparePartIOHistoryNo
		)
		VALUES
		(
			@pSparePartChangeHistoryNo,
			@pCompanyCode,
			@pWorkCenterCode,
			@pMachineCode,
			@pSparePartCode,
			@pChangeQty,
			@pBasicUnitPrice,
			GETDATE(),
			GETDATE(),
			1,
			@pSparePartIOHistoryNo
		)
		
		--설비수리자재이력 업데이트
		UPDATE STB_MachineRepairMaterialHist
		SET
				SparePartChangeHistoryNo = @pSparePartChangeHistoryNo
		WHERE
				MachineRepairHistoryNo = @pMachineRepairHistoryNo
				AND MachineRepairMaterialSeq = @pMachineRepairMaterialSeq
				
				
		--스페어파트재고에서 교체수량만큼 차감
		UPDATE STB_SparePartStockInfo
		SET
				CurrentStockQty = CurrentStockQty - @pChangeQty
		WHERE	
				SPWarehouseCode = @pSPWarehouseCode
				AND SPLocationCode = @pSPLocationCode
				AND SparePartCode = @pSparePartCode
				
		
		--설비별 스페어파트 최종교체일자 업데이트
		UPDATE STB_MachineSparePartInfo 
		SET
				LastChangeDate = GETDATE()
		WHERE
				MachineCode = @pMachineCode
				AND SparePartCode = @pSparePartCode
		
				
	END
	
	
	ELSE IF @pIUD_FLAG = 'UPDATE' BEGIN
		
		UPDATE STB_SparePartIOHistory
		SET
				SparePartIOTypeCode = @SparePartIOTypeCode,
				SparePartCode = @pSparePartCode,
				SPWarehouseCode = @pSPWarehouseCode,
				SPLocationCode = @pSPLocationCode,
				ProcessQty = @pChangeQty
		WHERE
				SparePartIOHistoryNo  = @pSparePartIOHistoryNo
		
		UPDATE STB_SparePartChangeHistory
		SET
				SparePartCode = @pSparePartCode,
				ChangeQty = @pChangeQty,
				BasicUnitPrice = @pBasicUnitPrice
		WHERE
				SparePartChangeHistoryNo = @pSparePartChangeHistoryNo
				
		
		
		UPDATE STB_SparePartStockInfo
		SET
				CurrentStockQty = CurrentStockQty + @OldChangeQty
		WHERE
				SPWarehouseCode = @OldSPWarehouseCode
				AND SPLocationCode = @OldSPLocationCode
				AND SparePartCode = @OldSparePartCode
		
		
		UPDATE STB_SparePartStockInfo
		SET
				CurrentStockQty = CurrentStockQty - @pChangeQty
		WHERE
				SPWarehouseCode = @pSPWarehouseCode
				AND SPLocationCode = @pSPLocationCode
				AND SparePartCode = @pSparePartCode
				
				
		
		--설비별 스페어파트 업데이트 이전 최종교체일자 구하기
		SELECT
				TOP 1
				@SpareChangeDate = SpareChangeDate
		FROM
				STB_SparePartChangeHistory 
		WHERE
				CompanyCode = @pCompanyCode
				AND WorkCenterCode = @pWorkCenterCode
				AND MachineCode = @pMachineCode
				AND SparePartCode = @OldSparePartCode
		ORDER BY
				SpareChangeDate DESC
		
		
				
		--설비별 스페어파트 최종교체일자 업데이트
		UPDATE STB_MachineSparePartInfo 
		SET
				LastChangeDate = @SpareChangeDate
		WHERE
				MachineCode = @pMachineCode
				AND SparePartCode = @OldSparePartCode
		
		UPDATE STB_MachineSparePartInfo
		SET
				LastChangeDate = GETDATE()
		WHERE
				MachineCode = @pMachineCode
				AND SparePartCode = @pSparePartCode
		
		
	END
	
	
	ELSE IF @pIUD_FLAG = 'DELETE' BEGIN
		
		DELETE FROM STB_MachineRepairMaterialHist 
		WHERE
				MachineRepairHistoryNo = @pOldMachineRepairHistoryNo 
				AND MachineRepairMaterialSeq = @pOldMachineRepairMaterialSeq
				
				
		DELETE FROM STB_SparePartChangeHistory 
		WHERE
				SparePartChangeHistoryNo = @pSparePartChangeHistoryNo
				
				
		DELETE FROM STB_SparePartIOHistory 
		WHERE
				SparePartIOHistoryNo = @pSparePartIOHistoryNo
				
		
		UPDATE STB_SparePartStockInfo 
		SET
				CurrentStockQty = CurrentStockQty + @OldChangeQty
		WHERE
				SPWarehouseCode = @OldSPWarehouseCode
				AND SPLocationCode = @OldSPLocationCode
				AND SparePartCode = @OldSparePartCode
		
		
		--설비별 스페어파트 업데이트 이전 최종교체일자 구하기
		SELECT
				TOP 1
				@SpareChangeDate = SpareChangeDate
		FROM
				STB_SparePartChangeHistory 
		WHERE
				CompanyCode = @pCompanyCode
				AND WorkCenterCode = @pWorkCenterCode
				AND MachineCode = @pMachineCode
				AND SparePartCode = @OldSparePartCode
		ORDER BY
				SpareChangeDate DESC
				
				
		--설비별 스페어파트 최종교체일자 업데이트	
		
			
		UPDATE STB_MachineSparePartInfo 
		SET
				LastChangeDate = @SpareChangeDate
		WHERE
				MachineCode = @pMachineCode
				AND SparePartCode = @OldSparePartCode
		
		UPDATE STB_MachineSparePartInfo
		SET
				LastChangeDate = GETDATE()
		WHERE
				MachineCode = @pMachineCode
				AND SparePartCode = @pSparePartCode
		
	END
	
	
	

END

