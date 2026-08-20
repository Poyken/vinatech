-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-03-09
-- Browsable : true
-- Group : 생산관리
-- Description:	슬리팅결과생성
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateSlittingResult]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pElectrodeLotNumber VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(20) = NULL,
	@pElectrodeThick INT = NULL,
	@pSlittingWidth NUMERIC(20,5) = NULL,
	@pSlittingQty INT = NULL,
	@pGoodQtyLength NUMERIC(20,5) = NULL
AS
BEGIN
	Declare @ElectrodeLotNumber VARCHAR(20) = @pElectrodeLotNumber
	       ,@ElectrodeThick NUMERIC(20,5) = @pElectrodeThick
		   ,@SlittingWidth NUMERIC(20,5) = @pSlittingWidth
		   ,@SlittingQty INT = @pSlittingQty
		   ,@GoodQtyLength NUMERIC(20,5) = @pGoodQtyLength
		   ,@SlittingBarcodeSeq INT
		   ,@StartNumber INT = 1
		   ,@CompanyCode VARCHAR(20) = NULL
		   ,@SlittingMatrialCode VARCHAR(20) = @pMaterialCode -- CoatingToSlitting 적용 예정 Start 220204 SJC -- 슬리팅 작업자가 직접 입력하도록 변경

		   --declare @aa varchar(10) =@GoodQtyLength
		   --RAISERROR(@aa, 16,1)
	--전극(CoatingRoll) 바코드로 Company 정보 조회
	SELECT @CompanyCode = DPP.CompanyCode
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_DayProdPlan DPP 
		ON SI.DayPlanNo = DPP.DayPlanNo
	 WHERE SI.Barcode = @ElectrodeLotNumber

