
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
  DECLARE @Barcode VARCHAR(50)
  DECLARE @ProductGroupCode VARCHAR(50)
  DECLARE @RawMaterialBarcode VARCHAR(4000)
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

   Declare @UpdateCnt INT = 0
   Declare @RawMaterialListCnt INT = 0
   DECLARE @TargetMaterialWarehouseCode varchar(50)
   DECLARE @WarehouseInOutCode varchar(50)
   Declare @WorkCenterCode VARCHAR(20)
   DECLARE @DecisionResult VARCHAR(20)
   DECLARE @count1 int;
   SELECT @WorkCenterCode = WorkCenterCode
     FROM STB_UserInfo
	WHERE UserID = @pProcessUserID

   Declare @IsRouteWarehouse BIT

   Declare @WeekCode VARCHAR(10)
   Declare @Grade VARCHAR(10)
   Declare @RouteCode VARCHAR(20)
   Declare @MaterialCode VARCHAR(50)

   DECLARE @OldRawMaterialBarcode VARCHAR(4000)
   

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
			DECLARE @AffectedRows TABLE (
                RawMaterialInputHistNo VARCHAR(20)
            );

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
										RawMaterialBarcode VARCHAR(4000),
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
					)

			OUTPUT inserted.RawMaterialInputHistNo INTO @AffectedRows;

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
										RawMaterialBarcode VARCHAR(4000),
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
					)

			OUTPUT inserted.RawMaterialInputHistNo INTO @AffectedRows;

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
										RawMaterialBarcode VARCHAR(4000),
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

			DECLARE @TargetHistNo VARCHAR(20);
            DECLARE SplitCursor CURSOR LOCAL FOR 
                SELECT DISTINCT RawMaterialInputHistNo FROM @AffectedRows WHERE RawMaterialInputHistNo IS NOT NULL;
            
            OPEN SplitCursor;
            FETCH NEXT FROM SplitCursor INTO @TargetHistNo;
            
            WHILE @@FETCH_STATUS = 0 BEGIN
                -- 여기서 내가 만든 분할 프로시저 호출!
                EXEC RawMaterialBarcodeSplitByNo @TargetHistNo;
                
                FETCH NEXT FROM SplitCursor INTO @TargetHistNo;
            END
            
            CLOSE SplitCursor;
            DEALLOCATE SplitCursor;

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
									ChangeUserID,
									WeekCode,
									Grade,
									RouteCode,
									OldRawMaterialBarcode,
									MaterialCode
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldRawMaterialInputHistNo VARCHAR(20),
											 RawMaterialInputHistNo VARCHAR(20),
											 Barcode VARCHAR(50),
											 ProductGroupCode VARCHAR(20),
											 RawMaterialBarcode VARCHAR(4000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 WeekCode VARCHAR(10),
											 Grade VARCHAR(10),
											 RouteCode VARCHAR(20),
											 OldRawMaterialBarcode VARCHAR(4000),
											 MaterialCode VARCHAR(50)
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
									ChangeUserID,
									WeekCode,
									Grade,
									RouteCode,
									OldRawMaterialBarcode,
									MaterialCode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldRawMaterialInputHistNo VARCHAR(20),
											 RawMaterialInputHistNo VARCHAR(20),
											 Barcode VARCHAR(50),
											 ProductGroupCode VARCHAR(20),
											 RawMaterialBarcode VARCHAR(4000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 WeekCode VARCHAR(10),
											 Grade VARCHAR(10),
											 RouteCode VARCHAR(20),
											 OldRawMaterialBarcode VARCHAR(4000),
											 MaterialCode VARCHAR(50)
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
									ChangeUserID,
									WeekCode,
									Grade,
									RouteCode,
									OldRawMaterialBarcode,
									MaterialCode
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldRawMaterialInputHistNo VARCHAR(20),
											 RawMaterialInputHistNo VARCHAR(20),
											 Barcode VARCHAR(50),
											 ProductGroupCode VARCHAR(20),
											 RawMaterialBarcode VARCHAR(4000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 WeekCode VARCHAR(10),
											 Grade VARCHAR(10),
											 RouteCode VARCHAR(20),
											 OldRawMaterialBarcode VARCHAR(4000),
											 MaterialCode VARCHAR(50)
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
								 @ChangeUserID,
								 @WeekCode,
								 @Grade,
								 @RouteCode,
								 @OldRawMaterialBarcode,
								 @MaterialCode


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				Declare @RawMaterialCode VARCHAR(20)

			SELECT @RawMaterialCode = MaterialCode 
				FROM STB_MaterialLotInfo
				WHERE LotID = @RawMaterialBarcode

			SELECT @RawMaterialListCnt = COUNT(*)
			  FROM STB_RawMaterialInputHist
			 WHERE Barcode = @Barcode

                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_RawMaterialInputHist WHERE RawMaterialInputHistNo = @RawMaterialInputHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @RawMaterialInputHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_RawMaterialInputHist',@RawMaterialInputHistNo OUTPUT
                    END

					IF EXISTS (SELECT 1 FROM STB_BomDetail_Revision WHERE ChildMaterialCode = @RawMaterialCode AND ValidTo <= GETDATE()) 
					BEGIN
						EXEC usp_RaiseLocalizedError @pProcessLanguage, '투입금지 원자재입니다.'
						RETURN
					END
					-- RAISERROR(@ProductGroupCode, 16, 1); RETURN;
                   



					
				

					/*
					 Author: Mr.Triều
					 CreateDate: 2026-05-19
					 Description: Prevent the release of raw materials that have not yet been released from the warehouse, and that warehouse must be for production.
					*/
					
					select @count1=count(*) from STB_MaterialWarehouseInOutHist
					where LotID=@RawMaterialBarcode
					-- Kiểm tra xem nó đã đuọc xuất kho hay chưa
					-- 공정창고에 바로 생성되는 반제품의 경우는 출고 이력이 남지 않는다.
					--if(@count1=0 and @WorkCenterCode='VVT_F4')
					--BEGIN
					--     RAISERROR(N'Mã lot chưa đươc xuất ra CellLine vấn đang ở trong kho',16,1);
					--	 RETURN;
					--END
					
					--select @TargetMaterialWarehouseCode=TargetMaterialWarehouseCode,@WarehouseInOutCode=WarehouseInOutCode 
					--  from STB_MaterialWarehouseInOutHist
					-- where LotID=@RawMaterialBarcode

					SELECT @TargetMaterialWarehouseCode = MaterialWarehouseCode
					  FROM STB_MaterialLotInfo
					 WHERE LotID = @RawMaterialBarcode

					SELECT @IsRouteWarehouse = IsRouteWarehouse
					  FROM STB_MaterialWarehouse
					 WHERE MaterialWarehouseCode = @TargetMaterialWarehouseCode
					
					

					--if(@WorkCenterCode='VVT_F4' and @TargetMaterialWarehouseCode not in ('ROUTE_BG2_WH') and @WarehouseInOutCode='O')
					IF @WorkCenterCode='VVT_F4' AND @IsRouteWarehouse <> CONVERT(BIT, 1)
					BEGIN
					   RAISERROR(N'Mã lot này kho chưa được xuất là CellLine từ bên kho NVL.Vui lòng kiểm tra lại. ',16,1);
					   RETURN;
					END
					/*
					  Author: Mr.Triều
					  CreateDate: 2026-05-19
					  Description: The entire raw material was blocked, and the IQC inspection rejected it, but it was still imported.
					*/
					SELECT @DecisionResult=DecisionResult from STB_MaterialWarehouseInOutHist WHIH
					LEFT JOIN STB_MaterialDocLotInfo MDL WITH(NOLOCK) ON WHIH.LotID=MDL.LotID
					LEFT JOIN STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo=MDL.MaterialDocDetailNo
					LEFT JOIN STB_MaterialQcInfo MQI WITH(NOLOCK) ON MQI.MaterialQcNo=MDD.MaterialIqcNo
					where MDL.LotID=@RawMaterialBarcode;
					if(@DecisionResult='Reject')
					BEGIN
					     RAISERROR(N'Mã lot này thuộc lô hàng bên IQC đánh Reject. Vui lòng xác nhận lại. ',16,1);
					     RETURN;
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
						    ChangeUserID,
							WeekCode,
							Grade,
							MaterialCode
						)
						VALUES
						(
						    @RawMaterialInputHistNo,
						    @Barcode,
						    CASE WHEN @ProductGroupCode = 'PWB173670' THEN 'PWB164180' ELSE @ProductGroupCode END,
						    @RawMaterialBarcode,
						    GETDATE(),
						    @pProcessUserID,
							--Nghi ngờ sai time: Time lấy từ client
						    GETDATE(),
						    @ChangeUserID,
							@WeekCode,
							@Grade,
							@MaterialCode
						)

					EXEC RawMaterialBarcodeSplitByNo @RawMaterialInputHistNo;

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
					SET @UpdateCnt = @UpdateCnt + 1

					IF EXISTS (SELECT 1 FROM STB_BomDetail_Revision WHERE ChildMaterialCode = @RawMaterialCode AND ValidTo <= GETDATE()) 
					BEGIN
						EXEC usp_RaiseLocalizedError @pProcessLanguage, '투입금지 원자재입니다.'
						RETURN
					END

					-- 업데이트 개수가 목록 수와 일치하는지 체크


					-- 유효기간 체크 
					--SELECT @ExpiredDate = ISNULL(CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121), '2050-06-14')
					--  FROM STB_MaterialDocLotInfo MDLI
					--  LEFT OUTER JOIN STB_MaterialMaster MM
					--    ON MDLI.MaterialCode = MM.MaterialCode
					-- WHERE MDLI.LotID = @RawMaterialBarcode OR LotNo = @RawMaterialBarcode

					--IF @ExpiredDate <= CONVERT(VARCHAR(10), GETDATE(), 121) BEGIN
					--	EXEC usp_RaiseLocalizedError @pProcessLanguage,'유효기간이 지난 자재입니다.'
					--	RETURN
					--END
					
					IF @OldRawMaterialBarcode IS NULL OR @OldRawMaterialBarcode = ''
					
					BEGIN -- 초기생성분이면 Update
					 /*
					   Author: Mr.Triều
					   CreateDate: 2026-06-19
					   Desc: Chặn không cho nhập giá trị nếu mã lot đang bị đanh giá là FAIL
					 */					
					   DECLARE @IsMaterialSCM VARCHAR(50);
					   SELECT @IsMaterialSCM=MaterialCode from STB_SetInfo where Barcode=@Barcode
					   IF @IsMaterialSCM='EDVTMD-248'
					   BEGIN
					       IF @ProductGroupCode='Capacitor Board'
						   BEGIN						  
						    DECLARE @LatestStatus VARCHAR(20) = '';
                            SELECT TOP 1 @LatestStatus = Status 
                            FROM STB_PassOrFailRouteStatus  
                            WHERE Barcode = @RawMaterialBarcode  
                            ORDER BY CreatedDate DESC; 
                    IF @LatestStatus = 'Fail'
                    BEGIN
                       RAISERROR(N'Mã lot này đang ở trạng thái là FAIL nên cần quay lại công đoạn trước đó để kiểm tra lại! ', 16, 1);
                       RETURN;
                    END							   
					END
				END
				  
				  /*
				     Author: Mr.Triều
					 CreateDate: 2026-06-19
					 Desc: Chặn không cho input NVL nếu mà con hàng chưa được bên OQC đanh giá là pass với con hàng SCM
				  */


				  IF @IsMaterialSCM='EDVTMD-248' AND @ProductGroupCode='Capacitor Board'
				  BEGIN
				     -- CHECK KIỂM Tra xem con nvl 
					 -- check xem thăng PCBA đã được pass hay chưa
					 DECLARE @IsOQCCheckOPass VARCHAR(50) = NULL

		
					 select @IsOQCCheckOPass=DecisionResult  from STB_MaterialQcInfo where  MaterialQcNo=@RawMaterialBarcode
					 IF @IsOQCCheckOPass='None' OR @IsOQCCheckOPass='Fail' OR @IsOQCCheckOPass='Hold' or @IsOQCCheckOPass='Reject' or isnull(@IsOQCCheckOPass, '') = ''
					 BEGIN
					      RAISERROR(N'Mã lot này chưa được được đanh giá là Pass.Vui lòng liên hệ Mr.Lê Luân-QC để kiểm tra!!!',16,1);
					      RETURN;
					 END
				  END
				 /* 
				   Author:Mr.Triều
				   CreateDate:2026-06-21
				   Desc: Chăn nếu là con hàn PCBA thì không chỉ cho nhâp cấp ở Cell
				 */

				 --SELECT MaterialCode FROM stb_setinfo where Barcode='K16418106262300536'
				 DECLARE @LotPCBA VARCHAR(50)
				 SELECT @LotPCBA=MaterialCode FROM stb_setinfo where Barcode=@Barcode

				IF (
                  @ProductGroupCode <> 'Capacitor35105' 
                  AND ISNULL((@Grade), '') <> '' 
                  AND @LotPCBA = 'BEPCBA-001'
                   )
					BEGIN
						RAISERROR(N'Nhóm sản phẩm này không phải là Capacitor35105, không thể cập nhật Grade. Vui lòng kiểm tra lại.', 16, 1);
						RETURN;
					END
				  --Capacitor35105

				  

					/*
					 Author: Mr.Triều
					 CreateDate: 2026-05-19
					 Description: Prevent the release of raw materials that have not yet been released from the warehouse, and that warehouse must be for production.
					*/
					
					select @count1=count(*) from STB_MaterialWarehouseInOutHist
					where LotID=@RawMaterialBarcode
					-- Kiểm tra xem nó đã đuọc xuất kho hay chưa
					--if(@count1=0 and @WorkCenterCode='VVT_F4')
					--BEGIN
					--  --   RAISERROR(N'Mã lot chưa đươc xuất ra CellLine vấn đang ở trong kho',16,1);
					--	 --RETURN;
					--END
					
					--select @TargetMaterialWarehouseCode=TargetMaterialWarehouseCode,@WarehouseInOutCode=WarehouseInOutCode from STB_MaterialWarehouseInOutHist
					--where LotID=@RawMaterialBarcode

					SELECT @TargetMaterialWarehouseCode = MaterialWarehouseCode
					  FROM STB_MaterialLotInfo
					 WHERE LotID = @RawMaterialBarcode

					SELECT @IsRouteWarehouse = IsRouteWarehouse
					  FROM STB_MaterialWarehouse
					 WHERE MaterialWarehouseCode = @TargetMaterialWarehouseCode
				
					

					if(@WorkCenterCode='VVT_F4' and @IsRouteWarehouse <> CONVERT(BIT, 1))
					BEGIN
					   RAISERROR(N'Mã lot này kho chưa được xuất là CellLine từ bên kho NVL.Vui lòng kiểm tra lại. ',16,1);
					   RETURN;
					END
					/*
					  Author: Mr.Triều
					  CreateDate: 2026-05-19
					  Description: The entire raw material was blocked, and the IQC inspection rejected it, but it was still imported.
					*/
					SELECT @DecisionResult=DecisionResult from STB_MaterialWarehouseInOutHist WHIH
					LEFT JOIN STB_MaterialDocLotInfo MDL WITH(NOLOCK) ON WHIH.LotID=MDL.LotID
					LEFT JOIN STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo=MDL.MaterialDocDetailNo
					LEFT JOIN STB_MaterialQcInfo MQI WITH(NOLOCK) ON MQI.MaterialQcNo=MDD.MaterialIqcNo
					where MDL.LotID=@RawMaterialBarcode;
					if(@DecisionResult='Reject')
					BEGIN
					     RAISERROR(N'Mã lot này thuộc lô hàng bên IQC đánh Reject. Vui lòng xác nhận lại. ',16,1);
					     RETURN;
					END
					/*
					   Author:Mr.Triều
					   CreateDate:2026-06-10
					   Desc: Prevent input raw material other with BOM PCBA(Version 1005)
					*/
					EXEC usp_RawMaterialInputHist_CheckLabelBOM 
				          @pBarcode = @Barcode,
				          @pProductGroupCode = @ProductGroupCode,
				          @pRawMaterialBarcode = @RawMaterialBarcode

				print '1'
				print '2'

						UPDATE STB_RawMaterialInputHist
						      SET
									RawMaterialInputHistNo =   ISNULL(@RawMaterialInputHistNo,RawMaterialInputHistNo),
									Barcode =   ISNULL(@Barcode,Barcode),
									ProductGroupCode =   CASE WHEN ISNULL(@ProductGroupCode,ProductGroupCode) = 'PWB173670' THEN 'PWB164180' ELSE ISNULL(@ProductGroupCode,ProductGroupCode) END,
									RawMaterialBarcode =   ISNULL(@RawMaterialBarcode,RawMaterialBarcode),
									CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
									CreateUserID =   ISNULL(@pProcessUserID,CreateUserID),
									ChangeDateTime = GETDATE(),
									ChangeUserID = @pProcessUserID,
									WeekCode = @WeekCode,
									Grade = @Grade
						WHERE
						    RawMaterialInputHistNo = @OldRawMaterialInputHistNo

					Print '3'

						EXEC RawMaterialBarcodeSplitByNo @RawMaterialInputHistNo;

					print '4'
					END ELSE IF @RawMaterialBarcode <> @OldRawMaterialBarcode

					    BEGIN -- RawMaterial 값이 변했으면 Insert

						IF @IsAutoKey = 1 BEGIN
							EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_RawMaterialInputHist',@RawMaterialInputHistNo OUTPUT
						END
					/*
					 Author: Mr.Triều
					 CreateDate: 2026-05-19
					 Description: Prevent the release of raw materials that have not yet been released from the warehouse, and that warehouse must be for production.
					*/
					
					select @count1=count(*) from STB_MaterialWarehouseInOutHist
					where LotID=@RawMaterialBarcode
					-- Kiểm tra xem nó đã đuọc xuất kho hay chưa
					--if(@count1=0 and @WorkCenterCode='VVT_F4')
					--BEGIN
					--  --   RAISERROR(N'Mã lot chưa đươc xuất ra CellLine vấn đang ở trong kho',16,1);
					--	 --RETURN;
					--END
					
					select @TargetMaterialWarehouseCode=TargetMaterialWarehouseCode,@WarehouseInOutCode=WarehouseInOutCode from STB_MaterialWarehouseInOutHist
					where LotID=@RawMaterialBarcode
					
					

					if(@WorkCenterCode='VVT_F4' and @TargetMaterialWarehouseCode not in ('ROUTE_BG2_WH') and @WarehouseInOutCode='O')
					BEGIN
					   RAISERROR(N'Mã lot này kho chưa được xuất là CellLine từ bên kho NVL.Vui lòng kiểm tra lại. ',16,1);
					   RETURN;
					END
					/*
					  Author: Mr.Triều
					  CreateDate: 2026-05-19
					  Description: The entire raw material was blocked, and the IQC inspection rejected it, but it was still imported.
					*/
					SELECT @DecisionResult=DecisionResult from STB_MaterialWarehouseInOutHist WHIH
					LEFT JOIN STB_MaterialDocLotInfo MDL WITH(NOLOCK) ON WHIH.LotID=MDL.LotID
					LEFT JOIN STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo=MDL.MaterialDocDetailNo
					LEFT JOIN STB_MaterialQcInfo MQI WITH(NOLOCK) ON MQI.MaterialQcNo=MDD.MaterialIqcNo
					where MDL.LotID=@RawMaterialBarcode;
					if(@DecisionResult='Reject')
					BEGIN
					     RAISERROR(N'Mã lot này thuộc lô hàng bên IQC đánh Reject. Vui lòng xác nhận lại. ',16,1);
					     RETURN;
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
								ChangeUserID,
								WeekCode,
								Grade,
								RouteCode,
								MaterialCode
							)
							VALUES
							(
								@RawMaterialInputHistNo,
								@Barcode,
								CASE WHEN @ProductGroupCode = 'PWB173670' THEN 'PWB164180' ELSE @ProductGroupCode END,
								@RawMaterialBarcode,
								GETDATE(),
								@pProcessUserID,
								--Nghi ngờ sai time: Time lấy từ client
								GETDATE(),
								@ChangeUserID,
								@WeekCode,
								@Grade,
								@RouteCode,
								@MaterialCode
							)
					END ELSE BEGIN
						UPDATE STB_RawMaterialInputHist
						      SET
									RawMaterialInputHistNo =   ISNULL(@RawMaterialInputHistNo,RawMaterialInputHistNo),
									Barcode =   ISNULL(@Barcode,Barcode),
									ProductGroupCode =   CASE WHEN ISNULL(@ProductGroupCode,ProductGroupCode) = 'PWB173670' THEN 'PWB164180' ELSE ISNULL(@ProductGroupCode,ProductGroupCode) END,
									RawMaterialBarcode =   ISNULL(@RawMaterialBarcode,RawMaterialBarcode),
									CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
									CreateUserID =   ISNULL(@pProcessUserID,CreateUserID),
									ChangeDateTime = GETDATE(),
									ChangeUserID = @pProcessUserID,
									WeekCode = @WeekCode,
									Grade = @Grade
						WHERE
						    RawMaterialInputHistNo = @OldRawMaterialInputHistNo

						EXEC RawMaterialBarcodeSplitByNo @RawMaterialInputHistNo;
					END

				EXEC RawMaterialBarcodeSplitByNo @RawMaterialInputHistNo;

