-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-08
-- Description:	Thực hiện việc đăng nhập
-- =============================================
CREATE PROCEDURE usp_VN_LoginFinishGood_Andon
	-- Add the parameters for the stored procedure here
	@pUSERID NVARCHAR(50),
    @pASSWORDS NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select
          vuw.id,vuw.username,vuw.password,vuw.groupid,li.LineName as typeid,vuw.typeid as listfunction,vuw.password2,
          vuw.createdatetime,vuw.createuserid,vuw.changedatetime,vuw.changeuserid
      from stb_vvt_userwarning vuw
      join STB_LineInfo li on vuw.groupid=li.LineCode
      where lower(vuw.username)=@pUSERID and  lower(vuw.password)=@pASSWORDS
 
     
END
