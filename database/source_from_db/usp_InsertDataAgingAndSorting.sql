-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2026-01-22
-- Description:	Thêm dữ liệu vào database
-- =============================================
CREATE PROCEDURE [dbo].[usp_InsertDataAgingAndSorting]
	-- Add the parameters for the stored procedure here
	@WorkCenterCode NVARCHAR(50),
    @EquipmentNumber NVARCHAR(100),
    @SorterNum NVARCHAR(100),
    @StartTime NVARCHAR(100),
    @WorkflowCode NVARCHAR(100),
    @Barcode NVARCHAR(100),
    @Slot NVARCHAR(50),
    @Position NVARCHAR(50),
    @Channel NVARCHAR(50),
    @Capacity NVARCHAR(50),
    @Capacitance NVARCHAR(50),
    @BeginVoltageSD NVARCHAR(50),
    @ChargeEndCurrent NVARCHAR(50),
    @EndVoltage NVARCHAR(50),
    @EndCurrent NVARCHAR(50),
    @DischargeVoltage1 NVARCHAR(50),
    @DischargeVoltage1_Time NVARCHAR(50),
    @DischargeVoltage2 NVARCHAR(50),
    @DischargeVoltage2_Time NVARCHAR(50),
    @DischargeBeginVoltage NVARCHAR(50),
    @DischargeBeginCurrent NVARCHAR(50),
    @NGInfo NVARCHAR(200),
    @EndTime NVARCHAR(100),
    @LineCode NVARCHAR(100),
    @MachineName NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	INSERT INTO STB_AgingSortingData (
        WorkCenterCode, EquipmentNumber, SorterNum, StartTime, WorkflowCode, Barcode, 
        Slot, Position, Channel, Capacity, Capacitance, BeginVoltageSD, ChargeEndCurrent, 
        EndVoltage, EndCurrent, DischargeVoltage1, DischargeVoltage1_Time, 
        DischargeVoltage2, DischargeVoltage2_Time, DischargeBeginVoltage, 
        DischargeBeginCurrent, NGInfo, EndTime, LineCode, MachineName, CreatedDateTime
    )
    VALUES (
        @WorkCenterCode, @EquipmentNumber, @SorterNum, @StartTime, @WorkflowCode, @Barcode, 
        @Slot, @Position, @Channel, @Capacity, @Capacitance, @BeginVoltageSD, @ChargeEndCurrent, 
        @EndVoltage, @EndCurrent, @DischargeVoltage1, @DischargeVoltage1_Time, 
        @DischargeVoltage2, @DischargeVoltage2_Time, @DischargeBeginVoltage, 
        @DischargeBeginCurrent, @NGInfo, @EndTime, @LineCode, @MachineName, GETDATE()
    );
END
