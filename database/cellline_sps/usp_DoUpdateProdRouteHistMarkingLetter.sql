-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2020-02-20
-- Browsable : true
-- Group : 품질관리
-- Description:	마킹문자를 업데이트 합니다.
-- Modified:  
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateProdRouteHistMarkingLetter]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(20),
	@pMarkingLetter NVARCHAR(MAX) = NULL,
	@pVietnamMarking2 VARCHAR(45)=null    --add by Mr.Tung on 2023-Sep-14
AS
BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode
		   ,@MarkingLetter NVARCHAR(MAX) = @pMarkingLetter

	UPDATE STB_SetInfo
	   SET SIExtText07 = isnull(@MarkingLetter,'') 
						+ case when rtrim(ltrim(isnull(@pVietnamMarking2,'')))<>'' then '-' + @pVietnamMarking2 else '' end --add by Mr.Tung on 2023-Sep-14
	 WHERE Barcode = @Barcode
END