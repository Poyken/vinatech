-- =============================================
-- Author: Jackaroe (yjyu@vina.co.kr)
-- Create date: 2021-02-18
-- Browsable : true
-- Group : 생산관리
-- Description:	단셀 Lot 모듈 Lot 바인딩 (CLR True)
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_DoCreateModuleLot]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(20),
	@pModuleBarcode VARCHAR(20)
AS
BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode
	       ,@ModuleBarcode VARCHAR(20) = @pModuleBarcode
		   ,@NextSeq INT 

	SELECT *
	  FROM STB_SetInfo
	 WHERE Barcode = @ModuleBarcode

	IF @@ROWCOUNT = 0 BEGIN 
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '모듈 Lot번호가 존재하지 않습니다.'
		RETURN
	END

	UPDATE STB_SetInfo
	   SET ModuleBarcode = @ModuleBarcode
	 WHERE Barcode = @Barcode

	-- 별도의 이력 저장 2021.08.23
	SELECT @NextSeq = ISNULL(MAX(seq), 0) + 1
	  FROM STB_SingleCellModuleMappingHist
	 WHERE ModuleLotNo = @ModuleBarcode

	INSERT INTO STB_SingleCellModuleMappingHist (ModuleLotNo, Seq, SingleCellLotNo, CreateUserID)
		SELECT @ModuleBarcode, @NextSeq, @Barcode, @pProcessUserID
END