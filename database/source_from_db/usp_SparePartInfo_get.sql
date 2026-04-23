-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-17
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SparePartInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
    @pSparePartCode VARCHAR(20) = NULL,
    @pSparePartName NVARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	  Declare @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	  Declare @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
      DECLARE @SparePartCode VARCHAR(20) = CASE WHEN ISNULL(@pSparePartCode,'') = '' THEN '*' ELSE @pSparePartCode END
      DECLARE @SparePartName NVARCHAR(100) = CASE WHEN ISNULL(@pSparePartName,'') = '' THEN '*' ELSE @pSparePartName END

    
	SELECT
	        SPI.SparePartCode AS OldSparePartCode,
	        SPI.SparePartCode,
	        SPI.SparePartName,
	        SPI.SparePartSpec01,
	        SPI.SparePartSpec02,
	        SPI.SparePartSpec03,
	        SPI.SparePartSpec04,
	        SPI.SparePartSpec05,
	        
	        SPI.SparePartImage,
	        AFM.[FileName],
			AFM.FileSize,
			ISNULL(AFM.FileContents, CONVERT(VARBINARY(MAX),NULL)) AS FileData,
			
	        SPI.BasicUnitPrice,
	        SPI.BasicDeliveryDay,
	        SPI.BasicUnit,
	        SPI.SafeQty,
	        SPI.LastDeliveryVendor,
	        SPI.CompatibilityGroup,
			(
					SELECT
							SUM(ISNULL(SPSI.CurrentStockQty,0)) AS CurrentStockQty
					FROM
							STB_SparePartStockInfo SPSI WITH (NOLOCK)
					WHERE
							SPSI.SparePartCode = SPI.SparePartCode
			) AS CurrentStockQty,
	        SPI.IsUsed,
	        SPI.CreateDateTime,
	        SPI.CreateUserID,
	        SPI.ChangeDateTime,
	        SPI.ChangeUserID
	FROM
	        STB_SparePartInfo SPI WITH(NOLOCK)
	        LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)
				ON AFM.FileID = SPI.SparePartImage
			LEFT OUTER JOIN STB_MachineMaster MM
			  ON MM.MachineCode = SUBSTRING(SPI.SparePartCode, 1, CHARINDEX('-', SPI.SparePartCode, 0) - 1)
	WHERE
	        ((@SparePartCode = '*') OR (SPI.SparePartCode = @SparePartCode))
	  AND   ((@SparePartName = '*') OR (SPI.SparePartName = @SparePartName)) 
	  AND (@CompanyCode = '*' OR SPI.SparePartCode LIKE 'COMM%' OR MM.CompanyCode = @CompanyCode)
	  AND (@WorkCenterCode = '*' OR SPI.SparePartCode LIKE 'COMM%' OR MM.WorkCenterCode = @WorkCenterCode)

END