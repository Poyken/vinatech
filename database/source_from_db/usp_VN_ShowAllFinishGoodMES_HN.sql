-- =============================================
-- Author:		Nguyen Hai Trieu
-- Create date: 2025-04-22
-- Description:	Finish Good MES for Ha Nam Factory
-- exec usp_VN_ShowAllFinishGoodMES_HN'2025-01-08','2025-08-06'
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_ShowAllFinishGoodMES_HN]
	-- Add the parameters for the stored procedure here
		@pFromdateinput DATE = NULL,
		@pTodateinput DATE = NULL
		--@TypeInput NVARCHAR(50) = NULL,
		--@pIsNhapKho BIT=null
AS
BEGIN
     --select * from stb_materialLotinfo
	 -- select top 2 * from STB_CreateMarkingLetterAndQtyForBarcode
	 -- select top 2 * from stb_materialLotinfo
	    ;WITH LotInfo AS (
        SELECT 
            PackingID,
            MIN(MergeParentID) AS MergeParentID,
            MIN(MaterialCode) AS MaterialCode,
            SUM(CAST(CurrentQty AS INT)) AS TotalCurrentQty
        FROM stb_materialLotinfo WITH (NOLOCK)
        GROUP BY PackingID
    ),
    -- Gom dữ liệu Marking để mỗi LotNo chỉ còn 1 dòng
    MarkingInfo AS (
        SELECT 
            Barcode AS LotNo,
            MIN(MarkingCode) AS MarkingCode,
            MIN(MarkingName) AS MarkingName
        FROM STB_CreateMarkingLetterAndQtyForBarcode WITH (NOLOCK)
        GROUP BY Barcode
    )
    SELECT
        T3.IDCODE,
        T3.PackingID,
        T5.MergeParentID,
        T3.LotNo,
        T5.MaterialCode,
        T6.MaterialName,
        T7.MarkingCode,
        T7.MarkingName,
        CAST(
            DATEDIFF(MONTH, 
                DATEFROMPARTS(
                    CASE LEFT(T7.MarkingName, 1)
                        WHEN '0' THEN 2030
                        WHEN '1' THEN 2021
                        WHEN '2' THEN 2022
                        WHEN '3' THEN 2023
                        WHEN '4' THEN 2024
                        WHEN '5' THEN 2025
                        WHEN '6' THEN 2026
                        WHEN '7' THEN 2027
                        WHEN '8' THEN 2028
                        WHEN '9' THEN 2029
                        ELSE NULL
                    END,
                    CASE SUBSTRING(T7.MarkingName, 2, 1)
                        WHEN 'A' THEN 1
                        WHEN 'B' THEN 2
                        WHEN 'C' THEN 3
                        WHEN 'D' THEN 4
                        WHEN 'E' THEN 5
                        WHEN 'F' THEN 6
                        WHEN 'G' THEN 7
                        WHEN 'H' THEN 8
                        WHEN 'J' THEN 9
                        WHEN 'K' THEN 10
                        WHEN 'L' THEN 11
                        WHEN 'M' THEN 12
                        ELSE NULL
                    END,
                    1
                ),
                GETDATE()
            ) / 12.0 AS DECIMAL(5, 2)
        ) AS MarkingAgeInYear,
        T3.PackQty,
        ISNULL(T5.TotalCurrentQty, 0) AS InitQty,
        T3.PackQtyOutPut,
        CASE  
            WHEN T3.PackQtyOutPut - T3.PackQty < 0 THEN 0
            ELSE T3.PackQtyOutPut - T3.PackQty
        END AS RemainingQty,
        T3.PublicCode, 
        T3.MethodAction,
        T3.SoPhieuNhapKho,
        T3.WorkCenterCode,
        T3.CreateDateTime  AS CreateDateIn,
        T3.Locations,
        T3.TypeInput,
        T4.TypeName,
        T3.CreateUserID,
        T3.ChangeUserID AS PersonOut,
        T3.ChangeDateTime AS CreateDateOut,
        ISNULL(T8.MBIExtText04, '') + 'V ' +
        ISNULL(T8.MBIExtText05, '') + 'µF, Ø' +
        CONVERT(VARCHAR, CONVERT(DECIMAL(10,1), T8.MBISizeW)) + '*' +
        CONVERT(VARCHAR, CONVERT(DECIMAL(10,1), T8.MBISizeH)) + 'L' AS FullSpec,
        NULL AS WarehouseName,
        NULL AS WarehouseType,
        NULL AS Note
    FROM STB_VN_FINISHGOODS_HN_New T3 WITH (NOLOCK)
    LEFT JOIN STB_TypeImport_HN T4 WITH (NOLOCK) ON T3.TypeInput = T4.TypeCode
    LEFT JOIN LotInfo T5 ON T3.PackingID = T5.PackingID
    LEFT JOIN STB_MaterialMaster T6 WITH (NOLOCK) ON T5.MaterialCode = T6.MaterialCode
    LEFT JOIN MarkingInfo T7 ON T3.LotNo = T7.LotNo
    LEFT JOIN STB_ModelBasicInfo T8 ON T8.ModelCode = T5.MaterialCode
    WHERE 
        (@pFromdateinput IS NULL OR CONVERT(DATE, T3.CreateDateTime) >= @pFromdateinput)
        AND 
        (@pTodateinput IS NULL OR CONVERT(DATE, T3.CreateDateTime) <= @pTodateinput)

    UNION ALL

    SELECT
        'HN' + RIGHT('000000' + CAST(ROW_NUMBER() OVER (ORDER BY CreateDateTime ASC) AS VARCHAR), 6) AS IDCODE,
        PackingID,
        NULL AS MergeParentID,
        LotNo,
        MaterialCode,
        ProductName AS MaterialName,
        NULL AS MarkingCode,
        Marking AS MarkingName,
        CAST(
            DATEDIFF(MONTH, 
                DATEFROMPARTS(
                    CASE LEFT(Marking, 1)
                        WHEN '0' THEN 2030
                        WHEN '1' THEN 2021
                        WHEN '2' THEN 2022
                        WHEN '3' THEN 2023
                        WHEN '4' THEN 2024
                        WHEN '5' THEN 2025
                        WHEN '6' THEN 2026
                        WHEN '7' THEN 2027
                        WHEN '8' THEN 2028
                        WHEN '9' THEN 2029
                        ELSE NULL
                    END,
                    CASE SUBSTRING(Marking, 2, 1)
                        WHEN 'A' THEN 1
                        WHEN 'B' THEN 2
                        WHEN 'C' THEN 3
                        WHEN 'D' THEN 4
                        WHEN 'E' THEN 5
                        WHEN 'F' THEN 6
                        WHEN 'G' THEN 7
                        WHEN 'H' THEN 8
                        WHEN 'J' THEN 9
                        WHEN 'K' THEN 10
                        WHEN 'L' THEN 11
                        WHEN 'M' THEN 12
                        ELSE NULL
                    END,
                    1
                ),
                GETDATE()
            ) / 12.0 AS DECIMAL(5, 2)
        ) AS MarkingAgeInYear,
        Quantity,
        Quantity AS InitQty,
        Quantity AS PackQtyOutPut,
        0 AS RemainingQty,
        NULL AS PublicCode,
        NULL AS MethodAction,
        NULL AS SoPhieuNhapKho,
        NULL AS WorkCenterCode,
        CreateDateTime AS CreateDateIn,
        NULL AS Locations,
        NULL AS TypeInput,
        NULL AS TypeName,
        CreateUserID,
        ChangeUserID AS PersonOut,
        ChangeDateTime AS CreateDateOut,
        '' AS FullSpec,
        WarehouseName,
        WarehouseType,
        N'Dữ liệu đẩy lên trước khi dùng MES' AS Note
    FROM FinishGoodMESInstock_HN WITH (NOLOCK)
    ORDER BY CreateDateIn DESC

END
/*
select top 1 * from STB_VN_FINISHGOODS_HN_New
 select * from STB_VN_FINISHGOODS_HN_New where CreateDateTime>='2025-04-25'  and PackingID='PKPM2400279'
 select  * from stb_materialLotinfo where PackingID='PKPM2400279'
 SELECT COUNT(*) 
FROM STB_VN_FINISHGOODS_HN_New T3
LEFT JOIN stb_materialLotinfo T5 ON T3.PackingID = T5.PackingID
WHERE T3.CreateDateTime >= '2025-04-25'*/