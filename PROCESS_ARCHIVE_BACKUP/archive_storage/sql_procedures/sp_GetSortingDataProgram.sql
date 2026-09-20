CREATE PROCEDURE [dbo].[sp_GetSortingDataProgram]
    @pProcessUserID VARCHAR(20) = NULL,
    @pProcessLanguage VARCHAR(20) = NULL,
    @pFromDate DATETIME,
    @pToDate   DATETIME,
    @pBarcode NVARCHAR(50) = NULL,
    @pEquipmentNumber NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120)
    DECLARE @ToDate   VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, @pToDate), 120) 
    DECLARE @Barcode  VARCHAR(50) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END
    DECLARE @EquipmentNumber VARCHAR(50) = CASE WHEN ISNULL(@pEquipmentNumber, '') = '' THEN '*' ELSE @pEquipmentNumber END

    SELECT 
        -- 1. Thông tin MES
        ISNULL(T2.InputLineCode, 'Line ' + REPLACE(T1.EquipmentNumber, '#', '')) AS InputLineCode,
        'Sorting ' + REPLACE(T1.EquipmentNumber, '#', '') AS EquipmentNumber,
        T2.LotNumber AS LotNo,
        
        -- 2. Thẻ vị trí & mã vạch (Khớp 100% Excel)
        T1.Channel,
        T1.Position,
        ISNULL(NULLIF(T1.TrayID, ''), 
            CASE WHEN CHARINDEX('#', T1.Position) > 0 AND CHARINDEX('-', T1.Position) > CHARINDEX('#', T1.Position)
                 THEN SUBSTRING(T1.Position, CHARINDEX('#', T1.Position) + 1, CHARINDEX('-', T1.Position) - CHARINDEX('#', T1.Position) - 1)
                 ELSE T1.TrayID END) AS TrayID,
        T1.Barcode,
        
        -- 3. Công đoạn CCCVChg (Nạp CCCV - Khớp 100% Excel)
        'CCCVChg' AS CCCVChg_WorkType,
        T1.CCCVChg_WorkstepTime,
        T1.CCCVChg_StopReason,
        T1.CCCVChg_BeginVoltage_mV,
        T1.CCCVChg_EndVoltage_mV,
        T1.CCCVChg_BeginTime,
        T1.CCCVChg_EndTime,
        T1.CCCVChg_BeginDKVoltage_mV,
        T1.CCCVChg_BeginCurrent_mA,
        T1.CCCVChg_EndCurrent_mA,
        T1.CCCVChg_EndDKVoltage_mV,
        
        -- 4. Công đoạn CCDchg (Xả CC - Khớp 100% Excel)
        'CCDchg' AS CCDchg_WorkType,
        T1.CCDchg_WorkstepTime,
        T1.CCDchg_StopReason,
        T1.CCDchg_BeginVoltage_mV,
        T1.CCDchg_EndVoltage_mV,
        T1.CCDchg_BeginTime,
        T1.CCDchg_EndTime,
        T1.CCDchg_BeginCurrent_mA,
        T1.CCDchg_EndCurrent_mA,
        T1.CCDchg_Capacity_mAh,
        T1.CCDchg_Capacitance_F,
        T1.CCDchg_Capacitance1_F,
        T1.CCDchg_CapacitanceVoltage2_mV,
        T1.CCDchg_Capacitance2_F,
        T1.CCDchg_Capacitance3_F,
        T1.CCDchg_Capacitance4_F,
        
        -- 5. Công đoạn Rest (Nghỉ - Khớp 100% Excel)
        'Rest' AS Rest_WorkType,
        T1.Rest_WorkstepTime,
        T1.Rest_StopReason,
        T1.Rest_BeginVoltage_mV,
        T1.Rest_EndVoltage_mV,
        T1.Rest_BeginTime,
        T1.Rest_EndTime,
        T1.Rest_BeginDKVoltage_mV,
        
        -- 6. Quản lý file hệ thống
        T1.FilePath,
        T1.ImportDate
    FROM SortingDataImportExcel_V2 T1 WITH(NOLOCK)
    LEFT JOIN STB_SetInfo T2 WITH(NOLOCK) ON ISNULL(T1.Barcode, '') <> '' AND T1.Barcode = T2.Barcode
    WHERE (T1.ImportDate >= @FromDate AND T1.ImportDate <= @ToDate)
      AND (@Barcode = '*' OR @Barcode = '' OR T1.Barcode = @Barcode)
      AND (@EquipmentNumber = '*' OR @EquipmentNumber = '' OR T1.EquipmentNumber LIKE '%' + @EquipmentNumber + '%')
    ORDER BY T1.ImportDate DESC;
END