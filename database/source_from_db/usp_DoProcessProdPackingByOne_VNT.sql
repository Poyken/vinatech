-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-29
-- Browsable : true
-- Group : 생산관리 > [B520] 제품 박스실적입력 > BoxID 생성버튼 클릭
-- Description:	BoxID를 생성합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessProdPackingByOne_VNT]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLineCode VARCHAR(20),
						@pRouteCode VARCHAR(20),
						@pBarcode VARCHAR(50),
						@pStockAttrib1 VARCHAR(20) = NULL,
						@pWorkerCode VARCHAR(20),
						@pMachineID VARCHAR(20),
						@pInProdQty NUMERIC(20,5),
						@pBoxQty INT = NULL,
						@pMachineCode VARCHAR(20) = NULL,
						@pPackingID VARCHAR(50) = NULL OUTPUT,
						@pMarkingCode varchar(20) = NULL -- Mr.Duy add cho nhà máy hà nam
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ERROR_MSG NVARCHAR(MAX)
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessDateTime DATETIME = GETDATE()
	DECLARE @LineCode VARCHAR(20) = @pLineCode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @Barcode VARCHAR(50) = @pBarcode
	DECLARE @StockAttrib1 VARCHAR(20) = ISNULL(@pStockAttrib1,'')
	DECLARE @WorkerCode VARCHAR(20) = ISNULL(@pWorkerCode,'')
	DECLARE @MachineID VARCHAR(20) = @pMachineID
	DECLARE @InProdQty NUMERIC(20,5) = @pInProdQty
	DECLARE @PackingID VARCHAR(50) = ISNULL(@pPackingID,'')
	DECLARE @BoxCount INT = ISNULL(@pBoxQty,1)
	DECLARE @MachineCode VARCHAR(20) = ISNULL(@pMachineCode,'')
	
	DECLARE @BoxID VARCHAR(50)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @LotNo VARCHAR(50)
	DECLARE @CurrentQty NUMERIC(20,5)
	DECLARE @ProdQty NUMERIC(20,5)
	DECLARE @Data VARCHAR(MAX)
	DECLARE @Header VARCHAR(20)
	DECLARE @Year INT = DATEPART(YEAR,@ProcessDateTime)
	DECLARE @Month INT = DATEPART(MONTH,@ProcessDateTime)
	DECLARE @YearCode VARCHAR(1)
	DECLARE @MonthCode VARCHAR(1) = CHAR(@Month + 73)	-- 1월이 J부터 시작
	DECLARE @DayCode VARCHAR(2) = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,@ProcessDateTime)),2)
	DECLARE @SerialNo INT
	DECLARE @Count INT = 1
	DECLARE @LotDecisionResult VARCHAR(10)
	DECLARE @IsHolding BIT
	DECLARE @ErrorMessage NVARCHAR(500)
	DECLARE @DPPExtText01 NVARCHAR(100)
	DECLARE @RouteIndex INT
	DECLARE @PONo VARCHAR(20)
	DECLARE @BefRouteName NVARCHAR(200)
	DECLARE @BefRouteCode VARCHAR(20)
	DECLARE @ControlNo VARCHAR(20)
	DECLARE @ErrorMsg NVARCHAR(500)

	SELECT
			@IsHolding = SI.SIExtInt01,
			@DPPExtText01 = DPP.DPPExtText01,
			@RouteIndex = POR.RouteIndex,
			@PONo = SI.PONo,
			@ControlNo = SI.ControlNo
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK)				   ON DPP.DayPlanNo = SI.DayPlanNo
			INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK) ON POR.PONo = SI.PONo             AND				POR.RouteCode = @RouteCode
	WHERE
			SI.Barcode = @Barcode

	IF ISNULL(@DPPExtText01,'') = '1'
	
	BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '마감처리된 Lot입니다'
			RETURN
	END

	SELECT
			@YearCode = YI.YearCode
	FROM
			STB_YearInfo YI
	WHERE
			YI.Year = @Year


   -- [공정검사 체크부분]
	IF ISNULL(@IsHolding,0) = 1 
	
	BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
											'^공정검사 불합격 제품입니다^',
											@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode)
			RETURN
	END

	

	-- 2019-10-25 JGH 수정 이전공정코드 가져오기
	--SELECT
	--		TOP 1
	--		@BefRouteCode = POR.RouteCode,
	--		@BefRouteName = RI.RouteName
	--FROM
	--		STB_ProductionOrderRouting POR
	--		LEFT OUTER JOIN STB_RouteInfo RI
	--			ON RI.RouteCode = POR.RouteCode
	--WHERE
	--		POR.PONo = @PONo AND
	--		POR.RouteIndex < @RouteIndex
	--ORDER BY
	--		POR.RouteIndex DESC

 ------------- Ha add 10/08/2024
		Declare @MaterialCot varchar(20)
		select @MaterialCot =SI.MaterialCode FROM STB_SetInfo SI   WHERE SI.Barcode = @Barcode
		if(@MaterialCot in ('LIVT38-009','VIVT38-018','VIVT38-007','LIVT38-018','LIVT38-026','LIVT38-007')) 
					begin
							SELECT
										TOP 1
										@BefRouteCode = POR.RouteCode,
										@BefRouteName = RI.RouteName
								FROM
										STB_ProductionOrderRouting POR
										LEFT OUTER JOIN STB_RouteInfo RI
											ON RI.RouteCode = POR.RouteCode
								WHERE
										POR.PONo = @PONo AND
										POR.RouteIndex < @RouteIndex AND
										POR.Routecode not in ('V-34_BG','V-29_BG','V-30_BG')
									
								ORDER BY
										POR.RouteIndex DESC	
							
					end
		else
					begin
								SELECT
										TOP 1
										@BefRouteCode = POR.RouteCode,
										@BefRouteName = RI.RouteName
								FROM
										STB_ProductionOrderRouting POR
										LEFT OUTER JOIN STB_RouteInfo RI
											ON RI.RouteCode = POR.RouteCode
								WHERE
										POR.PONo = @PONo AND
										POR.RouteIndex < @RouteIndex
								ORDER BY
										POR.RouteIndex DESC
					end	
