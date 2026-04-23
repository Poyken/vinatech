-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-07-18
-- Description:	Get Slitting Knife Lot
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_SlittingKnifeElectrodeLotNumber_get]
	-- Add the parameters for the stored procedure here
			@pSlittingKnifeLotID VARCHAR(30) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @SlittingKnifeLotID VARCHAR(30) = @pSlittingKnifeLotID 

	--with lot as (
	--	SELECT 
	--		ESR.SlittingKnifeLotID,
	--		ESR.ElectrodeLotNumber,
	--		SUM(ESR.GoodQtyLength) AS GoodQtyLength

	--	FROM STB_ElectrodeSlittingResult ESR 
	--	WHERE ESR.SlittingKnifeLotID = @SlittingKnifeLotID
		
	--)


	SELECT
			ESR.ElectrodeLotNumber,
			ESR.GoodQtyLength,
			ESI.MachineCode,
			MM.MachineName,
			ESR.Barcode,
			ESR.LotUniqueNumber,
			ESR.CreateDateTime,
			ESR.CreateUserID,
			ESR.ChangeDateTime,
			ESR.ChangeUserID

	FROM	STB_ElectrodeSlittingResult ESR WITH(NOLOCK) 
	LEFT JOIN STB_ElectrodeSlittingInfo ESI WITH(NOLOCK) ON ESR.ElectrodeLotNumber = ESI.ElectrodeLotNumber
	LEFT JOIN STB_MachineMaster MM WITH(NOLOCK) ON MM.MachineCode = ESI.MachineCode
	 
	WHERE 1=1
	AND ESR.SlittingKnifeLotID = @SlittingKnifeLotID

	ORDER BY ESR.CreateDateTime, ESR.ElectrodeLotNumber 
	-- exec usp_VN_SlittingKnifeElectrodeLotNumber_get 'DC2025071204'
END
