
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-29
-- Browsable : true
-- Group : 품질관리
-- Description: 출하검사 Lot을 생성합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateOqcInfoForLotByOne]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	EXEC usp_DoCreateOqcInfoForLot	@pProcessUserID = @pProcessUserID,
									@pProcessLanguage = @pProcessLanguage,
									@pBarcode = @pBarcode
END