--------------  [Update부분 Start]  ------------------------------------------------            22222
                PRINT '1'
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

PRINT '2'
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
PRINT '3'
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
							
									/*

									DECLARE @IsValid BIT = 0;
									DECLARE @InputMaterialCode VARCHAR(50);
									DECLARE @InputRevision VARCHAR(20);

									-- ① 투입 자재 정보 조회
									SELECT TOP 1
										@InputMaterialCode = MDLI.MaterialCode,
										@InputRevision = MDD.RevisionsVer
									FROM STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
									INNER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)
										ON MDD.MaterialDocDetailNo = MDLI.MaterialDocDetailNo
									WHERE MDLI.LotID = @RawMaterialBarcode;

									-- ② BomDetail_Revision에 등록된 품목인지 확인
									IF EXISTS (
										SELECT 1 FROM STB_BomDetail_Revision BDR WITH(NOLOCK)
										WHERE BDR.MaterialCode = @MotherCode
										  AND BDR.BomVersion = @BomVersion
										  AND BDR.ChildMaterialCode = @InputMaterialCode
									)
									BEGIN
										--────────────────────────────────────
										-- 리비전 관리 대상 품목
										--────────────────────────────────────

										-- ③-A: 직접 매칭 (품목 + 리비전 일치)
										IF EXISTS (
											SELECT 1 FROM STB_BomDetail_Revision BDR WITH(NOLOCK)
											WHERE BDR.MaterialCode = @MotherCode
											  AND BDR.BomVersion = @BomVersion
											  AND BDR.ChildMaterialCode = @InputMaterialCode
											  AND BDR.ChildRevision = @InputRevision
											  AND BDR.ValidFrom <= GETDATE()
											  AND BDR.ValidTo >= GETDATE()
										)
										BEGIN
											SET @IsValid = 1;  -- 리비전 일치 → 통과
										END
										ELSE
										BEGIN
											-- ③-B: 직접 리비전 불일치 → 대체자재로 등록되어 있는지 확인
											IF EXISTS (
												SELECT 1
												FROM STB_MaterialMaster MM WITH(NOLOCK)
												WHERE MM.MaterialCode = @InputMaterialCode
												  AND MM.DelegateMaterialCode IS NOT NULL
												  AND EXISTS (
													  SELECT 1 FROM STB_BomDetail BD WITH(NOLOCK)
													  WHERE BD.MaterialCode = @MotherCode
														AND BD.BomVersion = @BomVersion
														AND BD.ChildMaterialCode = MM.DelegateMaterialCode
												  )
												  AND (MM.DelegateMaterialRevision IS NULL
													   OR MM.DelegateMaterialRevision = @InputRevision)
											)
											BEGIN
												SET @IsValid = 1;  -- 대체자재로 통과
											END
										END
									END
									ELSE
									BEGIN
										--────────────────────────────────────
										-- 리비전 관리 비대상 품목
										--────────────────────────────────────

										-- ④-A: BOM에 직접 있으면 → 리비전 체크 없이 통과
										IF EXISTS (
											SELECT 1 FROM STB_BomDetail BD WITH(NOLOCK)
											WHERE BD.MaterialCode = @MotherCode
											  AND BD.BomVersion = @BomVersion
											  AND BD.ChildMaterialCode = @InputMaterialCode
										)
										BEGIN
											SET @IsValid = 1;
										END
										ELSE
										BEGIN
											-- ④-B: BOM에 없으면 → 대체자재 확인
											IF EXISTS (
												SELECT 1
												FROM STB_MaterialMaster MM WITH(NOLOCK)
												WHERE MM.MaterialCode = @InputMaterialCode
												  AND MM.DelegateMaterialCode IS NOT NULL
												  AND (MM.DelegateMaterialRevision IS NULL
													   OR MM.DelegateMaterialRevision = @InputRevision)
											)
											BEGIN
												SET @IsValid = 1;
											END
										END
									END

									-- 결과: @IsValid = 1 → 투입 가능, 0 → 투입 불가

									

									-- 결과 판정
									IF @IsValid = 0
									BEGIN
										DECLARE @ErrMsg NVARCHAR(500);
										SET @ErrMsg = N'리비전 불일치로 투입이 불가합니다. '
													+ N'투입자재: ' + ISNULL(@InputMaterialCode, '') 
													+ N' / Rev: ' + ISNULL(@InputRevision, 'NULL')
													+ N' (모품목: ' + ISNULL(@MotherCode, '') 
													+ N', BOM: ' + ISNULL(@BomVersion, '') + N')';
    
										RAISERROR(@ErrMsg, 16, 1);
										RETURN;
									END
									*/
							END

					-- 5. 원자재 투입 자재의 BOM 체크 END



--------------  [Update부분 End] 
PRINT '4'
                END ELSE IF @IUD_FLAG = 'DELETE' 
				
				BEGIN

                    DELETE FROM STB_RawMaterialInputHist
						WHERE
						    RawMaterialInputHistNo = @OldRawMaterialInputHistNo
                END
            END

			--IF @WorkCenterCode = 'VVT_F4' AND @UpdateCnt <> @RawMaterialListCnt BEGIN
			--	EXEC usp_RaiseLocalizedError @pProcessLanguage, '입력이 누락된 원자재가 있습니다.'
			--	RETURN
			--END
PRINT '5'
        END TRY

		BEGIN CATCH
		PRINT '6'
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	

    END

END
