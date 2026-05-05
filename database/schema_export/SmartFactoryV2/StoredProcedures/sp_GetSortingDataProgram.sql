-- Procedure: sp_GetSortingDataProgram
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- exec sp_GetSortingDataProgram '','','2026-04-26','2026-04-26','VVQM243R072752',''
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetSortingDataProgram]
    @pProcessUserID VARCHAR(20) = NULL,
	@pProcessLanguage VARCHAR(20) = NULL,
    @pFromDate DATETIME,
    @pToDate   DATETIME,
    @pBarcode NVARCHAR(50) = NULL,
    @pEquipmentNumber NVARCHAR(50) = NULL
AS

    declare @FromDate varchar(19) = convert(varchar(10),@pFromDate,120)
	declare @Todate varchar(19) = convert(varchar(10),dateadd(DAY,1,@pTodate),120) 
	DECLARE	@Barcode     VARCHAR(50) = CASE WHEN ISNULL(@pBarcode, '') = ''  THEN '*' ELSE @pBarcode     END
    DECLARE	@EquipmentNumber     VARCHAR(50) = CASE WHEN ISNULL(@pEquipmentNumber, '') = ''  THEN '*' ELSE @pEquipmentNumber     END
BEGIN
    SET NOCOUNT ON;
	
	-- Mr.Triêu(Dev) lấy ra tât cả mã điện cực ở nhà máy Bắc Giang
	;WITH RawMaterial AS (
        SELECT 
            Barcode,
			SUBSTRING(MAX(CASE WHEN ProductGroupCode = 'ElectrodeM' THEN RawMaterialBarcode END), 1, 14) AS ElectrodeM_Barcode_Short,
            SUBSTRING(MAX(CASE WHEN ProductGroupCode = 'ElectrodeP' THEN RawMaterialBarcode END), 1, 14) AS ElectrodeP_Barcode_Short
        FROM STB_RawMaterialInputHist WITH(NOLOCK)
		--where Barcode='VVQK053R072730'
        WHERE (@Barcode='*' OR Barcode = @Barcode) and CreateDateTime>='2026-01-01' and CreateDateTime<='2026-12-31' 
		and CreateUserID='vvtworker_bg' 
		and ProductGroupCode in ('ElectrodeM','ElectrodeP')
        GROUP BY Barcode

	
    ),
	--Mapping dữ liệu để lấy ra mã nguyên vật liệu từ bảng tạo lot điện cực
	 MappedMaterials AS (
        SELECT 
            RM.*,
            SetM.MaterialCode AS ElectrodeM_Code,
            SetP.MaterialCode AS ElectrodeP_Code
        FROM RawMaterial RM
        LEFT JOIN STB_SetInfo SetM WITH(NOLOCK) ON RM.ElectrodeM_Barcode_Short = SetM.Barcode
        LEFT JOIN STB_SetInfo SetP WITH(NOLOCK) ON RM.ElectrodeP_Barcode_Short = SetP.Barcode
    )
	
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
        FilePath,
		T10.ElectrodeM_Barcode_Short AS ElectrodeM_Code,
        T3.MaterialName AS ElectrodeM_Name,
		T10.ElectrodeP_Barcode_Short ASElectrodeP_Code,
        T4.MaterialName AS ElectrodeP_Name
    FROM 
        SortingDataImportExcel T1
		LEFT JOIN STB_SetInfo T2 WITH(NOLOCK) ON T1.Barcode=T2.Barcode
		LEFT JOIN RawMaterial RM WITH(NOLOCK) ON T1.Barcode = RM.Barcode
		LEFT JOIN MappedMaterials T10 ON T1.Barcode = T10.Barcode 
        LEFT JOIN STB_MaterialMaster T3 WITH(NOLOCK) ON T10.ElectrodeM_Code = T3.MaterialCode
        LEFT JOIN STB_MaterialMaster T4 WITH(NOLOCK) ON T10.ElectrodeP_Code = T4.MaterialCode
    WHERE 
     
        (ImportDate >= @FromDate AND ImportDate <= @ToDate)
        AND
      
        (@Barcode = '*' OR @Barcode = '' OR T1.Barcode = @Barcode)
        AND
         (@EquipmentNumber = '*' OR @EquipmentNumber = '' 
         OR EquipmentNumber Like '%' + @EquipmentNumber + '%')
    ORDER BY 
       ImportDate DESC;
END


GO

