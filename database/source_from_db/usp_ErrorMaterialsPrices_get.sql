-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-02-18
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[usp_ErrorMaterialsPrices_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 

		MCPW.MaterialCode,MCPW.PRICES,MCPW.CreateDateTime,MCPW.CreateUserID,MCPW.ChangeDateTime,MCPW.ChangeUserID,MCPW.TypeWasteID,TW.NameTypeWaste

	FROM
		STB_MaterialCodeAndPriceWWaste MCPW
		left join STB_TypeWaste TW on MCPW.TypeWasteID= TW.ID

END
