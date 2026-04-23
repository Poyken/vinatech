-- ED-VJPMTR000000017
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2022-08-16
-- Browsable : true
-- Group : MEA
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MEARawMaterialInputHist_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pWorkerCode VARCHAR(20) = NULL
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
  DECLARE @Qty NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  Declare @MotherCode VARCHAR(20)
  Declare @PONo VARCHAR(20)
  Declare @BomVersion VARCHAR(20)
  Declare @ChildCode VARCHAR(20)

  Declare @CompanyCode VARCHAR(20)
  Declare @WorkCenterCode VARCHAR(20)

  Declare @WorkerCode VARCHAR(20) = @pWorkerCode

  Declare @BomList TABLE (
	MaterialCode VARCHAR(20)
  );

  Declare @GIWarehouseCode VARCHAR(20)
         ,@GILocationCode VARCHAR(20)
		 ,@Remark NVARCHAR(MAX)
		 ,@MEADefectDivCode VARCHAR(20)

Declare @BeforeMaterialCode VARCHAR(20)

Declare @MaterialDocNo VARCHAR(20)



  CREATE TABLE #LotNoList (Barcode VARCHAR(20)
						  ,ProductGroupCode VARCHAR(20))


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_RawMaterialInputHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
		PRINT 'Remove Merge Logic'

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
									Qty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Remark,
									MEADefectDivCode
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldRawMaterialInputHistNo VARCHAR(20),
											 RawMaterialInputHistNo VARCHAR(20),
											 Barcode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 RawMaterialBarcode VARCHAR(200),
											 Qty NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark NVARCHAR(MAX),
											 MEADefectDivCode VARCHAR(20)
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
									Qty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Remark,
									MEADefectDivCode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldRawMaterialInputHistNo VARCHAR(20),
											 RawMaterialInputHistNo VARCHAR(20),
											 Barcode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 RawMaterialBarcode VARCHAR(200),
											 Qty NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark NVARCHAR(MAX),
											 MEADefectDivCode VARCHAR(20)
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
									Qty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Remark,
									MEADefectDivCode
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldRawMaterialInputHistNo VARCHAR(20),
											 RawMaterialInputHistNo VARCHAR(20),
											 Barcode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 RawMaterialBarcode VARCHAR(200),
											 Qty NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark NVARCHAR(MAX),
											 MEADefectDivCode VARCHAR(20)
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
								 @Qty,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @Remark,
								 @MEADefectDivCode


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				-- 다른 프로시저를 호출하기 전에 필요한 정보를 임시테이블에 담는다. 2022.09.06 By Jackaroe
				-- 추가로 필요한 정보가 있다면 해당 내용도 포함 시킬 수 있다.
				-- 단, 공통으로 사용하는 프로시저의 경우 OBJECT_ID를 사용하여 임시테이블이 존재하는 경우에만 쿼리를 적용한다.
				DELETE FROM #LotNoList
				INSERT INTO #LotNoList (Barcode, ProductGroupCode) VALUES (@Barcode, @ProductGroupCode)

                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_RawMaterialInputHist WHERE RawMaterialInputHistNo = @RawMaterialInputHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @RawMaterialInputHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_RawMaterialInputHist',@RawMaterialInputHistNo OUTPUT
                    END

                    INSERT INTO STB_RawMaterialInputHist
						(
						    RawMaterialInputHistNo,
						    Barcode,
						    ProductGroupCode,
						    RawMaterialBarcode,
						    Qty,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							Remark,
							MEADefectDivCode,
							WorkerCode
						)
						VALUES
						(
						    @RawMaterialInputHistNo,
						    @Barcode,
						    @ProductGroupCode,
						    @RawMaterialBarcode,
						    @Qty,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@Remark,
							@MEADefectDivCode,
							@WorkerCode
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					-- 커서에서 패치되는 변수가 아니므로 초기화 해준다.
					SET @ChildCode = NULL
					
					Select  @MotherCode =  SI.MaterialCode 
					       ,@PONo = SI.PONo
					From STB_SetInfo SI
					Where SI.Barcode = @Barcode


					-- 유효기간 체크 패스 (현재 자재 정보 상 유효개월 수가 없음)
					-- 이후 구현 시 현재 위치에 추가할 것
					-- 자재 유효기간 체크 To-Do
					-- 2020.06.03 선입선출 체크사항 Start  --------------------------------------------------------------------------------------------------------------------------------------------------------------------
					 Declare @MakeDate  VARCHAR(20)
					 Declare @PackDate   VARCHAR(20)	 	
					 Declare @MakeDate2  VARCHAR(20)
					 Declare @PackDate2   VARCHAR(20)	 	   
					 Declare @Todate   VARCHAR(20)
					 Declare @MaterialCode VARCHAR(20)
					 Declare @FIFOBarCode VARCHAR(200)
					 Declare @MaterialTypeCode VARCHAR(20)
					 Declare @CurrentQty NUMERIC(20,5)

					 SELECT @MaterialCode = MLI.MaterialCode
					       ,@MaterialTypeCode = MM.MaterialTypeCode
						   ,@CurrentQty = MLI.CurrentQty
					   From STB_MaterialLotInfo MLI
					   LEFT OUTER JOIN STB_MaterialMaster MM
					     ON MLI.MaterialCode = MM.MaterialCode
					  Where (MLI.LotID = @RawMaterialBarcode OR MLI.LotNo = @RawMaterialBarcode)

					  --1. 해당제품의 가장 빠른 제조일/유효일 파악
							 SELECT	TOP 1 @MakeDate = MIN(SML.Lotattr10)                                                                                                                                                 
										, @PackDate  = CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, SML.Lotattr10), 121)), 121)
										, @FIFOBarCode = CASE @MaterialTypeCode WHEN 'ROH'  THEN SML.LotID
																				WHEN 'HALB' THEN SML.LotNo END
							 FROM                           STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
	  									LEFT OUTER JOIN STB_MaterialMaster        MM WITH(NOLOCK)  ON MDLI.MaterialCode = MM.MaterialCode			 
										LEFT OUTER JOIN STB_MaterialLotInfo        SML WITH(NOLOCK)  ON SML.LotNo = MDLI.LotNo                    AND SML.LOTID = MDLI.LOTID
								WHERE 1=1				
									AND	MDLI.MaterialCode = @MaterialCode	
									AND SML.CompanyCode = 'VNT'
									AND SML.CurrentQty > 0
									AND SML.MaterialWarehouseCode In (Select MaterialWarehouseCode 
																			   From STB_MaterialWarehouse
																			  Where WorkCenterCode = 'VNT_F2'
																				And MaterialWarehouseName Like '%공정%')
								GROUP BY MM.MMExtInt01, SML.Lotattr10, SML.LotID, SML.LotNo
								ORDER BY SML.LotID


					  -- 2. 해당 Lot의 제조일/유효일 파악
								 SELECT	    @MakeDate2 = CASE WHEN  MDLI.Lotattr10 = '' THEN SML.Lotattr10 ELSE IsNull(MDLI.Lotattr10, SML.Lotattr10) END
										  , @PackDate2 = CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)
										  , @Todate = CONVERT(VARCHAR(10),	GetDate(), 121)
								   FROM                     STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
	  									LEFT OUTER JOIN STB_MaterialMaster           MM WITH(NOLOCK) ON MDLI.MaterialCode = MM.MaterialCode			 
										LEFT OUTER JOIN STB_MaterialLotInfo         SML WITH(NOLOCK) ON SML.LotNo = MDLI.LotNo                    AND SML.LOTID = MDLI.LOTID
								WHERE 1=1
									AND SML.CompanyCode = 'VNT'
									AND SML.MaterialWarehouseCode In (Select MaterialWarehouseCode 
																			   From STB_MaterialWarehouse
																			  Where WorkCenterCode = 'VNT_F2'
																				And MaterialWarehouseName Like '%공정%')
									AND MDLI.LOTID = @RawMaterialBarcode OR MDLI.LotNo = @RawMaterialBarcode
									AND MDLI.MDLISeqNo = (Select Max(MDLISeqNo) From STB_MaterialDocLotInfo Where LotID = @RawMaterialBarcode OR LotNo = @RawMaterialBarcode )

					 ---- 3. 해당 의 제조일이 가장빠르지 않으면 에러
					    --IF @MakeDate < @MakeDate2         
						--IF @RawMaterialBarcode <> @FIFOBarCode
		    
						--	BEGIN
						--		 RAISERROR(' 원자재 투입처리가 실패하였습니다. (제조일자가 앞선 Lot : %s 존재합니다) ' ,16, 1, @FIFOBarCode)           
						--		 RETURN
						--	END

				  -- 2020.06.03 선입선출 체크사항 End --------------------------------------------------------------------------------------------------------------------------------------------------------------------

				  -- 원자재바코드 재고수량 >= 투입수량 확인 체크
						IF @Qty > @CurrentQty
							BEGIN
								 RAISERROR(' 투입수량이 초과 되었습니다. 현재고 : %s ' ,16, 1, @CurrentQty)           
								 RETURN
							END
				  -- 원자재바코드 재고수량 >= 투입수량 확인 체크

				    --RAISERROR('Before Update %s',16,1, @CreateUserID) RETURN
					-- 최초 입력이면 업데이트 한다.
					IF @CreateUserID IS NULL BEGIN
						UPDATE STB_RawMaterialInputHist
							SET
								RawMaterialInputHistNo =   ISNULL(@RawMaterialInputHistNo,RawMaterialInputHistNo),
								Barcode =   ISNULL(@Barcode,Barcode),
								ProductGroupCode =   ISNULL(@ProductGroupCode,ProductGroupCode),
								RawMaterialBarcode =   ISNULL(@RawMaterialBarcode,RawMaterialBarcode),
								Qty =   ISNULL(@Qty,Qty),
								CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
								CreateUserID =   @pProcessUserID,
								ChangeDateTime = GETDATE(),
								ChangeUserID = @pProcessUserID,
								Remark =   ISNULL(@Remark,Remark),
								MEADefectDivCode =   ISNULL(@MEADefectDivCode,MEADefectDivCode),
								WorkerCode = @WorkerCode
							WHERE
								RawMaterialInputHistNo = @OldRawMaterialInputHistNo
					END ELSE BEGIN -- 추가 입력이면 행을 추가한다.
						IF @IsAutoKey = 1 BEGIN
							EXEC usp_DoCreateSerial 'STB_RawMaterialInputHist',@RawMaterialInputHistNo OUTPUT
						END

						INSERT INTO STB_RawMaterialInputHist
							(
								RawMaterialInputHistNo,
								Barcode,
								ProductGroupCode,
								RawMaterialBarcode,
								Qty,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								Remark,
								MEADefectDivCode,
								WorkerCode
							)
							VALUES
							(
								@RawMaterialInputHistNo,
								@Barcode,
								@ProductGroupCode,
								@RawMaterialBarcode,
								@Qty,
								GETDATE(),
								@pProcessUserID,
								@ChangeDateTime,
								@ChangeUserID,
								@Remark,
								@MEADefectDivCode,
								@WorkerCode
							)
					END

					-- 5. 원자재 투입 자재의 BOM 체크 START

						--BOM 버전과 사업장, 작업장 정보를 가져온다.
						SELECT @BomVersion = BomVersion
						      ,@CompanyCode = CompanyCode
							  ,@WorkCenterCode = WorkCenterCode
						  FROM STB_ProductionOrderInfo
						 WHERE PONo = @PONo

						--모품목에 속하는 BOM 자재 리스트를 테이블 변수에 저장한다.
						INSERT INTO @BomList (MaterialCode)
							exec usp_GetNormalModelBomListOutput '', '', @MotherCode, @BomVersion, 1

						--대체품목이 존재하면 해당 내용을 추가해준다. 2022.09.05 By Jackaroe
						INSERT INTO @BomList (MaterialCode)
							SELECT DelegateMaterialCode 
							  FROM STB_MaterialMaster 
							 WHERE ISNULL(DelegateMaterialCode, '') <> ''
							   AND MaterialCode IN (SELECT MaterialCode FROM @BomList)

						-- MEA Cathode 오투입 체크
						IF @ProductGroupCode = 'Cathode' BEGIN
								IF SUBSTRING(@RawMaterialBarcode, 8, 1) <> 'C' BEGIN
									IF SUBSTRING(@RawMaterialBarcode, 9, 1) <> 'C' BEGIN
										RAISERROR('Cathode전극이 아닙니다. %s 자재 확인바랍니다.',16,1, @ProductGroupCode)
										RETURN
									END
								END

						END

						-- MEA Anode 오투입 체크
						IF @ProductGroupCode = 'Anode' BEGIN
							IF SUBSTRING(@RawMaterialBarcode, 8, 1) <> 'A' BEGIN
								IF SUBSTRING(@RawMaterialBarcode, 9, 1) <> 'A' BEGIN
									RAISERROR('Anode전극이 아닙니다. %s 자재 확인바랍니다.',16,1, @ProductGroupCode)
									RETURN
								END
							END
						END

						-- BOM 체크					
						IF (@RawMaterialBarcode <> '' Or @RawMaterialBarcode IS NOT NULL) BEGIN
							-- 원자재 바코드로 원자재 코드를 구한 후 해당 품목이 BOM에 포함되고, 공정창고에 존재하는지 확인한다.
							-- 전극은 SetInfo에서 구한다.
							SELECT @ChildCode = MaterialCode
							  FROM STB_SetInfo
							 WHERE Barcode = @RawMaterialBarcode

							-- @ChildCode IS NULL 이면, LotInfo에서 찾는다. 
							-- ML 코드가 입력될 경우와 업체 바코드가 입력될 경우를 각각 상정하여 공정창고에서 찾는다.
							IF @ChildCode IS NULL BEGIN
								SELECT @ChildCode = MLI.MaterialCode
								  FROM STB_MaterialLotInfo MLI
								 WHERE (MLI.LotID = @RawMaterialBarcode OR LotNo = @RawMaterialBarcode)
								   AND MLI.MaterialCode IN (SELECT MaterialCode FROM @BomList WHERE MaterialCode = MLI.MaterialCode)
								   AND MLI.MaterialWarehouseCode IN (SELECT MaterialWarehouseCode 
								                                  FROM STB_MaterialWarehouse 
																 WHERE IsRouteWarehouse = CONVERT(BIT, 1)
																   AND CompanyCode = @CompanyCode
																   AND WorkCenterCode = @WorkCenterCode
																)
							END ELSE BEGIN 
								SELECT MaterialCode FROM @BomList
								-- 전극이면 (STB_SetInfo에 존재하면) 공정창고 존재 여부를 체크한다.
								SELECT @ChildCode = MLI.MaterialCode
								  FROM STB_MaterialLotInfo MLI
								 WHERE MLI.MaterialCode IN (SELECT MaterialCode FROM @BomList)
								   AND MLI.MaterialCode = @ChildCode
								   AND CurrentQty > 0
								   AND MaterialWarehouseCode IN (SELECT MaterialWarehouseCode 
								                                  FROM STB_MaterialWarehouse 
																 WHERE IsRouteWarehouse = CONVERT(BIT, 1)
																   AND CompanyCode = @CompanyCode
																   AND WorkCenterCode = @WorkCenterCode
																)
							END

							IF @ChildCode IS NULL BEGIN
								RAISERROR('원자재 재고가 없거나 생산 중인 제품 BOM에 적합하지 않은 자재입니다. %s 자재 확인바랍니다.',16,1, @ProductGroupCode)
								RETURN
							END

							-- 창고정보 
							SELECT @GIWarehouseCode = MaterialWarehouseCode
							  FROM STB_UserInfo
							 WHERE UserID = @pProcessUserID

							-- 지지체 반제품 정보
							SELECT @BeforeMaterialCode = BeforeMaterialCode
							  FROM STB_MaterialMaster 
							 WHERE MaterialCode = @ChildCode

							IF @GIWarehouseCode = 'W02' BEGIN
								SET @GIWarehouseCode = 'W13'
								SET @GILocationCode = 'W13_WH_01'
							END ELSE BEGIN
								-- 반제품 종류에 따라 로케이션 재조정 By Jackaroe 2023.01.10 
								SET @GIWarehouseCode = 'W15'
								SET @GILocationCode = 'W15_WH_01'

								IF @BeforeMaterialCode IN ('450', '750') BEGIN
									SET @GILocationCode = 'W15_WH_02'
								END 

								IF @BeforeMaterialCode IN ('450S2', '750S2') BEGIN
									SET @GILocationCode = 'W15_WH_03'
								END 
							END

							-- 정상처리 후 백플러시
							--exec usp_DoProcessProdGIMaterialByManual @pProcessUserID
							--										,@pProcessLanguage
							--										,@CompanyCode
							--										,@WorkCenterCode
							--										,@RawMaterialBarcode
							--										,@Qty
							--										,@GIWarehouseCode
							--										,@GILocationCode

							-- Lot ID 지정 출고... 2024.05.21 By Jackaroe
							-- ProductGroupCode가 Anode이거나 Cathode이면, LotNo를 LotID로 변환해준다.
							IF @ProductGroupCode IN ('Cathode', 'Anode', 'VFS-SP0450-IP1', 'VFS-SP0450-IP2', 'VFS-SP0750-IP1', 'VFS-SP0750-IP2', 'CCM') BEGIN
								SELECT TOP 1 @RawMaterialBarcode = LotID 
								  FROM STB_MaterialLotInfo
								 WHERE LotNo = @RawMaterialBarcode
							END


							EXEC usp_DoProcessProdGIMaterialForBarcode	@pProcessUserID = @ProcessUserID,
																	@pProcessLanguage = @ProcessLanguage,
																	@pPONo = NULL,
																	@pLotID = @RawMaterialBarcode,
																	@pProdQty = @Qty,
																	@pMaterialDocNo = @MaterialDocNo OUTPUT

							EXEC usp_DoFinishMaterialDoc	@pProcessLanguage = @ProcessLanguage,
															@pProcessUserID = @ProcessUserID,
															@pMaterialDocNo = @MaterialDocNo

							EXEC usp_DoFixMaterialDoc	@pProcessUserID = @ProcessUserID,
														@pProcessLanguage = @ProcessLanguage,
														@pMaterialDocNo = @MaterialDocNo
						END

					-- 5. 원자재 투입 자재의 BOM 체크 END
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

	DROP TABLE #LotNoList
END