-- Trigger: utr_UserPermissionGroup_u
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[utr_UserPermissionGroup_u]
   ON  [dbo].[STB_UserPermissionGroup]
   AFTER UPDATE
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
		  ,'UB'
		  ,NULL
		  ,GETDATE()
		  ,CreateUserID
	  FROM deleted

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
		  ,'UA'
		  ,NULL
		  ,GETDATE()
		  ,ChangeUserID
	  FROM inserted
END

GO

