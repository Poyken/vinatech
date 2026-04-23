-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- exec sp_GetSortingDataProgram '','','2026-02-01','2026-03-31',''
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetSortingDataProgram]
    @pProcessUserID VARCHAR(20) = NULL,
	@pProcessLanguage VARCHAR(20) = NULL,
    @pFromDate DATETIME,
    @pToDate   DATETIME,
    @pBarcode NVARCHAR(50) = NULL,
    @pEquipmentNumber NVARCHAR(50) = NULL
AS

    declare @FromDate varchar(19) = convert(varchar(10),@pFromDate,120) + ' 10:00:00'
	declare @Todate varchar(19) = convert(varchar(10),dateadd(DAY,1,@pTodate),120) + ' 10:00:00'
	DECLARE	@Barcode     VARCHAR(50) = CASE WHEN ISNULL(@pBarcode, '') = ''  THEN '*' ELSE @pBarcode     END
    DECLARE	@EquipmentNumber     VARCHAR(50) = CASE WHEN ISNULL(@pEquipmentNumber, '') = ''  THEN '*' ELSE @pEquipmentNumber     END
BEGIN
    SET NOCOUNT ON;
	/*
	;WITH RawMaterial AS (
        SELECT 
            Barcode,
            MAX(CASE WHEN ProductGroupCode = 'ElectrodeM' THEN RawMaterialBarcode END) AS ElectrodeM,
            MAX(CASE WHEN ProductGroupCode = 'ElectrodeP' THEN RawMaterialBarcode END) AS ElectrodeP
        FROM STB_RawMaterialInputHist WITH(NOLOCK)
		--where Barcode='VVQK053R072730'
        WHERE (@Barcode='*' OR Barcode = @Barcode) and CreateDateTime>=@FromDate and CreateDateTime<=@Todate and CreateUserID='vvtworker_bg' and ProductGroupCode in ('ElectrodeM','ElectrodeP')
        GROUP BY Barcode
    )
	*/
    SELECT 
	    T2.InputLineCode, -- Mr.Triều add CellLine follow request Mr Cao Hưng
       'Sorting ' + REPLACE(EquipmentNumber, '#', '') as EquipmentNumber,
        SorterNum,
        DATEADD(hour, 2, StartTime) as StartTime,
        WorkflowCode,
        T1.Barcode,
        Slot,
        Position,
        Channel,
        Capacity_mAh,
        Capacitance_F,
        BeginVoltageSD_mV,
        ChargeEndCurrent_mA,
        EndVoltage_mV,
        EndCurrent_mA,
        DischargeVoltage1_mV,
        DischargeVoltage1_Time,
        DischargeVoltage2_mV,
        DischargeVoltage2_Time,
        DischargeBeginVoltage_mV,
        DischargeBeginCurrent_mA,
        NGInfo,
        DATEADD(hour, 2, EndTime) as EndTime,
        FilePath
		--RM.ElectrodeM,
        --RM.ElectrodeP
    FROM 
        SortingDataImportExcel T1
		LEFT JOIN STB_SetInfo T2 WITH(NOLOCK) ON T1.Barcode=T2.Barcode
		--EFT JOIN RawMaterial RM WITH(NOLOCK) ON T1.Barcode = RM.Barcode
    WHERE 
     
        (ImportDate >= @FromDate AND ImportDate <= @ToDate)
        AND
      
        (@Barcode = '*' OR @Barcode = '' OR T1.Barcode = @Barcode)
        AND
         (@EquipmentNumber = '*' OR @EquipmentNumber = '' 
         OR EquipmentNumber Like '%' + @EquipmentNumber + '%')
    ---ORDER BY 
       --ImportDate DESC;
END

