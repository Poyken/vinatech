
-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018-07-22
-- Browsable : true
-- Group : 자재관리
-- Description:	자재창고로케이션정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialLocation_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialWarehouseCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      --DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END
		DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '' ELSE @pMaterialWarehouseCode END
    
	SELECT
	        ML.MaterialLocationCode AS OldMaterialLocationCode,
	        ML.MaterialLocationCode,
	        ML.MaterialWarehouseCode AS OldMaterialWarehouseCode,
	        ML.MaterialWarehouseCode,
			MW.MaterialWarehouseName,
	        ML.MaterialLocationName,
	        ML.MaterialLocationNameL,
	        ML.MLExtText01,
	        ML.MLExtText02,
	        ML.MLExtText03,
	        ML.MLExtText04,
	        ML.MLExtText05,
			ML.IsUseLotID,
			ML.IsCanPicking,
	        ML.CreateDateTime,
	        ML.CreateUserID,
	        ML.ChangeDateTime,
	        ML.ChangeUserID,
			'LOCATION' AS LabelType,
			'LocationLabel' AS LabelFormatName,
			'Report' AS CommandType
	FROM
	        STB_MaterialLocation ML WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)
				ON MW.MaterialWarehouseCode = ML.MaterialWarehouseCode
	WHERE
	        (ML.MaterialWarehouseCode = @MaterialWarehouseCode)

END

