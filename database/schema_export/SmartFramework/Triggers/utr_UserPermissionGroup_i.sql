-- Trigger: utr_UserPermissionGroup_i
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[utr_UserPermissionGroup_i]
   ON  [dbo].[STB_UserPermissionGroup]
   AFTER INSERT
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
		  ,'I'
		  ,NULL
		  ,GETDATE()
		  ,CreateUserID
	  FROM inserted
END

GO

