CREATE PROC [dbo].[usp_DoCreateModuleAssemblyLotNo]
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pModuleParentLotNo VARCHAR(20)
AS
BEGIN
	Declare @LoopCnt INT
	Declare @Header CHAR(4)
	Declare @SerialNo INT
	Declare @Barcode VARCHAR(20)
	Declare @CurrentCnt INT = 0
	Declare @ModuleParentLotNo VARCHAR(20) = @pModuleParentLotNo
	Declare @MaterialCode VARCHAR(20)

	Declare @PONo VARCHAR(20)
	Declare @DayPlanNo VARCHAR(20)

	-- 작업지시수량
	SELECT @LoopCnt = ProdQty
	      ,@MaterialCode = MaterialCode
		  ,@PONo = PONo
		  ,@DayPlanNo = DayPlanNo
	  FROM STB_SetInfo
	 WHERE Barcode = @ModuleParentLotNo

	SET @Header = LEFT(@ModuleParentLotNo, 4)

	-- 생성된 데이터가 있으면 생성 불가
	IF EXISTS (SELECT 1 FROM STB_ModuleAssemblyLabelInfo WHERE ModuleParentLotNo = @ModuleParentLotNo) BEGIN
		RAISERROR('조립 Lot 번호가 존재합니다. : KeyField = %s', 16, 1, @ModuleParentLotNo)
		RETURN
	END

	-- ★ 부모 LOT가 선점한 시리얼 초기화 → 자식 LOT은 001부터 시작
	UPDATE STB_SerialInfo
	SET    SerialNo = 0,
	       ChangeDateTime = GETDATE(),
	       ChangeUserID = @pProcessUserID
	WHERE  MaterialCode = ''
	  AND  Header = @Header

	 WHILE @CurrentCnt < @LoopCnt BEGIN
		EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
											@pMaterialCode = '',
											@pHeader = @Header,
											@pSerialNo = @SerialNo OUTPUT

		SET @Barcode = @Header + RIGHT('000' + CONVERT(VARCHAR,ISNULL(@SerialNo,1)), 3) 

		INSERT INTO STB_ModuleAssemblyLabelInfo (ModuleAssemblyLotNo, CreateUserID, ModuleParentLotNo)
			SELECT @Barcode, @pProcessUserID, @ModuleParentLotNo

		EXEC usp_DoCreateSetInfo	@pProcessUserID = 'eai',
								@pProcessLanguage = 'Korean',
								@pPONo = @PONo,
								@pDayPlanNo = @DayPlanNo,
								@pProdQty = 1,
								@pBarcode = @Barcode

		SET @CurrentCnt = @CurrentCnt + 1
	END

	-- ★ 자식 LOT 생성 완료 후, 불필요한 부모 LOT을 STB_SetInfo에서 삭제
	DELETE FROM STB_SetInfo
	WHERE Barcode = @ModuleParentLotNo
END
