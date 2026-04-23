-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-09
-- Browsable : true
-- Group : 품질관리
-- Description:	공용 검사를 완료처리합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoFinishCommInspDoc]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCommInspDocNo VARCHAR(20) = NULL,
	@pIsCheckItem BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@CommInspDocNo VARCHAR(20) = @pCommInspDocNo,
			@IsCheckItem BIT = @pIsCheckItem,
			@ErrorMessage NVARCHAR(500)
	
	IF @IsCheckItem = 1 BEGIN
		IF EXISTS (
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
				EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																	'^미검사 항목이 있습니다^',
																	@ErrorMessage OUTPUT
				SET @ErrorMessage = @ErrorMessage + ' [%s]'
				RAISERROR(@ErrorMessage,16,1,@CommInspDocNo)
				RETURN
		END
	END

	UPDATE	STB_CommInspDocHistory
	SET
			IsFinished = 1
	WHERE
			CommInspDocNo = @CommInspDocNo 
END
