CREATE  PROCEDURE [dbo].[usp_ToDate_get]
	@pToDate date=NULL

AS
BEGIN
	select @pToDate as ToDate,@pToDate as ToDate1, @pToDate as ToDate2
	


END


--exec usp_ToDate_get '2021-05-01'