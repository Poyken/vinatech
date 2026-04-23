
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
CREATE PROCEDURE [dbo].[usp_RawMaterialInputHist_iud]
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
   DECLARE @Check INT        -- 2020.02.09
   Declare @CompanyCode VARCHAR(20)
   Declare @BomVersion VARCHAR(10)

   Declare @ExpiredDate VARCHAR(10)
   

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

				Declare @RawMaterialCode VARCHAR(20)

			SELECT @RawMaterialCode = MaterialCode 
				FROM STB_MaterialLotInfo
				WHERE LotID = @RawMaterialBarcode

                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_RawMaterialInputHist WHERE RawMaterialInputHistNo = @RawMaterialInputHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @RawMaterialInputHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_RawMaterialInputHist',@RawMaterialInputHistNo OUTPUT
                    END

					IF EXISTS (SELECT 1 FROM STB_BomDetail_Revision WHERE ChildMaterialCode = @RawMaterialCode AND ValidTo <= GETDATE()) 
					BEGIN
						RAISERROR('투입금지 원자재입니다.', 16, 1)
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

--------------  [Insert 부분 End] 

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

					IF EXISTS (SELECT 1 FROM STB_BomDetail_Revision WHERE ChildMaterialCode = @RawMaterialCode AND ValidTo <= GETDATE()) 
					BEGIN
						RAISERROR('투입금지 원자재입니다.', 16, 1)
					END

					-- 유효기간 체크 
					SELECT @ExpiredDate = ISNULL(CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121), '2050-06-14')
					  FROM STB_MaterialDocLotInfo MDLI
					  LEFT OUTER JOIN STB_MaterialMaster MM
					    ON MDLI.MaterialCode = MM.MaterialCode
					 WHERE MDLI.LotID = @RawMaterialBarcode OR LotNo = @RawMaterialBarcode

					IF @ExpiredDate <= CONVERT(VARCHAR(10), GETDATE(), 121) BEGIN
						EXEC usp_RaiseLocalizedError @pProcessLanguage,'유효기간이 지난 자재입니다.'
						RETURN
					END
					
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


				-- 5. 원자재 투입 자재의 BOM 체크 START

						--제품 바코드로 Company 정보 조회
						SELECT @CompanyCode = DPP.CompanyCode
						FROM STB_SetInfo SI
						LEFT OUTER JOIN STB_DayProdPlan DPP 
							ON SI.DayPlanNo = DPP.DayPlanNo
						WHERE SI.Barcode = @Barcode

						--IF @CompanyCode = 'VNT'
						--BEGIN
						--	SELECT @BomVersion = MAX(BomVersion) 
						--	  FROM STB_BomHeader
						--	 WHERE MaterialCode = @MotherCode
						--	   AND BomVersion = 1000

						--	IF @BomVersion IS NULL
						--		SELECT @BomVersion = MAX(BomVersion) 
						--			FROM STB_BomHeader
						--			WHERE MaterialCode = @MotherCode
						--			AND BomVersion < 51
						--END

						--ELSE IF @CompanyCode = 'VVT'
						--	SELECT @BomVersion = MAX(BomVersion) 
						--		FROM STB_BomHeader
						--		WHERE MaterialCode = @MotherCode
						--		AND BomVersion > 50

						-- 본사/법인 상관없이 Barcode 기준의 PO정보의 BOM을 가져오도록 수정 2025.03-18 by Jackaroe
						SELECT @BomVersion = BomVersion
						  FROM STB_ProductionOrderInfo
						 WHERE PONo = (SELECT PONo FROM STB_SetInfo WHERE Barcode = @Barcode)

						-- Sliiting 양극 체크
						IF @ProductGroupCode = 'ElectrodeP'
							BEGIN
							SELECT TOP 1 @ChildCode = SI.MaterialCode
							FROM STB_ElectrodeSlittingResult ESR
							LEFT OUTER JOIN STB_SetInfo SI
							  ON ESR.ElectrodeLotNumber = SI.Barcode
							LEFT OUTER JOIN STB_MaterialMaster MM
							  ON SI.MaterialCode = MM.MaterialCode
							WHERE MM.MaterialName Like '%(+)%'
							AND ESR.Barcode = @RawMaterialBarcode

								IF @@ROWCOUNT = 0
									BEGIN
									RAISERROR('생산중인 제품의 전극(+)에 적합하지 않습니다. %s 자재 확인바랍니다.',16,1, @ProductGroupCode)
									RETURN
									END

							END

						-- Sliiting 음극 체크
						IF @ProductGroupCode = 'ElectrodeM'
							BEGIN
							SELECT TOP 1 @ChildCode = SI.MaterialCode
							FROM STB_ElectrodeSlittingResult ESR
							LEFT OUTER JOIN STB_SetInfo SI
							  ON ESR.ElectrodeLotNumber = SI.Barcode
							LEFT OUTER JOIN STB_MaterialMaster MM
							  ON SI.MaterialCode = MM.MaterialCode
							WHERE MM.MaterialName Like '%(-)%'
							AND ESR.Barcode = @RawMaterialBarcode

								IF @@ROWCOUNT = 0
									BEGIN
									RAISERROR('생산중인 제품의 전극(-)에 적합하지 않습니다. %s 자재 확인바랍니다.',16,1, @ProductGroupCode)
									RETURN
									END

							END

						-- 전극 자재(Slitting) BOM 체크, 전극측정결과 Slitting 품번 완료되면 적용 예정
						IF SUBSTRING(@ProductGroupCode, 1, 9) = 'Electrode'
							BEGIN
							SELECT BOMCHECK.SlittingMaterialCode
								FROM 
								(
								SELECT ESR.SlittingMaterialCode
									FROM STB_ElectrodeSlittingResult ESR
								LEFT OUTER JOIN 
									(
									SELECT ChildMaterialCode 
										FROM STB_BomDetail
										WHERE MaterialCode = @MotherCode  --'LIVT38-009'
										AND BomVersion = @BomVersion	  --'1'
									UNION ALL 
									SELECT ChildMaterialCode 
										FROM VW_BomDetailWithHeaderBomUnit
										WHERE MaterialCode IN (SELECT ChildMaterialCode 
																FROM STB_BomDetail 
																WHERE MaterialCode = @MotherCode	--'LIVT38-009'
																AND BomVersion = @BomVersion) 
										AND BomVersion = @BomVersion	--'1'
									) BOM
									ON ESR.SlittingMaterialCode = BOM.ChildMaterialCode
									WHERE ESR.Barcode = @RawMaterialBarcode	--'VJLQ1512001E07-001
									AND BOM.ChildMaterialCode Is NOT NULL
								) BOMCHECK

							   --IF @@ROWCOUNT = 0
								 --  BEGIN
									--RAISERROR('생산중인 제품 BOM에 적합하지 않은 전극자재입니다. %s 자재 확인바랍니다.',16,1, @ProductGroupCode)
									--RETURN
								 --  END
								END

						-- 나머지 자재 BOM 체크

						--RAISERROR('%s-%s-%s',16,1, @MotherCode, @BomVersion, @RawMaterialBarcode )

						IF SUBSTRING(@ProductGroupCode, 1, 9) <> 'Electrode' AND (@RawMaterialBarcode <> '' Or @RawMaterialBarcode IS NOT NULL)
							BEGIN
							SELECT TOP 1 @ChildCode = BOMCHECK.MaterialCode
							  FROM 
							   (
								SELECT MLI.MaterialCode
								  FROM STB_MaterialLotInfo MLI
								LEFT OUTER JOIN 
									(
									SELECT ChildMaterialCode 
									  FROM STB_BomDetail
									 WHERE MaterialCode = @MotherCode
									   AND BomVersion = @BomVersion
									UNION ALL 
									SELECT ChildMaterialCode 
									  FROM VW_BomDetailWithHeaderBomUnit
									 WHERE MaterialCode IN (SELECT ChildMaterialCode 
															  FROM STB_BomDetail 
															 WHERE MaterialCode = @MotherCode
															   AND BomVersion = @BomVersion) 
									   AND BomVersion = @BomVersion
									UNION ALL
									SELECT ChildMaterialCode
									  FROM VW_BomDetailWithHeaderBomUnit
									 WHERE MaterialCode IN (SELECT ChildMaterialCode 
															  FROM VW_BomDetailWithHeaderBomUnit
															 WHERE MaterialCode IN (SELECT ChildMaterialCode 
  																					 FROM STB_BomDetail 
																					WHERE MaterialCode = @MotherCode
																					  AND BomVersion = @BomVersion) 
															   AND BomVersion = @BomVersion)
									   AND BomVersion = @BomVersion
									) BOM
									ON MLI.MaterialCode = BOM.ChildMaterialCode
								 WHERE MLI.LotID = @RawMaterialBarcode
								   AND BOM.ChildMaterialCode Is NOT NULL
								   AND MLI.MaterialWarehouseCode IN (SELECT MaterialWarehouseCode FROM STB_MaterialWarehouse WHERE IsRouteWarehouse = CONVERT(BIT, 1))  --공정창고에 존재하는 자재만 투입 가능
								UNION ALL
								SELECT TOP 1 MM.MaterialCode 
								  FROM STB_MaterialMaster MM
								  LEFT OUTER JOIN STB_MaterialLotInfo MLI ON MM.MaterialCode = MLI.MaterialCode
								  LEFT OUTER JOIN (SELECT ChildMaterialCode 
													 FROM STB_BomDetail
													WHERE MaterialCode = @MotherCode
													  AND BomVersion = @BomVersion
													UNION ALL 
												   SELECT ChildMaterialCode 
													 FROM VW_BomDetailWithHeaderBomUnit
													WHERE MaterialCode IN (SELECT ChildMaterialCode 
																			 FROM STB_BomDetail 
																			WHERE MaterialCode = @MotherCode
																			  AND BomVersion = @BomVersion) 
													  AND BomVersion = @BomVersion) BD ON MM.DelegateMaterialCode = BD.ChildMaterialCode
								 WHERE MM.DelegateMaterialCode IS NOT NULL
								   --AND BD.BomVersion = @BomVersion
								   --AND BD.MaterialCode = @MotherCode
								   AND MLI.LotID = @RawMaterialBarcode
								   --AND MLI.MaterialWarehouseCode = 'ROUTE_WH' --공정창고에 존재하는 자재만 투입 가능
								   AND MLI.MaterialWarehouseCode IN (SELECT MaterialWarehouseCode FROM STB_MaterialWarehouse WHERE IsRouteWarehouse = CONVERT(BIT, 1))
								) BOMCHECK

							-- Nordex Audit 때문에 임시 블럭 조치 2026.02.05
							  -- IF @@ROWCOUNT = 0
								 --  BEGIN
									--RAISERROR('생산중인 제품 BOM에 적합하지 않은 자재입니다. %s 자재 확인바랍니다.',16,1, @ProductGroupCode)
									--RETURN
								 --  END
							END

					-- 5. 원자재 투입 자재의 BOM 체크 END

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
