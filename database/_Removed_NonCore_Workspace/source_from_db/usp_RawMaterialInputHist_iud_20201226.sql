
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr
-- Create date: 2019-10-31
-- Browsable : true
-- Group : 생산관리 > 자주검사/원자재투입 > 원자재투입이력 등록시
-- Description:	
--                 2020.12.26 제품 BOM인지 Check, VET전해액인지 Check (유재민)
-- Modified:
-- =============================================
Create PROCEDURE [dbo].[usp_RawMaterialInputHist_iud_20201226]
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
  DECLARE @OldRawMaterialInputHistNo VARCHAR(20)
  DECLARE @RawMaterialInputHistNo VARCHAR(20)
  DECLARE @Barcode VARCHAR(20)
  DECLARE @ProductGroupCode VARCHAR(20)
  DECLARE @RawMaterialBarcode VARCHAR(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_RawMaterialInputHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_RawMaterialInputHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRawMaterialInputHistNo IS NULL THEN RawMaterialInputHistNo
							    ELSE OldRawMaterialInputHistNo
							END AS OldRawMaterialInputHistNo,
							RawMaterialInputHistNo,
							Barcode,
							ProductGroupCode,
							RawMaterialBarcode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldRawMaterialInputHistNo VARCHAR(20),
										RawMaterialInputHistNo VARCHAR(20),
										Barcode VARCHAR(20),
										ProductGroupCode VARCHAR(20),
										RawMaterialBarcode VARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RawMaterialInputHistNo = SourceTable.RawMaterialInputHistNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					RawMaterialInputHistNo = ISNULL(SourceTable.RawMaterialInputHistNo,TargetTable.RawMaterialInputHistNo),
					Barcode = ISNULL(SourceTable.Barcode,TargetTable.Barcode),
					ProductGroupCode = ISNULL(SourceTable.ProductGroupCode,TargetTable.ProductGroupCode),
					RawMaterialBarcode = ISNULL(SourceTable.RawMaterialBarcode,TargetTable.RawMaterialBarcode),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						RawMaterialInputHistNo,
						Barcode,
						ProductGroupCode,
						RawMaterialBarcode,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.RawMaterialInputHistNo,
							SourceTable.Barcode,
							SourceTable.ProductGroupCode,
							SourceTable.RawMaterialBarcode,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_RawMaterialInputHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRawMaterialInputHistNo IS NULL THEN RawMaterialInputHistNo
							    ELSE OldRawMaterialInputHistNo
							END AS OldRawMaterialInputHistNo,
							RawMaterialInputHistNo,
							Barcode,
							ProductGroupCode,
							RawMaterialBarcode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldRawMaterialInputHistNo VARCHAR(20),
										RawMaterialInputHistNo VARCHAR(20),
										Barcode VARCHAR(20),
										ProductGroupCode VARCHAR(20),
										RawMaterialBarcode VARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RawMaterialInputHistNo = SourceTable.OldRawMaterialInputHistNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					RawMaterialInputHistNo = ISNULL(SourceTable.RawMaterialInputHistNo,TargetTable.RawMaterialInputHistNo),
					Barcode = ISNULL(SourceTable.Barcode,TargetTable.Barcode),
					ProductGroupCode = ISNULL(SourceTable.ProductGroupCode,TargetTable.ProductGroupCode),
					RawMaterialBarcode = ISNULL(SourceTable.RawMaterialBarcode,TargetTable.RawMaterialBarcode),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						RawMaterialInputHistNo,
						Barcode,
						ProductGroupCode,
						RawMaterialBarcode,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.RawMaterialInputHistNo,
							SourceTable.Barcode,
							SourceTable.ProductGroupCode,
							SourceTable.RawMaterialBarcode,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_RawMaterialInputHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRawMaterialInputHistNo IS NULL THEN RawMaterialInputHistNo
							    ELSE OldRawMaterialInputHistNo
							END AS OldRawMaterialInputHistNo,
							RawMaterialInputHistNo,
							Barcode,
							ProductGroupCode,
							RawMaterialBarcode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldRawMaterialInputHistNo VARCHAR(20),
										RawMaterialInputHistNo VARCHAR(20),
										Barcode VARCHAR(20),
										ProductGroupCode VARCHAR(20),
										RawMaterialBarcode VARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RawMaterialInputHistNo = SourceTable.RawMaterialInputHistNo
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
									OldRawMaterialInputHistNo,
									RawMaterialInputHistNo,
									Barcode,
									ProductGroupCode,
									RawMaterialBarcode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldRawMaterialInputHistNo VARCHAR(20),
											 RawMaterialInputHistNo VARCHAR(20),
											 Barcode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 RawMaterialBarcode VARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldRawMaterialInputHistNo IS NULL THEN RawMaterialInputHistNo
										ELSE OldRawMaterialInputHistNo
									END AS OldRawMaterialInputHistNo,
									RawMaterialInputHistNo,
									Barcode,
									ProductGroupCode,
									RawMaterialBarcode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldRawMaterialInputHistNo VARCHAR(20),
											 RawMaterialInputHistNo VARCHAR(20),
											 Barcode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 RawMaterialBarcode VARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldRawMaterialInputHistNo IS NULL THEN RawMaterialInputHistNo
										ELSE OldRawMaterialInputHistNo
									END AS OldRawMaterialInputHistNo,
									RawMaterialInputHistNo,
									Barcode,
									ProductGroupCode,
									RawMaterialBarcode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldRawMaterialInputHistNo VARCHAR(20),
											 RawMaterialInputHistNo VARCHAR(20),
											 Barcode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 RawMaterialBarcode VARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldRawMaterialInputHistNo,
								 @RawMaterialInputHistNo,
								 @Barcode,
								 @ProductGroupCode,
								 @RawMaterialBarcode,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_RawMaterialInputHist WHERE RawMaterialInputHistNo = @RawMaterialInputHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @RawMaterialInputHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_RawMaterialInputHist',@RawMaterialInputHistNo OUTPUT
                    END

                    INSERT INTO STB_RawMaterialInputHist
						(
						    RawMaterialInputHistNo,
						    Barcode,
						    ProductGroupCode,
						    RawMaterialBarcode,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @RawMaterialInputHistNo,
						    @Barcode,
						    @ProductGroupCode,
						    @RawMaterialBarcode,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					IF @CreateUserID IS NULL BEGIN -- 초기생성분이면 Update
						UPDATE STB_RawMaterialInputHist
						SET
						    RawMaterialInputHistNo =   ISNULL(@RawMaterialInputHistNo,RawMaterialInputHistNo),
						    Barcode =   ISNULL(@Barcode,Barcode),
						    ProductGroupCode =   ISNULL(@ProductGroupCode,ProductGroupCode),
						    RawMaterialBarcode =   ISNULL(@RawMaterialBarcode,RawMaterialBarcode),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@pProcessUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    RawMaterialInputHistNo = @OldRawMaterialInputHistNo
					END ELSE BEGIN -- 그렇지 않으면 Insert
						IF @IsAutoKey = 1 BEGIN
							EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_RawMaterialInputHist',@RawMaterialInputHistNo OUTPUT
						END

						INSERT INTO STB_RawMaterialInputHist
							(
								RawMaterialInputHistNo,
								Barcode,
								ProductGroupCode,
								RawMaterialBarcode,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID
							)
							VALUES
							(
								@RawMaterialInputHistNo,
								@Barcode,
								@ProductGroupCode,
								@RawMaterialBarcode,
								GETDATE(),
								@pProcessUserID,
								@ChangeDateTime,
								@ChangeUserID
							)
					END
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_RawMaterialInputHist
						WHERE
						    RawMaterialInputHistNo = @OldRawMaterialInputHistNo
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


/*
 -- VET 전해액 또는 일반 전해액 체크 2020.12.23 , 유재민 요청사항 Start

				   -- 1.  제품종류를 확인해본다 (VET인지)
					SELECT @MaterialCode =  SI.MaterialCode        -- 제품코드
							 , @MaterialType  = VM.MBIExtText03      -- 제품VET여부
					 FROM Stb_SetInfo SI
					          LEFT OUTER JOIN VW_ModelBasicInfo VM On VM.ModelCode = SI.MaterialCode
					WHERE Barcode =  @Barcode


					-- 2. 원자재 전해액 종류를 확인해본다 (원자재품목에 VET가 들어있는지..)
					   SELECT  @Count = Count(*) 
						 FROM STB_BomDetail  SD 
								  LEFT OUTER JOIN STB_MaterialMaster  SM ON SM.MaterialCode = SD.ChildMaterialCode
						WHERE 1=1
						  AND SD.MaterialCode = @MaterialCode
						  AND SM.ProductGroupCode = 'ELECTROLYTE'           -- 전해액만 확인
							AND SM.MaterialName LIKE '%VET%'                    -- VET확인


					 --3. Check사항 
					 IF @MaterialType = 'VET'  AND  @Count = 0

						BEGIN
							RAISERROR('VET 제품인데 전해액은 VET가 아닙니다. 확인 바랍니다.',16,1)
							--RETURN          
						END

					 IF @MaterialType <> 'VET'  AND  @Count = 1 

						BEGIN
							RAISERROR('VET 제품이 아닌데, 원자재는 VET 전해액입니다. 확인 바랍니다.',16,1)
							--RETURN            - 
						END

            --유재민 요청사항  End
*/