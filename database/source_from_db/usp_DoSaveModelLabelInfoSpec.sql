-- =============================================
-- Author:	    KimGiGeun(ggkim@awoo.co.kr)
-- Create date: 2018-12-31
-- Browsable : true
-- Group : 모델라벨정보
-- Description:	모델라벨정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSaveModelLabelInfoSpec]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pModelCode VARCHAR(50) = NULL,
	@pLabelType VARCHAR(60) = NULL,
	@pFormatName VARCHAR(60) = NULL

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ModelCode VARCHAR(50) = @pModelCode
	DECLARE @LabelType VARCHAR(60) = @pLabelType
	DECLARE @FormatName VARCHAR(60) = @pFormatName


		IF ISNULL(@FormatName,'') = '' 
		BEGIN
			DELETE 					
			FROM
				STB_ModelLabelInfo
			WHERE
				ModelCode = @ModelCode AND
				LabelType = @LabelType
		END
		ELSE
		BEGIN
			UPDATE
					STB_ModelLabelInfo
			SET
					FormatName = @FormatName
			WHERE
				ModelCode = @ModelCode AND
				LabelType = @LabelType
			IF @@ROWCOUNT = 0 
			BEGIN
				INSERT INTO STB_ModelLabelInfo
					(
						ModelCode,
						LabelType,
						FormatName,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							@ModelCode,
							@LabelType,
							@FormatName,
							GETDATE(),
							@pProcessUserID
					)
			END
		END

		


END