
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DivideStampsFoxconn_update]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName  
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @IsAutoKey BIT
    DECLARE @IsLoopIUD BIT
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT

	DECLARE @CPN VARCHAR(50)
	DECLARE @Qty NUMERIC(20, 5)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @GRDate VARCHAR(20)
	DECLARE @LotNo VARCHAR(50)
	DECLARE @PackingID VARCHAR(50)
	DECLARE @COO VARCHAR(20)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)
	DECLARE @id VARCHAR(20)
	DECLARE @ParentPackingID VARCHAR(50)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ProdWorkerInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    

	--raiserror(@id,16,1)	
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
			declare @QtyTemp varchar (50)
			    SELECT  @id =id,
							 @QtyTemp =Qty
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  ( 	id VARCHAR(30),  Qty VARCHAR(30) )

		
		 
	     set @Qty = CAST(SUBSTRING(@QtyTemp, PATINDEX('%[0-9.]%', @QtyTemp), LEN(@QtyTemp)) AS NUMERIC(20,5))
									 
		If(@Qty) <= 0 
			begin
					 raiserror(N'Số lượng phải lớn hơn 0',16,1)	
					 return;
			end

			select * from STB_VN_STAMP_FOXCONN
			update STB_VN_STAMP_FOXCONN set Qty = @Qty,
																	ChangeUserID=@pProcessUserID,
																	ChangeDateTime = GETDATE()
																	 where id = @id
 
 
 EXEC sp_xml_removedocument @idoc	

   
END
