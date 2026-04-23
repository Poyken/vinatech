-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-07-10
-- Description:	Get Slitting Knife Code in use
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_SlittingKnifeUsed_get]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20)
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



    -- Insert statements for procedure here
	SELECT 
		SNIU.SlittingKnifeLotID ,
		SNIU.SlittingKnifeCode ,
		SKI.SlittingKnifeName,
		SNIU.MachineCode ,
		MM.MachineName,
		(SELECT SUM(ESR.GoodQtyLength) FROM STB_ElectrodeSlittingResult ESR WHERE ESR.SlittingKnifeLotID = SNIU.SlittingKnifeLotID 
			)	AS UsedQty,
		SKI.StandardQty,
		SNIU.UsingStatus ,
		SNIU.CreateDateTime ,
		SNIU.CreateUserID 
	FROM	
		STB_VN_SlittingKnifeInUse SNIU WITH(NOLOCK)
		LEFT JOIN STB_VN_SlittingKnifeInfo SKI WITH(NOLOCK) ON SKI.SlittingKnifeCode = SNIU.SlittingKnifeCode
		--LEFT JOIN STB_VN_SlittingKnifeLotInfo SKLI WITH(NOLOCK) ON SKLI.SlittingKnifeLotID = SNIU.SlittingKnifeLotID
		LEFT JOIN STB_MachineMaster MM WITH(NOLOCK) ON SNIU.MachineCode = MM.MachineCode
		--LEFT JOIN STB_ElectrodeSlittingResult ESR WITH (NOLOCK) ON ESR.ElectrodeLotNumber = SKLI.
	WHERE 1=1
		AND SNIU.UsingStatus = 0

	ORDER BY 
		CreateDateTime desc
END