-- 마스터 테이블에서 찾는 방식에서 작업자가 입력하는 방식으로 변경 2025.07.03 by Jackaroe
/*
	SELECT @SlittingMatrialCode = STSM.SlittingMaterialCode
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_CoatingToSlittingMaster STSM
	    ON SI.MaterialCode = STSM.CoatingMaterialCode
	 WHERE SI.Barcode = @ElectrodeLotNumber
	   AND STSM.SlittingWidth = @SlittingWidth
	   AND STSM.CompanyCode = @CompanyCode
*/
	--IF @@ROWCOUNT = 0 
	--	BEGIN
	--	RAISERROR('Slitting 품번이 존재 하지 않습니다. 슬리팅 폭 확인 바랍니다.', 16,1)
	--	RETURN
	--	END	-- CoatingToSlitting 적용 예정 End 220204 SJC
	

	--================================== Mr.Manh update on 2025-07-17 for Bac Giang Factory -----------------------------------------
	DECLARE @MachineCode VARCHAR(30)
	DECLARE @KnifeCheck INT
	DECLARE @KnifeCode VARCHAR(30)
	DECLARE @ProdQtyCheck BIGINT
	DECLARE @StandardQty BIGINT
	DECLARE @SlittingKnifeLotID VARCHAR(30)

	-- Lấy mã máy của Lot hiện tại
	SELECT @MachineCode =  MachineCode FROM STB_ElectrodeSlittingInfo WHERE ElectrodeLotNumber = @ElectrodeLotNumber

	-- Kiểm tra nếu tồn tại 1 loại dao trong máy hiện tại
	SELECT @KnifeCheck = count(*) FROM STB_VN_SlittingKnifeInUse 
			WHERE UsingStatus = 1 AND MachineCode = @MachineCode
	
	

	-- Điều kiện
	IF @MachineCode IN (select MachineCode from STB_ProductMachine where RouteCode = 'V-11_BG') and @KnifeCheck > 0
		BEGIN

			SELECT @SlittingKnifeLotID = SlittingKnifeLotID,
					@KnifeCode = SlittingKnifeCode
					FROM STB_VN_SlittingKnifeInUse 
					WHERE UsingStatus = 1 AND MachineCode = @MachineCode

			--INSERT INTO STB_VN_SlittingKnifeLotInfo (SlittingKnifeLotID, ElectrodeLotNumber, CreateDateTime) VALUES (@SlittingKnifeLotID, @ElectrodeLotNumber, GETDATE())
			-- Kiểm tra số lượng đã cắt
			SELECT @ProdQtyCheck = COUNT(ProductionQty) from STB_ElectrodeSlittingResult where SlittingKnifeLotID = @SlittingKnifeLotID
			SELECT @StandardQty = StandardQty FROM STB_VN_SlittingKnifeInfo WHERE SlittingKnifeCode = @KnifeCode


			IF(@ProdQtyCheck >= @StandardQty)
				BEGIN
					RAISERROR(N'Đã đến giới hạn phải thay dao!', 16,1)
					RETURN
				END

			WHILE @StartNumber <= @SlittingQty BEGIN
				-- Get Next Seq
				EXEC usp_GetNewSerialNoForBarcode @pProcessUserID, '', @ElectrodeLotNumber, @SlittingBarcodeSeq OUTPUT

				-- INSERT DATA
				INSERT INTO STB_ElectrodeSlittingResult (ElectrodeLotNumber, Seq, ElectrodeThick, SlittingWidth, ProductionQty
														,GoodQtyLength, CreateDateTime, CreateUserID, SlittingMaterialCode,CompanyCode,WorkCenterCode, SlittingKnifeLotID
				) VALUES (@ElectrodeLotNumber, @SlittingBarcodeSeq, @ElectrodeThick, @SlittingWidth, @GoodQtyLength
						 ,@GoodQtyLength, GETDATE(), @pProcessUserID, @SlittingMatrialCode,'VVT','VVT_F1', @SlittingKnifeLotID)

				SET @StartNumber = @StartNumber + 1
			END

		END
	ELSE IF @MachineCode IN (select MachineCode from STB_ProductMachine where RouteCode = 'V-11_BG') and @KnifeCheck = 0
		BEGIN
			RAISERROR(N'Máy hiện tại chưa có dao!', 16,1)
			RETURN
		END


	ELSE
		BEGIN
			WHILE @StartNumber <= @SlittingQty BEGIN
				-- Get Next Seq
				EXEC usp_GetNewSerialNoForBarcode @pProcessUserID, '', @ElectrodeLotNumber, @SlittingBarcodeSeq OUTPUT

				-- INSERT DATA
				INSERT INTO STB_ElectrodeSlittingResult (ElectrodeLotNumber, Seq, ElectrodeThick, SlittingWidth, ProductionQty
														,GoodQtyLength, CreateDateTime, CreateUserID, SlittingMaterialCode,CompanyCode,WorkCenterCode
				) VALUES (@ElectrodeLotNumber, @SlittingBarcodeSeq, @ElectrodeThick, @SlittingWidth, @GoodQtyLength
						 ,@GoodQtyLength, GETDATE(), @pProcessUserID, @SlittingMatrialCode,'VVT','VVT_F1')

				SET @StartNumber = @StartNumber + 1
			END
		END


	--WHILE @StartNumber <= @SlittingQty BEGIN
	--	-- Get Next Seq
	--	EXEC usp_GetNewSerialNoForBarcode @pProcessUserID, '', @ElectrodeLotNumber, @SlittingBarcodeSeq OUTPUT

	--	-- INSERT DATA
	--	INSERT INTO STB_ElectrodeSlittingResult (ElectrodeLotNumber, Seq, ElectrodeThick, SlittingWidth, ProductionQty
	--	                                        ,GoodQtyLength, CreateDateTime, CreateUserID, SlittingMaterialCode,CompanyCode,WorkCenterCode
	--	) VALUES (@ElectrodeLotNumber, @SlittingBarcodeSeq, @ElectrodeThick, @SlittingWidth, @GoodQtyLength
	--	         ,@GoodQtyLength, GETDATE(), @pProcessUserID, @SlittingMatrialCode,'VVT','VVT_F1')

	--	SET @StartNumber = @StartNumber + 1
	--END
	
END