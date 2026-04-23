-- =============================================
-- Author: Nguyễn Hải Triều
-- Create date: 2026-03-16
-- Description:	Hiển thị vị trí cho nhà máy Hà Nam
-- EXEC usp_GetFinishGood_HNByLocation
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetFinishGood_HNByLocation] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
  SET NOCOUNT ON;

  ;WITH data1 AS (
    SELECT 
        fish.LotNo AS barcode, 
        si.materialcode,
        locations,
        PackQty AS Qty
    FROM STB_VN_FINISHGOODS_HN_New fish WITH(NOLOCK)
    LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK) ON si.Barcode = fish.LotNo
    WHERE locations IS NOT NULL 
      AND locations <> '' 
      AND PackQtyOutPut IS NULL

    UNION ALL

    SELECT 
        lotno AS barcode, 
        materialcode, 
        locations,
        Quantity AS Qty
    FROM FinishGoodMESInstock_HN T10 WITH(NOLOCK)
	--LEFT JOIN STB_DividePackaging T2 WHERE t2.PackingParentID = T10.PackingID
    WHERE locations IS NOT NULL 
      AND locations <> ''
),
data2 AS (
    SELECT  
        locations,
        MaterialCode,
        barcode AS lotno, 
        SUM(Qty) AS totalqty,    
        COUNT(barcode) AS totalstock 
    FROM data1
    GROUP BY locations, MaterialCode, barcode 
)
  SELECT 
    lotno,
    locations,
    materialcode,
    totalqty,
    totalstock
FROM data2
ORDER BY locations, materialcode, lotno;
 
 END


