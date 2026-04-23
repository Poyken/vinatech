
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-25
-- Browsable : true
-- Group : 생산관리
-- Description:	전극슬리팅결과
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeSlittingResult_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @IsAutoKey BIT
    DECLARE @IsLoopIUD BIT
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT

    -- Declare Columns Variable
  DECLARE @OldElectrodeLotNumber VARCHAR(20)
  DECLARE @OldSeq INT
  DECLARE @ElectrodeLotNumber VARCHAR(20)
  DECLARE @Seq INT
  DECLARE @ElectrodeThick NUMERIC(20,5)
  DECLARE @SlittingWidth NUMERIC(20,5)
  DECLARE @ProductionQty NUMERIC(20,5)
  DECLARE @GoodQtyLength NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  DECLARE @SlittingBarcodeSeq INT


  declare @companycode varchar(10)=''
  select @companycode=companycode from STB_UserInfo
  where UserID=@pProcessUserID


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeSlittingResult',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeSlittingResult AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							Seq,
							ElectrodeThick,
							SlittingWidth,
							ProductionQty,
							GoodQtyLength,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										Seq INT,
										ElectrodeThick NUMERIC(20,5),
										SlittingWidth NUMERIC(20,5),
										ProductionQty NUMERIC(20,5),
										GoodQtyLength NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.Seq = SourceTable.Seq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					ElectrodeThick = ISNULL(SourceTable.ElectrodeThick,TargetTable.ElectrodeThick),
					SlittingWidth = ISNULL(SourceTable.SlittingWidth,TargetTable.SlittingWidth),
					ProductionQty = ISNULL(SourceTable.ProductionQty,TargetTable.ProductionQty),
					GoodQtyLength = ISNULL(SourceTable.GoodQtyLength,TargetTable.GoodQtyLength),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						Seq,
						ElectrodeThick,
						SlittingWidth,
						ProductionQty,
						GoodQtyLength,
						CreateDateTime,
						CreateUserID,
						CompanyCode,
						WorkCenterCode
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.Seq,
							SourceTable.ElectrodeThick,
							SourceTable.SlittingWidth,
							SourceTable.ProductionQty,
							SourceTable.GoodQtyLength,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							'VVT',
							'VVT_F1'
					);


			-- Process Update Table
            MERGE STB_ElectrodeSlittingResult AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							Seq,
							ElectrodeThick,
							SlittingWidth,
							ProductionQty,
							GoodQtyLength,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										Seq INT,
										ElectrodeThick NUMERIC(20,5),
										SlittingWidth NUMERIC(20,5),
										ProductionQty NUMERIC(20,5),
										GoodQtyLength NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.OldElectrodeLotNumber AND
					TargetTable.Seq = SourceTable.OldSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					ElectrodeThick = ISNULL(SourceTable.ElectrodeThick,TargetTable.ElectrodeThick),
					SlittingWidth = ISNULL(SourceTable.SlittingWidth,TargetTable.SlittingWidth),
					ProductionQty = ISNULL(SourceTable.ProductionQty,TargetTable.ProductionQty),
					GoodQtyLength = ISNULL(SourceTable.GoodQtyLength,TargetTable.GoodQtyLength),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						Seq,
						ElectrodeThick,
						SlittingWidth,
						ProductionQty,
						GoodQtyLength,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.Seq,
							SourceTable.ElectrodeThick,
							SourceTable.SlittingWidth,
							SourceTable.ProductionQty,
							SourceTable.GoodQtyLength,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ElectrodeSlittingResult AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							Seq,
							ElectrodeThick,
							SlittingWidth,
							ProductionQty,
							GoodQtyLength,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										Seq INT,
										ElectrodeThick NUMERIC(20,5),
										SlittingWidth NUMERIC(20,5),
										ProductionQty NUMERIC(20,5),
										GoodQtyLength NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.Seq = SourceTable.Seq
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldElectrodeLotNumber,
									OldSeq,
									ElectrodeLotNumber,
									Seq,
									ElectrodeThick,
									SlittingWidth,
									ProductionQty,
									GoodQtyLength,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 Seq INT,
											 ElectrodeThick NUMERIC(20,5),
											 SlittingWidth NUMERIC(20,5),
											 ProductionQty NUMERIC(20,5),
											 GoodQtyLength NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
										ELSE OldElectrodeLotNumber
									END AS OldElectrodeLotNumber,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ElectrodeLotNumber,
									Seq,
									ElectrodeThick,
									SlittingWidth,
									ProductionQty,
									GoodQtyLength,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 Seq INT,
											 ElectrodeThick NUMERIC(20,5),
											 SlittingWidth NUMERIC(20,5),
											 ProductionQty NUMERIC(20,5),
											 GoodQtyLength NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
							
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
										ELSE OldElectrodeLotNumber
									END AS OldElectrodeLotNumber,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ElectrodeLotNumber,
									Seq,
									ElectrodeThick,
									SlittingWidth,
									ProductionQty,
									GoodQtyLength,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 Seq INT,
											 ElectrodeThick NUMERIC(20,5),
											 SlittingWidth NUMERIC(20,5),
											 ProductionQty NUMERIC(20,5),
											 GoodQtyLength NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldElectrodeLotNumber,
								 @OldSeq,
								 @ElectrodeLotNumber,
								 @Seq,
								 @ElectrodeThick,
								 @SlittingWidth,
								 @ProductionQty,
								 @GoodQtyLength,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeSlittingResult WHERE ElectrodeLotNumber = @ElectrodeLotNumber AND Seq = @Seq) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeLotNumber)
					END

                    IF @IsAutoKey = 1 BEGIN
                        --EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeSlittingResult',@ElectrodeLotNumber OUTPUT

						EXEC usp_GetNewSerialNoForBarcode @pProcessUserID, '', @ElectrodeLotNumber, @SlittingBarcodeSeq OUTPUT
                    END

                    INSERT INTO STB_ElectrodeSlittingResult
						(
						    ElectrodeLotNumber,
						    Seq,
						    ElectrodeThick,
						    SlittingWidth,
						    ProductionQty,
						    GoodQtyLength,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
									CompanyCode,
									WorkCenterCode
						)
						VALUES
						(
						    @ElectrodeLotNumber,
						    @SlittingBarcodeSeq,
						    @ElectrodeThick,
						    @SlittingWidth,
						    @GoodQtyLength, -- ProductionQty는 화면에서 삭제(의미없음.)
						    @GoodQtyLength,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							'VVT',
							'VVT_F1'
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					
						  -- Mr.Triều Block user delete lotnumber for Electrode
  						IF (@pProcessUserID NOT IN ('HaiTrieu','DinhManh') )
						BEGIN
							RAISERROR(N'Bạn không có quyền vui lòng liên hệ EA !',16,1);
						END    

					--Mr.Manh update 2026-03-20 Lưu lịch sử chỉnh sửa
					INSERT INTO STB_ElectrodeSlittingResultHist (ElectrodeLotNumber, Seq, Flag, CreateDateTime, CreateUserID) values
						(@ElectrodeLotNumber, @Seq, @IUD_FLAG, GETDATE(), @pProcessUserID)
					--

                    UPDATE STB_ElectrodeSlittingResult
						SET
						    SlittingWidth =   ISNULL(@SlittingWidth,SlittingWidth),
						    ProductionQty =   case when @companycode='VVT' then ISNULL(@ProductionQty,ProductionQty) else ProductionQty end, --updated for Vietnam Factory, remain for Korean
						    GoodQtyLength =   ISNULL(@GoodQtyLength,GoodQtyLength),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber AND
						    Seq = @OldSeq

					
							
					
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					
						  -- Mr.Triều Block user delete lotnumber for Electrode
  							IF (@pProcessUserID NOT IN ('HaiTrieu','DinhManh') )
							BEGIN
								RAISERROR(N'Bạn không có quyền vui lòng liên hệ EA !',16,1);
							END    

					--Mr.Manh update 2026-03-20 Lưu lịch sử Xóa
					INSERT INTO STB_ElectrodeSlittingResultHist (ElectrodeLotNumber, Seq, Flag, CreateDateTime, CreateUserID) values
						(@ElectrodeLotNumber, @Seq, @IUD_FLAG, GETDATE(), @pProcessUserID)
					--

                    DELETE FROM STB_ElectrodeSlittingResult
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber AND
						    Seq = @OldSeq
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
END