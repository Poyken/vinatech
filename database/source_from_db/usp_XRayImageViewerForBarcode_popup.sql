-- =============================================
-- Author: Jackaroe
-- Create date: 2020.01.08
-- Browsable : true
-- Group : 생산관리
-- Description:	바코드 기준 엑스레이 이미지를 불러옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_XRayImageViewerForBarcode_popup]
	@pProcessUserID [varchar](20),
	@pProcessLanguage [varchar](20),
	@pBarcode [varchar](20) = NULL,
	@pSystemName [Varchar](50) = 'STB_XRayImageUploadHist'
AS
BEGIN
	Declare @Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END
	
	SELECT AFM.FileName
	      ,AFM.FileContents
	  FROM SmartFramework_File.dbo.STB_AttachedFileMaster AFM
	  WHERE (@Barcode = '*' OR (AFM.Barcode LIKE @Barcode + '%' OR AFM.Barcode IN (SELECT NewBarcode 
	                                                                       FROM STB_LotChangeMaterialHistory 
																		  WHERE OldBarcode LIKE @Barcode + '%')))
	   AND AFM.SystemName = @pSystemName																				
	  ORDER BY AFM.Barcode
END