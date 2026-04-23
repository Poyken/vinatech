-- =============================================
-- Author:	SJC
-- Create date: 2022-08-18
-- Browsable : true
-- Group : MEA
-- Description:	거래선명을 업데이트 합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateCustomerName_VNT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPackingID VARCHAR(20),
	@pCustomerName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @PackingID VARCHAR(20) = @pPackingID,
			@CustomerName VARCHAR(50) = @pCustomerName

		--LotAttr08 : 박스실적 라벨발행시 거래처명(고객사) 입력받아 LotAttr08 칼럼에 저장함.
		UPDATE	STB_MaterialDocLotInfo
		SET
				LotAttr08 = @CustomerName
		WHERE
				PackingID = @PackingID

		UPDATE	STB_MaterialLotInfo
		SET
				LotAttr08 = @CustomerName
		WHERE
				PackingID = @PackingID

END