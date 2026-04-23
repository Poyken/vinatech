
-- =========================================================================================
-- Author : Kangs (kilee@vina.co.kr)
-- Create date: 2020-09-10
-- Browsable : true
-- Group : 품질관리 > Reset LotNo
-- Description:	
-- Modified: 
--                2020-12-18 SQL문 추가

--  EXEC uusp_ResetLotNo_iud 'kilee','Korean','19041400010'
-- =========================================================================================
CREATE  PROCEDURE [dbo].[usp_ResetLotNo_iud]
 							@pProcessUserID VARCHAR(20),
							@pProcessLanguage VARCHAR(20),
							@pMaterialQcNo VARCHAR(20) = NULL						
AS


BEGIN

	SET NOCOUNT ON;

	DECLARE @MaterialQcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '' ELSE @pMaterialQcNo END
	DECLARE @LotNo           VARCHAR(500)


   UPDATE STB_MaterialQcInfo
		SET IQCSampleLotList = Null    
	WHERE MaterialQcNo = @MaterialQcNo
  
  
  
  -- SELECT * FROM   STB_MaterialQcInfo  WHERE  MaterialQcNo =     '20121600002'   



END


