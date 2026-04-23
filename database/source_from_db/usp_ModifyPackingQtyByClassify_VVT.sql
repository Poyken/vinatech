-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-12-22
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModifyPackingQtyByClassify_VVT]
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
	declare @id			VARCHAR(10)
	declare @LotNo		varchar(50)  
	declare @SClass numeric(15, 0)
	declare @AClass numeric(15, 0)
	declare @BClass numeric(15, 0)
	declare @CClass numeric(15, 0)
	declare @DClass numeric(15, 0)



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
								id,
								LotNo,
								SClass,
								AClass,
								BClass,
								CClass,
								DClass							
																				
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
						        WITH  (
										id			VARCHAR(10) ,
										LotNo		varchar(50) ,
										SClass numeric(15, 0),
										AClass numeric(15, 0),
										BClass numeric(15, 0),
										CClass numeric(15, 0),
										DClass numeric(15, 0)

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
							 @id,
							 @LotNo	,
							 @SClass,
							 @AClass,
							 @BClass,
							 @CClass,
							 @DClass
		 

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END
	

            IF @IUD_FLAG = 'INSERT' BEGIN

				IF EXISTS (SELECT 1 FROM STB_SavePackingQtyByLevel_VVT WHERE id = @id) BEGIN
					RAISERROR('INSERT ERROR id = %s', 16, 1, @id)
					RETURN
				END



			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN			



				DECLARE @SumClass NUMERIC(15, 0) = 0
				DECLARE @MaterialCode VARCHAR(30),
						@MaterialName NVARCHAR(200),
						@BoxQty NUMERIC(15, 0)

				SET @SumClass = ISNULL(@SClass, 0) + ISNULL(@AClass, 0) + ISNULL(@BClass, 0) + ISNULL(@CClass, 0) + ISNULL(@DClass, 0)

				-- Kiểm tra xem có phải là hàng 35105 hay không, nếu không phải thì sẽ trả về lỗi
				SELECT @MaterialCode = MaterialCode,
						@MaterialName = MaterialName,
						@BoxQty = PackQty
				FROM STB_SavePackingTime_VVT WHERE ID = @id AND LotNo = @LotNo


				IF @MaterialCode NOT IN ('ECVT30-357', 'ECVT30-076', 'ECVT30-117') 
					BEGIN

						RAISERROR(N'Không phải là hàng "ECVT30-076 / ECVT30-117 (3582) / ECVT30-357 (35105)" .!. Lot no "%s : %s - %s"', 16, 1, @LotNo, @MaterialCode, @MaterialName)
						RETURN
					END
	
				ELSE IF @SumClass <> @BoxQty
					BEGIN
						DECLARE @SumClassString VARCHAR(50),
								@BoxQtyString VARCHAR(50)

						SET @SumClassString = CAST(@SumClass AS VARCHAR(50));
						SET @BoxQtyString = CAST(@BoxQty AS VARCHAR(50));
						

						RAISERROR(N'LotNo: %s Tổng số lượng đã nhập %s <> số lượng đóng gói %s. Vui lòng kiểm tra lại ..!', 16, 1, @LotNo, @SumClassString, @BoxQtyString)
						RETURN
					END

				ELSE 
					BEGIN
						IF EXISTS (SELECT 1 FROM STB_SavePackingQtyByLevel_VVT where IDSPT = @id AND LotNo = @LotNo)
							BEGIN
								UPDATE STB_SavePackingQtyByLevel_VVT
								SET SClass = ISNULL(@SClass, 0),
									AClass = ISNULL(@AClass, 0),
									BClass = ISNULL(@BClass, 0),
									CClass = ISNULL(@CClass, 0),
									DClass = ISNULL(@DClass, 0),
									ChangeDateTime = GETDATE(),
									ChangeUserID = @pProcessUserID
								WHERE IDSPT = @id
									AND LotNo = @LotNo

							END

						ELSE
							BEGIN
								INSERT INTO STB_SavePackingQtyByLevel_VVT (IDSPT, LotNo, SClass, AClass, BClass, CClass, DClass, CreateDateTime, CreateUserID) 
								values		(@id, @LotNo, ISNULL(@SClass, 0), ISNULL(@AClass, 0), ISNULL(@BClass, 0), ISNULL(@CClass, 0), ISNULL(@DClass, 0), GETDATE(), @pProcessUserID)

							END
					END



            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN								


					RAISERROR('DELETE ERROR id = %s', 16, 1, @id)
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
