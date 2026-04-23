-- =============================================
-- Author:	Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-19
-- Browsable : true
-- Group : 팝업
-- Description:	스페어파트입출고 유형정보(출고) -팝업용
-- =============================================
CREATE PROCEDURE [dbo].[usp_OutSparePartTypeCode_popup] 
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	
	
	SELECT
			SPLI.SparePartIOTypeCode,
			SPLI.SparePartIOTypeName,
			SPLI.IOType,
			SPLI.SparePartIOTypeDesc
	FROM
			STB_SparePartIOTypeCode SPLI WITH(NOLOCK)
			
	WHERE
			(SPLI.IOType <> 'I') 
			--AND (SPLI.IsDefaultRepairGI = 0)
			AND (SPLI.IsUsed = 1)

END
