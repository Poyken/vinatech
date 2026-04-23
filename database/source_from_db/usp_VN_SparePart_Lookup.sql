CREATE PROCEDURE [dbo].[usp_VN_SparePart_Lookup]
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pSearchText NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT 
        SPI.SparePartCode, 
        SPI.SparePartName,
        SPI.SparePartSpec01,
        SPI.BasicUnit,
        ISNULL(Stock.Qty1, 0) AS CurrentStock1Qty,
        ISNULL(Stock.Qty2, 0) AS CurrentStock2Qty,
        ISNULL(Stock.TotalQty, 0) AS TotalStockQty
    FROM STB_VNSparePartInfo SPI WITH(NOLOCK)
    OUTER APPLY (
        SELECT 
            SUM(CASE WHEN spwarehousecode = 'Kho1' THEN CurrentStockQty ELSE 0 END) AS Qty1,
            SUM(CASE WHEN spwarehousecode = 'Kho2' THEN CurrentStockQty ELSE 0 END) AS Qty2,
            SUM(CurrentStockQty) AS TotalQty
        FROM STB_VNSparePartStockInfo_TEST ST WITH(NOLOCK)
        WHERE ST.SparePartCode = SPI.SparePartCode 
          AND ST.WorkCenterCode = SPI.WorkCenterCode
    ) AS Stock
    WHERE (SPI.WorkCenterCode = @pWorkCenterCode OR @pWorkCenterCode IS NULL)
      AND (
          @pSearchText IS NULL 
          OR SPI.SparePartCode LIKE '%' + @pSearchText + '%' 
          OR SPI.SparePartName LIKE '%' + @pSearchText + '%'
      )
      AND SPI.IsUsed = 1
    ORDER BY SPI.SparePartName ASC
END
