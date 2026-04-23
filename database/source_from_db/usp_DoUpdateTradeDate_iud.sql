
-- =============================================
-- Author: SJC
-- Group : 자재관리
-- Browsable : true
-- Create date: 2022-02-04
-- Description: [F330]자재입고 및 라벨발행 - 거래명세서 거래일자, 비고 입력
-- exec usp_DoUpdateTradeDate_iud '', '', '210802000011', '2022-02-04', 'asdf'
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateTradeDate_iud]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocNo VARCHAR(20),
	@pTradeDate DATE = NULL,
	@pRemark VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	Declare @MaterialDocNo VARCHAR(20) = @pMaterialDocNo
	       ,@TradeDate DATE = @pTradeDate
		   ,@Remark VARCHAR(MAX) = @pRemark

	--정보 조회
	SELECT *
	  FROM STB_MaterialDocInfo
	 WHERE MaterialDocNo = @MaterialDocNo

	IF @@ROWCOUNT = 1
		BEGIN

		UPDATE STB_MaterialDocInfo
		   SET TradeDate = @TradeDate
		      ,Remark = @Remark
		 WHERE MaterialDocNo = @MaterialDocNo

		END
END


