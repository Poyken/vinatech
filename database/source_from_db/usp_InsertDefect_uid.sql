-- =============================================
-- Author:		Nguyễn Hải Triêu
-- Create date: 2025-07-09
-- Description:	Thêm lỗi
-- exec usp_InsertDefect_uid 'UserCell2','WINDING-권취_CUỐN','치수불량(권취)Winding_ NG kích thước','test','test','trieu'
-- ============================================
CREATE PROCEDURE [dbo].[usp_InsertDefect_uid] 
	-- Add the parameters for the stored procedure here
	@pUserId varchar(20),
	@pRouterName nvarchar(100),
	@pDefectName nvarchar(100),
	@pDesc NVARCHAR(100),
	@pNguoiPhatHien NVARCHAR(100),
	@pNguoiThaoTax NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
    DECLARE @groupid NVARCHAR(100);
	 

    SELECT @groupid = groupid
    FROM stb_vvt_userwarning
    WHERE username = @pUserId;

	INSERT INTO DefectReportsAnDon(LineCode,RouteName,ErrorName,ErrorDescription ,DetectedBy,Operator,Status)
	VALUES (@groupid,@pRouterName,@pDefectName,@pDesc,@pNguoiPhatHien,@pNguoiThaoTax,0)
	
END
