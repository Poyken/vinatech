CREATE PROCEDURE [dbo].[usp_Information_NameError](
@pWasteCode nvarchar(50)=NULL,
@pWasteName nvarchar(50)=NULL )
AS
BEGIN
select *  FROM STB_VN_ITEM WITH (NOLOCK)
		WHERE IsUsed=1

END