-- Procedure: usp_CategoryCheckList_get
CREATE PROCEDURE [dbo].[usp_CategoryCheckList_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pTypeCheck nvarchar(100) = NULL,
	@pStage nvarchar(50) = NULL,
	@pTypeTest nvarchar(100) = NULL, 
	@pItemCheck nvarchar(500) =NULL,
	@pTestMethod nvarchar(100)=NULL,
	@pNoChecks nvarchar(100)=NULL
AS
BEGIN
	SET NOCOUNT ON;

    SELECT  ID,
			TypeCheck,
			Stage,
			TypeTest,
			ItemCheck,
			TestMethod,
			NoChecks,
			IsUsed,
			CreateDateTime,
			CreateUserID,
			ChangeDateTime,
			ChangeUserID
	FROM  Stb_CategogyCheckList 
	WHERE (@pTypeCheck is null or TypeCheck='' or TypeCheck like  N'%'+@pTypeCheck+'%' )
	and (@pStage is null or Stage='' or Stage like N'%'+@pStage+'%')
	and (@pTypeTest is null or TypeTest='' or TypeTest like N'%'+@pTypeTest+'%')
	and (@pItemCheck is null or ItemCheck='' or ItemCheck like N'%'+@pItemCheck+'%')
	and (@pTestMethod is null or TestMethod='' or TestMethod like N'%'+@pTestMethod+'%')
	and (@pNoChecks is null or NoChecks='' or NoChecks like N'%'+@pNoChecks+'%')
	
	order by id
END
GO