-----------------------------------


	-- 2019-10-25 JGH 수정 이전공정 실적수량 가져오기
	SELECT
			@ProdQty = SUM(PRH.ProdQty)
	FROM
			STB_ProdRouteHist PRH
	WHERE
			PRH.ControlNo = @ControlNo AND
			--PRH.RouteCode =@BefRouteCode
			PRH.RouteCode like '%'+@BefRouteCode+'%' --chỉ khi nào lot từ bắc giang chuyển sang bắc ninh mà làm PO công đoạn bắc ninh thì mở ra mới có thể gộp box được.
		
		
		--declare @fd varchar(22)=@ProdQty

		--raiserror(@fd,16,1)
	-- 2019-10-25 JGH 수정 이전공정 실적수량이 없으면 에러 발생
	IF ISNULL(@ProdQty,0) = 0
	BEGIN

		SET @ErrorMsg = isnull(@BefRouteName,'') +  ' 공정에서 실적을 입력하지 않았습니다'
		EXEC usp_RaiseLocalizedError @pProcessLanguage,@ErrorMsg
		RETURN
	END

	


	WHILE @BoxCount >= @Count BEGIN
			SELECT
					@ProdQty = SI.ProdQty,
					@MaterialCode = SI.MaterialCode,
					@CurrentQty = ISNULL(SUM(PRH.ProdQty),0),
					@LotDecisionResult = SI.LotDecisionResult
			FROM
					STB_SetInfo SI
					LEFT OUTER JOIN STB_ProdRouteHist PRH
						ON PRH.ControlNo = SI.ControlNo AND
						PRH.RouteCode = @RouteCode
			WHERE
					SI.Barcode = @Barcode
			GROUP BY
					SI.MaterialCode,
					SI.ProdQty,
					SI.LotDecisionResult


			IF @LotDecisionResult <> 'Pass' and @Barcode not like 'MV%'  and ( upper(@ProcessLanguage)='VIETNAMESE') BEGIN
					EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
													'^Lot nay OQC chua danh gia PASS nen khong dong goi duoc!^',
													@ERROR_MSG OUTPUT
					SET @ERROR_MSG = @ERROR_MSG + ' [%s]/[%s]'
					RAISERROR(@ERROR_MSG,16,1,@Barcode,@LotDecisionResult)
					RETURN
			END


			--IF @LotDecisionResult <> 'Pass' and @Barcode not like 'MV%'   BEGIN
			--		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
			--										'^제품검사 합격판정 받은 Lot만 생산할수 있습니다^',
			--										@ERROR_MSG OUTPUT
			--		SET @ERROR_MSG = @ERROR_MSG + ' [%s]/[%s]'
			--		RAISERROR(@ERROR_MSG,16,1,@Barcode,@LotDecisionResult)
			--		RETURN
			--END
				--declare @aa varchar(20) = @InProdQty +1
					--RAISERROR(@RouteCode,16,1)
			IF @RouteCode NOT IN ('E-28', 'V-28', 'V-28_BG','EM-03', 'M-06','VE10')   --2022.02.09 추가 (MEA포장공정)
		
			BEGIN 
			    -- 포장 공정의 경우 갯수조정과 관련하여 Lot 총수량을 초과할 수 있음.
				IF @CurrentQty + @InProdQty > @ProdQty 
				
				    BEGIN	-- CurrentQty : 현재까지 생산한 수량, InputQty : 입력한 실적수량, ProdQty : SetInfo의 총수량
						EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage, '^Lot 총수량을 초과할수 없습니다^',	@ERROR_MSG OUTPUT
						SET @ERROR_MSG = @ERROR_MSG + ' [%s] ' + CONVERT(VARCHAR,@CurrentQty) + ' / ' + CONVERT(VARCHAR,@InProdQty) + ' / ' + CONVERT(VARCHAR,@ProdQty)
						RAISERROR(@ERROR_MSG,16,1,@Barcode)
						RETURN
				   END
			END


			-- 추가부분 
			-- 위에서 예외처리된 E-28 코드가 재처리됨. 위의 IF문 조건으로 통합하고 주석처리함.
			-- 2020.01.06 By Jackaroe

			--	IF @RouteCode <> 'V-28' 
				
			--	BEGIN -- 포장의 경우 갯수조정과 관련하여 Lot 총수량을 초과할 수 있음.
			--	IF @CurrentQty + @InProdQty > @ProdQty 
				
			--	BEGIN	-- CurrentQty : 현재까지 생산한 수량, InputQty : 입력한 실적수량, ProdQty : SetInfo의 총수량
			--			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
			--											'^Lot 총수량을 초과할수 없습니다^',
			--											@ERROR_MSG OUTPUT
			--			SET @ERROR_MSG = @ERROR_MSG + ' [%s] ' + CONVERT(VARCHAR,@CurrentQty) + ' / ' + CONVERT(VARCHAR,@InProdQty) + ' / ' + CONVERT(VARCHAR,@ProdQty)
			--			RAISERROR(@ERROR_MSG,16,1,@Barcode)
			--			RETURN
			--	END
			--END

