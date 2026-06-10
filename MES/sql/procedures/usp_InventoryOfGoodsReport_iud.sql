
ALTER PROCEDURE [dbo].[usp_InventoryOfGoodsReport_iud]
    @pProcessUserID VARCHAR(20) = NULL, 
    @pProcessLanguage VARCHAR(20) = NULL,
    @pProcessViewName VARCHAR(50) = NULL, 
    @pXml NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'InventoryOfGoodsReport') + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'InventoryOfGoodsReport') + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'InventoryOfGoodsReport') + '_DELETE'
    DECLARE @iDoc INT
    
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- ==========================================
        -- 1. DELETE
        -- ==========================================
        DELETE T FROM STB_InventoryOfGoodsReport T
        INNER JOIN (SELECT ID FROM OPENXML(@iDoc, @DeleteTableName, 3) WITH (ID INT)) S ON T.ID = S.ID;

        -- ==========================================
        -- 2. UPDATE
        -- ==========================================
        UPDATE T SET 
            T.[Classify] = S.[Classify], 
            T.[Size] = S.[Size], 
            T.[Item] = S.[Item], 
            T.[ItemCodeVN] = S.[ItemCodeVN], 
            T.[ItemCodeKorea] = S.[ItemCodeKorea],
            T.[ItemName] = S.[ItemName], 
            T.[SizeDiameter] = S.[SizeDiameter], 
            T.[Model] = S.[Model],
            T.[UnitPrice] = S.[UnitPrice],
            T.[ChangeUserID] = @pProcessUserID, 
            T.[ChangeDateTime] = GETDATE()
        FROM STB_InventoryOfGoodsReport T
        INNER JOIN (
            SELECT 
                ID, 
                [Classify], [Size], [Item], [ItemCodeVN], [ItemCodeKorea], 
                [ItemName], [SizeDiameter], [Model],
                ISNULL(TRY_CAST(UnitPrice AS DECIMAL(18,4)), 0) AS UnitPrice
            FROM OPENXML(@iDoc, @UpdateTableName, 3) WITH (
                ID INT,
                [Classify] NVARCHAR(50), [Size] NVARCHAR(50), [Item] NVARCHAR(50), 
                [ItemCodeVN] NVARCHAR(50), [ItemCodeKorea] NVARCHAR(50), 
                [ItemName] NVARCHAR(255), [SizeDiameter] NVARCHAR(50), [Model] NVARCHAR(50),
                UnitPrice VARCHAR(50)
            )
        ) S ON T.ID = S.ID;

        -- ==========================================
        -- 3. INSERT
        -- ==========================================
        INSERT INTO STB_InventoryOfGoodsReport (
            [Classify], [Size], [Item], [ItemCodeVN], [ItemCodeKorea], 
            [ItemName], [SizeDiameter], [Model], [UnitPrice],
            CreateUserID, CreateDateTime, ChangeUserID, ChangeDateTime
        )
        SELECT 
            T.[Classify], 
            T.[Size], 
            T.[Item], 
            T.[ItemCodeVN], 
            T.[ItemCodeKorea], 
            T.[ItemName], 
            T.[SizeDiameter], 
            T.[Model],
            ISNULL(TRY_CAST(T.UnitPrice AS DECIMAL(18,4)), 0),
            @pProcessUserID, GETDATE(), @pProcessUserID, GETDATE()
        FROM OPENXML(@iDoc, @InsertTableName, 3) WITH (
            [Classify] NVARCHAR(50), [Size] NVARCHAR(50), [Item] NVARCHAR(50), 
            [ItemCodeVN] NVARCHAR(50), [ItemCodeKorea] NVARCHAR(50), 
            [ItemName] NVARCHAR(255), [SizeDiameter] NVARCHAR(50), [Model] NVARCHAR(50),
            UnitPrice VARCHAR(50)
        ) AS T
        WHERE T.[Classify] IS NOT NULL 
          AND T.[Size] IS NOT NULL 
          AND T.[Item] IS NOT NULL 
          AND T.[ItemCodeVN] IS NOT NULL 
          AND T.[ItemCodeKorea] IS NOT NULL 
          AND T.[ItemName] IS NOT NULL 
          AND T.[SizeDiameter] IS NOT NULL 
          AND T.[Model] IS NOT NULL 
          AND T.UnitPrice IS NOT NULL; 

        COMMIT TRANSACTION;
        EXEC sp_xml_removedocument @iDoc;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        IF @iDoc IS NOT NULL EXEC sp_xml_removedocument @iDoc;
        
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
