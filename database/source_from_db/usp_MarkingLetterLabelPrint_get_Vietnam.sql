-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-11-05
-- Description:	Get Marking Letter
-- =============================================


-- exec usp_MarkingLetterLabelPrint_get_Vietnam '', '', 'VVPT053R072704', '', ''

CREATE PROCEDURE [dbo].[usp_MarkingLetterLabelPrint_get_Vietnam] 
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pLotNo1 VARCHAR(50) = NULL,
			@pLotNo2 VARCHAR(50) = NULL,
			@pLotNo3 VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE		 @LotNo1 VARCHAR(50) = @pLotNo1
					,@LotNo2 VARCHAR(50) = @pLotNo2
					,@LotNo3 VARCHAR(50) = @pLotNo3
					,@IsProdFinish1 BIT
					,@IsProdFinish2 BIT
					,@IsProdFinish3 BIT
					,@error NVARCHAR(MAX)
					,@MarkingLetter1 NVARCHAR(50)
					,@MarkingLetter2 NVARCHAR(50)
					,@MarkingLetter3 NVARCHAR(50)

		-- có thể tìm được khi lotno đã đc chuyển đổi lot
		DECLARE @NewBarcode1 VARCHAR(30) = NULL
		DECLARE @NewBarcode2 VARCHAR(30) = NULL
		DECLARE @NewBarcode3 VARCHAR(30) = NULL
		SELECT @NewBarcode1 = NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @LotNo1
		SELECT @NewBarcode2 = NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @LotNo2
		SELECT @NewBarcode3 = NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @LotNo3


			-- Check LotNo
		SELECT	@IsProdFinish1 = IsProdFinish,
				@MarkingLetter1 = SIExtText07
		  FROM STB_SetInfo SI WITH(NOLOCK)
		LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
		 WHERE Barcode = @LotNo1 or Barcode = @NewBarcode1

		 SELECT @IsProdFinish2 = IsProdFinish,
				@MarkingLetter2 = SIExtText07
		  FROM STB_SetInfo SI WITH(NOLOCK)
		LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
		 WHERE Barcode = @LotNo2 or Barcode = @NewBarcode2

		 SELECT @IsProdFinish3 = IsProdFinish,
				@MarkingLetter3 = SIExtText07
		  FROM STB_SetInfo SI WITH(NOLOCK)
		LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
		 WHERE Barcode = @LotNo3 or Barcode = @NewBarcode3


		IF ISNULL(@LotNo1, '') <> '' AND @IsProdFinish1 IS NULL 
			BEGIN 
				SET @error = N'Mã Lotno1 "' + @Lotno1 + N'" không tồn tại trên hệ thống.!'
				EXEC usp_RaiseLocalizedError @pProcessLanguage, @error
				RETURN
			END
		IF ISNULL(@LotNo2, '') <> '' AND @IsProdFinish2 IS NULL 
			BEGIN 
				SET @error = N'Mã Lotno2 "' + @Lotno2 + N'" không tồn tại trên hệ thống.!'
				EXEC usp_RaiseLocalizedError @pProcessLanguage, @error
				RETURN
			END
		IF ISNULL(@LotNo3, '') <> '' AND @IsProdFinish3 IS NULL 
			BEGIN 
				SET @error = N'Mã Lotno3 "' + @Lotno3 + N'" không tồn tại trên hệ thống.!'
				EXEC usp_RaiseLocalizedError @pProcessLanguage, @error
				RETURN
			END


		-- select * from STB_SetInfo where Barcode = 'VVPT043R010641'

		--raiserror(@MarkingLetter2, 16, 1)
		--return

		DECLARE @MarkingLabel NVARCHAR(MAX) 
		SET @MarkingLabel = @MarkingLetter1  
			+(CASE WHEN @MarkingLetter2 IS NULL OR ISNULL(@MarkingLetter2,'')='' THEN ''
				--WHEN (ISNULL(@MarkingLetter2,'')='' OR ISNULL(@MarkingLetter1,'')='') THEN @MarkingLetter2
				ELSE CONCAT(' - ', @MarkingLetter2)
			END)
			+(CASE WHEN @MarkingLetter3 IS NULL OR ISNULL(@MarkingLetter3,'')='' THEN ''
				--WHEN (ISNULL(@MarkingLetter3,'')='' OR ISNULL(@MarkingLetter2,'')='')  THEN @MarkingLetter3
				ELSE CONCAT(' - ', @MarkingLetter3)
			END)


		SELECT
			@MarkingLabel AS MarkingLetters,
			@LotNo1 AS LotNo1,
			@MarkingLetter1 AS MarkingLetter1,
			@LotNo2 AS LotNo2,
			@MarkingLetter2 AS MarkingLetter2,
			@LotNo3 AS LotNo3,
			@MarkingLetter3 AS MarkingLetter3,
			1 AS LabelQty,
			'Report' AS CommandType


END
