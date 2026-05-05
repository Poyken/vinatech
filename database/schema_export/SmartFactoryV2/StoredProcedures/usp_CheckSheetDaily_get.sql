-- Procedure: usp_CheckSheetDaily_get
CREATE procedure [dbo].[usp_CheckSheetDaily_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPeopleTest nvarchar(100) = NULL,
	@pShifts nvarchar(50) = NULL,
	@pDateTest date = NULL, 
	@pModel nvarchar(100) =NULL,
	@pPart nvarchar(100) = NULL,
	@pCellLine nvarchar(100) = NULL,
	@pTypeCheck nvarchar(50) = NULL,
	@pUtcOffset INT
AS
BEGIN
	SET NOCOUNT ON;

		    select
				No,
				TypeCheck,
				PeopleTest,
				Shifts,
				--convert(varchar, DateTest, 111) as DateTest, 
				dbo.fnGetLocalTime(DateTest, @pUtcOffset) AS DateTest ,
				Model,
				Part,
				Cellline,
				CreateDateTime,
				CreateUserID,
				ChangeDateTime,
				ChangeUserID
			from stb_CheckSheetDaily a
			where  
			(@pPeopleTest is null or @pPeopleTest ='' or PeopleTest =@pPeopleTest )
			and (@pShifts is null or @pShifts='' or Shifts=@pShifts) 
			and (@pDateTest is null or @pDateTest='' or DateTest = @pDateTest) 
			and (@pModel is null or @pModel='' or model = @pModel )
			and (@pPart is null or @pPart='' or Part = @pPart )
			and (@pCellLine is null or @pCellLine='' or Cellline = @pCellLine )
			and (@pTypeCheck is null or @pTypeCheck='' or TypeCheck =@pTypeCheck	)	

END


GO

