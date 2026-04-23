-- Author:Nguyễn Hải Triều
-- Date:2025-07-25
-- Desc:Hiển thị tồn kho thành phẩm
-- exec usp_InventoryWareHouse_HN '','','',''
CREATE PROCEDURE [dbo].[usp_InventoryWareHouse_HN]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
    @pLotNo VARCHAR(20) = NULL,
    @pPackingID VARCHAR(20) = NULL,
    @pMaterialCode VARCHAR(20) = NULL,
	@pToDate DATETIME=NULL,
	@pFromDate DATETIME=NULL

AS
BEGIN
    SET NOCOUNT ON;

    -- CTE Nhập kho gốc
   ;WITH NhapGoc AS (
        SELECT 
            T3.PackingID,
            T3.LotNo,
            T3.CommentType,
            SUM(ISNULL(T3.PackQty, 0)) AS TotalInput,
			T3.Note
        FROM STB_VN_FINISHGOODS_HN_New T3 WITH (NOLOCK)
        WHERE 
            (ISNULL(@pPackingID, '') = '' OR T3.PackingID = @pPackingID)
            AND (ISNULL(@pLotNo, '') = '' OR T3.LotNo = @pLotNo) 
			 AND (@pFromDate IS NULL OR T3.CreateDateTime >= @pFromDate)
            AND (@pToDate IS NULL OR T3.CreateDateTime <= @pToDate)
        GROUP BY 
            T3.PackingID, 
            T3.LotNo,
            T3.CommentType,
			T3.Note
    ),

  NhapKho AS (
    SELECT 
        COALESCE(T9.PackingID, g.PackingID) as PackingID,
        g.LotNo,
        -- Ưu tiên lấy mã vật tư từ bảng Chia (T9)
        ISNULL(T9.MaterialCode, T5.MaterialCode) AS MaterialCode,
        T6.MaterialName,
        -- Lấy MarkingCode trực tiếp từ bảng T9 nếu có, nếu không lấy từ T5
        ISNULL(T9.MarkingCode, MK.MarkingCode) AS MarkingCode, 
        MK.MarkingName,
        CASE
           WHEN MAX(T9.PackingID) IS NOT NULL THEN SUM(T9.Qty)
           ELSE g.TotalInput
        END AS TotalInput,
        g.CommentType,
        g.Note
    FROM NhapGoc g
    LEFT JOIN stb_materialLotinfo T5 WITH (NOLOCK)
        ON g.PackingID = T5.PackingID AND g.LotNo = T5.LotNo
    LEFT JOIN STB_DividePackaging T9 WITH (NOLOCK) 
        ON T9.PackingID = g.PackingID
    -- Join lấy tên vật tư dựa trên Code đã xác định
    LEFT JOIN STB_MaterialMaster T6 WITH (NOLOCK)
        ON T6.MaterialCode = ISNULL(T9.MaterialCode, T5.MaterialCode)
    -- Join lấy Marking Name dựa trên MarkingCode của T9 hoặc T5
    LEFT JOIN STB_CreateMarkingLetterAndQtyForBarcode MK WITH (NOLOCK)
        ON MK.MarkingCode = ISNULL(T9.MarkingCode, T5.MarkingCode)

    -- Chỗ này quan trọng: Nếu bảng T9 có dữ liệu nhưng T5 chưa có (hoặc ngược lại) thì vẫn lấy được
    WHERE (T5.WorkCenterCode = 'VVT_F3' OR T9.WorkCenterCode = 'VVT_F3')

    GROUP BY 
        COALESCE(T9.PackingID, g.PackingID),
        g.LotNo,
        g.TotalInput,
        ISNULL(T9.MaterialCode, T5.MaterialCode),
        T6.MaterialName,
        ISNULL(T9.MarkingCode, MK.MarkingCode),
        MK.MarkingName,
        g.CommentType,
        g.Note
),

    -- CTE Xuất kho
    XuatKho AS (
        SELECT 
            COALESCE(T2.PackingID, T10.PackingID) AS PackingID,
            T2.LotNo,
            T2.CustomerName,
			CASE
			    WHEN max(T10.PackingID) IS NOT NULL THEN SUM(T10.Qty)
				ELSE SUM(T2.Qty)
			END AS TotalOutput
            --SUM(ISNULL(T2.Qty, 0)) AS TotalOutput
        FROM STB_VN_FINISHGOODS_HN_Export T2 WITH (NOLOCK)
        LEFT JOIN STB_DividePackaging T10 WITH(NOLOCK) 
            ON T10.PackingParentID = T2.PackingID   -- Packing con → cha
        WHERE 
            (ISNULL(@pPackingID, '') = '' OR T2.PackingID = @pPackingID)
            AND (ISNULL(@pLotNo, '') = '' OR T2.LotNo = @pLotNo) 
			 AND (@pFromDate IS NULL OR T2.CreateDateTime >= @pFromDate)
            AND (@pToDate IS NULL OR T2.CreateDateTime <= @pToDate)
        GROUP BY 
            COALESCE(T2.PackingID, T10.PackingID),
            T2.LotNo,
            T2.CustomerName
    )
    -- Final UNION ALL and ORDER BY outside
    SELECT 
       ISNULL(HN.NewMaterialCode, n.MaterialCode) AS MaterialCode,
        n.MaterialName,
        n.PackingID, 
        n.LotNo,
        n.MarkingCode,
        n.MarkingName,
	CAST(
    DATEDIFF(DAY,
        CASE 
            WHEN n.MaterialCode = '30VS330ME12XXXVC01' THEN
                DATEFROMPARTS(
                    CASE LEFT((n.MarkingName COLLATE SQL_Latin1_General_CP1_CS_AS), 1)
                        WHEN 'A' THEN 2022 WHEN 'B' THEN 2022 WHEN 'C' THEN 2022 WHEN 'D' THEN 2022
                        WHEN 'E' THEN 2022 WHEN 'F' THEN 2022 WHEN 'G' THEN 2022 WHEN 'H' THEN 2022
                        WHEN 'I' THEN 2022 WHEN 'J' THEN 2022 WHEN 'K' THEN 2022 WHEN 'L' THEN 2022
                        WHEN 'M' THEN 2023 WHEN 'N' THEN 2023 WHEN 'O' THEN 2023 WHEN 'P' THEN 2023
                        WHEN 'Q' THEN 2023 WHEN 'R' THEN 2023 WHEN 'S' THEN 2023 WHEN 'T' THEN 2023
                        WHEN 'U' THEN 2023 WHEN 'V' THEN 2023 WHEN 'W' THEN 2023 WHEN 'X' THEN 2023
                        WHEN 'Y' THEN 2024 WHEN 'Z' THEN 2024 WHEN 'a' THEN 2024 WHEN 'b' THEN 2024
                        WHEN 'c' THEN 2024 WHEN 'd' THEN 2024 WHEN 'e' THEN 2024 WHEN 'f' THEN 2024
                        WHEN 'g' THEN 2024 WHEN 'h' THEN 2024 WHEN 'i' THEN 2024 WHEN 'j' THEN 2024
                        WHEN 'k' THEN 2025 WHEN 'l' THEN 2025 WHEN 'm' THEN 2025 WHEN 'n' THEN 2025
                        WHEN 'o' THEN 2025 WHEN 'p' THEN 2025 WHEN 'q' THEN 2025 WHEN 'r' THEN 2025
                        WHEN 's' THEN 2025 WHEN 't' THEN 2025 WHEN 'u' THEN 2025 WHEN 'v' THEN 2025
                        WHEN 'w' THEN 2025 WHEN 'x' THEN 2025 WHEN 'y' THEN 2025 WHEN 'z' THEN 2025
                    END,
                    CASE LEFT((n.MarkingName COLLATE SQL_Latin1_General_CP1_CS_AS), 1)
                        WHEN 'A' THEN 1  WHEN 'B' THEN 2  WHEN 'C' THEN 3  WHEN 'D' THEN 4
                        WHEN 'E' THEN 5  WHEN 'F' THEN 6  WHEN 'G' THEN 7  WHEN 'H' THEN 8
                        WHEN 'I' THEN 9  WHEN 'J' THEN 10 WHEN 'K' THEN 11 WHEN 'L' THEN 12
                        WHEN 'M' THEN 1  WHEN 'N' THEN 2  WHEN 'O' THEN 3  WHEN 'P' THEN 4
                        WHEN 'Q' THEN 5  WHEN 'R' THEN 6  WHEN 'S' THEN 7  WHEN 'T' THEN 8
                        WHEN 'U' THEN 9  WHEN 'V' THEN 10 WHEN 'W' THEN 11 WHEN 'X' THEN 12
                        WHEN 'Y' THEN 1  WHEN 'Z' THEN 2  WHEN 'a' THEN 3  WHEN 'b' THEN 4
                        WHEN 'c' THEN 5  WHEN 'd' THEN 6  WHEN 'e' THEN 7  WHEN 'f' THEN 8
                        WHEN 'g' THEN 9  WHEN 'h' THEN 10 WHEN 'i' THEN 11 WHEN 'j' THEN 12
                        WHEN 'k' THEN 1  WHEN 'l' THEN 2  WHEN 'm' THEN 3  WHEN 'n' THEN 4
                        WHEN 'o' THEN 5  WHEN 'p' THEN 6  WHEN 'q' THEN 7  WHEN 'r' THEN 8
                        WHEN 's' THEN 9  WHEN 't' THEN 10 WHEN 'u' THEN 11 WHEN 'v' THEN 12
                        WHEN 'w' THEN 1  WHEN 'x' THEN 2  WHEN 'y' THEN 3  WHEN 'z' THEN 4
                    END,
                    1
                )
            ELSE
                DATEFROMPARTS(
                    CASE LEFT(n.MarkingName, 1)
                        WHEN '0' THEN 2030 WHEN '1' THEN 2021 WHEN '2' THEN 2022
                        WHEN '3' THEN 2023 WHEN '4' THEN 2024 WHEN '5' THEN 2025
                        WHEN '6' THEN 2026 WHEN '7' THEN 2027 WHEN '8' THEN 2028
                        WHEN '9' THEN 2029
                    END,
                    CASE SUBSTRING(n.MarkingName, 2, 1)
                        WHEN 'A' THEN 1 WHEN 'B' THEN 2 WHEN 'C' THEN 3 WHEN 'D' THEN 4
                        WHEN 'E' THEN 5 WHEN 'F' THEN 6 WHEN 'G' THEN 7 WHEN 'H' THEN 8
                        WHEN 'J' THEN 9 WHEN 'K' THEN 10 WHEN 'L' THEN 11 WHEN 'M' THEN 12
                    END,
                    1
                )
        END,
        GETDATE()
    ) / 365.25 AS DECIMAL(5,2)
) AS MarkingAgeInYear,

        CAST(n.TotalInput AS INT) AS TotalInput,
        CAST(x.TotalOutput AS INT) AS TotalOutput,
        CAST(n.TotalInput - ISNULL(x.TotalOutput, 0) AS INT) AS StockQty,
        'EA' AS Unit,
		n.CommentType,
		case
		    WHEN n.CommentType = 1 THEN 'Good'
           WHEN n.CommentType = 2 THEN 'NG'
		   WHEN n.CommentType = 3 THEN 'Pending'
		   WHEN n.CommentType = 4 THEN 'Customer Return'
		   WHEN n.CommentType = 5 THEN 'On Hold'
		    WHEN n.CommentType = 6 THEN N'Chưa đánh giá'
        ELSE N'Chưa đánh giá'
		END AS CommentTypeImport,
	n.Note
		--select * from STB_ChangeMaterialCode_HN
    FROM NhapKho n
    LEFT JOIN XuatKho x 
        ON n.PackingID = x.PackingID --AND n.LotNo = x.LotNo
	LEFT JOIN STB_ChangeMaterialCode_HN HN WITH(NOLOCK) ON HN.PackingID = n.PackingID
    --WHERE (n.TotalInput - ISNULL(x.TotalOutput, 0)) > 0
    UNION ALL

    SELECT 
        ISNULL(HN.NewMaterialCode, FGHN.MaterialCode) AS MaterialCode,
        FGHN.ProductName AS MaterialName,
        FGHN.PackingID,
        FGHN.LotNo,
        NULL AS MarkingCode,
        FGHN.Marking AS MarkingName,
	CAST(
    DATEDIFF(DAY,
        CASE 
            WHEN FGHN.MaterialCode = '30VS330ME12XXXVC01' THEN
                DATEFROMPARTS(
                    CASE LEFT((FGHN.Marking COLLATE SQL_Latin1_General_CP1_CS_AS), 1)
                        WHEN 'A' THEN 2022 WHEN 'B' THEN 2022 WHEN 'C' THEN 2022 WHEN 'D' THEN 2022
                        WHEN 'E' THEN 2022 WHEN 'F' THEN 2022 WHEN 'G' THEN 2022 WHEN 'H' THEN 2022
                        WHEN 'I' THEN 2022 WHEN 'J' THEN 2022 WHEN 'K' THEN 2022 WHEN 'L' THEN 2022
                        WHEN 'M' THEN 2023 WHEN 'N' THEN 2023 WHEN 'O' THEN 2023 WHEN 'P' THEN 2023
                        WHEN 'Q' THEN 2023 WHEN 'R' THEN 2023 WHEN 'S' THEN 2023 WHEN 'T' THEN 2023
                        WHEN 'U' THEN 2023 WHEN 'V' THEN 2023 WHEN 'W' THEN 2023 WHEN 'X' THEN 2023
                        WHEN 'Y' THEN 2024 WHEN 'Z' THEN 2024 WHEN 'a' THEN 2024 WHEN 'b' THEN 2024
                        WHEN 'c' THEN 2024 WHEN 'd' THEN 2024 WHEN 'e' THEN 2024 WHEN 'f' THEN 2024
                        WHEN 'g' THEN 2024 WHEN 'h' THEN 2024 WHEN 'i' THEN 2024 WHEN 'j' THEN 2024
                        WHEN 'k' THEN 2025 WHEN 'l' THEN 2025 WHEN 'm' THEN 2025 WHEN 'n' THEN 2025
                        WHEN 'o' THEN 2025 WHEN 'p' THEN 2025 WHEN 'q' THEN 2025 WHEN 'r' THEN 2025
                        WHEN 's' THEN 2025 WHEN 't' THEN 2025 WHEN 'u' THEN 2025 WHEN 'v' THEN 2025
                        WHEN 'w' THEN 2025 WHEN 'x' THEN 2025 WHEN 'y' THEN 2025 WHEN 'z' THEN 2025
                    END,
                    CASE LEFT((FGHN.Marking COLLATE SQL_Latin1_General_CP1_CS_AS), 1)
                        WHEN 'A' THEN 1  WHEN 'B' THEN 2  WHEN 'C' THEN 3  WHEN 'D' THEN 4
                        WHEN 'E' THEN 5  WHEN 'F' THEN 6  WHEN 'G' THEN 7  WHEN 'H' THEN 8
                        WHEN 'I' THEN 9  WHEN 'J' THEN 10 WHEN 'K' THEN 11 WHEN 'L' THEN 12
                        WHEN 'M' THEN 1  WHEN 'N' THEN 2  WHEN 'O' THEN 3  WHEN 'P' THEN 4
                        WHEN 'Q' THEN 5  WHEN 'R' THEN 6  WHEN 'S' THEN 7  WHEN 'T' THEN 8
                        WHEN 'U' THEN 9  WHEN 'V' THEN 10 WHEN 'W' THEN 11 WHEN 'X' THEN 12
                        WHEN 'Y' THEN 1  WHEN 'Z' THEN 2  WHEN 'a' THEN 3  WHEN 'b' THEN 4
                        WHEN 'c' THEN 5  WHEN 'd' THEN 6  WHEN 'e' THEN 7  WHEN 'f' THEN 8
                        WHEN 'g' THEN 9  WHEN 'h' THEN 10 WHEN 'i' THEN 11 WHEN 'j' THEN 12
                        WHEN 'k' THEN 1  WHEN 'l' THEN 2  WHEN 'm' THEN 3  WHEN 'n' THEN 4
                        WHEN 'o' THEN 5  WHEN 'p' THEN 6  WHEN 'q' THEN 7  WHEN 'r' THEN 8
                        WHEN 's' THEN 9  WHEN 't' THEN 10 WHEN 'u' THEN 11 WHEN 'v' THEN 12
                        WHEN 'w' THEN 1  WHEN 'x' THEN 2  WHEN 'y' THEN 3  WHEN 'z' THEN 4
                    END,
                    1
                )
            ELSE
                DATEFROMPARTS(
                    CASE LEFT(FGHN.Marking, 1)
                        WHEN '0' THEN 2030 WHEN '1' THEN 2021 WHEN '2' THEN 2022
                        WHEN '3' THEN 2023 WHEN '4' THEN 2024 WHEN '5' THEN 2025
                        WHEN '6' THEN 2026 WHEN '7' THEN 2027 WHEN '8' THEN 2028
                        WHEN '9' THEN 2029
                    END,
                    CASE SUBSTRING(FGHN.Marking, 2, 1)
                        WHEN 'A' THEN 1 WHEN 'B' THEN 2 WHEN 'C' THEN 3 WHEN 'D' THEN 4
                        WHEN 'E' THEN 5 WHEN 'F' THEN 6 WHEN 'G' THEN 7 WHEN 'H' THEN 8
                        WHEN 'J' THEN 9 WHEN 'K' THEN 10 WHEN 'L' THEN 11 WHEN 'M' THEN 12
                    END,
                    1
                )
        END,
        GETDATE()
    ) / 365.25 AS DECIMAL(5,2)
) AS MarkingAgeInYear,




        CAST(FGHN.Quantity AS INT) AS TotalInput,
        CAST(ISNULL(FGHN.QtyOutput, 0) AS INT) AS TotalOutput,
        CAST(FGHN.Quantity - ISNULL(FGHN.QtyOutput, 0) AS INT) AS StockQty,
        FGHN.Unit,
		FGHN.CommentType,
		case
		   WHEN FGHN.CommentType = 1 THEN 'Good'
           WHEN FGHN.CommentType = 2 THEN 'NG'
		   WHEN FGHN.CommentType = 3 THEN 'Pending'
		   WHEN FGHN.CommentType = 4 THEN 'Customer Return'
		   WHEN FGHN.CommentType = 5 THEN 'On Hold'
		   WHEN FGHN.CommentType = 6 THEN N'Chưa đánh giá'
        ELSE N'Chưa đánh giá'
		END AS CommentTypeImport,
		 FGHN.Note
	
    FROM FinishGoodMESInstock_HN FGHN
	--LEFT JOIN STB_VN_FINISHGOODS_HN_New T9 on T9.PackingID=FGHN.PackingID
	LEFT JOIN STB_ChangeMaterialCode_HN HN WITH(NOLOCK) ON HN.PackingID = FGHN.PackingID
	--LEFT JOIN STB_ChangeMaterialCode_Config CFG WITH(NOLOCK) ON CFG.oldMaterialCode = HN.oldMaterialCode
    WHERE 
        (ISNULL(@pPackingID, '') = '' OR FGHN.PackingID = @pPackingID)
        AND (ISNULL(@pLotNo, '') = '' OR FGHN.LotNo = @pLotNo)
		--AND (FGHN.Quantity - ISNULL(FGHN.QtyOutput, 0)) > 0
		 AND (@pFromDate IS NULL OR FGHN.CreateDateTime >= @pFromDate)
            AND (@pToDate IS NULL OR FGHN.CreateDateTime <= @pToDate)
    ORDER BY MaterialCode, PackingID;
	

END



--PKPP1600348_02
