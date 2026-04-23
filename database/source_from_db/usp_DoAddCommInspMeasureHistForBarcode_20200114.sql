-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 품질관리
-- Description:	공용 검사이력을 추가 합니다.
-- Modified: 바코드 입력시
-- 2020.01.13  비고정보 업데이트 되도록 수정 (kilee)
-- 2020.01.13  
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddCommInspMeasureHistForBarcode_20200114]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCommInspDocNo VARCHAR(20),
						@pCommInspDocItemNo VARCHAR(20),
						@pTextMeasure VARCHAR(50),
						@pNumericMeasure NUMERIC(20,5),
						@pCheckDisplay BIT,
						@pInspWorkerCode VARCHAR(20),
						@pCIDHExtText02 VARCHAR(200) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@CommInspDocNo VARCHAR(20) = @pCommInspDocNo,
			@CommInspDocItemNo VARCHAR(20) = @pCommInspDocItemNo,
			@TextMeasure VARCHAR(50) = @pTextMeasure,
			@NumericMeasure NUMERIC(20,5) = @pNumericMeasure,
			@CheckDisplay BIT = @pCheckDisplay,
			@InspWorkerCode VARCHAR(20) = @pInspWorkerCode,
			@CIDHExtText02 VARCHAR(200) = @pCIDHExtText02

	DECLARE @Barcode VARCHAR(50)
	DECLARE @CommInspMeasureNo VARCHAR(20)
	DECLARE @IsAutoFinish BIT
	DECLARE @IsFinished BIT
	DECLARE @ErrorMessage NVARCHAR(500)

	SELECT
			@IsFinished = CIDH.IsFinished,
			@Barcode = SI.Barcode
	FROM
			                       STB_CommInspDocHistory CIDH
			LEFT OUTER JOIN STB_SetInfo                       SI		ON SI.ControlNo = CIDH.ProdNo
	WHERE
			CIDH.CommInspDocNo = @CommInspDocNo

	IF @IsFinished = 1 
	BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																'^이미 완료처리 되었습니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode)
			RETURN
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
		MeasureUserID,
		InspWorkerCode
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
		CASE  WHEN @CheckDisplay = 1 THEN 'OK'			ELSE 'NG' 	END,
		GETDATE(),
		@ProcessUserID,
		@InspWorkerCode
	)

	-- 2020.01.13 비고정보 추가 (kilee) Start   -->   Select CIDHExtText02,  * from STB_CommInspDocHistory where CommInspDocNo = '20191203000049'
		IF @CIDHExtText02 IS NOT NULL 
	
		BEGIN

			UPDATE  STB_CommInspDocHistory
				SET  CIDHExtText02 = @CIDHExtText02
			WHERE CommInspDocNo = @CommInspDocNo

		END
	-- 2020.01.13 비고정보 추가 (kilee) End

	SELECT
			@IsAutoFinish = CITI.IsAutoFinish
	FROM
			STB_CommInspDocHistory CIDH
			LEFT OUTER JOIN STB_CommInspTypeInfo CITI				ON CITI.CommInspTypeCode = CIDH.CommInspTypeCode
	WHERE
			CIDH.CommInspDocNo = @CommInspDocNo

	UPDATE STB_CommInspDocItem
	     SET ItemQty = (SELECT COUNT(*) FROM STB_CommInspMeasureHist WHERE CommInspDocItemNo = @CommInspDocItemNo)
	 WHERE CommInspDocItemNo = @CommInspDocItemNo
						
	IF @IsAutoFinish = 1 
	
	BEGIN
		IF NOT EXISTS (
						SELECT	1
						FROM
								(
									SELECT
											CIDI.CommInspDocItemNo,
											CIDI.ItemTargetQty,
											CASE 	WHEN CIDI.ItemTargetQty < COUNT(CIMH.MeasureResult) THEN CIDI.ItemTargetQty	ELSE COUNT(CIMH.MeasureResult)	END  AS GoodCount
									FROM 
														    STB_CommInspMeasureHist CIMH
											INNER JOIN STB_CommInspDocItem       CIDI		ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo
									WHERE 1=1
										AND CIDI.CommInspDocNo = @CommInspDocNo 
										AND	CIMH.MeasureResult = 'OK'
									GROUP BY
											CIDI.CommInspDocItemNo,
											CIDI.ItemTargetQty
								) CII

						WHERE
								CII.ItemTargetQty > CII.GoodCount

					) BEGIN
								UPDATE	STB_CommInspDocHistory
								SET
										IsFinished = 1,
										ChangeDateTime = GETDATE(),
										ChangeUserID = @ProcessUserID
								WHERE
										CommInspDocNo = @CommInspDocNo
					END
	END
END
