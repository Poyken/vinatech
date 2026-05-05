-- View: VW_CodeGroup





CREATE VIEW [dbo].[VW_CodeGroup]
AS
SELECT	BC.ItemCode AS CodeGroup,
			BC.Description AS CodeGroupName
   FROM		STB_BaseCode BC
   WHERE	BC.CodeGroup='Group'







GO

