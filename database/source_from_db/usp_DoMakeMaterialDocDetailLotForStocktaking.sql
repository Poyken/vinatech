
-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Group : 자재관리 > [F750]자재재고실사 >  실사반영처리 버튼처리시 호출받는 프로시저(중요)
-- Create date: 2018-09-17
-- Description:	재고실사 기준데이터로 DocDetail, DocLotInfo 를 생성합니다  
--                  2020.06.11 PackingID부분 수정 (kilee) 
--                  2020.07.14 자동 PackingID 생성되도록 수정 (kilee) -> 백업용 : usp_DoMakeMaterialDocDetailLotForStocktaking_20200714

-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMakeMaterialDocDetailLotForStocktaking]
						@pProcessLanguage VARCHAR(20),
						@pProcessUserID VARCHAR(20),
						@pMaterialDocNo VARCHAR(20),
						@pMaterialLotNo VARCHAR(20),
						@pMaterialCode VARCHAR(50),
						@pMaterialStockAttribute VARCHAR(20),
						@pLotID VARCHAR(50) = NULL,
						@pStockAttrib1 VARCHAR(20) = NULL,
						@pStockAttrib2 VARCHAR(20) = NULL,
						@pStockAttrib3 VARCHAR(20) = NULL,
						@pMaterialLocationCode VARCHAR(20) = NULL,
						@pRequestQty NUMERIC(20,5),
						@pPackingID VARCHAR(50) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
				@ProcessUserID VARCHAR(20) = @pProcessUserID,
				@MaterialDocNo VARCHAR(20) = @pMaterialDocNo,
				@MaterialLotNo VARCHAR(20) = @pMaterialLotNo,
				@MaterialCode VARCHAR(50) = @pMaterialCode,
				@MaterialStockAttribute VARCHAR(20) = @pMaterialStockAttribute,
				@LotID VARCHAR(50) = ISNULL(@pLotID,''),
				@StockAttrib1 VARCHAR(20) = ISNULL(@pStockAttrib1,''),
				@StockAttrib2 VARCHAR(20) = ISNULL(@pStockAttrib2,''),
				@StockAttrib3 VARCHAR(20) = ISNULL(@pStockAttrib3,''),
				@MaterialLocationCode VARCHAR(20) = @pMaterialLocationCode,
				@RequestQty NUMERIC(20,5) = @pRequestQty,
				@PackingID VARCHAR(50) = @pPackingID


	DECLARE @MaterialDocDetailNo VARCHAR(20)
	DECLARE @MDLISeqNo INT
	DECLARE @ErrorMessage NVARCHAR(500)

	SELECT
			@MaterialDocDetailNo = MDD.MaterialDocDetailNo
	FROM
			STB_MaterialDocDetail MDD
	WHERE
			MDD.MaterialDocNo = @MaterialDocNo AND
			MDD.MaterialCode = @MaterialCode AND
			MDD.MaterialStockAttribute = @MaterialStockAttribute AND
			MDD.StockAttrib1 = @StockAttrib1 AND
			MDD.StockAttrib2 = @StockAttrib2 AND
			MDD.StockAttrib3 = @StockAttrib3

	IF ISNULL(@MaterialDocDetailNo,'') = '' 
	
	BEGIN
			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocDetail', @MaterialDocDetailNo OUTPUT

			INSERT INTO STB_MaterialDocDetail
			(
				MaterialDocDetailNo,
				MaterialDocNo,
				MaterialCode,
				MaterialStockAttribute,
				StockAttrib1,
				StockAttrib2,
				StockAttrib3,
				RequestQty,
				AllowQty,
				PickingAssignQty,
				PickingQty,
				ProcessFixQty,
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@MaterialDocDetailNo,
				@MaterialDocNo,
				@MaterialCode,
				@MaterialStockAttribute,
				@StockAttrib1,
				@StockAttrib2,
				@StockAttrib3,
				@RequestQty,
				@RequestQty,
				@RequestQty,
				@RequestQty,
				0,
				GETDATE(),
				@ProcessUserID
			)
	END ELSE 
	
	BEGIN
			UPDATE	STB_MaterialDocDetail
			SET
					RequestQty = RequestQty + @RequestQty,
					AllowQty = AllowQty + @RequestQty,
					PickingAssignQty = PickingAssignQty + @RequestQty,
					PickingQty = PickingQty + @RequestQty
			WHERE
					MaterialDocDetailNo = @MaterialDocDetailNo
	END

	SET @MDLISeqNo = ISNULL((SELECT MAX(MDLISeqNo) FROM STB_MaterialDocLotInfo WHERE MaterialDocDetailNo = @MaterialDocDetailNo),0) + 1

	IF ISNULL(@MaterialLotNo,'') <> ''
	 BEGIN
			INSERT INTO STB_MaterialDocLotInfo
			(
				MaterialDocDetailNo,
				MDLISeqNo,
				MaterialLotNo,
				LotID,
				MaterialCode,
				MaterialStockAttribute,
				StockAttrib1,
				StockAttrib2,
				StockAttrib3,
				StockQty,
				IsChecked,
				MaterialLocationCode,
				MaterialDocNo,
				PackingID,
				LotNo,
				VendorLotNo,
				LotAttr01,
				LotAttr02,
				LotAttr03,
				LotAttr04,
				LotAttr05,
				LotAttr06,
				LotAttr07,
				LotAttr08,
				LotAttr09,
				LotAttr10,
				CreateDateTime,
				CreateUserID
			)
			SELECT
					@MaterialDocDetailNo,
					@MDLISeqNo,
					MLI.MaterialLotNo,
					MLI.LotID,
					MLI.MaterialCode,
					MLI.MaterialStockAttribute,
					MLI.StockAttrib1,
					MLI.StockAttrib2,
					MLI.StockAttrib3,
					@RequestQty,
					1,
					MLI.MaterialLocationCode,
					@MaterialDocNo,
					MLI.PackingID,
					MLI.LotNo,
					MLI.VendorLotNo,
					MLI.LotAttr01,
					MLI.LotAttr02,
					MLI.LotAttr03,
					MLI.LotAttr04,
					MLI.LotAttr05,
					MLI.LotAttr06,
					MLI.LotAttr07,
					MLI.LotAttr08,
					MLI.LotAttr09,
					MLI.LotAttr10,
					GETDATE(),
					@ProcessUserID
			FROM
					STB_MaterialLotInfo MLI
			WHERE
					MLI.MaterialLotNo = @MaterialLotNo
	END ELSE BEGIN		-- MaterialLot에 없는 품목 입고할때
			DECLARE @IsUseBarcode BIT

			
			SELECT
					@IsUseBarcode = MSA.IsUseBarcode
			FROM
					STB_MaterialStockAttributeInfo MSA
			WHERE
					MSA.MaterialCode = @MaterialCode

			IF @IsUseBarcode = 1 AND @LotID = ''           -- 바코드 없는지 체크		
					BEGIN
				 			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage, '^바코드 사용품목은 바코드가 필수입니다^', @ErrorMessage OUTPUT
							SET @ErrorMessage = @ErrorMessage + ' [%s]'
							RAISERROR(@ErrorMessage,16,1,@MaterialCode)
							RETURN
					END

