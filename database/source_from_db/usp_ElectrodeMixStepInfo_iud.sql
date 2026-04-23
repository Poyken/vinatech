
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-25
-- Browsable : true
-- Group : 생산관리
-- Description:	전극믹싱단계정보
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeMixStepInfo_iud]
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
  DECLARE @OldElectrodeLotNumber VARCHAR(20)
  DECLARE @OldElectrodeStep VARCHAR(10)
  DECLARE @OldSeq INT
  DECLARE @ElectrodeLotNumber VARCHAR(20)
  DECLARE @ElectrodeStep VARCHAR(10)
  DECLARE @Seq INT
  DECLARE @ElectrodeMaterialCode VARCHAR(20)
  DECLARE @InputQty1 NUMERIC(20,5)
  DECLARE @InputQty2 NUMERIC(20,5)
  DECLARE @MaterialLotNumber VARCHAR(20)
  DECLARE @BinderInputTime DATETIMEOFFSET
  DECLARE @BinderOutputTime DATETIMEOFFSET
  DECLARE @MixingInputTime DATETIMEOFFSET
  DECLARE @MixingOutputTime DATETIMEOFFSET
  DECLARE @SpecInOut VARCHAR(5)
  DECLARE @SpecOutQty NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeMixStepInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeMixStepInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldElectrodeStep IS NULL THEN ElectrodeStep
							    ELSE OldElectrodeStep
							END AS OldElectrodeStep,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							ElectrodeStep,
							Seq,
							ElectrodeMaterialCode,
							InputQty1,
							InputQty2,
							MaterialLotNumber,
							BinderInputTime,
							BinderOutputTime,
							MixingInputTime,
							MixingOutputTime,
							SpecInOut,
							SpecOutQty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldElectrodeStep VARCHAR(10),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										ElectrodeStep VARCHAR(10),
										Seq INT,
										ElectrodeMaterialCode VARCHAR(20),
										InputQty1 NUMERIC(20,5),
										InputQty2 NUMERIC(20,5),
										MaterialLotNumber VARCHAR(20),
										BinderInputTime DATETIMEOFFSET,
										BinderOutputTime DATETIMEOFFSET,
										MixingInputTime DATETIMEOFFSET,
										MixingOutputTime DATETIMEOFFSET,
										SpecInOut VARCHAR(5),
										SpecOutQty NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.ElectrodeStep = SourceTable.ElectrodeStep AND
					TargetTable.Seq = SourceTable.Seq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					ElectrodeStep = ISNULL(SourceTable.ElectrodeStep,TargetTable.ElectrodeStep),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					ElectrodeMaterialCode = ISNULL(SourceTable.ElectrodeMaterialCode,TargetTable.ElectrodeMaterialCode),
					InputQty1 = ISNULL(SourceTable.InputQty1,TargetTable.InputQty1),
					InputQty2 = ISNULL(SourceTable.InputQty2,TargetTable.InputQty2),
					MaterialLotNumber = ISNULL(SourceTable.MaterialLotNumber,TargetTable.MaterialLotNumber),
					BinderInputTime = ISNULL(SourceTable.BinderInputTime,TargetTable.BinderInputTime),
					BinderOutputTime = ISNULL(SourceTable.BinderOutputTime,TargetTable.BinderOutputTime),
					MixingInputTime = ISNULL(SourceTable.MixingInputTime,TargetTable.MixingInputTime),
					MixingOutputTime = ISNULL(SourceTable.MixingOutputTime,TargetTable.MixingOutputTime),
					SpecInOut = ISNULL(SourceTable.SpecInOut,TargetTable.SpecInOut),
					SpecOutQty = ISNULL(SourceTable.SpecOutQty,TargetTable.SpecOutQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						ElectrodeStep,
						Seq,
						ElectrodeMaterialCode,
						InputQty1,
						InputQty2,
						MaterialLotNumber,
						BinderInputTime,
						BinderOutputTime,
						MixingInputTime,
						MixingOutputTime,
						SpecInOut,
						SpecOutQty,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.ElectrodeStep,
							SourceTable.Seq,
							SourceTable.ElectrodeMaterialCode,
							SourceTable.InputQty1,
							SourceTable.InputQty2,
							SourceTable.MaterialLotNumber,
							SourceTable.BinderInputTime,
							SourceTable.BinderOutputTime,
							SourceTable.MixingInputTime,
							SourceTable.MixingOutputTime,
							SourceTable.SpecInOut,
							SourceTable.SpecOutQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ElectrodeMixStepInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldElectrodeStep IS NULL THEN ElectrodeStep
							    ELSE OldElectrodeStep
							END AS OldElectrodeStep,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							ElectrodeStep,
							Seq,
							ElectrodeMaterialCode,
							InputQty1,
							InputQty2,
							MaterialLotNumber,
							BinderInputTime,
							BinderOutputTime,
							MixingInputTime,
							MixingOutputTime,
							SpecInOut,
							SpecOutQty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldElectrodeStep VARCHAR(10),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										ElectrodeStep VARCHAR(10),
										Seq INT,
										ElectrodeMaterialCode VARCHAR(20),
										InputQty1 NUMERIC(20,5),
										InputQty2 NUMERIC(20,5),
										MaterialLotNumber VARCHAR(20),
										BinderInputTime DATETIMEOFFSET,
										BinderOutputTime DATETIMEOFFSET,
										MixingInputTime DATETIMEOFFSET,
										MixingOutputTime DATETIMEOFFSET,
										SpecInOut VARCHAR(5),
										SpecOutQty NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.OldElectrodeLotNumber AND
					TargetTable.ElectrodeStep = SourceTable.OldElectrodeStep AND
					TargetTable.Seq = SourceTable.OldSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					ElectrodeStep = ISNULL(SourceTable.ElectrodeStep,TargetTable.ElectrodeStep),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					ElectrodeMaterialCode = ISNULL(SourceTable.ElectrodeMaterialCode,TargetTable.ElectrodeMaterialCode),
					InputQty1 = ISNULL(SourceTable.InputQty1,TargetTable.InputQty1),
					InputQty2 = ISNULL(SourceTable.InputQty2,TargetTable.InputQty2),
					MaterialLotNumber = ISNULL(SourceTable.MaterialLotNumber,TargetTable.MaterialLotNumber),
					BinderInputTime = ISNULL(SourceTable.BinderInputTime,TargetTable.BinderInputTime),
					BinderOutputTime = ISNULL(SourceTable.BinderOutputTime,TargetTable.BinderOutputTime),
					MixingInputTime = ISNULL(SourceTable.MixingInputTime,TargetTable.MixingInputTime),
					MixingOutputTime = ISNULL(SourceTable.MixingOutputTime,TargetTable.MixingOutputTime),
					SpecInOut = ISNULL(SourceTable.SpecInOut,TargetTable.SpecInOut),
					SpecOutQty = ISNULL(SourceTable.SpecOutQty,TargetTable.SpecOutQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						ElectrodeStep,
						Seq,
						ElectrodeMaterialCode,
						InputQty1,
						InputQty2,
						MaterialLotNumber,
						BinderInputTime,
						BinderOutputTime,
						MixingInputTime,
						MixingOutputTime,
						SpecInOut,
						SpecOutQty,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.ElectrodeStep,
							SourceTable.Seq,
							SourceTable.ElectrodeMaterialCode,
							SourceTable.InputQty1,
							SourceTable.InputQty2,
							SourceTable.MaterialLotNumber,
							SourceTable.BinderInputTime,
							SourceTable.BinderOutputTime,
							SourceTable.MixingInputTime,
							SourceTable.MixingOutputTime,
							SourceTable.SpecInOut,
							SourceTable.SpecOutQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ElectrodeMixStepInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldElectrodeStep IS NULL THEN ElectrodeStep
							    ELSE OldElectrodeStep
							END AS OldElectrodeStep,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							ElectrodeStep,
							Seq,
							ElectrodeMaterialCode,
							InputQty1,
							InputQty2,
							MaterialLotNumber,
							BinderInputTime,
							BinderOutputTime,
							MixingInputTime,
							MixingOutputTime,
							SpecInOut,
							SpecOutQty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldElectrodeStep VARCHAR(10),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										ElectrodeStep VARCHAR(10),
										Seq INT,
										ElectrodeMaterialCode VARCHAR(20),
										InputQty1 NUMERIC(20,5),
										InputQty2 NUMERIC(20,5),
										MaterialLotNumber VARCHAR(20),
										BinderInputTime DATETIMEOFFSET,
										BinderOutputTime DATETIMEOFFSET,
										MixingInputTime DATETIMEOFFSET,
										MixingOutputTime DATETIMEOFFSET,
										SpecInOut VARCHAR(1),
										SpecOutQty NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.ElectrodeStep = SourceTable.ElectrodeStep AND
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
									OldElectrodeStep,
									OldSeq,
									ElectrodeLotNumber,
									ElectrodeStep,
									Seq,
									ElectrodeMaterialCode,
									InputQty1,
									InputQty2,
									MaterialLotNumber,
									BinderInputTime,
									BinderOutputTime,
									MixingInputTime,
									MixingOutputTime,
									SpecInOut,
									SpecOutQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldElectrodeStep VARCHAR(10),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 ElectrodeStep VARCHAR(10),
											 Seq INT,
											 ElectrodeMaterialCode VARCHAR(20),
											 InputQty1 NUMERIC(20,5),
											 InputQty2 NUMERIC(20,5),
											 MaterialLotNumber VARCHAR(20),
											 BinderInputTime DATETIMEOFFSET,
											 BinderOutputTime DATETIMEOFFSET,
											 MixingInputTime DATETIMEOFFSET,
											 MixingOutputTime DATETIMEOFFSET,
											 SpecInOut VARCHAR(5),
											 SpecOutQty NUMERIC(20,5),
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
										WHEN OldElectrodeStep IS NULL THEN ElectrodeStep
										ELSE OldElectrodeStep
									END AS OldElectrodeStep,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ElectrodeLotNumber,
									ElectrodeStep,
									Seq,
									ElectrodeMaterialCode,
									InputQty1,
									InputQty2,
									MaterialLotNumber,
									BinderInputTime,
									BinderOutputTime,
									MixingInputTime,
									MixingOutputTime,
									SpecInOut,
									SpecOutQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldElectrodeStep VARCHAR(10),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 ElectrodeStep VARCHAR(10),
											 Seq INT,
											 ElectrodeMaterialCode VARCHAR(20),
											 InputQty1 NUMERIC(20,5),
											 InputQty2 NUMERIC(20,5),
											 MaterialLotNumber VARCHAR(20),
											 BinderInputTime DATETIMEOFFSET,
											 BinderOutputTime DATETIMEOFFSET,
											 MixingInputTime DATETIMEOFFSET,
											 MixingOutputTime DATETIMEOFFSET,
											 SpecInOut VARCHAR(5),
											 SpecOutQty NUMERIC(20,5),
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
										WHEN OldElectrodeStep IS NULL THEN ElectrodeStep
										ELSE OldElectrodeStep
									END AS OldElectrodeStep,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ElectrodeLotNumber,
									ElectrodeStep,
									Seq,
									ElectrodeMaterialCode,
									InputQty1,
									InputQty2,
									MaterialLotNumber,
									BinderInputTime,
									BinderOutputTime,
									MixingInputTime,
									MixingOutputTime,
									SpecInOut,
									SpecOutQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldElectrodeStep VARCHAR(10),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 ElectrodeStep VARCHAR(10),
											 Seq INT,
											 ElectrodeMaterialCode VARCHAR(20),
											 InputQty1 NUMERIC(20,5),
											 InputQty2 NUMERIC(20,5),
											 MaterialLotNumber VARCHAR(20),
											 BinderInputTime DATETIMEOFFSET,
											 BinderOutputTime DATETIMEOFFSET,
											 MixingInputTime DATETIMEOFFSET,
											 MixingOutputTime DATETIMEOFFSET,
											 SpecInOut VARCHAR(5),
											 SpecOutQty NUMERIC(20,5),
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
								 @OldElectrodeStep,
								 @OldSeq,
								 @ElectrodeLotNumber,
								 @ElectrodeStep,
								 @Seq,
								 @ElectrodeMaterialCode,
								 @InputQty1,
								 @InputQty2,
								 @MaterialLotNumber,
								 @BinderInputTime,
								 @BinderOutputTime,
								 @MixingInputTime,
								 @MixingOutputTime,
								 @SpecInOut,
								 @SpecOutQty,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID



			
					


				--Declare @company varchar(20)='';
--select * 
--from STB_UserInfo 
--where UserID=@pProcessUserID and CompanyCode='VVT' ;

if(@pProcessUserID='nguyentung' /*or @@ROWCOUNT>0 and @ElectrodeMaterialCode like '%GAKCCA-00%'*/) begin 

raiserror('nguyentung',16,1)  WITH NOWAIT;
break;
				return;

			select * from 
			STB_MaterialLotInfo
			where MaterialCode=replace(@ElectrodeMaterialCode,'VJJ','')
			and MaterialWarehouseCode like 'ROH%WH'
			and Lotid=@MaterialLotNumber

			if(@@ROWCOUNT=0 ) begin 
				raiserror('Ma LotID cua Kho khong dung voi Nguyen Lieu Dien Cuc thiet lap!',16,1)  WITH NOWAIT;
				break;
				return;
			end
end 



                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END



                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeMixStepInfo WHERE ElectrodeLotNumber = @ElectrodeLotNumber AND ElectrodeStep = @ElectrodeStep AND Seq = @Seq) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeLotNumber)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeMixStepInfo',@ElectrodeLotNumber OUTPUT
                    END
	

                    INSERT INTO STB_ElectrodeMixStepInfo
						(
						    ElectrodeLotNumber,
						    ElectrodeStep,
						    Seq,
						    ElectrodeMaterialCode,
						    InputQty1,
						    InputQty2,
						    MaterialLotNumber,
						    BinderInputTime,
						    BinderOutputTime,
						    MixingInputTime,
						    MixingOutputTime,
						    SpecInOut,
						    SpecOutQty,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ElectrodeLotNumber,
						    @ElectrodeStep,
						    @Seq,
						    @ElectrodeMaterialCode,
						    @InputQty1,
						    @InputQty2,
						    @MaterialLotNumber,
						    @BinderInputTime,
						    @BinderOutputTime,
						    @MixingInputTime,
						    @MixingOutputTime,
						    @SpecInOut,
						    @SpecOutQty,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN


                    UPDATE STB_ElectrodeMixStepInfo
						SET
						    ElectrodeLotNumber =   ISNULL(@ElectrodeLotNumber,ElectrodeLotNumber),
						    ElectrodeStep =   ISNULL(@ElectrodeStep,ElectrodeStep),
						    Seq =   ISNULL(@Seq,Seq),
						    ElectrodeMaterialCode =   ISNULL(@ElectrodeMaterialCode,ElectrodeMaterialCode),
						    InputQty1 =   ISNULL(@InputQty1,InputQty1),
						    InputQty2 =   ISNULL(@InputQty2,InputQty2),
						    MaterialLotNumber =   ISNULL(@MaterialLotNumber,MaterialLotNumber),
						    BinderInputTime =   ISNULL(@BinderInputTime,BinderInputTime),
						    BinderOutputTime =   ISNULL(@BinderOutputTime,BinderOutputTime),
						    MixingInputTime =   ISNULL(@MixingInputTime,MixingInputTime),
						    MixingOutputTime =   ISNULL(@MixingOutputTime,MixingOutputTime),
						    SpecInOut =   ISNULL(@SpecInOut,SpecInOut),
						    SpecOutQty =   ISNULL(@SpecOutQty,SpecOutQty),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber AND
						    ElectrodeStep = @OldElectrodeStep AND
						    Seq = @OldSeq
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeMixStepInfo
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber AND
						    ElectrodeStep = @OldElectrodeStep AND
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
