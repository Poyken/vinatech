-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-12
-- Description:	Get Special Spare Part LotID 
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_SpecialSparePartLotID_get]
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pCompanyCode VARCHAR(10) = NULL,
			@pWorkCenterCode VARCHAR(10) = NULL,
			@pSparePartLotID VARCHAR(30) = NULL
			--@pLotID VARCHAR(30) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @SparePartLotID VARCHAR(20) = CASE WHEN ISNULL(@pSparePartLotID,'') = '' THEN '%' ELSE @pSparePartLotID END
	--DECLARE @pLotID VARCHAR(20) = CASE WHEN ISNULL(@pLotID,'') = '' THEN '%' ELSE @pLotID END

	DECLARE @UsedLotQty INT



	IF (@SparePartLotID = '%' OR SUBSTRING(@SparePartLotID, 1, 3) = 'SSP')          -- Nếu tìm kiếm theo SparePartLotID
		BEGIN

			SELECT 
					SSPIO.ID,
					SSPIO.SparePartLotID,
					SSPIO.SparePartCode,
					SSPI.SparePartName,
					(SELECT COUNT(LotID) FROM STB_VN_SpecialSparePartLotInfo SSPLI WHERE SSPLI.SparePartLotID = SSPIO.SparePartLotID) AS UsedLotQty,
					FLOOR(SSPI.CycleReplace / SSPI.LotQty)  AS StandardLotQty,
					SSPI.Model,
					SSPI.LotQty,
					SSPIO.IOType,
					SSPIO.IOQty,
					SSPIO.LineCode,
					SSPIO.WorkCenterCode,
					SSPIO.MachineCode,
					SSPIO.CreateDateTime,
					SSPIO.CreateUserID

			FROM 
				STB_VN_SpecialSparePartIOHist SSPIO WITH(NOLOCK)
				LEFT OUTER JOIN STB_VN_SpecialSparePartInfo SSPI WITH(NOLOCK) ON SSPI.SparePartCode = SSPIO.SparePartCode
				--LEFT OUTER JOIN STB_VN_SpecialSparePartIOHist SSPIO WITH(NOLOCK) ON SSPIO.SparePartLotID = SSPLI.SparePartLotID
				--LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK) ON SI.Barcode = SSPLI.LotID

			WHERE 1=1 
				AND SSPI.CompanyCode LIKE @CompanyCode
				AND SSPI.WorkCenterCode LIKE @WorkCenterCode
				AND SSPIO.SparePartLotID LIKE @SparePartLotID

			ORDER BY SSPIO.CreateDateTime desc
		END


	ELSE							--  Nếu tìm kiếm theo Barcode thì hiện ra các SparePart đã dùng 
		BEGIN
			SELECT 
					SSPIO.ID,
					SSPIO.SparePartLotID,
					SSPIO.SparePartCode,
					SSPI.SparePartName,
					(SELECT COUNT(LotID) FROM STB_VN_SpecialSparePartLotInfo SSPLI WHERE SSPLI.SparePartLotID = SSPIO.SparePartLotID) AS UsedLotQty,
					FLOOR(SSPI.CycleReplace / SSPI.LotQty)  AS StandardLotQty,
					SSPI.Model,
					SSPI.LotQty,
					SSPIO.IOType,
					SSPIO.IOQty,
					SSPIO.LineCode,
					SSPIO.WorkCenterCode,
					SSPIO.MachineCode,
					SSPIO.CreateDateTime,
					SSPIO.CreateUserID

			FROM 
				STB_VN_SpecialSparePartIOHist SSPIO WITH(NOLOCK)
				LEFT OUTER JOIN STB_VN_SpecialSparePartInfo SSPI WITH(NOLOCK) ON SSPI.SparePartCode = SSPIO.SparePartCode
				--LEFT OUTER JOIN STB_VN_SpecialSparePartIOHist SSPIO WITH(NOLOCK) ON SSPIO.SparePartLotID = SSPLI.SparePartLotID
				--LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK) ON SI.Barcode = SSPLI.LotID

			WHERE 1=1 
				AND SSPI.CompanyCode LIKE @CompanyCode
				AND SSPI.WorkCenterCode LIKE @WorkCenterCode
				AND SSPIO.SparePartLotID IN (
					SELECT SSPLI2.SparePartLotID FROM STB_VN_SpecialSparePartLotInfo SSPLI2 WHERE SSPLI2.LotID = @SparePartLotID
				)

			ORDER BY SSPIO.CreateDateTime desc
		END
-- select * from STB_VN_SpecialSparePartIOHist

END
