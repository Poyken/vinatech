-- =============================================
-- Author:	Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-17
-- Browsable : true
-- Group : 공통
-- Description: 이미지관리	
-- =============================================
CREATE PROCEDURE [dbo].[usp_StatusImageInfo_get]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT
			SII.ImageType AS OldImageType,
			SII.ImageType,
			SII.ImageValue AS OldImageValue,
			SII.ImageValue,
			SII.ImageData,
			SII.CreateDateTime,
			SII.CreateUserID,
			SII.ChangeDateTime,
			SII.ChangeUserID
	FROM
			STB_StatusImageInfo SII WITH(NOLOCK)
			
END


