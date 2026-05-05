-- Procedure: usp_CheckSheetDailyDetail_get
CREATE PROCEDURE [dbo].[usp_CheckSheetDailyDetail_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCheckSheetDaily nvarchar(50)=null
AS
BEGIN

	DECLARE @id int
	Declare @cnt int
	
	Declare c Cursor For Select id from Stb_CategogyCheckList where TypeCheck = (select TypeCheck from stb_CheckSheetDaily where no=@pCheckSheetDaily) and IsUsed=1 order by id asc
	Open c
	Fetch next From c into @ID
	While @@Fetch_Status=0 Begin

		--raiserror (@pCheckSheetDaily, 16,1)
		select @cnt=count(*) from Stb_CheckSheetDailyDetail where CategoryCheckListNo=@id and checksheetdaily=@pCheckSheetDaily
		if @cnt = 0
		begin
			insert into Stb_CheckSheetDailyDetail
				 (checksheetdaily,
				 categoryCheckListNo,
				 CreateDatetime,
				 CreateUserID)
				 values
				 (@pCheckSheetDaily,
				 @id,
				 GETDATE(),
				 @pProcessUserID)
		end
    Fetch next From c into @ID
	End
	Close c
	DEALLOCATE  c
	

	select
		   a.ID,
		   c.no,
		   b.Stage,
		   b.TypeTest,
		   b.ItemCheck,
		   b.TestMethod,
		   b.NoChecks,
		   a.Result1,
		   a.ChangeTimeResult1,
		   a.Result2,
		   a.ChangeTimeResult2,
		   a.Result3,
		   a.ChangeTimeResult3,
		   a.Result4,
		   a.ChangeTimeResult4
	from Stb_CheckSheetDailyDetail a left join Stb_CategogyCheckList b ON a.CategoryCheckListNo = b.ID
	left join stb_CheckSheetDaily c on a.CheckSheetDaily = c.No
	where a.CheckSheetDaily = @pCheckSheetDaily
	order by a.id
END


GO

