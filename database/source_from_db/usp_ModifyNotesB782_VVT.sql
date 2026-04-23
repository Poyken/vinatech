-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_ModifyNotesB782_VVT
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pProcessViewName VARCHAR(50),
		@pXml NVARCHAR(MAX) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    --DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    --DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)
	
	
	
	    -- Declare Columns Variable
	declare @ControlNo	VARCHAR(50)
	declare @RouteCode	varchar(50)  
	declare @Notes NVARCHAR(MAX)




	DECLARE @iDoc INT

 
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
	    DECLARE SourceData CURSOR FOR
            SELECT
      --              'INSERT' AS IUD_FLAG,
						--		OldMaterialDocDetailNo
						--FROM
						--		OPENXML(@idoc , @InsertTableName , 2)
						--        WITH  (
						--				 OldMaterialDocDetailNo VARCHAR(20),
						--				 MaterialDocDetailNo VARCHAR(20)										
						--				)
						--UNION ALL
						--SELECT
								'UPDATE' AS IUD_FLAG,
								ControlNo,
								RouteCode,
								Notes						
																				
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
						        WITH  (
										ControlNo	VARCHAR(50) ,
										RouteCode	varchar(50) ,
										Notes NVARCHAR(MAX)

										)
						--UNION ALL
						--SELECT
						--		'DELETE' AS IUD_FLAG,
						--		CASE 
						--			WHEN OldMaterialDocDetailNo IS NULL THEN MaterialDocDetailNo
						--			ELSE OldMaterialDocDetailNo
						--		END AS OldMaterialDocDetailNo
								
						--FROM
						--		OPENXML(@idoc , @DeleteTableName , 2)
						--        WITH  (
						--				 OldMaterialDocDetailNo VARCHAR(20),
						--				 MaterialDocDetailNo VARCHAR(20)
										 
						--				) 


        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
							 @IUD_FLAG,
							 @ControlNo,
							 @RouteCode,
							 @Notes
		 

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END
	

            IF @IUD_FLAG = 'INSERT' BEGIN

				--IF EXISTS (SELECT 1 FROM STB_ProdRouteHistNotes WHERE id = @id) BEGIN
					RAISERROR('INSERT ERROR hihi', 16, 1)
					RETURN
				--END



			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN			



				--DECLARE @SumClass NUMERIC(15, 0) = 0
				--DECLARE @MaterialCode VARCHAR(30),
				--		@MaterialName NVARCHAR(200),
				--		@BoxQty NUMERIC(15, 0)

				--SET @SumClass = ISNULL(@SClass, 0) + ISNULL(@AClass, 0) + ISNULL(@BClass, 0) + ISNULL(@CClass, 0) + ISNULL(@DClass, 0)

				-- Kiểm tra xem có phải là hàng 35105 hay không, nếu không phải thì sẽ trả về lỗi
				--SELECT @MaterialCode = MaterialCode,
				--		@MaterialName = MaterialName,
				--		@BoxQty = PackQty
				--FROM STB_SavePackingTime_VVT WHERE ID = @id AND LotNo = @LotNo


				--IF @MaterialCode NOT IN ('ECVT30-357', 'ECVT30-076', 'ECVT30-117') 
				--	BEGIN

				--		RAISERROR(N'Không phải là hàng "ECVT30-076 / ECVT30-117 (3582) / ECVT30-357 (35105)" .!. Lot no "%s : %s - %s"', 16, 1, @LotNo, @MaterialCode, @MaterialName)
				--		RETURN
				--	END
	
				--ELSE IF @SumClass <> @BoxQty
				--	BEGIN
				--		DECLARE @SumClassString VARCHAR(50),
				--				@BoxQtyString VARCHAR(50)

				--		SET @SumClassString = CAST(@SumClass AS VARCHAR(50));
				--		SET @BoxQtyString = CAST(@BoxQty AS VARCHAR(50));
						

				--		RAISERROR(N'LotNo: %s Tổng số lượng đã nhập %s <> số lượng đóng gói %s. Vui lòng kiểm tra lại ..!', 16, 1, @LotNo, @SumClassString, @BoxQtyString)
				--		RETURN
				--	END

				--ELSE 
				--	BEGIN
						IF EXISTS (SELECT 1 FROM STB_ProdRouteHistNotes where ControlNo = @ControlNo AND RouteCode = @RouteCode)
							BEGIN
								UPDATE STB_ProdRouteHistNotes
								SET Notes = ISNULL(@Notes, 0),
									ChangeDateTime = GETDATE(),
									ChangeUserID = @pProcessUserID
								WHERE ControlNo = @ControlNo
									AND RouteCode = @RouteCode

							END

						ELSE
							BEGIN
								INSERT INTO STB_ProdRouteHistNotes (ControlNo, RouteCode, Notes, CreateDateTime, CreateUserID) 
								values		(@ControlNo, @RouteCode, @Notes , GETDATE(), @pProcessUserID)

							END
					--END



            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN								


					RAISERROR('DELETE ERROR hjhj', 16, 1)
					RETURN


            END



        END
    END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
		
	CLOSE SourceData;
	DEALLOCATE SourceData;
		
	EXEC sp_xml_removedocument @idoc	

END

