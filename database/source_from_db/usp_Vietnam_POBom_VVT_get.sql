

CREATE PROCEDURE [dbo].[usp_Vietnam_POBom_VVT_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;


    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@PONo VARCHAR(20) ,
			--@MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END,
			--@IsUseAll BIT = CASE WHEN ISNULL(@pIsUseAll,0) = 1 THEN 0 ELSE 1 END
			@lstPO NVARCHAR(MAX) = '''',		
			@strsql NVARCHAR(MAX) 

	--DECLARE @ProcessViewName VARCHAR(50) = 'ProductionOrderInfo'
	--DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName  

	--ProductionOrderInfo

	DECLARE @ERROR_MSG NVARCHAR(MAX)
		DECLARE @iDoc INT



	if(@pPONo is null or @pPONo = '') begin
			select  
				@strsql = sqlstring
					from STB_Vietnam_POBom_VVT
					where userid=@ProcessUserID


		if(@strsql is not null and @strsql<>'') begin
		  EXEC sp_executesql @strsql;
		  delete STB_Vietnam_POBom_VVT	
		  where  userid=@ProcessUserID
		 end
		else begin
			select '' as Materialcode
		end
								
		  	  

		return;
	end
	
	

END
