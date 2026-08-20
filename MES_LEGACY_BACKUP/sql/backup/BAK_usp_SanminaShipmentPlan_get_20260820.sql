-- =============================================
-- BACKUP OF usp_SanminaShipmentPlan_get
-- DATE: 2026-08-20
-- =============================================
CREATE PROCEDURE [dbo].[usp_SanminaShipmentPlan_get]
    @pProcessUserID VARCHAR(20) = NULL,
    @pProcessLanguage VARCHAR(20) = NULL,
    @pPONumber VARCHAR(50) = NULL,
    @pPartNumber VARCHAR(50) = NULL,
    @pLotNo VARCHAR(50) = NULL,
    @pIsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @pProcessLanguage IS NULL SET @pProcessLanguage = 'vi-VN';

    SELECT 
        PlanID,
        ISNULL(IsActive, 1) AS IsActive,
        PONumber,
        PartNumber,
        LotNo,
        QtyPerBox AS Quantity,
        TotalBox,
        PrintedBoxCount,
        CASE 
            WHEN TotalBox - PrintedBoxCount < 0 THEN 0 
            ELSE TotalBox - PrintedBoxCount 
        END AS RemainingBox,
        StartSerial,
        Status,
        Remark,
        CreateDateTime,
        CreateUserID
    FROM STB_SanminaShipmentPlan WITH(NOLOCK)
    WHERE (@pPONumber IS NULL OR LTRIM(RTRIM(@pPONumber)) = '' OR PONumber LIKE '%' + LTRIM(RTRIM(@pPONumber)) + '%')
      AND (@pPartNumber IS NULL OR LTRIM(RTRIM(@pPartNumber)) = '' OR PartNumber LIKE '%' + LTRIM(RTRIM(@pPartNumber)) + '%')
      AND (@pLotNo IS NULL OR LTRIM(RTRIM(@pLotNo)) = '' OR LotNo LIKE '%' + LTRIM(RTRIM(@pLotNo)) + '%')
      AND (@pIsActive IS NULL OR IsActive = @pIsActive)
    ORDER BY IsActive DESC, CreateDateTime DESC;

END
