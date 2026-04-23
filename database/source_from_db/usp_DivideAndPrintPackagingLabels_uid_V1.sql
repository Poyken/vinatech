-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
  
-- =============================================
CREATE PROCEDURE [dbo].[usp_DivideAndPrintPackagingLabels_uid_V1] 
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pQtySliptBox int =null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
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

	DECLARE @DividePackagingID VARCHAR(50)
	DECLARE @DividePackagingIDNew VARCHAR(50)
	DECLARE @Qty NUMERIC(20, 5)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @GRDate VARCHAR(20)
	DECLARE @LotNo VARCHAR(50)
	DECLARE @PackingID VARCHAR(50)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)
	DECLARE @ParentPackingID VARCHAR(50)



	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_DividePackaging',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
			
			    SELECT  @DividePackagingID  =DividePackagingID
								 
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  ( 	DividePackagingID VARCHAR(50) )
				    SELECT  @DividePackagingID  =DividePackagingID
								 
							FROM
									OPENXML(@idoc , @TableName , 2)
							        WITH  ( 	DividePackagingID VARCHAR(50) )
			--raiserror(@DividePackagingID,16,1)
		--return

			   SELECT
									@Qty = Qty,
									@MaterialCode  =MaterialCode ,
									@GRDate =GRDate ,
									@LotNo =LotNo ,
									@PackingID =PackingID,
									@ParentPackingID=ParentPackingID
								FROM  STB_DividePackaging		where DividePackagingID = @DividePackagingID
						
			DECLARE @i INT=1
			DECLARE @SmallPackingID VARCHAR(50)		
			DECLARE @QtyPerChild INT =0
			DECLARE @Remainder	 INT =0
				

				
						 
						if(@Qty % @pQtySliptBox =0)
						begin
						
								set @QtyPerChild = @Qty / @pQtySliptBox --chỉ tính 12 cái tem có số lượng hàng lớn

								WHILE @i <= @QtyPerChild
								BEGIN
										EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DividePackaging',@DividePackagingIDNew OUTPUT
										
													 SET @SmallPackingID = @PackingID + '_' + RIGHT('00' + CAST(@i AS VARCHAR(10)), 2)
													 -- Cập nhật 2 thùng con
													INSERT INTO STB_DividePackaging
														(DividePackagingID,Qty, MaterialCode, GRDate, LotNo, PackingID, CreateDateTime, CreateUserID, ParentPackingID,TypeBox,PackingParentID)
													VALUES
														(@DividePackagingIDNew,@pQtySliptBox, @MaterialCode, @GRDate, @LotNo, @SmallPackingID,GETDATE(), @ProcessUserID,@DividePackagingID, 1,@PackingID) 
										
												
									
											SET @i = @i + 1
								END
						end
						else
						begin
					
								set @QtyPerChild = @Qty / @pQtySliptBox --chỉ tính 12 cái tem có số lượng hàng lớn
								set @Remainder   = @Qty - (@QtyPerChild * @pQtySliptBox); 
					
							
								WHILE @i <= @QtyPerChild
								BEGIN
											EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DividePackaging',@DividePackagingIDNew OUTPUT
										
													 SET @SmallPackingID = @PackingID + '_' + RIGHT('00' + CAST(@i AS VARCHAR(10)), 2)
													 -- Cập nhật 2 thùng con
													INSERT INTO STB_DividePackaging
														(DividePackagingID,Qty, MaterialCode, GRDate, LotNo, PackingID, CreateDateTime, CreateUserID, ParentPackingID,TypeBox,PackingParentID)
													VALUES
														(@DividePackagingIDNew,@pQtySliptBox, @MaterialCode, @GRDate, @LotNo, @SmallPackingID,GETDATE(), @ProcessUserID,@DividePackagingID, 1,@PackingID) 
										
												
											
									
												SET @i = @i + 1
									END

									if(@Remainder>=1)
												begin
												EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DividePackaging',@DividePackagingIDNew OUTPUT
												 SET @SmallPackingID = @PackingID + '_' + RIGHT('00' + CAST(@i AS VARCHAR(10)), 2)
													 -- Cập nhật 2 thùng con
													INSERT INTO STB_DividePackaging
														(DividePackagingID,Qty, MaterialCode, GRDate, LotNo, PackingID, CreateDateTime, CreateUserID, ParentPackingID,TypeBox,PackingParentID)
													VALUES
														(@DividePackagingIDNew,@Remainder, @MaterialCode, @GRDate, @LotNo, @SmallPackingID,GETDATE(), @ProcessUserID,@DividePackagingID, 1,@PackingID) 
											 end
							end
					
					update STB_DividePackaging 
					set IsSmailBox='1'
					where DividePackagingID = @DividePackagingID 
						
				
			
EXEC sp_xml_removedocument @idoc	



		
			
    
END


