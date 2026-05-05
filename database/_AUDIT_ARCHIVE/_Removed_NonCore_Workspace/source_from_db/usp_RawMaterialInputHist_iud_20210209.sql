
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr
-- Create date: 2019-10-31
-- Browsable : true
-- Group : 생산관리 > 자주검사/원자재투입 > 원자재투입이력 등록시
-- Description:	
--                 2020.12.26 제품 BOM인지 Check, VET전해액인지 Check (유재민)
--                 2021.02.08 오투입방지 - 모자제품 전압체크 (이미정)
-- Modified:
-- =============================================
Create PROCEDURE [dbo].[usp_RawMaterialInputHist_iud_20210209]
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


   DECLARE @MotherCode VARCHAR(50)
   DECLARE @MaterialType VARCHAR(20)
   DECLARE @ChildCode     VARCHAR(50)
   DECLARE @ChildName      VARCHAR(50)
   DECLARE @MotherVolt     VARCHAR(20)        -- 2020.02.09
   DECLARE @ChildVolt        VARCHAR(20)        -- 2020.02.09
   DECLARE @ChildProductGroupCode  VARCHAR(50)        -- 2020.02.09
   

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

----------------[ Insert부분 Check사항]  ------------------------------------------------------------------ 첫번째
                     
			-- 1.  Barcode를 이용하여 제품의 품목이 VET제품인지 Check
					Select  @MotherCode =  SI.MaterialCode 
							, @MaterialType = VM.MBIExtText03        -- 제품 VET 여부
							, @MotherVolt   = VM.MBIExtText04        -- 제품의 전압 (2020.02.09 추가 - 이미정님 요청)
					From STB_SetInfo SI
							LEFT OUTER JOIN VW_ModelBasicInfo VM On VM.ModelCode = SI.MaterialCode 
					Where 1=1
						And SI.Barcode = @Barcode

              -- 2. 업체바코드를 이용하여 원자재품목이 VET인지 체크
						Select @ChildCode = MaterialCode
						       , @ChildName = (Select MaterialName From STB_MaterialMaster SM Where  SM.MaterialCode = SML.MaterialCode) 
						 From STB_MaterialDocLotInfo  SML 
						Where (LotID = @RawMaterialBarcode) Or (LotNo = @RawMaterialBarcode)                                                                            -- 원자재바코드가 비나텍바코드일지 업체바코드일지 모름
						Group by SML.MaterialCode

               --  3. 원자재품목의 전압품목인지 체크  (2020.02.09 추가 - 이미정님 요청)
						 Select @ChildVolt = MM.MMExtText01                          -- 전압(V) [A230 자재정보] 제품명 : 2.7 Or 3.0
						        , @ChildProductGroupCode = MM.ProductGroupCode
						  From STB_MaterialMaster  MM 
						 Where  MM.MaterialCode = @ChildCode 

			   -- 4. Check사항 
			           -- 4.1 VET확인 (유재민요청)
						IF  (@ChildProductGroupCode = 'ELECTROLYTE'  AND @MaterialType = 'VET'  AND  @Childcode <> 'GBEC00-009' )

						BEGIN
							RAISERROR('VET 제품인데 전해액은 VET가 아닙니다. 확인 바랍니다.',16,1)
							--RETURN          
						END

						-- 4.2 VET확인 (유재민요청)
						IF ( @ChildProductGroupCode = 'ELECTROLYTE' AND @MaterialType <> 'VET'  AND  @ChildName Like '%VET%' )

						BEGIN
							RAISERROR('VET 제품이 아닌데, 원자재는 VET 전해액입니다. 확인 바랍니다.',16,1)
							--RETURN            - 
						END

						 -- 4.3  (2020.02.09 추가 - 이미정님 요청)
					 --      IF (@ChildProductGroupCode = 'ELECTROLYTE'  AND @MotherVolt = '2.7'  AND @ChildVolt <> '2.7')

						--	BEGIN
						--		RAISERROR('제품과 원자재 전해액의 전압이 서로 맞지 않습니다. 확인 바랍니다.',16,1)
						--		--RETURN            - 
						--	END

						---- 4.4  (2020.02.09 추가 - 이미정님 요청)
					 --      IF  (@ChildProductGroupCode = 'ELECTROLYTE'  AND @MotherVolt = '3.0'  AND @ChildVolt <> '3.0')

						--	BEGIN
						--		RAISERROR('제품과 원자재 전해액의 전압이 서로 맞지 않습니다. 확인 바랍니다.',16,1)
						--		--RETURN            - 
						--	END

