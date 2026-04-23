-- =============================================
-- Author:	Kevin Nguyen(nguyennha@vina.co.kr)
-- Create date: 2020.06.23
-- Browsable : true
-- Group : EA VN TEAM
-- Description:	The inventory first stage months function.
-- =============================================
CREATE PROC VN_MODEL_INVENTORY
AS
BEGIN
SET NOCOUNT ON;

	SELECT 
				CODEMODEL,
				NAMES
	FROM 
				STB_VN_MODEL_INVENTORY WITH(NOLOCK)
	WHERE
				IsUsed='True'
END

