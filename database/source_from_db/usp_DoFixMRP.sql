
-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr
-- Create date: 2016-08-09
-- Browsable : true
-- Group : MRP
-- Description:	MRP를 확정처리합니다.
-- Modified: 
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoFixMRP]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMrpNo VARCHAR(20)
AS
BEGIN
	DECLARE @IsFix BIT
	DECLARE @IsRun BIT
	DECLARE @IsCancel BIT

	SELECT
			@IsFix = MM.IsFixedMRP,
			@IsRun = MM.IsRunMrp,
			@IsCancel = MM.IsCancel
	FROM
			STB_MrpMaster MM
	WHERE
			MM.MrpNo = @pMrpNo

	

	IF ISNULL(@IsFix, CONVERT(BIT, 0)) = CONVERT(BIT, 1)
	BEGIN
			RAISERROR('이미 확정된 MRP 입니다', 16, 1)
			RETURN
	END

	IF ISNULL(@IsCancel, CONVERT(BIT, 0)) = CONVERT(BIT, 1)
	BEGIN
			RAISERROR('취소된 MRP는 확정할 수 없습니다.', 16, 1)
			RETURN
	END

	IF ISNULL(@IsRun, CONVERT(BIT, 0)) = CONVERT(BIT, 0)
	BEGIN
			RAISERROR('실행되지 않은 MRP 입니다. 먼저 실행 후 확정해 주세요.', 16, 1)
			RETURN
	END

	IF EXISTS(
				SELECT	1
				FROM
						STB_MrpTargetMaterial MTM
				WHERE
						ISNULL(MTM.CustomerCode,'') = ''
			)
	BEGIN
			RAISERROR('거래처가 설정되지 않은 품목이 있습니다 거래처를 설정해주세요', 16, 1)
			RETURN
	END

	-- 2016-11-21 JGH 수정 자재별 업체지정정보에 수주단가 입력되지 않았을때 오류 메시지 
	----------------------------------------------------------------------------------------------------------
	DECLARE @MaterialCode VARCHAR(50),
			@CustomerCode VARCHAR(20)

	SELECT
			TOP 1
			@MaterialCode = MTM.MaterialCode,
			@CustomerCode = MTM.CustomerCode
	FROM
			STB_MrpTargetMaterial MTM
			LEFT OUTER JOIN STB_MaterialVendorMapping MVM
				ON MVM.MaterialCode = MTM.MaterialCode
				AND MVM.CustomerCode = MTM.CustomerCode
	WHERE
			MTM.MrpNo = @pMrpNo AND
			(MVM.UnitPrice IS NULL OR MVM.UnitPrice = 0)
	
	IF ISNULL(@MaterialCode,'') <> ''
	BEGIN
			RAISERROR('%s 자재의 %s 거래처에 수주단가가 입력되지 않았습니다!', 16, 1,@MaterialCode,@CustomerCode)
			RETURN
	END
	----------------------------------------------------------------------------------------------------------

	UPDATE STB_MrpMaster
	SET
			IsFixedMRP = 1,
			MrpFixDateTime = GETDATE(),
			MrpFixUserID = @pProcessUserID
	WHERE 
			MrpNo = @pMrpNo

END
