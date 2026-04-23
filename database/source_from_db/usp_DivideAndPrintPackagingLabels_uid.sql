-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-04-02
-- Description:	Chia tem cho hà nam
-- Ghi chú TypeBox = 1 ,2 ,3
/*
	1 : Chia tem thùng
	2 : Chia tem túi bóng
	3 : Chia box để xuất kho
*/
-- =============================================
CREATE PROCEDURE [dbo].[usp_DivideAndPrintPackagingLabels_uid]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pTypeAction VARCHAR(50) = null,
	@pQtySliptBox int =null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	-- 

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
	DECLARE @TypeAction VARCHAR(50) =@pTypeAction



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
			if(@TypeAction ='DELETE')
				begin
						Delete from STB_DividePackaging where  ParentPackingID = @DividePackagingID
						return
				end

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
			DECLARE @Err NVARCHAR(500)	
			  -- Tạo thùng con 
			 if(@TypeAction ='SliptBoxSmall')			         
				BEGIN
				
				/*
				
						 -- Kiểm tra xem mã đó đã được nhập kho hay chưa nếu mã nhập rồi thì không cho tách số lương
				    IF EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_HN_New WHERE PackingID = @PackingID)
                    BEGIN
                            SET @Err = N'Packing này đã được nhập kho không thể tách số lương ' + @PackingID;
                            RAISERROR(@Err, 16, 1);
                    END
					*/
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
						
				END
			 -- túi bóng
			IF(@TypeAction ='SliptNilon')
			     /*
				 
				 IF EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_HN_New WHERE PackingID = @PackingID)
                    BEGIN
                            SET @Err = N'Packing này đã được nhập kho không thể tách số lương ' + @PackingID;
                            RAISERROR(@Err, 16, 1);
                    END
                 */
				
				BEGIN
						if(@Qty % @pQtySliptBox =0)
						begin
						
								set @QtyPerChild = @Qty / (@pQtySliptBox) --chỉ tính 12 cái tem có số lượng hàng lớn

								WHILE @i <= @QtyPerChild
								BEGIN
											EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DividePackaging',@DividePackagingIDNew OUTPUT
									
													 SET @SmallPackingID = @PackingID + '_' + RIGHT('00' + CAST(@i AS VARCHAR(10)), 2)
													 -- Cập nhật 2 thùng con
													INSERT INTO STB_DividePackaging
														(DividePackagingID,Qty, MaterialCode, GRDate, LotNo, PackingID, CreateDateTime, CreateUserID, ParentPackingID,TypeBox,PackingParentID)
													VALUES
														(@DividePackagingIDNew,@pQtySliptBox, @MaterialCode, @GRDate, @LotNo, @SmallPackingID,GETDATE(), @ProcessUserID,@DividePackagingID, 2,@PackingID) 
										
						
									
											SET @i = @i + 1
								END
						end
						else
						begin
					             set @QtyPerChild = @Qty / @pQtySliptBox --chỉ tính 12 cái tem có số lượng hàng lớn
								 set @Remainder   = @Qty - (@QtyPerChild * @pQtySliptBox); 
								--set @QtyPerChild = @Qty / (@pQtySliptBox-1) --chỉ tính 12 cái tem có số lượng hàng lớn
								--set @Remainder   = @Qty - (@QtyPerChild * (@pQtySliptBox-1)); 
							  /*
								WHILE @i <= @QtyPerChild
								BEGIN
											EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DividePackaging',@DividePackagingIDNew OUTPUT
											if(@i <> @pQtySliptBox)
											begin
													 SET @SmallPackingID = @PackingID + '_' + RIGHT('00' + CAST(@i AS VARCHAR(10)), 2)
													 -- Cập nhật 2 thùng con
													INSERT INTO STB_DividePackaging
														(DividePackagingID,Qty, MaterialCode, GRDate, LotNo, PackingID, CreateDateTime, CreateUserID, ParentPackingID,TypeBox,PackingParentID)
													VALUES
														(@DividePackagingIDNew,@pQtySliptBox, @MaterialCode, @GRDate, @LotNo, @SmallPackingID,GETDATE(), @ProcessUserID,@DividePackagingID, 2,@PackingID) 
											end
											else
											begin
												if(@Remainder>=1)
												begin
												 SET @SmallPackingID = @PackingID + '_' + RIGHT('00' + CAST(@i AS VARCHAR(10)), 2)
													 -- Cập nhật 2 thùng con
													INSERT INTO STB_DividePackaging
														(DividePackagingID,Qty, MaterialCode, GRDate, LotNo, PackingID, CreateDateTime, CreateUserID, ParentPackingID,TypeBox,PackingParentID)
													VALUES
														(@DividePackagingIDNew,@Remainder, @MaterialCode, @GRDate, @LotNo, @SmallPackingID,GETDATE(), @ProcessUserID,@DividePackagingID, 2,@PackingID) 
											end
											end
									
												SET @i = @i + 1
									END
									*/
								WHILE @i <= @QtyPerChild
								BEGIN
											EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DividePackaging',@DividePackagingIDNew OUTPUT
										
													 SET @SmallPackingID = @PackingID + '_' + RIGHT('00' + CAST(@i AS VARCHAR(10)), 2)
													 -- Cập nhật 2 thùng con
													INSERT INTO STB_DividePackaging
														(DividePackagingID,Qty, MaterialCode, GRDate, LotNo, PackingID, CreateDateTime, CreateUserID, ParentPackingID,TypeBox,PackingParentID)
													VALUES
														(@DividePackagingIDNew,@pQtySliptBox, @MaterialCode, @GRDate, @LotNo, @SmallPackingID,GETDATE(), @ProcessUserID,@DividePackagingID, 2,@PackingID) 
										
												
											
									
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
														(@DividePackagingIDNew,@Remainder, @MaterialCode, @GRDate, @LotNo, @SmallPackingID,GETDATE(), @ProcessUserID,@DividePackagingID, 2,@PackingID) 
											 end
							end
			
					update STB_DividePackaging 
					set IsNilonlBox='1'
					where DividePackagingID = @DividePackagingID 
						
				END



				-- Thùng con cần chia nhỏ tiếp để xuất số bé
			 if(@TypeAction ='SlpitBoxSmall_Chi')			         
				BEGIN
				/*
					 IF EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_HN_New WHERE PackingID = @PackingID)
                    BEGIN
                            SET @Err = N'Packing này đã được nhập kho không thể tách số lương ' + @PackingID;
                            RAISERROR(@Err, 16, 1);
                    END
					*/
						 
						if(@Qty % @pQtySliptBox =0)
						begin
						
								set @QtyPerChild = @Qty / @pQtySliptBox 

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
						
				END

					-- Chia lot ra để xuất
			 if(@TypeAction ='SplitOddLotsForExport')	
			 /*
			  IF EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_HN_New WHERE PackingID = @PackingID)
                    BEGIN
                            SET @Err = N'Packing này đã được nhập kho không thể tách số lương ' + @PackingID;
                            RAISERROR(@Err, 16, 1);
                    END

					*/
				BEGIN
				
										
						DECLARE @Prefix VARCHAR(50) = @PackingID;  -- phần đầu
						DECLARE @MaxSuffix INT;

						SELECT @MaxSuffix = MAX(CAST(RIGHT(PackingID, 2) AS INT))
						FROM STB_DividePackaging
						WHERE PackingID LIKE @Prefix + '_%';

						SET @MaxSuffix = ISNULL(@MaxSuffix, 0) + 1; -- nếu không có bản khi xét bằng 1
						

										EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DividePackaging',@DividePackagingIDNew OUTPUT
										
													 SET @SmallPackingID = @Prefix + '_' + RIGHT('00' + CAST(@MaxSuffix AS VARCHAR), 2); -- @PackingID + '_' + RIGHT('00' + CAST(@i AS VARCHAR(10)), 2)
													 -- Cập nhật 2 thùng con
													INSERT INTO STB_DividePackaging
														(DividePackagingID,Qty, MaterialCode, GRDate, LotNo, PackingID, CreateDateTime, CreateUserID, ParentPackingID,TypeBox,PackingParentID)
													VALUES
														(@DividePackagingIDNew,@pQtySliptBox, @MaterialCode, @GRDate, @LotNo, @SmallPackingID,GETDATE(), @ProcessUserID,@DividePackagingID, 3,@PackingID) 
										
												
									
							
				
						
					
					update STB_DividePackaging 
					set isSliptPacking=1
					where DividePackagingID = @DividePackagingID 
						
				END
EXEC sp_xml_removedocument @idoc	

END


--select * from STB_DividePackaging