-- Trigger: utr_UserFlagUpdate
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022.04.25
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER utr_UserFlagUpdate
   ON  STB_UserInfo
   AFTER UPDATE
AS 
BEGIN
	Declare @UserID VARCHAR(20)
	       ,@BefAllowFlag VARCHAR(20)
		   ,@AftAllowFlag VARCHAR(20)

	SELECT @AftAllowFlag = AllowFlag
	      ,@UserID = UserID
	  FROM inserted

	SELECT @BefAllowFlag = AllowFlag
	  FROM deleted

	IF @BefAllowFlag <> @AftAllowFlag BEGIN
		INSERT INTO STB_UserFlagUpdateHist (UserID, BefAllowFlag, AftAllowFlag) VALUES (@UserID, @BefAllowFlag, @AftAllowFlag)
	END
END

GO

