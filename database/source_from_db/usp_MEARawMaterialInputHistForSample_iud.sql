-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-09-20
-- Browsable : true
-- Group : MEA
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MEARawMaterialInputHistForSample_iud]
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
  DECLARE @OldMEARawMaterialInputHistNo VARCHAR(20)
  DECLARE @MEARawMaterialInputHistNo VARCHAR(20)
  DECLARE @InputDate DATE
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @RawMaterialBarcode VARCHAR(50)
  DECLARE @InputQty NUMERIC(20,5)
  DECLARE @Remark NVARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  -- Column 추가
  Declare @GIWarehouseCode VARCHAR(20)
         ,@GILocationCode VARCHAR(20)
		 ,@CompanyCode VARCHAR(20)
		 ,@WorkCenterCode VARCHAR(20)

  Declare @MaterialDocNo VARCHAR(20)

  --COLUMN 추가 2025-11-27 MEA 반제품 투입을 위한 변수
  DECLARE @ProductGroupCode VARCHAR(20)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MEARawMaterialInputHistForSample',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        PRINT 'Batch was removed'
    END ELSE BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldMEARawMaterialInputHistNo,
									MEARawMaterialInputHistNo,
									InputDate,
									MaterialCode,
									RawMaterialBarcode,
									InputQty,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMEARawMaterialInputHistNo VARCHAR(20),
											 MEARawMaterialInputHistNo VARCHAR(20),
											 InputDate DATETIMEOFFSET,
											 MaterialCode VARCHAR(20),
											 RawMaterialBarcode VARCHAR(50),
											 InputQty NUMERIC(20,5),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMEARawMaterialInputHistNo IS NULL THEN MEARawMaterialInputHistNo
										ELSE OldMEARawMaterialInputHistNo
									END AS OldMEARawMaterialInputHistNo,
									MEARawMaterialInputHistNo,
									InputDate,
									MaterialCode,
									RawMaterialBarcode,
									InputQty,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMEARawMaterialInputHistNo VARCHAR(20),
											 MEARawMaterialInputHistNo VARCHAR(20),
											 InputDate DATETIMEOFFSET,
											 MaterialCode VARCHAR(20),
											 RawMaterialBarcode VARCHAR(50),
											 InputQty NUMERIC(20,5),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMEARawMaterialInputHistNo IS NULL THEN MEARawMaterialInputHistNo
										ELSE OldMEARawMaterialInputHistNo
									END AS OldMEARawMaterialInputHistNo,
									MEARawMaterialInputHistNo,
									InputDate,
									MaterialCode,
									RawMaterialBarcode,
									InputQty,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMEARawMaterialInputHistNo VARCHAR(20),
											 MEARawMaterialInputHistNo VARCHAR(20),
											 InputDate DATETIMEOFFSET,
											 MaterialCode VARCHAR(20),
											 RawMaterialBarcode VARCHAR(50),
											 InputQty NUMERIC(20,5),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMEARawMaterialInputHistNo,
								 @MEARawMaterialInputHistNo,
								 @InputDate,
								 @MaterialCode,
								 @RawMaterialBarcode,
								 @InputQty,
								 @Remark,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MEARawMaterialInputHistForSample WHERE MEARawMaterialInputHistNo = @MEARawMaterialInputHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MEARawMaterialInputHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_MEARawMaterialInputHistForSample',@MEARawMaterialInputHistNo OUTPUT
                    END

                    INSERT INTO STB_MEARawMaterialInputHistForSample
						(
						    MEARawMaterialInputHistNo,
						    InputDate,
						    MaterialCode,
						    RawMaterialBarcode,
						    InputQty,
						    Remark,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MEARawMaterialInputHistNo,
						    @InputDate,
						    @MaterialCode,
						    @RawMaterialBarcode,
						    @InputQty,
						    @Remark,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MEARawMaterialInputHistForSample
						SET
						    InputDate =   ISNULL(@InputDate,InputDate),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    RawMaterialBarcode =   ISNULL(@RawMaterialBarcode,RawMaterialBarcode),
						    InputQty =   ISNULL(@InputQty,InputQty),
						    Remark =   ISNULL(@Remark,Remark),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MEARawMaterialInputHistNo = @OldMEARawMaterialInputHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MEARawMaterialInputHistForSample
						WHERE
						    MEARawMaterialInputHistNo = @OldMEARawMaterialInputHistNo
                END


			-- 2022.11.16 선입선출 체크사항 Start  --------------------------------------------------------------------------------------------------------------------------------------------------------------------
				Declare @MakeDate  VARCHAR(20)
				Declare @PackDate   VARCHAR(20)	 	
				Declare @MakeDate2  VARCHAR(20)
				Declare @PackDate2   VARCHAR(20)	 	   
				Declare @Todate   VARCHAR(20)
				--Declare @MaterialCode VARCHAR(20)
				Declare @FIFOBarCode VARCHAR(200)
				Declare @MaterialTypeCode VARCHAR(20)
				Declare @CurrentQty NUMERIC(20,5)

				SELECT @MaterialCode = MLI.MaterialCode
					,@MaterialTypeCode = MM.MaterialTypeCode
					,@CurrentQty = MLI.CurrentQty
					,@ProductGroupCode = MM.ProductGroupCode -- 반제품 투입 시 처리를 위한 변수  2025-11-27 소병운 추가
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
																		And MaterialWarehouseName Like '%원자재%')
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
																		And MaterialWarehouseName Like '%원자재%')
							AND MDLI.LOTID = @RawMaterialBarcode OR MDLI.LotNo = @RawMaterialBarcode
							AND MDLI.MDLISeqNo = (Select Max(MDLISeqNo) From STB_MaterialDocLotInfo Where LotID = @RawMaterialBarcode OR LotNo = @RawMaterialBarcode )

				---- 3. 해당 의 제조일이 가장빠르지 않으면 에러 -- 샘플의 경우에는 체크하지 않음. 2024.04.19 서동영프로요청 by Jackaroe
				--IF @MakeDate < @MakeDate2         
				--IF @RawMaterialBarcode <> @FIFOBarCode
		    
				--	BEGIN
				--			RAISERROR(' 원자재 투입처리가 실패하였습니다. (제조일자가 앞선 Lot : %s 존재합니다) ' ,16, 1, @FIFOBarCode)           
				--			RETURN
				--	END


			-- 원자재바코드 재고수량 >= 투입수량 확인 체크
				IF @InputQty > @CurrentQty
					BEGIN
							RAISERROR(' 투입수량이 초과 되었습니다. 현재고 : %s ' ,16, 1, @CurrentQty)           
							RETURN
					END
			-- 원자재바코드 재고수량 >= 투입수량 확인 체크
			-- 2022.11.16 선입선출 체크사항 End --------------------------------------------------------------------------------------------------------------------------------------------------------------------


				-- 샘플원자재에 대한 백플러시 적용
				-- 처리자의 CompanyCode, WorkCenterCode, 창고 정보를 가져온다
				SELECT @GIWarehouseCode = MaterialWarehouseCode
				      ,@CompanyCode = CompanyCode
					  ,@WorkCenterCode = WorkCenterCode
					FROM STB_UserInfo
					WHERE UserID = @pProcessUserID

				-- 샘플 자재의 경우 공정창고가 아닌 원자재 창고에서 차감한다. 2022.11.15 우향난 매니저 요청
				-- 지지체의 경우 별도의 요청은 없었으나(사용하는 화면이 아님) 로직의 통일성을 위해 동일한 기준으로 변경함.
				IF @GIWarehouseCode = 'W02' BEGIN
					SET @GIWarehouseCode = 'W02'
					SET @GILocationCode = 'W02_WH_01'
				END ELSE BEGIN
					SET @GIWarehouseCode = 'W14'
					SET @GILocationCode = 'W14_WH_01'
				END

				-- ProductGroupCode가 Anode이거나 Cathode이면, LotNo를 LotID로 변환해준다.
				IF @ProductGroupCode IN ('Cathode', 'Anode', 'VFS-SP0450-IP1', 'VFS-SP0450-IP2', 'VFS-SP0750-IP1', 'VFS-SP0750-IP2', 'CCM') BEGIN
					SELECT TOP 1 @RawMaterialBarcode = LotID 
						FROM STB_MaterialLotInfo
						WHERE LotNo = @RawMaterialBarcode
				END

				-- 정상처리 후 백플러시
				--exec usp_DoProcessProdGIMaterialByManual @pProcessUserID
				--										,@pProcessLanguage
				--										,@CompanyCode
				--										,@WorkCenterCode
				--										,@RawMaterialBarcode
				--										,@InputQty
				--										,@GIWarehouseCode
				--										,@GILocationCode

				-- Lot ID 지정 출고... 2024.05.21 By Jackaroe
				EXEC usp_DoProcessProdGIMaterialForBarcode	@pProcessUserID = @ProcessUserID,
														@pProcessLanguage = @ProcessLanguage,
														@pPONo = NULL,
														@pLotID = @RawMaterialBarcode,
														@pProdQty = @InputQty,
														@pMaterialDocNo = @MaterialDocNo OUTPUT

				EXEC usp_DoFinishMaterialDoc	@pProcessLanguage = @ProcessLanguage,
												@pProcessUserID = @ProcessUserID,
												@pMaterialDocNo = @MaterialDocNo

				EXEC usp_DoFixMaterialDoc	@pProcessUserID = @ProcessUserID,
											@pProcessLanguage = @ProcessLanguage,
											@pMaterialDocNo = @MaterialDocNo
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