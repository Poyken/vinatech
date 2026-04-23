
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-09-02
-- Browsable : true
-- Group : 생산관리
-- Description: PO를 취소처리 합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCancelPO]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20),
	@pDefectSummaryNo VARCHAR(20)=null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @DefectSummaryNo VARCHAR(20) =@pDefectSummaryNo

	--raiserror(@DefectSummaryNo,16,1)
	DECLARE @IsCancel BIT
	DECLARE @IsFix BIT
	DECLARE @ErrorMessage NVARCHAR(500)

	IF EXISTS (
				SELECT	1
				FROM
						STB_SetInfo SI
				WHERE
						SI.PONo = @PONo
				) BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
											'^Lot이 생성된 PO는 취소할 수 없습니다^',
											@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@PONo)
			RETURN

	END

	SELECT @IsCancel = IsCancel
	      ,@IsFix = IsFix
	  FROM STB_ProductionOrderInfo
	 WHERE PONo = @PONo

	IF ISNULL(@IsCancel,0) = 1 BEGIN
			EXEC usp_RaiseLocalizedError    @pProcessLanguage,
											'이미 취소된 계획입니다'
	END

	-- 확정된 것도 취소가능하도록 
	/*
	IF ISNULL(@IsFix,0) = 1 BEGIN
			EXEC usp_RaiseLocalizedError    @pProcessLanguage,
											'확정된 계획은 취소할 수 없습니다.'
	END
	*/

	UPDATE	STB_ProductionOrderInfo
	SET
			IsCancel = 1,
			IsFix = 0,
			ChangeDateTime = GETDATE(),
			ChangeUserID = @pProcessUserID
	WHERE
			PONo = @PONo

	
	if(@DefectSummaryNo is not null)
	begin
			UPDATE STB_ReDropping  set isStatus = 1 where DefectSummaryNo =  @DefectSummaryNo

	
	end

END