--- 2020.07.14 패킹아이디 부분 추가 Start
		   DECLARE @ProcessDateTime DATETIME = GETDATE()
		   DECLARE @BoxID VARCHAR(50)
		-- DECLARE @MaterialCode VARCHAR(50)
			DECLARE @LotNo VARCHAR(50)
			DECLARE @CurrentQty NUMERIC(20,5)
			DECLARE @ProdQty NUMERIC(20,5)
			DECLARE @Data VARCHAR(MAX)
			DECLARE @Header VARCHAR(20)
			DECLARE @Year INT = DATEPART(YEAR,@ProcessDateTime)
			DECLARE @Month INT = DATEPART(MONTH,@ProcessDateTime)  
			DECLARE @YearCode VARCHAR(1)
			DECLARE @MonthCode VARCHAR(1) = CHAR(@Month + 73)            --                                          	-- 1월이 J부터 시작
			DECLARE @DayCode VARCHAR(2) = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,@ProcessDateTime)),2)   
			DECLARE @SerialNo INT
			DECLARE @Count INT = 1

				SELECT
						@YearCode = YI.YearCode
				FROM
						STB_YearInfo YI
				WHERE
						YI.Year = @Year

		   	IF ISNULL(@PackingID,'') = ''
			
			 BEGIN
					SET @Header = 'PT' + @YearCode + @MonthCode + @DayCode        --  PT+K+P+14

					EXEC usp_GetNewSerialNoForBarcode	
																@pProcessUserID = @pProcessUserID,
																@pMaterialCode = '',
																@pHeader = @Header,					
																@pSerialNo = @SerialNo OUTPUT

					SET @PackingID = @Header + RIGHT('00000' + CONVERT(VARCHAR,@SerialNo),5)
			END

			--SET @Header = @YearCode + @MonthCode + @DayCode

			--INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoProcessProdPackingByOne_VNT', '@Header', @Header)
			--INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoProcessProdPackingByOne_VNT', '@PackingID', @PackingID)

			----INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoProcessProdPackingByOne_VNT', 'Header', 'HeaderTest')
			----INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoProcessProdPackingByOne_VNT', '@PackingID', @PackingID)

			--EXEC usp_GetNewSerialNoForBarcode	
			--                                    @pProcessUserID = @pProcessUserID,
			--									@pMaterialCode = @MaterialCode,
			--									--@pHeader = @Header,
			--									@pHeader = 'Get_Header',
			--									@pSerialNo = @SerialNo OUTPUT

			--SET @BoxID = @MaterialCode + @Header + RIGHT('00000' + CONVERT(VARCHAR,@SerialNo),5)
			----SET @LotNo = @Barcode

			--INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 	VALUES ('usp_DoProcessProdPackingByOne_VNT', '@BoxID', @BoxID)
			--INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 	VALUES ('usp_DoProcessProdPackingByOne_VNT', '@LotNo', @LotNo)

			----SET @Data = 
			----            LEFT('PRODPACKING' + REPLICATE(' ',20),20) +
			----			LEFT(@LineCode + REPLICATE(' ',20),20) +
			----			LEFT(@RouteCode + REPLICATE(' ',20),20) +
			----			dbo.fnConvertDateTimeToVarChar('yyyyMMddHHmissfff',@ProcessDateTime) +
			----			LEFT(@Barcode + REPLICATE(' ',50),50) +
			----			LEFT(@WorkerCode + REPLICATE(' ',20),20) +
			----			LEFT(@BoxID + REPLICATE(' ',50),50) +
			----			LEFT(@LotNo + REPLICATE(' ',50),50) + 
			----			LEFT(@MachineCode + REPLICATE(' ',20),20) +
			----			LEFT(CONVERT(VARCHAR(10),@InProdQty) + REPLICATE(' ',10),10) +
			----			LEFT(@PackingID + REPLICATE(' ',50),50) + 
			----			LEFT(@StockAttrib1 + REPLICATE(' ',20),20)

		

			--EXEC usp_DoProcessTerminalData	
			--                                @pProcessUserID = @ProcessUserID,
			--								@pProcessLanguage = @ProcessLanguage,
			--								@pIPAddress = 'TestMachine',
			--								--@pIPAddress = @MachineID,
			--								@pPortNo = 0,
			--								--@pData = @Data
			--								@pData = 'TestData'

			--SET @pPackingID = @PackingID
			--SET @PackingID = ''

			--SET @Count = @Count + 1

----- 추가부분 End

			INSERT INTO STB_MaterialDocLotInfo
			(
				MaterialDocDetailNo,
				MDLISeqNo,
				MaterialLotNo,
				LotID,
				MaterialCode,
				MaterialStockAttribute,
				StockAttrib1,
				StockAttrib2,
				StockAttrib3,
				StockQty,
				IsChecked,
				MaterialLocationCode,
				MaterialDocNo,
				PackingID,
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@MaterialDocDetailNo,
				@MDLISeqNo,
				'',
				@LotID,
				@MaterialCode,
				@MaterialStockAttribute,
				@StockAttrib1,
				@StockAttrib2,
				@StockAttrib3,
				@RequestQty,
				1,
				@MaterialLocationCode,
				@MaterialDocNo,				
				@PackingID,				
				GETDATE(),
				@ProcessUserID
			)
	END

END