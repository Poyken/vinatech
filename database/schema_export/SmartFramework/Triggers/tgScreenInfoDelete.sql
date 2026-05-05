-- Trigger: tgScreenInfoDelete

-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-12-13
-- Description:	STB_ScreenInfo Delete 트리거
-- =============================================
CREATE TRIGGER [dbo].[tgScreenInfoDelete]
   ON  [dbo].[STB_ScreenInfo]
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;

    DELETE FROM STB_ScreenLayoutInfo
	WHERE Name IN (SELECT Name FROM deleted)

	DELETE FROM STB_ScreenObjects
	WHERE ScreenName IN (SELECT Name FROM deleted)

	DELETE FROM STB_ScreenLayoutInfo
	WHERE Name IN (SELECT Name FROM deleted)

	DELETE FROM STB_ScreenDiagrams
	WHERE Name IN (SELECT Name FROM deleted)

	DELETE FROM STB_ScreenHelp
	WHERE Name IN (SELECT Name FROM deleted)

	DELETE FROM STB_UserTypeBasicPermission
	WHERE Name IN (SELECT Name FROM deleted)

	DELETE FROM STB_UserTypeViewPermission
	WHERE Name IN (SELECT Name FROM deleted)

	DELETE FROM STB_UserTypeFunctionPermission
	WHERE Name IN (SELECT Name FROM deleted)

	DELETE FROM STB_VendorScreenInfo
	WHERE Name IN (SELECT Name FROM deleted)
END

GO

