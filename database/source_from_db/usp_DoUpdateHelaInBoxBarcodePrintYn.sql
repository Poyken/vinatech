-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-03-26
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateHelaInBoxBarcodePrintYn]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPackageID VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @PackageID VARCHAR(20) = '2' + RIGHT(@pPackageID, 12) -- 업체요청으로 S로 변환했던 키를 원복한다. 2020.03.11 By Jackaroe
	
	UPDATE STB_HelaBarcode
	   SET PrintYn = 1
	 WHERE PackageID = @PackageID
END
