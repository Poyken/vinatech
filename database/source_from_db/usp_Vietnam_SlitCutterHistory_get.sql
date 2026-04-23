
create PROCEDURE [dbo].[usp_Vietnam_SlitCutterHistory_get]
	@pFrom    datetime =null,	
	@pTo      datetime =null

AS
BEGIN

	SET NOCOUNT ON;

	set @pFrom = isnull(@pFrom,dateadd(day,-10,getdate()))
	set @pTo = isnull(@pTo,getdate())

	select * from STB_Vietnam_SlitCutterHistory
	where createdatetime between @pFrom and @pTo
	
END

