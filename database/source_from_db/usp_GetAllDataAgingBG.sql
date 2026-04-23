-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-08-14
-- Description:	Get all data aging Bac Giang
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetAllDataAgingBG]
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pFromDate DATETIME = NULL,
			@pToDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00'
	DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00'


    -- Insert statements for procedure here
	SELECT 
		ABG.ID,
		ABG.EquipmentNumber,
		ABG.SorterNum,
		ABG.StartTime,
		ABG.WorkflowCode, 
		ABG.Barcode,
		ABG.Slot,
		ABG.Position,
		ABG.Channel,
		ABG.Capacity AS [Capacity(mAh)],
		ABG.Capacitance AS [Capacitance(F)],
		ABG.BeginVoltageSD AS [BeginVoltageSD(mV)],
		ABG.ChargeEndCurrent AS [ChargeEndCurrent(mA)],
		ABG.EndVoltage AS [EndVoltage(mV)],
		ABG.EndCurrent AS [EndCurrent(mA)],
		ABG.DischargeVoltage1 AS [DischargeVoltage1(mV)],
		ABG.DischargeVoltage1_Time AS [DischargeVoltage1_Time (mm：ss)],
		ABG.DischargeVoltage2 AS [DischargeVoltage2(mV)],
		ABG.DischargeVoltage2_Time [DischargeVoltage2_Time (mm：ss)],
		ABG.DischargeBeginVoltage AS [DischargeBeginVoltage(mV)],
		ABG.DischargeBeginCurrent AS [DischargeBeginCurrent(mA)],
		ABG.NGInfo,
		ABG.EndTime,
		ABG.SystemCreateDate,
		ABG.Computers,
		ABG.Linename
	FROM
		stb_vn_AgingBG ABG WITH(NOLOCK)

	WHERE 
		ABG.StartTime BETWEEN @FromDate AND @ToDate

END
