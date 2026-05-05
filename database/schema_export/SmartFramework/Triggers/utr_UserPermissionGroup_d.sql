-- Trigger: utr_UserPermissionGroup_d
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER utr_UserPermissionGroup_d
   ON  STB_UserPermissionGroup
   AFTER DELETE
AS 
BEGIN
	INSERT INTO STB_UserPermissionGroupChangeHist (
		UserID
       ,UserType
       ,HasPermission
       ,ActionType
       ,SBCDocumentNo
       ,CreateDateTime
       ,CreateUserID
	)
	SELECT UserID
	      ,UserType
		  ,HasPermission
		  ,'D'
		  ,NULL
		  ,GETDATE()
		  ,CreateUserID
	  FROM inserted
END

GO

