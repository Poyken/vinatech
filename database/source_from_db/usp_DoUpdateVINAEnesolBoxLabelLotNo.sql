
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-09-27
-- Browsable : true
-- Group : 비나에너솔
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateVINAEnesolBoxLabelLotNo]
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
  DECLARE @OldVINAEnesolBoxLabelPrintHistNo VARCHAR(20)
  DECLARE @VINAEnesolBoxLabelPrintHistNo VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @ProdDate DATE
  DECLARE @ProdWeek VARCHAR(50)
  DECLARE @LastLotNo VARCHAR(50)
  DECLARE @ProdMachineCode VARCHAR(50)
  DECLARE @ProdLocationCode VARCHAR(50)
  DECLARE @PackingQty INT
  DECLARE @LabelQty INT
  DECLARE @CustomerPartNo VARCHAR(50)
  DECLARE @LotNo VARCHAR(10)
  DECLARE @LabelClassCode VARCHAR(20)
  DECLARE @ModelSpec VARCHAR(50)
  DECLARE @SerialNo VARCHAR(3)
  DECLARE @Barcode VARCHAR(50)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VINAEnesolBoxLabelPrintHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        RAISERROR( 'Batch was removed' ,16, 1)
		PRINT 'Batch was removed'
    END ELSE BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldVINAEnesolBoxLabelPrintHistNo,
									VINAEnesolBoxLabelPrintHistNo,
									MaterialCode,
									ProdDate,
									ProdWeek,
									LastLotNo,
									ProdMachineCode,
									ProdLocationCode,
									PackingQty,
									LabelQty,
									CustomerPartNo,
									LotNo,
									LabelClassCode,
									ModelSpec,
									SerialNo,
									Barcode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldVINAEnesolBoxLabelPrintHistNo VARCHAR(20),
											 VINAEnesolBoxLabelPrintHistNo VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 ProdDate DATETIMEOFFSET,
											 ProdWeek VARCHAR(50),
											 LastLotNo VARCHAR(50),
											 ProdMachineCode VARCHAR(50),
											 ProdLocationCode VARCHAR(50),
											 PackingQty INT,
											 LabelQty INT,
											 CustomerPartNo VARCHAR(50),
											 LotNo VARCHAR(10),
											 LabelClassCode VARCHAR(20),
											 ModelSpec VARCHAR(50),
											 SerialNo VARCHAR(3),
											 Barcode VARCHAR(50),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldVINAEnesolBoxLabelPrintHistNo IS NULL THEN VINAEnesolBoxLabelPrintHistNo
										ELSE OldVINAEnesolBoxLabelPrintHistNo
									END AS OldVINAEnesolBoxLabelPrintHistNo,
									VINAEnesolBoxLabelPrintHistNo,
									MaterialCode,
									ProdDate,
									ProdWeek,
									LastLotNo,
									ProdMachineCode,
									ProdLocationCode,
									PackingQty,
									LabelQty,
									CustomerPartNo,
									LotNo,
									LabelClassCode,
									ModelSpec,
									SerialNo,
									Barcode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldVINAEnesolBoxLabelPrintHistNo VARCHAR(20),
											 VINAEnesolBoxLabelPrintHistNo VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 ProdDate DATETIMEOFFSET,
											 ProdWeek VARCHAR(50),
											 LastLotNo VARCHAR(50),
											 ProdMachineCode VARCHAR(50),
											 ProdLocationCode VARCHAR(50),
											 PackingQty INT,
											 LabelQty INT,
											 CustomerPartNo VARCHAR(50),
											 LotNo VARCHAR(10),
											 LabelClassCode VARCHAR(20),
											 ModelSpec VARCHAR(50),
											 SerialNo VARCHAR(3),
											 Barcode VARCHAR(50),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldVINAEnesolBoxLabelPrintHistNo IS NULL THEN VINAEnesolBoxLabelPrintHistNo
										ELSE OldVINAEnesolBoxLabelPrintHistNo
									END AS OldVINAEnesolBoxLabelPrintHistNo,
									VINAEnesolBoxLabelPrintHistNo,
									MaterialCode,
									ProdDate,
									ProdWeek,
									LastLotNo,
									ProdMachineCode,
									ProdLocationCode,
									PackingQty,
									LabelQty,
									CustomerPartNo,
									LotNo,
									LabelClassCode,
									ModelSpec,
									SerialNo,
									Barcode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldVINAEnesolBoxLabelPrintHistNo VARCHAR(20),
											 VINAEnesolBoxLabelPrintHistNo VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 ProdDate DATETIMEOFFSET,
											 ProdWeek VARCHAR(50),
											 LastLotNo VARCHAR(50),
											 ProdMachineCode VARCHAR(50),
											 ProdLocationCode VARCHAR(50),
											 PackingQty INT,
											 LabelQty INT,
											 CustomerPartNo VARCHAR(50),
											 LotNo VARCHAR(10),
											 LabelClassCode VARCHAR(20),
											 ModelSpec VARCHAR(50),
											 SerialNo VARCHAR(3),
											 Barcode VARCHAR(50),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldVINAEnesolBoxLabelPrintHistNo,
								 @VINAEnesolBoxLabelPrintHistNo,
								 @MaterialCode,
								 @ProdDate,
								 @ProdWeek,
								 @LastLotNo,
								 @ProdMachineCode,
								 @ProdLocationCode,
								 @PackingQty,
								 @LabelQty,
								 @CustomerPartNo,
								 @LotNo,
								 @LabelClassCode,
								 @ModelSpec,
								 @SerialNo,
								 @Barcode,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VINAEnesolBoxLabelPrintHist WHERE VINAEnesolBoxLabelPrintHistNo = @VINAEnesolBoxLabelPrintHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @VINAEnesolBoxLabelPrintHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_VINAEnesolBoxLabelPrintHist',@VINAEnesolBoxLabelPrintHistNo OUTPUT
                    END

					RAISERROR( @IUD_FLAG ,16, 1)

                    INSERT INTO STB_VINAEnesolBoxLabelPrintHist
						(
						    VINAEnesolBoxLabelPrintHistNo,
						    MaterialCode,
						    ProdDate,
						    ProdWeek,
						    LastLotNo,
						    ProdMachineCode,
						    ProdLocationCode,
						    PackingQty,
						    LabelQty,
						    CustomerPartNo,
						    LotNo,
						    LabelClassCode,
						    ModelSpec,
						    SerialNo,
						    Barcode,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @VINAEnesolBoxLabelPrintHistNo,
						    @MaterialCode,
						    @ProdDate,
						    @ProdWeek,
						    @LastLotNo,
						    @ProdMachineCode,
						    @ProdLocationCode,
						    @PackingQty,
						    @LabelQty,
						    @CustomerPartNo,
						    @LotNo,
						    @LabelClassCode,
						    @ModelSpec,
						    @SerialNo,
						    @Barcode,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_VINAEnesolBoxLabelPrintHist
						SET
						    VINAEnesolBoxLabelPrintHistNo =   ISNULL(@VINAEnesolBoxLabelPrintHistNo,VINAEnesolBoxLabelPrintHistNo),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    ProdDate =   ISNULL(@ProdDate,ProdDate),
						    ProdWeek =   ISNULL(@ProdWeek,ProdWeek),
						    LastLotNo =   ISNULL(@LastLotNo,LastLotNo),
						    ProdMachineCode =   ISNULL(@ProdMachineCode,ProdMachineCode),
						    ProdLocationCode =   ISNULL(@ProdLocationCode,ProdLocationCode),
						    PackingQty =   ISNULL(@PackingQty,PackingQty),
						    LabelQty =   ISNULL(@LabelQty,LabelQty),
						    CustomerPartNo =   ISNULL(@CustomerPartNo,CustomerPartNo),
						    LotNo =   ISNULL(@LotNo,LotNo),
						    LabelClassCode =   ISNULL(@LabelClassCode,LabelClassCode),
						    ModelSpec =   ISNULL(@ModelSpec,ModelSpec),
						    SerialNo =   ISNULL(@SerialNo,SerialNo),
						    Barcode =   ISNULL(@Barcode,Barcode),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    VINAEnesolBoxLabelPrintHistNo = @OldVINAEnesolBoxLabelPrintHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_VINAEnesolBoxLabelPrintHist
						WHERE
						    VINAEnesolBoxLabelPrintHistNo = @OldVINAEnesolBoxLabelPrintHistNo
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
