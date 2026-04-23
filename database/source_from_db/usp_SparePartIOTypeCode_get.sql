-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-17
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트입출고유형정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SparePartIOTypeCode_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pSparePartIOTypeCode VARCHAR(20) = NULL,
    @pSparePartIOTypeName NVARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @SparePartIOTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pSparePartIOTypeCode,'') = '' THEN '*' ELSE @pSparePartIOTypeCode END
      DECLARE @SparePartIOTypeName NVARCHAR(100) = CASE WHEN ISNULL(@pSparePartIOTypeName,'') = '' THEN '*' ELSE @pSparePartIOTypeName END

    
	SELECT
	        SPIOTC.SparePartIOTypeCode AS OldSparePartIOTypeCode,
	        SPIOTC.SparePartIOTypeCode,
	        SPIOTC.IOType,
	        SPIOTC.SparePartIOTypeName,
	        SPIOTC.SparePartIOTypeDesc,
	        ISNULL(SPIOTC.IsDefaultRepairGI,0) AS IsDefaultRepairGI,
	        SPIOTC.IsUsed,
	        SPIOTC.CreateDateTime,
	        SPIOTC.CreateUserID,
	        SPIOTC.ChangeDateTime,
	        SPIOTC.ChangeUserID
	FROM
	        STB_SparePartIOTypeCode SPIOTC WITH(NOLOCK)
	WHERE
	        ((@SparePartIOTypeCode = '*') OR (SPIOTC.SparePartIOTypeCode = @SparePartIOTypeCode)) AND
	        ((@SparePartIOTypeName = '*') OR (SPIOTC.SparePartIOTypeName = @SparePartIOTypeName)) 

END


