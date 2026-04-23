-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-01
-- Browsable : true
-- Group : 공통
-- Description:	BOM Batch 정보를 Bom Header / Detail 에 반영합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateBomBatch]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	MERGE STB_BomHeader AS TargetTable
	USING
		(
			SELECT
					DISTINCT
					MaterialCode,
					ISNULL(BomVersion,'') AS BomVersion,
					BomUnit,
					'' AS RouteCode,
					CASE
						WHEN ISNULL(BomVersion,'') = '' THEN 1
						ELSE 0
					END AS IsBasic,
					'' AS BomHeaderDesc,
					1 AS IsUsed
			FROM
					STB_BomBatchInfo BBI WITH (NOLOCK) 
		) SOURCE
	ON (SOURCE.MaterialCode = TargetTable.MaterialCode AND SOURCE.BomVersion = TargetTable.BomVersion)
	WHEN NOT MATCHED THEN
		INSERT 
			(
				MaterialCode,
				BomVersion,
				BomUnit,
				RouteCode,
				IsBasic,
				BomHeaderDesc,
				IsUsed,
				CreateDateTime,
				CreateUserID
			)
		VALUES
		(	
				SOURCE.MaterialCode,
				SOURCE.BomVersion,
				SOURCE.BomUnit,
				SOURCE.RouteCode,
				SOURCE.IsBasic,
				SOURCE.BomHeaderDesc,
				SOURCE.IsUsed,
				GETDATE(),
				@pProcessUserID
		);


	MERGE STB_BomDetail AS TargetTable
	USING
		(
			SELECT 
					BBI.MaterialCode,
					ISNULL(BBI.BomVersion,'')  AS BomVersion,
					BBI.ChildMaterialCode,
					ISNULL(BBI.ChildBomVersion,'')  AS ChildBomVersion,
					BBI.ChildBomUnit,
					BBi.UsedQty,
					RouteCode AS RouteCode,
					0 AS IsOptionItem,
					'' AS BomDetailDesc
			FROM
					STB_BomBatchInfo BBI WITH (NOLOCK)
		) SOURCE
	ON (
			SOURCE.MaterialCode = TargetTable.MaterialCode AND SOURCE.BomVersion = TargetTable.BomVersion AND 
			SOURCE.ChildMaterialCode = TargetTable.ChildMaterialCode AND SOURCE.ChildBomVersion = TargetTable.ChildBomVersion
		)
	WHEN NOT MATCHED THEN
		INSERT 
			(
				MaterialCode,
				BomVersion,
				ChildMaterialCode,
				ChildBomVersion,
				BomUnit,
				UsedQty,
				RouteCode,
				IsOptionItem,
				BomDetailDesc,
				CreateDateTime,
				CreateUserID
			)
		VALUES
			(
				SOURCE.MaterialCode,
				SOURCE.BomVersion,
				SOURCE.ChildMaterialCode,
				SOURCE.ChildBomVersion,
				SOURCE.ChildBomUnit,
				SOURCE.UsedQty,
				SOURCE.RouteCode,
				SOURCE.IsOptionItem,
				SOURCE.BomDetailDesc,
				GETDATE(),
				@pProcessUserID
			)
	WHEN MATCHED THEN
		UPDATE SET
			BomUnit = SOURCE.ChildBomUnit,
			UsedQty = SOURCE.UsedQty,
			ChangeDateTime = GETDATE(),
			ChangeUserID = @pProcessUserID;

	--BOM 정보 반영 후 기존 데이터 삭제
	DELETE FROM STB_BomBatchInfo
END


