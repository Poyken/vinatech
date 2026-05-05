-- Procedure: usp_add_iud
CREATE PROC usp_add_iud
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE  @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE  @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE  @ProcessViewName VARCHAR(50) = @pProcessViewName
	DECLARE  @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
	DECLARE  @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
	DECLARE  @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE  @ERROR_MSG NVARCHAR(MAX)
	DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

	-- Declare columns variable
	DECLARE @Code VARCHAR(20)
	DECLARE @Names VARCHAR(20)
	DECLARE @Decs VARCHAR(20)
	DECLARE @IsUsed BIT
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)
	DECLARE @iDoc INT

	 EXEC SmartFramework.dbo.usp_GetSerialRule 
		    @pTableName = 'STB_VN_TEST',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

END	
GO

