-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-06
-- Browsable : true
-- Group : 품질관리
-- Description:	바코드의 불량정보를 등록합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessDefectRepairInfoByBarcodeLine_SmartApp]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pRouteCode VARCHAR(20),
	@pBarcode VARCHAR(50),
	@pDefectCode VARCHAR(20),
	@pDefectQty NUMERIC(20,5),
	@pMachineID VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Barcode VARCHAR(20) = @pBarcode
	DECLARE @LineCode VARCHAR(20)

	SELECT
			@LineCode = SI.InputLineCode
	FROM
			STB_SetInfo SI
	WHERE
			SI.Barcode = @Barcode

	EXEC usp_DoProcessDefectRepairInfoByBarcode_SmartApp	@pProcessUserID = @pProcessUserID,
															@pProcessLanguage = @pProcessLanguage,
															@pLineCode = @LineCode,
															@pRouteCode = @pRouteCode,
															@pBarcode = @Barcode,
															@pDefectCode = @pDefectCode,
															@pDefectQty = @pDefectQty,
															@pMachineID = @pMachineID
		
END
