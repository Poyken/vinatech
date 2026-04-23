
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-29
-- Browsable : true > [C510] 제품검사 Lot관리 > Lot생성버튼
-- Group : 품질관리
-- Description: 출하검사 Lot을 생성합니다
-- Modified:
-- usp_DoCreateOqcInfoForLotByOne_VNT '','','VJLT132R710615',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateOqcInfoForLotByOne_VNT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(50) = NULL,
	@pProdQty NUMERIC(20,5) = NULL
AS
BEGIN
	SET NOCOUNT ON;
--	select @pBarcode = oldlotid from STB_ChangePartNoAndLotNo where  

	EXEC usp_DoCreateOqcInfoForLot_VNT	@pProcessUserID = @pProcessUserID,
														@pProcessLanguage = @pProcessLanguage,
														@pBarcode = @pBarcode,
														@pProdQty = @pProdQty
END

--select *  from STB_MaterialQcInfo where MaterialQcNo='VVPN123R015606'
--select *  from  STB_MaterialQcDetail where MaterialQcNo='VVPN123R015606'

/*
			UPDATE	STB_SetInfo
			SET
					LotNumber = NULL,
					LotCreateDateTime = NULL,
					LotDecisionResult = NULL
			WHERE
					Barcode = 'VVPN123R015606'


					*/