-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-06
-- Browsable : false
-- Group : 현장용
-- Description:	공용 검사이력을 추가 합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddCommInspMeasureHistForBarcode_SmartApp]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCommInspDocNo VARCHAR(20),
	@pCommInspDocItemNo VARCHAR(20),
	@pTextMeasure VARCHAR(50) = NULL,
	@pNumericMeasure NUMERIC(20,5) = NULL,
	@pCheckDisplay BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@CommInspDocNo VARCHAR(20) = @pCommInspDocNo,
			@CommInspDocItemNo VARCHAR(20) = @pCommInspDocItemNo,
			@TextMeasure VARCHAR(50) = @pTextMeasure,
			@NumericMeasure NUMERIC(20,5) = @pNumericMeasure,
			@CheckDisplay BIT = @pCheckDisplay

	DECLARE @CommInspMeasureNo VARCHAR(20)
	DECLARE @IsAutoFinish BIT
	DECLARE @CommInspInputType VARCHAR(1)
	DECLARE @CommInspItemSpec VARCHAR(50)
	DECLARE @CommInspUpper VARCHAR(50)
	DECLARE @CommInspLower VARCHAR(50)
	DECLARE @CheckResult VARCHAR(10) = 'NG'
	DECLARE @UpperResult BIT = 0
	DECLARE @LowerResult BIT = 0

	SELECT
			@CommInspInputType = CIDI.CommInspInputType,
			@CommInspItemSpec = CIDI.COmmInspItemSpec,
			@CommInspUpper = CIDI.CommInspUpper,
			@CommInspLower = CIDI.CommInspLower
	FROM
			STB_CommInspDocItem CIDI
	WHERE
			CIDI.CommInspDocItemNo = @CommInspDocItemNo

	IF @CommInspInputType = '1' BEGIN		-- NUMERIC
			IF ISNULL(@CommInspUpper,'') = '' BEGIN
					SET @UpperResult = 1
			END ELSE BEGIN
					IF CONVERT(NUMERIC(20,5),@CommInspUpper) >= @NumericMeasure BEGIN
							SET @UpperResult = 1
					END
			END

			IF ISNULL(@CommInspLower,'') = '' BEGIN
					SET @LowerResult = 1
			END ELSE BEGIN
					IF CONVERT(NUMERIC(20,5),@CommInspLower) <= @NumericMeasure BEGIN
							SET @LowerResult = 1
 					END
			END

			IF (@UpperResult = 1) AND (@LowerResult = 1) BEGIN
					SET @CheckResult = 'OK'
			END
	END ELSE IF @CommInspInputType = '2' BEGIN	-- CHECK
			IF ISNULL(@CheckDisplay,0) = 1 BEGIN
					SET @CheckResult = 'OK'
			END
	END ELSE IF @CommInspInputType = '3' BEGIN	-- CommInspSelectGroup
			SELECT
					@CheckResult = CISI.CommInspSelectResult
			FROM
					STB_CommInspSelectItem CISI
			WHERE
					CISI.CommInspSelectItemValue = @TextMeasure
	END
	
	EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspMeasureHist', @CommInspMeasureNo OUTPUT

	INSERT INTO STB_CommInspMeasureHist
	(
		CommInspMeasureNo,
		CommInspDocItemNo,
		MeasureSeq,
		TextMeasure,
		NumericMeasure,
		MeasureResult,
		MeasureDateTime,
		MeasureUserID
	)
	VALUES
	(
		@CommInspMeasureNo,
		@CommInspDocItemNo,
		(
			SELECT ISNULL(MAX(MeasureSeq),0) + 1 FROM STB_CommInspMeasureHist CIMH WHERE CIMH.CommInspDocItemNo = @CommInspDocItemNo
		),
		@TextMeasure,
		@NumericMeasure,
		@CheckResult,
		GETDATE(),
		@ProcessUserID
	)

	SELECT
			@IsAutoFinish = CITI.IsAutoFinish
	FROM
			STB_CommInspDocHistory CIDH
			LEFT OUTER JOIN STB_CommInspTypeInfo CITI
				ON CITI.CommInspTypeCode = CIDH.CommInspTypeCode
	WHERE
			CIDH.CommInspDocNo = @CommInspDocNo

	UPDATE STB_CommInspDocItem
	SET
			ItemQty = (SELECT COUNT(*) FROM STB_CommInspMeasureHist WHERE CommInspDocItemNo = @CommInspDocItemNo)
	WHERE
			CommInspDocItemNo = @CommInspDocItemNo
						
	IF @IsAutoFinish = 1 BEGIN
		IF NOT EXISTS (
						SELECT	1
						FROM
						(
							SELECT
									CIDI.CommInspDocItemNo,
									CIDI.ItemTargetQty,
									CASE 
										WHEN CIDI.ItemTargetQty < COUNT(CIMH.MeasureResult) THEN CIDI.ItemTargetQty
										ELSE COUNT(CIMH.MeasureResult)
									END AS GoodCount
							FROM 
									STB_CommInspMeasureHist CIMH
									INNER JOIN STB_CommInspDocItem CIDI
										ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo
							WHERE
									CIDI.CommInspDocNo = @CommInspDocNo AND
									CIMH.MeasureResult = 'OK'
							GROUP BY
									CIDI.CommInspDocItemNo,
									CIDI.ItemTargetQty
						) CII
						WHERE
								CII.ItemTargetQty > CII.GoodCount
					) BEGIN
				UPDATE	STB_CommInspDocHistory
				SET
						IsFinished = 1
				WHERE
						CommInspDocNo = @CommInspDocNo
		END
	END
END
