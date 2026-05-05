-- Procedure: usp_DoSavePopup






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-18
-- Browsable : false
-- Description:	Save Popup Grid
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSavePopup]
	@pName NVARCHAR(50),
	@pDescription NVARCHAR(MAX),
	@pLayout VARBINARY(MAX),
	@pXmlLayout NVARCHAR(MAX),
	@pProcessUserID VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
	
    MERGE INTO STB_PopupGrid AS T
    USING (SELECT @pName, @pDescription, @pLayout, @pXmlLayout, @pProcessUserID) AS S  (
																			Name,
																			Description,
																			Layout,
																			XmlLayout,
																			ProcessUserID
																		)
	ON (T.Name = S.Name)
	WHEN MATCHED THEN
		UPDATE SET Description = S.Description,
				   Layout = S.Layout,
				   XmlLayout = S.XmlLayout,
				   ChangeUserID = S.ProcessUserID,
				   ChangeDateTime = GETDATE()
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (Name,Description, Layout, XmlLayout, CreateUserID, CreateDateTime)
		VALUES (@pName, @pDescription, @pLayout, @pXmlLayout, @pProcessUserID, GETDATE());
		
END







GO