--------------  [Insert 부분 End] 

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					
					IF @CreateUserID IS NULL 
					
					BEGIN -- 초기생성분이면 Update

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
					END ELSE 

					    BEGIN -- 그렇지 않으면 Insert

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

--------------  [Update부분 Start]  ------------------------------------------------            22222
                
			-- 1.  Barcode를 이용하여 제품의 품목이 VET제품인지 Check
					Select  @MotherCode =  SI.MaterialCode 
							, @MaterialType = VM.MBIExtText03        -- 제품 VET 여부
							, @MotherVolt   = VM.MBIExtText04        -- 제품의 전압 (2020.02.09 추가 - 이미정님 요청)
					From STB_SetInfo SI
							LEFT OUTER JOIN VW_ModelBasicInfo VM On VM.ModelCode = SI.MaterialCode 
					Where 1=1
						And SI.Barcode = @Barcode

              -- 2. 업체바코드를 이용하여 원자재품목이 VET인지 체크
						Select @ChildCode = MaterialCode
						       , @ChildName = (Select MaterialName From STB_MaterialMaster SM Where  SM.MaterialCode = SML.MaterialCode) 
						 From STB_MaterialDocLotInfo  SML 
						Where (LotID = @RawMaterialBarcode) Or (LotNo = @RawMaterialBarcode)                                                                            -- 원자재바코드가 비나텍바코드일지 업체바코드일지 모름
						Group by SML.MaterialCode

               --  3. 원자재품목의 전압품목인지 체크  (2020.02.09 추가 - 이미정님 요청)
						 Select @ChildVolt = MM.MMExtText01                          -- 전압(V) [A230 자재정보] 제품명 : 2.7 Or 3.0
						        , @ChildProductGroupCode = MM.ProductGroupCode
						  From STB_MaterialMaster  MM 
						 Where  MM.MaterialCode = @ChildCode 

			   -- 4. Check사항 
			           -- 4.1 VET확인 (유재민요청)
						IF  (@ChildProductGroupCode = 'ELECTROLYTE'  AND @MaterialType = 'VET'  AND  @Childcode <> 'GBEC00-009' )

						BEGIN
							RAISERROR('VET 제품인데 전해액은 VET가 아닙니다. 확인 바랍니다.',16,1)
							--RETURN          
						END

						-- 4.2 VET확인 (유재민요청)
						IF ( @ChildProductGroupCode = 'ELECTROLYTE' AND @MaterialType <> 'VET'  AND  @ChildName Like '%VET%' )

						BEGIN
							RAISERROR('VET 제품이 아닌데, 원자재는 VET 전해액입니다. 확인 바랍니다.',16,1)
							--RETURN            - 
						END

						 -- 4.3  (2020.02.09 추가 - 이미정님 요청)
					 --      IF (@ChildProductGroupCode = 'ELECTROLYTE'  AND @MotherVolt = '2.7'  AND @ChildVolt <> '2.7')

						--	BEGIN
						--		RAISERROR('제품과 원자재 전해액의 전압이 서로 맞지 않습니다. 확인 바랍니다.',16,1)
						--		--RETURN            - 
						--	END

						---- 4.4  (2020.02.09 추가 - 이미정님 요청)
					 --      IF  (@ChildProductGroupCode = 'ELECTROLYTE'  AND @MotherVolt = '3.0'  AND @ChildVolt <> '3.0')

						--	BEGIN
						--		RAISERROR('제품과 원자재 전해액의 전압이 서로 맞지 않습니다. 확인 바랍니다.',16,1)
						--		--RETURN            - 
						--	END

--------------  [Update부분 End] 

                END ELSE IF @IUD_FLAG = 'DELETE' 
				
				BEGIN

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
