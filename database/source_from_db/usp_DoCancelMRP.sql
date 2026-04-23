
-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr
-- Create date: 2016-08-09
-- Browsable : true
-- Group : MRP
-- Description:	MRP를 취소처리합니다.
-- Modified: 
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCancelMRP]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMrpNo VARCHAR(20)
AS
BEGIN
	DECLARE @IsCancel BIT

	SELECT
			@IsCancel = ISNULL(MM.IsCancel, 0)
	FROM
			STB_MrpMaster MM
	WHERE
			MM.MrpNo = @pMrpNo


	IF ISNULL(@IsCancel, CONVERT(BIT, 0)) = CONVERT(BIT, 1)
	BEGIN
			RAISERROR('이미 취소된 MRP 입니다', 16, 1)
			RETURN
	END


	UPDATE STB_MrpMaster
	SET
			IsCancel = 1
	WHERE 
			MrpNo = @pMrpNo

	-- 이미 발주가 진행된 MRP 자재는 삭제하지 않습니다
	DELETE FROM STB_MrpTargetMaterial
	WHERE
			MrpNo = @pMrpNo AND
			ISNULL(MaterialOrderNo, '') = ''

END

