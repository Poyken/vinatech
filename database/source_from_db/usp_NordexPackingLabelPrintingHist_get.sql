CREATE PROC usp_NordexPackingLabelPrintingHist_get
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pMFGDate DATE
   ,@pLabelQty INT
AS
BEGIN
	Declare @MFGDate VARCHAR(20) = CONVERT(CHAR(8), @pMFGDate, 112)
	Declare @LabelQty INT = @pLabelQty
	Declare @MaxLabelQty INT = 0
	Declare @cnt INT = 1

	SELECT @MaxLabelQty = ISNULL(MAX(Seq), 0)
	  FROM STB_NordexPackingLabelPrintingHist
	 WHERE MFGDate = @MFGDate

    IF @LabelQty <> 0 BEGIN
	    IF @MaxLabelQty + @LabelQty > 99 BEGIN
			RAISERROR('제조일자를 기준으로 발행할 수 있는 라벨의 수량은 99개를 초과할 수 없습니다.' ,16, 1)
			RETURN
	    END
   
	    WHILE @cnt <= @LabelQty BEGIN
			INSERT INTO STB_NordexPackingLabelPrintingHist
				SELECT @MFGDate, RIGHT('0' + CONVERT(VARCHAR(2), @MaxLabelQty + @cnt), 2), GETDATE(), @pProcessUserID

			SET @cnt = @cnt + 1
	    END
   END

   SELECT MFGDate
         ,Seq
		 ,CreateDateTime
		 ,CreateUserID
		 ,'Report' AS CommandType
	  FROM STB_NordexPackingLabelPrintingHist
	 WHERE MFGDate = @MFGDate
	 ORDER BY Seq
END