

-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-09-16
-- Browsable : true
-- Group : 리포트관리
-- Description:	입고 Lot 라벨을 발행합니다.
-- Modified: 
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialDocLot_ForLabel]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialDocNo VARCHAR(20) = NULL,
	@pLotID VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaterialDocNo VARCHAR(20) = ISNULL(@pMaterialDocNo,'')
	DECLARE @LotID VARCHAR(50) = CASE WHEN ISNULL(@pLotID, '') = '' THEN '*' ELSE @pLotID END

	SELECT
			MDLI.LotID,
			MDLI.LotNo,
			MDLI.MaterialCode,
			MM.MaterialName,
			MM.MaterialSpec,
			CI.CustomerName,
			MDI.BasicDate,
			MM.MaterialSpec,
			MM.MaterialSource,
			MDLI.StockQty,
			'' AS CheckUser
	FROM	
			STB_MaterialDocLotInfo MDLI WITH (NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH (NOLOCK)
				ON (MM.MaterialCode = MDLI.MaterialCode)
			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH (NOLOCK)
				ON (MDI.MaterialDocNo = MDLI.MaterialDocNo)
			LEFT OUTER JOIN STB_CustomerInfo CI WITH (NOLOCK)
				ON (CI.CustomerCode = MDI.SourceCustomerCode)
	WHERE
			(MDLI.MaterialDocNo = @MaterialDocNo) AND
			((@LotID = '*') OR (MDLI.LotID = @LotID ))
	ORDER BY
			MDLI.MaterialDocDetailNo,
			MDLI.LotID


END

