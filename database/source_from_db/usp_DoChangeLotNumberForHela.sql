-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-09-26
-- Browsable : true
-- Group : 생산관리
-- Description: VV로 생산된 헬라향 바코드 정보를 수정합니다.
-- =============================================
CREATE PROC usp_DoChangeLotNumberForHela
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pBaseDate DATE
   ,@pBarcode VARCHAR(20)
AS
BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode
	       ,@BaseDate DATE = @pBaseDate
	       ,@MaxSeq INT
		   ,@FirstString VARCHAR(10) = 'VJ' -- VV로 시작하는 Lot만 처리할 수 있으므로 고정해도 문제가 되지 않음. 차후 베트남에서 반대의 경우를 처리해야한다면, 사용자의 Company코드에 따라 수정해주어야 함.
		   ,@Header VARCHAR(20)
		   ,@SerialNo INT
		   ,@Year INT
		   ,@YearCode CHAR(1)
		   ,@Month INT
		   ,@MonthCode CHAR(1)
		   ,@Volt VARCHAR(20)
		   ,@Capacity VARCHAR(20)

	Declare @DayCode VARCHAR(2) = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,@BaseDate)),2) -- Declare를 분리하지 않으면 선언과 동시에 기본값을 줄 수 없음.
	       ,@NewBarcode VARCHAR(20)
		   ,@ControlNo VARCHAR(20)

	IF NOT EXISTS (SELECT 1 FROM STB_SetInfo WHERE Barcode = @Barcode) BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, 'Lot번호가 존재하지 않습니다.'
		RETURN
	END

	IF LEFT(@Barcode, 2) = 'VJ' BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, 'VJ로 시작하는 Lot입니다. 처리할 수 없습니다.'
		RETURN
	END

	IF EXISTS (SELECT 1 FROM STB_LotNumberChangeHistForHela WHERE OldBarcode = @Barcode) BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '처리 이력이 존재합니다. 처리할 수 없습니다.'
		RETURN
	END

	IF EXISTS (SELECT 1 FROM STB_LotNumberChangeHistForHela WHERE NewBarcode = @Barcode) BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '처리 이력이 존재합니다. 처리할 수 없습니다.'
		RETURN
	END

	-- ControlNo
	SELECT @ControlNo = ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode

	-- 파라미터로 받은 날짜에 대한 헤더를 미리 구함.
	SET @Year    = DATEPART(YEAR,@BaseDate)
	SET @Month = DATEPART(MONTH,@BaseDate)
	SET @MonthCode = CHAR(@Month + 73)	-- 1월이 J부터 시작

	SELECT @YearCode = YI.YearCode
	  FROM STB_YearInfo YI WITH(NOLOCK)
	 WHERE YI.Year = @Year

	SELECT @Volt = MBI.MBIExtText01,
		   @Capacity = MBI.MBIExtText02
	  FROM VW_ModelBasicInfo MBI
	 WHERE ModelCode = (SELECT MaterialCode 
	                      FROM STB_SetInfo 
						 WHERE Barcode = @Barcode)

	SET @Header = @FirstString + @YearCode + @MonthCode + @DayCode + @Volt + @Capacity

	-- 원본Lot번호와 동일한 구성 VJ Lot의 Max Seq
	SELECT @MaxSeq = SerialNo
	  FROM STB_SerialInfo
	 WHERE Header = LEFT (REPLACE(@Barcode, 'VV', 'VJ') , 12)

	IF @MaxSeq = 99 BEGIN
		-- 지정일 기준의 Max Seq
		SELECT @MaxSeq = SerialNo
		  FROM STB_SerialInfo
		 WHERE Header = @Header

		 IF @MaxSeq = 99 BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '지정된 날짜의 Lot 일련번호가 더 이상 존재하지 않습니다.'
			RETURN
		 END ELSE BEGIN
			-- 지정된 날짜 기준으로 VJ 신규 바코드 생성
			EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
														  @pMaterialCode = '',
														  @pHeader = @Header,
														  @pSerialNo = @SerialNo OUTPUT

			SET @NewBarcode = @Header + RIGHT('00' + CONVERT(VARCHAR,ISNULL(@SerialNo,0)), 2) 
		 END
	END ELSE BEGIN
		-- 동일한 날짜 기준으로 VJ 신규 바코드 생성
		-- @Header 변경
		SET @Header = LEFT (REPLACE(@Barcode, 'VV', 'VJ') , 12)

		EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
														  @pMaterialCode = '',
														  @pHeader = @Header,
														  @pSerialNo = @SerialNo OUTPUT

		SET @NewBarcode = @Header + RIGHT('00' + CONVERT(VARCHAR,ISNULL(@SerialNo,0)), 2) 
	END

	-- Lot번호 변경 처리
	-- 1. Barcode = LotNumber 이면, 
	IF EXISTS (SELECT 1 FROM STB_SetInfo WHERE Barcode = @Barcode AND Barcode = LotNumber) BEGIN
		-- STB_SetInfo의 LotNumber 업데이트
		UPDATE STB_SetInfo
		   SET LotNumber = @NewBarcode
		 WHERE Barcode = @Barcode

		-- STB_MaterialQcInfo의 MaterialQcNo 업데이트
		UPDATE STB_MaterialQcInfo
		   SET MaterialQcNo = @NewBarcode
		 WHERE MaterialQcNo = @Barcode
	END

	-- 2. STB_MaterialDocLotInfo의 LotNo 업데이트
	UPDATE STB_MaterialDocLotInfo
	   SET LotNo = @NewBarcode
	 WHERE LotNo = @Barcode

	-- 3. STB_MaterialLotInfo의 LotNo 업데이트
	UPDATE STB_MaterialLotInfo
	   SET LotNo = @NewBarcode
	 WHERE LotNo = @Barcode

	-- 4. STB_SetInfo의 Barcode 업데이트
	UPDATE STB_SetInfo
	   SET Barcode = @NewBarcode
	 WHERE Barcode = @Barcode

	-- 5. 변경이력 생성
	INSERT INTO STB_LotNumberChangeHistForHela (ControlNo, OldBarcode, NewBarcode, CreateUserID)
		SELECT @ControlNo, @Barcode, @NewBarcode, @pProcessUserID

	SELECT ControlNo
	      ,OldBarcode
		  ,NewBarcode
		  ,CreateDateTime
		  ,CreateUserID
		  ,ChangeDateTime
		  ,ChangeUserID
	  FROM STB_LotNumberChangeHistForHela
	 WHERE OldBarcode = @Barcode
END