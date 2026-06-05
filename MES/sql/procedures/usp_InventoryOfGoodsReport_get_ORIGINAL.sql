
CREATE PROCEDURE [dbo].[usp_InventoryOfGoodsReport_get]
    @pItemCode NVARCHAR(50) = NULL,   -- Tìm chung cho Mã VN hoặc Mã Korea
    @pItemName NVARCHAR(255) = NULL,  -- Tìm theo Tên vật tư
    @pModel NVARCHAR(50) = NULL,      -- Tìm theo Model (VD: 0612, 0820)
    @pItem NVARCHAR(50) = NULL        -- Tìm theo Mục / Phân loại (VD: EDLC, TP)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ID, 
        [Classify], 
        [Size], 
        [Item], 
        [ItemCodeVN], 
        [ItemCodeKorea], 
        [ItemName],
        [SizeDiameter],
        [Model],
        CAST([UnitPrice] AS VARCHAR(50)) AS [UnitPrice],
        [Status] = ''
    FROM STB_InventoryOfGoodsReport
    WHERE 
        -- 1. Tìm Mã (Quét 2 cột mã)
        (@pItemCode IS NULL OR 
         ItemCodeVN LIKE '%' + @pItemCode + '%' OR 
         ItemCodeKorea LIKE '%' + @pItemCode + '%')
         
        -- 2. Tìm Tên vật tư
        AND (@pItemName IS NULL OR [ItemName] LIKE N'%' + @pItemName + '%')
          
        -- 3. Tìm Model
        AND (@pModel IS NULL OR [Model] LIKE '%' + @pModel + '%')
        
        -- 4. Tìm Mục hoặc Phân loại (Gộp chung để user gõ EDLC hay TP đều ra)
        AND (@pItem IS NULL OR 
             [Item] LIKE '%' + @pItem + '%' OR 
             [Classify] LIKE '%' + @pItem + '%')
        
    ORDER BY ID DESC;
END;
