-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-03-27
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCheckInBoxLabelPrintYn]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPackageID VARCHAR(20),
	@pCheckOption INT
AS
BEGIN
	SET NOCOUNT ON;


	Declare @PackageID VARCHAR(20) = REPLACE(@pPackageID, 'S', '2')
	Declare @chkResult INT
	DECLARE @ErrorMessage NVARCHAR(500),@d varchar(1)=@pCheckOption
	Declare @CheckOption INT = @pCheckOption

	IF @CheckOption = 1 BEGIN
		SELECT @chkResult = MAX(CONVERT(VARCHAR(1), PrintYn))
		  FROM STB_HelaBarcode
		 WHERE PackageID = @PackageID	

		 IF @chkResult = 1 BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
												'^이미 출력된 라벨이 포함되어 있습니다.^',
												@ErrorMessage OUTPUT
				SET @ErrorMessage = @ErrorMessage + ' [%s]'
				RAISERROR(@ErrorMessage,16,1,@pPackageID)
				RETURN
		END
	END ELSE BEGIN
		SELECT @chkResult = MIN(CONVERT(VARCHAR(1), PrintYn))
		  FROM STB_HelaBarcode
		 WHERE PackageID = @PackageID	

		 IF @chkResult = 0 BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
												'^출력된 라벨만 리스트에 포함될 수 있습니다.^',
												@ErrorMessage OUTPUT
				SET @ErrorMessage = @ErrorMessage + ' [%s]'
				RAISERROR(@ErrorMessage,16,1,@pPackageID)
				RETURN
		END
	END
	

END