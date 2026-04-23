
CREATE PROCEDURE [dbo].[usp_InventoryWareHouse_HN_New] 
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
    @pToDate DATETIME,
    @pPackingID NVARCHAR(50) = '',
    @pLotNo NVARCHAR(50) = ''
AS
BEGIN
    SET NOCOUNT ON;

    WITH TotalInput AS (
        SELECT 
            T3.PackingID, T3.LotNo,
            ISNULL(HN.NewMaterialCode, ISNULL(T9.MaterialCode, T5.MaterialCode)) AS MaterialCode,
            T6.MaterialName,
            ISNULL(T9.MarkingCode, T5.MarkingCode) AS MarkingCode,
            ISNULL(MK.MarkingName, '') AS MarkingName,
            T3.CommentType, T3.Note, T3.Locations,
            SUM(CASE WHEN T9.Qty IS NOT NULL THEN T9.Qty ELSE T3.PackQty END) AS InQty
        FROM STB_VN_FINISHGOODS_HN_New T3 WITH (NOLOCK)
        LEFT JOIN stb_materialLotinfo T5 WITH (NOLOCK) ON T3.PackingID = T5.PackingID AND T3.LotNo = T5.LotNo
        LEFT JOIN STB_DividePackaging T9 WITH (NOLOCK) ON T9.PackingID = T3.PackingID
        LEFT JOIN STB_MaterialMaster T6 WITH (NOLOCK) ON T6.MaterialCode = ISNULL(T9.MaterialCode, T5.MaterialCode)
        LEFT JOIN STB_CreateMarkingLetterAndQtyForBarcode MK WITH (NOLOCK) ON MK.MarkingCode = ISNULL(T9.MarkingCode, T5.MarkingCode)
        LEFT JOIN STB_ChangeMaterialCode_HN HN WITH(NOLOCK) ON HN.PackingID = T3.PackingID
        WHERE CAST(DATEADD(HOUR, -10, T3.CreateDateTime) AS DATE) <= @pToDate
          AND (T5.WorkCenterCode = 'VVT_F3' OR T9.WorkCenterCode = 'VVT_F3')
        GROUP BY T3.PackingID, T3.LotNo, ISNULL(HN.NewMaterialCode, ISNULL(T9.MaterialCode, T5.MaterialCode)), T6.MaterialName, ISNULL(T9.MarkingCode, T5.MarkingCode), MK.MarkingName, T3.CommentType, T3.Note, T3.Locations
    ),
    TotalOutput AS (
        SELECT 
            T2.PackingID, T2.LotNo,
            SUM(ISNULL(T10.Qty, T2.Qty)) AS OutQty
        FROM STB_VN_FINISHGOODS_HN_Export T2 WITH (NOLOCK)
        LEFT JOIN STB_DividePackaging T10 WITH (NOLOCK) ON T10.PackingParentID = T2.PackingID
        WHERE CAST(DATEADD(HOUR, -10, T2.DateRequestExport) AS DATE) <= @pToDate
        GROUP BY T2.PackingID, T2.LotNo
    ),
    FinalResults AS (
        SELECT 
            I.MaterialCode, I.MaterialName, I.PackingID, I.LotNo, I.MarkingCode, I.MarkingName,
            CAST(I.InQty AS INT) AS TotalInput,
            CAST(ISNULL(O.OutQty, 0) AS INT) AS TotalOutput,
            CAST(I.InQty - ISNULL(O.OutQty, 0) AS INT) AS StockQty,
            'EA' AS Unit,
            I.CommentType,
            I.Note, I.Locations
        FROM TotalInput I
        LEFT JOIN TotalOutput O ON I.PackingID = O.PackingID AND I.LotNo = O.LotNo
        WHERE (I.InQty - ISNULL(O.OutQty, 0)) > 0
          AND (ISNULL(@pPackingID, '') = '' OR I.PackingID = @pPackingID)
          AND (ISNULL(@pLotNo, '') = '' OR I.LotNo = @pLotNo)

        UNION ALL

        SELECT 
            ISNULL(HN.NewMaterialCode, FGHN.MaterialCode) AS MaterialCode,
            FGHN.ProductName AS MaterialName,
            FGHN.PackingID,
            FGHN.LotNo,
            NULL AS MarkingCode,
            FGHN.Marking AS MarkingName,
            CAST(FGHN.Quantity AS INT) AS TotalInput,
            CAST(ISNULL(FGHN.QtyOutput, 0) AS INT) AS TotalOutput,
            CAST(FGHN.Quantity - ISNULL(FGHN.QtyOutput, 0) AS INT) AS StockQty,
            FGHN.Unit,
            FGHN.CommentType,
            FGHN.Note, FGHN.Locations
        FROM FinishGoodMESInstock_HN FGHN
        LEFT JOIN STB_ChangeMaterialCode_HN HN WITH(NOLOCK) ON HN.PackingID = FGHN.PackingID
        WHERE CAST(DATEADD(HOUR, -10, FGHN.CreateDateTime) AS DATE) <= @pToDate
          AND (ISNULL(@pPackingID, '') = '' OR FGHN.PackingID = @pPackingID)
          AND (ISNULL(@pLotNo, '') = '' OR FGHN.LotNo = @pLotNo)
          AND (FGHN.Quantity - ISNULL(FGHN.QtyOutput, 0)) > 0
    )
    SELECT 
        MaterialCode, MaterialName, PackingID, LotNo, MarkingCode, MarkingName,
        @pToDate AS ReportDate,
        CAST(DATEDIFF(DAY,
            CASE 
                WHEN MaterialCode = '30VS330ME12XXXVC01' THEN
                    DATEFROMPARTS(
                        CASE LEFT((MarkingName COLLATE SQL_Latin1_General_CP1_CS_AS), 1)
                            WHEN 'A' THEN 2022 WHEN 'B' THEN 2022 WHEN 'C' THEN 2022 WHEN 'D' THEN 2022 WHEN 'E' THEN 2022 WHEN 'F' THEN 2022 WHEN 'G' THEN 2022 WHEN 'H' THEN 2022 WHEN 'I' THEN 2022 WHEN 'J' THEN 2022 WHEN 'K' THEN 2022 WHEN 'L' THEN 2022 WHEN 'M' THEN 2023 WHEN 'N' THEN 2023 WHEN 'O' THEN 2023 WHEN 'P' THEN 2023 WHEN 'Q' THEN 2023 WHEN 'R' THEN 2023 WHEN 'S' THEN 2023 WHEN 'T' THEN 2023 WHEN 'U' THEN 2023 WHEN 'V' THEN 2023 WHEN 'W' THEN 2023 WHEN 'X' THEN 2023 WHEN 'Y' THEN 2024 WHEN 'Z' THEN 2024 WHEN 'a' THEN 2024 WHEN 'b' THEN 2024 WHEN 'c' THEN 2024 WHEN 'd' THEN 2024 WHEN 'e' THEN 2024 WHEN 'f' THEN 2024 WHEN 'g' THEN 2024 WHEN 'h' THEN 2024 WHEN 'i' THEN 2024 WHEN 'j' THEN 2024 WHEN 'k' THEN 2025 WHEN 'l' THEN 2025 WHEN 'm' THEN 2025 WHEN 'n' THEN 2025 WHEN 'o' THEN 2025 WHEN 'p' THEN 2025 WHEN 'q' THEN 2025 WHEN 'r' THEN 2025 WHEN 's' THEN 2025 WHEN 't' THEN 2025 WHEN 'u' THEN 2025 WHEN 'v' THEN 2025 WHEN 'w' THEN 2025 WHEN 'x' THEN 2025 WHEN 'y' THEN 2025 WHEN 'z' THEN 2025 END,
                        CASE LEFT((MarkingName COLLATE SQL_Latin1_General_CP1_CS_AS), 1)
                            WHEN 'A' THEN 1  WHEN 'B' THEN 2  WHEN 'C' THEN 3  WHEN 'D' THEN 4 WHEN 'E' THEN 5  WHEN 'F' THEN 6  WHEN 'G' THEN 7  WHEN 'H' THEN 8 WHEN 'I' THEN 9  WHEN 'J' THEN 10 WHEN 'K' THEN 11 WHEN 'L' THEN 12 WHEN 'M' THEN 1  WHEN 'N' THEN 2  WHEN 'O' THEN 3  WHEN 'P' THEN 4 WHEN 'Q' THEN 5  WHEN 'R' THEN 6  WHEN 'S' THEN 7  WHEN 'T' THEN 8 WHEN 'U' THEN 9  WHEN 'V' THEN 10 WHEN 'W' THEN 11 WHEN 'X' THEN 12 WHEN 'Y' THEN 1  WHEN 'Z' THEN 2  WHEN 'a' THEN 3  WHEN 'b' THEN 4 WHEN 'c' THEN 5  WHEN 'd' THEN 6  WHEN 'e' THEN 7  WHEN 'f' THEN 8 WHEN 'g' THEN 9  WHEN 'h' THEN 10 WHEN 'i' THEN 11 WHEN 'j' THEN 12 WHEN 'k' THEN 1  WHEN 'l' THEN 2  WHEN 'm' THEN 3  WHEN 'n' THEN 4 WHEN 'o' THEN 5  WHEN 'p' THEN 6  WHEN 'q' THEN 7  WHEN 'r' THEN 8 WHEN 's' THEN 9  WHEN 't' THEN 10 WHEN 'u' THEN 11 WHEN 'v' THEN 12 WHEN 'w' THEN 1  WHEN 'x' THEN 2  WHEN 'y' THEN 3  WHEN 'z' THEN 4 END, 1)
                ELSE
                    DATEFROMPARTS(
                        CASE LEFT(MarkingName, 1)
                            WHEN '0' THEN 2030 WHEN '1' THEN 2021 WHEN '2' THEN 2022 WHEN '3' THEN 2023 WHEN '4' THEN 2024 WHEN '5' THEN 2025 WHEN '6' THEN 2026 WHEN '7' THEN 2027 WHEN '8' THEN 2028 WHEN '9' THEN 2029 END,
                        CASE SUBSTRING(MarkingName, 2, 1)
                            WHEN 'A' THEN 1 WHEN 'B' THEN 2 WHEN 'C' THEN 3 WHEN 'D' THEN 4 WHEN 'E' THEN 5 WHEN 'F' THEN 6 WHEN 'G' THEN 7 WHEN 'H' THEN 8 WHEN 'J' THEN 9 WHEN 'K' THEN 10 WHEN 'L' THEN 11 WHEN 'M' THEN 12 END, 1)
            END, GETDATE()) / 365.25 AS DECIMAL(5,2)) AS MarkingAgeInYear,
        TotalInput, TotalOutput, StockQty, Unit,
        CASE 
            WHEN CommentType = 1 THEN 'Good'
            WHEN CommentType = 2 THEN 'NG'
            WHEN CommentType = 3 THEN 'Pending'
            WHEN CommentType = 4 THEN 'Customer Return'
            WHEN CommentType = 5 THEN 'On Hold'
            WHEN CommentType = 6 THEN N'Chưa đánh giá'
            ELSE N'Chưa đánh giá'
        END AS CommentTypeImport,
        Note, Locations
    FROM FinalResults
    ORDER BY MaterialCode, PackingID;
END
