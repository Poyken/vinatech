

CREATE PROCEDURE [dbo].[usp_ModifyPack_VVT_iud]
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
	declare	@PackingID  varchar(30)  
	declare @LotNo		varchar(30)  
	declare @PackQty	numeric(18, 0) 
	declare @PrintTime	datetime 
	declare @isPrinted	varchar(30) 
	declare @id			int 

	declare @MaterialCode varchar(30) 
	declare @MaterialName varchar(30) 
	declare @Route_22 varchar(30) 
	declare @Route_23 varchar(30) 
	declare @Route_24 varchar(30) 
	declare @Route_25 varchar(30) 
	declare @Route_26 varchar(30) 
	declare @Route_27 varchar(30) 
	declare @Route_28 varchar(30) 
	declare @Route_99 varchar(30) 

 -- DECLARE @DocStatus VARCHAR(20)
 -- DECLARE @IsCancel BIT

	--DECLARE @UID_KEY VARCHAR(50)
	--DECLARE @MaterialDocTypeCode VARCHAR(20)
	--DECLARE @MaterialDocType VARCHAR(10)
	--DECLARE @IsRequireQC BIT
	--DECLARE @CustomerCode VARCHAR(20)
	--DECLARE @BefRequestQty NUMERIC(20,5)
	--DECLARE @BefAllowQty NUMERIC(20,5)
	--DECLARE @BefPickingAssignQty NUMERIC(20,5)

	--DECLARE @FPMainPlanNo VARCHAR(20)

	--DECLARE @AUTOFIXQTY_GI VARCHAR(1)
	--DECLARE @AUTOFIXQTY_GR VARCHAR(1)

	--DECLARE @AUTOARRIVALQTY_GR VARCHAR(1)

	DECLARE @iDoc INT

 --   EXEC SmartFramework.dbo.usp_GetSerialRule 
	--		@pTableName = 'STB_SavePackingTime_VVT',
	--		@pIsAutoKey = @IsAutoKey OUTPUT,
	--		@pIsLoopIUD = @IsLoopIUD OUTPUT,
	--		@pPrefixData = @PrefixString OUTPUT,
	--		@pSerialLen = @SerialLen OUTPUT
    

	--SET @IsAutoKey = 1
	--SET @IsLoopIUD = 1

	--SET @AUTOFIXQTY_GI = dbo.fnGetProcessRule('SALES_GI_ITEM_FIXQTY', 'Y')
	--SET @AUTOFIXQTY_GR = dbo.fnGetProcessRule('SALES_GR_ITEM_FIXQTY', 'Y')	
	--SET @AUTOARRIVALQTY_GR = dbo.fnGetProcessRule('SALES_GR_ITEM_ARRIVALQTY', 'Y')
	
 
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
								PackingID   ,
								LotNo		,
								PackQty		,
								PrintTime	,
								isPrinted	,
								id					,

								MaterialCode,
								MaterialName,
								Route_22	,
								Route_23,
								Route_24,
								Route_25,
								Route_26,
								Route_27,
								Route_28,
								Route_99								
																				
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
						        WITH  (
										PackingID   varchar(30)  ,
										LotNo		varchar(30)  ,
										PackQty		numeric(18, 0) ,
										PrintTime	datetime ,
										isPrinted	varchar(30)  ,
										id			int ,

										MaterialCode varchar(30),
										MaterialName varchar(30),
										Route_22 varchar(30) ,
										Route_23 varchar(30) ,
										Route_24 varchar(30) ,
										Route_25 varchar(30) ,
										Route_26 varchar(30) ,
										Route_27 varchar(30) ,
										Route_28 varchar(30) ,
										Route_99 varchar(30) 
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
							 @PackingID,
							 @LotNo		,
							 @PackQty	,
							 @PrintTime	,
							 @isPrinted	,
							 @id							,

							 @MaterialCode,
							 @MaterialName,
							 @Route_22,
							 @Route_23,
							 @Route_24,
							 @Route_25,
							 @Route_26,
							 @Route_27,
							 @Route_28,
							 @Route_99			 

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			--IF ISNULL(@MaterialCode,'') <> ''
			--BEGIN
			--	IF (
			--			SELECT
			--					COUNT(*)
			--			FROM
			--					STB_MaterialMaster MM WITH (NOLOCK)
			--			WHERE
			--					MM.MaterialCode = @MaterialCode
			--		) < 1
			--	BEGIN
			--			RAISERROR('존재하지 않는 자재코드 입니다. %s', 16, 1, @MaterialCode)
			--			RETURN
			--	END
			--END

			--IF @IUD_FLAG = 'INSERT' BEGIN
			--	SELECT
			--			@MaterialDocNo = KeyValue
			--	FROM
			--			#SEQUENCE_TABLE
			--	WHERE
			--			UID_KEY = @MaterialDocNo
			--END

			--IF ISNULL(@MaterialDocNo,'')  <> ''
			--BEGIN
			--		IF  (LEN(@MaterialDocNo) = 36) OR (LEN(@MaterialDocNo) = 20)  --NEWID()로 따진 데이터로 생각함
			--		BEGIN
			--				SET @UID_KEY = @MaterialDocNo

			--				SET @MaterialDocNo = NULL
				
			--				IF OBJECT_ID(N'tempdb..#SEQUENCE_TABLE', N'U') IS NOT NULL BEGIN
			--					SELECT 
			--							@MaterialDocNo = KeyValue
			--					FROM 
			--							#SEQUENCE_TABLE
			--					WHERE
			--							UID_KEY = @UID_KEY
				
			--					IF @MaterialDocNo IS NULL
			--					BEGIN
			--						SET @MaterialDocNo = @UID_KEY
			--					END
			--				END
			--		END
			--END

			--SELECT
			--		@MaterialDocTypeCode = MDI.MaterialDocTypeCode,
			--		@CustomerCode = MDI.SourceCustomerCode,
			--		@MaterialDocType = MDI.MaterialDocType,
			--		@DocStatus = MDI.DocStatus,			
			--		@FPMainPlanNo = MDI.FPItemWorkNo,
			--		@IsCancel = MDI.IsCancel	
			--FROM
			--		STB_MaterialDocInfo MDI
			--WHERE
			--		MDI.MaterialDocNo = @MaterialDocNo
					

			--IF @IsCancel = 1 BEGIN
			--	RAISERROR('이미 취소된 문서입니다.',16,1)
			--	RETURN
			--END

			--IF @DocStatus IN ('FIX')
			--BEGIN
			--		RAISERROR('확정 처리된 문서는 수정할 수 없습니다.: %s',16,1,@MaterialDocNo)
			--		RETURN
			--END
			
		


			--IF (@AUTOFIXQTY_GI = 'Y') AND (@MaterialDocType IN ('GI', 'MOVE' ) AND (@IUD_FLAG = 'INSERT'))
			--BEGIN
			--	SET @AllowQty = @RequestQty
			--END

			--IF @MaterialDocType = 'GR'
			--BEGIN				
			----IF (@AUTOFIXQTY_GR = 'Y') AND (@MaterialDocType = 'GR' AND (@IUD_FLAG = 'INSERT'))
			----BEGIN
			--	SET @AllowQty = @RequestQty
			----END
			--END




			

            IF @IUD_FLAG = 'INSERT' BEGIN

                IF EXISTS (SELECT 1 FROM STB_SavePackingTime_VVT WHERE id = @id) BEGIN
					RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @id)
					RETURN
				END


				--IF (@AUTOARRIVALQTY_GR = 'Y') AND (@MaterialDocType = 'GR')
				--BEGIN
				--	SET @PickingAssignQty = @RequestQty
				--END

				--IF ISNULL(@MaterialDocDetailNo,'') = ''
				--BEGIN
				--		IF @IsAutoKey = 1 BEGIN
				--			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_SavePackingTime_VVT', @MaterialDocDetailNo OUTPUT
					
				--			IF OBJECT_ID(N'tempdb..#SEQUENCE_TABLE', N'U') IS NOT NULL BEGIN
				--				INSERT INTO #SEQUENCE_TABLE
				--					(KeyValue, UID_KEY)
				--				VALUES
				--					(@MaterialDocDetailNo, @OldMaterialDocDetailNo)
				--			END
				--		END
				--END
                


				--IF ISNULL(@MaterialDocNo,'')  <> ''
				--BEGIN
				--		IF  (LEN(@MaterialDocNo) = 36) OR (LEN(@MaterialDocNo) = 20)  --NEWID()로 따진 데이터로 생각함
				--		BEGIN
				--				SET @UID_KEY = @MaterialDocNo

				--				SET @MaterialDocNo = NULL
				
				--				SELECT 
				--						@MaterialDocNo = KeyValue
				--				FROM 
				--						#SEQUENCE_TABLE
				--				WHERE
				--						UID_KEY = @UID_KEY
				
				--				IF @MaterialDocNo IS NULL
				--				BEGIN
				--					SET @MaterialDocNo = @UID_KEY
				--				END
				--		END
				--END

				--SELECT
				--		@MaterialDocTypeCode = MDI.MaterialDocTypeCode,
				--		@CustomerCode = MDI.SourceCustomerCode
				--FROM
				--		STB_MaterialDocInfo MDI
				--WHERE
				--		MDI.MaterialDocNo = @MaterialDocNo
						
				--SELECT
				--		--@MaterialDocType = MDT.MaterialDocType,
				--		@IsRequireQC = MDT.IsRequireQC
				--FROM
				--		STB_MaterialDocType MDT
				--WHERE
				--		MDT.MaterialDocTypeCode = @MaterialDocTypeCode
						
				
				--IF @IsRequireQC IS NULL
				--BEGIN
				--	SET @IsRequireQC = 0
				--END
				
				--SET @InspectionType = 'NONE'
				
				--IF @IsRequireQC = 1
				--BEGIN
				--		SELECT
				--				TOP 1
				--				@InspectionType = MVM.InspectionType
				--		FROM
				--				STB_MaterialVendorMapping MVM
				--		WHERE
				--				MVM.MaterialCode = @MaterialCode AND
				--				( (ISNULL(MVM.CustomerCode,'') = '') OR (ISNULL(MVM.CustomerCode,'') = @CustomerCode))
				--		ORDER BY 
				--				MVM.CustomerCode DESC
								
				--		IF @InspectionType IS NULL
				--		BEGIN
				--				SET @InspectionType = 'NONE'
				--		END
				--END


				--IF ISNULL(@OrderDetailNo,'') <> '' BEGIN
				--	IF @MaterialDocType = 'GR' BEGIN
					
				--		UPDATE
				--				STB_MaterialOrderItem
				--		SET
				--				MaterialOrderRemainQty = ISNULL(MaterialOrderRemainQty,0) - @AllowQty,
				--				ChangeDateTime =  GETDATE(),
				--				ChangeUserID = @ProcessUserID
				--		WHERE
				--				MaterialOrderItemNo = @OrderDetailNo
				--	END
				
				--	IF @MaterialDocType = 'GI' BEGIN
				--		IF ISNULL(@OrderDetailNo,'') <> '' BEGIN
				--			UPDATE
				--					STB_SalesOrderItem
				--			SET
				--					GIPlanQty = GIPlanQty + @RequestQty,
				--					ChangeDateTime =  GETDATE(),
				--					ChangeUserID = @ProcessUserID
				--			WHERE
				--					SOISequence = @OrderDetailNo
				--		END
				--	END
				--END
					
                INSERT INTO STB_SavePackingTime_VVT
					(
					    LotNo
					   
					)
					VALUES
					(
					    @LotNo
					)


				--IF @MaterialDocTypeCode = 'MV_WH_ROUTE' AND ISNULL(@FPMainPlanNo,'') = '' BEGIN
				--	UPDATE
				--			STB_ProdPlanBom
				--	SET
				--			RequestQty = ISNULL(RequestQty,0) + @RequestQty
				--	WHERE
				--			FPMainPlanNo = @FPMainPlanNo AND
				--			MaterialCode = @MaterialCode
				--END

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN			

				--SELECT
				--		@BefRequestQty = MDD.RequestQty,
				--		@BefAllowQty = MDD.AllowQty,
				--		@BefPickingAssignQty = MDD.PickingAssignQty
				--FROM
				--		STB_SavePackingTime_VVT MDD
				--WHERE
				--		MDD.MaterialDocDetailNo = @MaterialDocDetailNo



				--IF @MaterialDocType = 'GR' BEGIN
						


				--	IF @BefRequestQty <> @RequestQty BEGIN

				--		EXEC usp_DoValidateMaterialDoc	@pProcessLanguage = @ProcessLanguage,
				--										@pProcessUserID = @ProcessUserID,											
				--										@pMaterialDocNo = @MaterialDocNo,
				--										@pErrorWhenStart = 1	

				--		IF @BefRequestQty <> @BefPickingAssignQty BEGIN
				--			RAISERROR('입하가 진행중입니다.',16,1)
				--			RETURN
				--		END
				--		SET @AllowQty = @RequestQty
				--		SET @PickingAssignQty = @RequestQty							
				--	END
					
				--	UPDATE
				--			STB_MaterialOrderItem
				--	SET
				--			MaterialOrderRemainQty = ISNULL(MaterialOrderRemainQty,0) + ISNULL(@BefAllowQty,0) - @AllowQty,
				--			ChangeDateTime =  GETDATE(),
				--			ChangeUserID = @ProcessUserID
				--	WHERE
				--			MaterialOrderItemNo = @OrderDetailNo
				--END
				
				--IF @MaterialDocType IN ('GI' ,'MOVE') BEGIN
					
	
				--	EXEC usp_DoValidateMaterialDoc	@pProcessLanguage = @ProcessLanguage,
				--									@pProcessUserID = @ProcessUserID,											
				--									@pMaterialDocNo = @MaterialDocNo

				--	IF @BefRequestQty <> @RequestQty BEGIN
							

				--		EXEC usp_DoValidateMaterialDoc	@pProcessLanguage = @ProcessLanguage,
				--										@pProcessUserID = @ProcessUserID,											
				--										@pMaterialDocNo = @MaterialDocNo,
				--										@pErrorWhenStart = 1		

				--		IF @BefRequestQty <> @BefAllowQty BEGIN
				--			RAISERROR('작업이 진행중입니다.',16,1)
				--			RETURN
				--		END
				--		SET @AllowQty = @RequestQty
				--		SET @PickingAssignQty = @RequestQty							
				--	END

				--	IF ISNULL(@OrderDetailNo,'') <> '' BEGIN
				--			UPDATE
				--					STB_SalesOrderItem
				--			SET
				--					GIPlanQty = GIPlanQty - @BefRequestQty + @RequestQty,
				--					ChangeDateTime =  GETDATE(),
				--					ChangeUserID = @ProcessUserID
				--			WHERE
				--					SOISequence = @OrderDetailNo
				--	END
				--END


				if 			 @PackingID is null or
							 @Route_22 is not null or
							 @Route_23 is not null or
							 @Route_24 is not null or
							 @Route_25 is not null or
							 @Route_26 is not null or
							 @Route_27 is not null or
							 @Route_28 is not null or
							 @Route_99 is not null 	    begin

									declare @stage varchar(30) = case  when @Route_22 is not null then 'V-22'
																when @Route_23 is not null then 'V-23'
																when @Route_24 is not null then 'V-24'
																when @Route_25 is not null then 'V-25'
																when @Route_26 is not null then 'V-26'
																when @Route_27 is not null then 'V-27'
																when @Route_28 is not null then 'V-28'
																when @Route_99 is not null then 'V-99' else 'V-' end

							 	INSERT INTO STB_SavePackingTime_VVT
										(
											PackingID,
											LotNo,
					   						MaterialCode,
											MaterialName,
											PackQty,
											PrintTime,
											isModule,
											EmpNo
										)
										VALUES
										(
											@stage,
											@LotNo,
											@MaterialCode,
											@MaterialName,
											1,
											getdate(),
											0,
											@pProcessUserID
										)
					 end
				else begin

					UPDATE STB_SavePackingTime_VVT
					SET
						isPrinted = (case when @isPrinted='Hien(show)'	then 0 else 1 end	)
						,EmpChange = @pProcessUserID
					WHERE
						id = @id
				end

				--IF @MaterialDocTypeCode = 'MV_WH_ROUTE' AND ISNULL(@FPMainPlanNo,'') <> '' BEGIN
				--	UPDATE
				--			STB_ProdPlanBom
				--	SET
				--			RequestQty = ISNULL(RequestQty,0) - @BefRequestQty + @RequestQty
				--	WHERE
				--			FPMainPlanNo = @FPMainPlanNo AND
				--			MaterialCode = @MaterialCode
				--END
            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
				

				--IF (@MaterialDocType = 'GI') BEGIN--AND (@DocStatus <> 'CREATE')) BEGIN
				--	IF (
				--			SELECT
				--					COUNT(*)
				--			FROM
				--					STB_MaterialDocLotInfo MDLI
				--			WHERE
				--					MDLI.MaterialDocDetailNo = @MaterialDocDetailNo
				--		) > 0
				--	BEGIN
				--			RAISERROR(' %s',16,1,@DocStatus)
				--			RETURN
				--	END
				--END
				------------------------------------------------------------------------

				--IF ISNULL(@OrderDetailNo,'') <> '' BEGIN

				--	SELECT
				--			@BefRequestQty = MDD.RequestQty,
				--			@BefAllowQty = MDD.AllowQty
				--	FROM
				--			STB_SavePackingTime_VVT MDD
				--	WHERE
				--			MDD.MaterialDocDetailNo = @MaterialDocDetailNo

				--	--RAISERROR('STEP 1 %s',16, 1, @MaterialDocType)
				--	--RETURN


				--	IF @MaterialDocType = 'GR' BEGIN
					
				--		UPDATE
				--				STB_MaterialOrderItem
				--		SET
				--				MaterialOrderRemainQty = ISNULL(MaterialOrderRemainQty,0) + ISNULL(@BefAllowQty,0),
				--				ChangeDateTime =  GETDATE(),
				--				ChangeUserID = @ProcessUserID
				--		WHERE
				--				MaterialOrderItemNo = @OrderDetailNo
				--	END
				
				--	IF @MaterialDocType = 'GI' BEGIN
				--		UPDATE
				--				STB_SalesOrderItem
				--		SET
				--				GIPlanQty = GIPlanQty - @BefRequestQty,
				--				ChangeDateTime =  GETDATE(),
				--				ChangeUserID = @ProcessUserID
				--		WHERE
				--				SOISequence = @OrderDetailNo
				--	END
				--END						


                DELETE FROM STB_SavePackingTime_VVT
				WHERE
					    id = @id


				--IF @MaterialDocTypeCode = 'MV_WH_ROUTE' AND ISNULL(@FPMainPlanNo,'') <> '' BEGIN
				--	UPDATE
				--			STB_ProdPlanBom
				--	SET
				--			RequestQty = ISNULL(RequestQty,0) - @BefRequestQty
				--	WHERE
				--			FPMainPlanNo = @FPMainPlanNo AND
				--			MaterialCode = @MaterialCode
				--END
            END


			--IF @DocStatus IN ('FINISH')
			--BEGIN
			--		IF @MaterialDocType IN ('GI', 'MOVE')
			--		BEGIN
			--				UPDATE STB_MaterialDocInfo
			--				SET
			--						DocStatus = 'WORKING'
			--				WHERE
			--						MaterialDocNo = @MaterialDocNo
			--		END
			--		IF @MaterialDocType IN ('GR') 
			--		BEGIN
			--				UPDATE STB_MaterialDocInfo
			--				SET
			--						DocStatus = 'ARRIVAL'
			--				WHERE
			--						MaterialDocNo = @MaterialDocNo
			--		END

			--END

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

