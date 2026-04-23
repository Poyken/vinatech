-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-07-18
-- Description:	Get Slitting Knife Lot
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_SlittingKnifeLotID_get]
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pSlittingKnifeLotID VARCHAR(30) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @SlittingKnifeLotID VARCHAR(20) = CASE WHEN ISNULL(@pSlittingKnifeLotID,'') = '' THEN '%' ELSE @pSlittingKnifeLotID END


	IF (@SlittingKnifeLotID = '%' OR SUBSTRING(@SlittingKnifeLotID, 1, 2) = 'DC')    -- Tìm kiếm theo mã dao
		BEGIN
			SELECT 
				SNIU.SlittingKnifeLotID ,
				SNIU.SlittingKnifeCode ,
				SKI.SlittingKnifeName,
				SNIU.MachineCode ,
				MM.MachineName,
				(SELECT SUM(ESR.GoodQtyLength) FROM STB_ElectrodeSlittingResult ESR WHERE ESR.SlittingKnifeLotID = SNIU.SlittingKnifeLotID 
				)	AS UsedQty,
				SKI.StandardQty,
				--SNIU.UsingStatus ,
				CASE
					WHEN SNIU.UsingStatus = 1 THEN N'Đang dùng'
					ELSE N'Đã dùng'
				END AS UsingStatus,
				SNIU.CreateDateTime ,
				SNIU.CreateUserID 
			FROM	
				STB_VN_SlittingKnifeInUse SNIU WITH(NOLOCK)
				LEFT JOIN STB_VN_SlittingKnifeInfo SKI WITH(NOLOCK) ON SKI.SlittingKnifeCode = SNIU.SlittingKnifeCode
				--LEFT JOIN STB_VN_SlittingKnifeLotInfo SKLI WITH(NOLOCK) ON SKLI.SlittingKnifeLotID = SNIU.SlittingKnifeLotID
				LEFT JOIN STB_MachineMaster MM WITH(NOLOCK) ON SNIU.MachineCode = MM.MachineCode
				--LEFT JOIN STB_ElectrodeSlittingResult ESR WITH (NOLOCK) ON ESR.ElectrodeLotNumber = SKLI.
			WHERE 1=1
				AND SNIU.SlittingKnifeLotID LIKE @SlittingKnifeLotID

			ORDER BY 
				CreateDateTime desc
		END


	ELSE 
		BEGIN
			SELECT 
				SNIU.SlittingKnifeLotID ,
				SNIU.SlittingKnifeCode ,
				SKI.SlittingKnifeName,
				SNIU.MachineCode ,
				MM.MachineName,
				(SELECT SUM(ESR.GoodQtyLength) FROM STB_ElectrodeSlittingResult ESR WHERE ESR.SlittingKnifeLotID = SNIU.SlittingKnifeLotID 
				)	AS UsedQty,
				SKI.StandardQty,
				--SNIU.UsingStatus ,
				CASE
					WHEN SNIU.UsingStatus = 1 THEN N'Đang dùng'
					ELSE N'Đã dùng'
				END AS UsingStatus,
				SNIU.CreateDateTime ,
				SNIU.CreateUserID 
			FROM	
				STB_VN_SlittingKnifeInUse SNIU WITH(NOLOCK)
				LEFT JOIN STB_VN_SlittingKnifeInfo SKI WITH(NOLOCK) ON SKI.SlittingKnifeCode = SNIU.SlittingKnifeCode
				--LEFT JOIN STB_VN_SlittingKnifeLotInfo SKLI WITH(NOLOCK) ON SKLI.SlittingKnifeLotID = SNIU.SlittingKnifeLotID
				LEFT JOIN STB_MachineMaster MM WITH(NOLOCK) ON SNIU.MachineCode = MM.MachineCode
				--LEFT JOIN STB_ElectrodeSlittingResult ESR WITH (NOLOCK) ON ESR.ElectrodeLotNumber = SKLI.
			WHERE 1=1
				AND SNIU.SlittingKnifeLotID IN (SELECT Lot2.SlittingKnifeLotID FROM STB_VN_SlittingKnifeLotInfo Lot2 WHERE Lot2.ElectrodeLotNumber = @SlittingKnifeLotID)

			ORDER BY 
				CreateDateTime desc
		END

	


END