-- 패킹ID 생성 Start부분인듯 ----
			SET @ProcessDateTime = GETDATE()
		
			INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 	VALUES ('usp_DoProcessProdPackingByOne_VNT', '@PackingID', @PackingID)

			IF ISNULL(@PackingID,'') = '' 
			BEGIN
					SET @Header = 'PK' + @YearCode + @MonthCode + @DayCode

					EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
														@pMaterialCode = '',
														@pHeader = @Header,
														@pSerialNo = @SerialNo OUTPUT

					SET @PackingID = @Header + RIGHT('00000' + CONVERT(VARCHAR,@SerialNo),5)
			END

			SET @Header = @YearCode + @MonthCode + @DayCode

			INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoProcessProdPackingByOne_VNT', '@Header', @Header)

			INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoProcessProdPackingByOne_VNT', '@PackingID', @PackingID)

			EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
																@pMaterialCode = @MaterialCode,
																@pHeader = @Header,
																@pSerialNo = @SerialNo OUTPUT

			SET @BoxID = RTRIM(@MaterialCode) + @Header + RIGHT('00000' + CONVERT(VARCHAR,@SerialNo),5)
			SET @LotNo = @Barcode

			INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoProcessProdPackingByOne_VNT', '@BoxID', @BoxID)

			INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoProcessProdPackingByOne_VNT', '@LotNo', @LotNo)


			--declare @aa varchar(20) = @InProdQty +1
			

			SET @Data = LEFT('PRODPACKING' + REPLICATE(' ',20),20) +
								LEFT(@LineCode + REPLICATE(' ',20),20) +
								LEFT(@RouteCode + REPLICATE(' ',20),20) +
								dbo.fnConvertDateTimeToVarChar('yyyyMMddHHmissfff',@ProcessDateTime) +
								LEFT(@Barcode + REPLICATE(' ',50),50) +
								LEFT(@WorkerCode + REPLICATE(' ',20),20) +
								LEFT(@BoxID + REPLICATE(' ',50),50) +
								LEFT(@LotNo + REPLICATE(' ',50),50) + 
								LEFT(@MachineCode + REPLICATE(' ',20),20) +
								--LEFT(CONVERT(VARCHAR(10),@InProdQty) + REPLICATE(' ',10),10) +
								LEFT(CONVERT(VARCHAR(10),CAST(@InProdQty AS INT)) + REPLICATE(' ',10),10) + --Mr.Duy change
								LEFT(@PackingID + REPLICATE(' ',50),50) + 
								LEFT(@StockAttrib1 + REPLICATE(' ',20),20)+
								LEFT((isnull(@pMarkingCode,'')) + REPLICATE(' ',20),20)

			--RAISERROR(@Data,16,1)
			--return
				
			EXEC usp_DoProcessTerminalData	@pProcessUserID = @ProcessUserID,
														@pProcessLanguage = @ProcessLanguage,
														@pIPAddress = @MachineID,
														@pPortNo = 0,
														@pData = @Data

			SET @pPackingID = @PackingID
			SET @PackingID = ''

			SET @Count = @Count + 1
	END
-- 패킹ID 생성 End부분인듯 ----

END

