CREATE procedure [dbo].[usp_Strategy_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCheckSheetDaily nvarchar(50)=null
AS
BEGIN
	select ID,
	       CheckSheetDaily,
		   Stage,
		   Issue,
		   Reason,
		   Strategy,
		   PersonCharge
	from Stb_Strategy
	where CheckSheetDaily=@pCheckSheetDaily
END