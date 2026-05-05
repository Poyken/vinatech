-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-02-17
-- Description:	Lấy các mã nguyên vật liệu phế 
-- =============================================
CREATE PROCEDURE [dbo].[usp_CodeNVL_HN598]
	@pTypeWasteID int =NULL
AS
BEGIN
		--raiserror('fds',16,1)
		SELECT
			MCPW.MaterialCode ,MM.MaterialName,MM.MaterialUnit
		FROM STB_MaterialCodeAndPriceWWaste MCPW WITH(NOLOCK)
		left outer join STB_MaterialMaster MM on MCPW.MaterialCode = MM.MaterialCode
		WHERE TypeWasteID = @pTypeWasteID
			
END
