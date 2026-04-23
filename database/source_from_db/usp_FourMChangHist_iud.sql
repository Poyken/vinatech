
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-02-18
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_FourMChangHist_iud]
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
  DECLARE @OldLotNo VARCHAR(18)  --2021.05.26 추가
  DECLARE @OldMaterialCode VARCHAR(50)
  DECLARE @OldMachineCode VARCHAR(20)
  DECLARE @TimeCode VARCHAR(2)
  DECLARE @ProdUserID VARCHAR(20)
  DECLARE @Approver VARCHAR(20)
  DECLARE @LotNo VARCHAR(18)
   DECLARE @LotNo2 VARCHAR(18)     -- 2021.04.09 추가
    DECLARE @LotNo3 VARCHAR(18)    -- 2021.04.09 추가
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @ChangesReasons VARCHAR(1000)
  DECLARE @DetailContent VARCHAR(1000)
  DECLARE @ItemCode Varchar(1)
  DECLARE @Inspector VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
   DECLARE @Unusual VARCHAR(100) 


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_FourMChangHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_FourMChangHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLotNo IS NULL THEN LotNo
							    ELSE OldLotNo
							END AS OldLotNo,

							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,

							CASE
							    WHEN OldMachineCode IS NULL THEN MachineCode
							    ELSE OldMachineCode
							END AS OldMachineCode,
							TimeCode,
							ProdUserID,
							Approver,
							LotNo,
							LotNo2,
							LotNo3,
							MaterialCode,
							MachineCode,
							ChangesReasons,
							DetailContent,
							ItemCode,
							Inspector,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Unusual
					FROM
							OPENXML(@idoc , @InsertTableName , 3)
							WITH  (
							           OldLotNo VARCHAR(18),
										OldMaterialCode VARCHAR(50),
										OldMachineCode VARCHAR(20),
										TimeCode VARCHAR(2),
										ProdUserID VARCHAR(20),
										Approver VARCHAR(20),
										LotNo VARCHAR(18),
										LotNo2 VARCHAR(18),
										LotNo3 VARCHAR(18),
										MaterialCode VARCHAR(50),
										MachineCode VARCHAR(20),
										ChangesReasons VARCHAR(1000),
										DetailContent VARCHAR(1000),
										ItemCode Varchar(1),
										Inspector VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Unusual VARCHAR(100)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.MachineCode = SourceTable.MachineCode AND
					TargetTable.LotNo = SourceTable.LotNo 
				)

			WHEN MATCHED THEN
				UPDATE SET
					TimeCode = ISNULL(SourceTable.TimeCode,TargetTable.TimeCode),
					ProdUserID = ISNULL(SourceTable.ProdUserID,TargetTable.ProdUserID),
					Approver = ISNULL(SourceTable.Approver,TargetTable.Approver),
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					LotNo2 = ISNULL(SourceTable.LotNo2,TargetTable.LotNo2),
					LotNo3 = ISNULL(SourceTable.LotNo3,TargetTable.LotNo3),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					ChangesReasons = ISNULL(SourceTable.ChangesReasons,TargetTable.ChangesReasons),
					DetailContent = ISNULL(SourceTable.DetailContent,TargetTable.DetailContent),
					ItemCode = ISNULL(SourceTable.ItemCode,TargetTable.ItemCode),
					Inspector = ISNULL(SourceTable.Inspector,TargetTable.Inspector),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					Unusual = ISNULL(SourceTable.Unusual,TargetTable.Unusual)
			WHEN NOT MATCHED THEN
				INSERT
					(
						TimeCode,
						ProdUserID,
						Approver,
						LotNo,
						LotNo2,
						LotNo3,
						MaterialCode,
						MachineCode,
						ChangesReasons,
						DetailContent,
						ItemCode,
						Inspector,
						CreateDateTime,
						CreateUserID,
						Unusual
					)
				VALUES
					(
							SourceTable.TimeCode,
							SourceTable.ProdUserID,
							SourceTable.Approver,
							SourceTable.LotNo,
							SourceTable.LotNo2,
							SourceTable.LotNo3,
							SourceTable.MaterialCode,
							SourceTable.MachineCode,
							SourceTable.ChangesReasons,
							SourceTable.DetailContent,
							SourceTable.ItemCode,
							SourceTable.Inspector,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.Unusual
					);


			-- Process Update Table
            MERGE STB_FourMChangHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,

							CASE
							    WHEN OldMachineCode IS NULL THEN MachineCode
							    ELSE OldMachineCode
							END AS OldMachineCode,

							CASE
							    WHEN OldLotNo IS NULL THEN LotNo
							    ELSE OldLotNo
							END AS OldLotNo,

							TimeCode,
							ProdUserID,
							Approver,
							LotNo,
							LotNo2,
							LotNo3,
							MaterialCode,
							MachineCode,
							ChangesReasons,
							DetailContent,
							ItemCode,
							Inspector,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Unusual
					FROM
							OPENXML(@idoc , @UpdateTableName , 3)
							WITH  (
							            OldLotNo VARCHAR(18),
										OldMaterialCode VARCHAR(50),
										OldMachineCode VARCHAR(20),

										TimeCode VARCHAR(2),
										ProdUserID VARCHAR(20),
										Approver VARCHAR(20),
										LotNo VARCHAR(18),
										LotNo2 VARCHAR(18),
										LotNo3 VARCHAR(18),
										MaterialCode VARCHAR(50),
										MachineCode VARCHAR(20),
										ChangesReasons VARCHAR(1000),
										DetailContent VARCHAR(1000),
										ItemCode Varchar(1),
										Inspector VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Unusual VARCHAR(100)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.OldMaterialCode AND
					TargetTable.MachineCode = SourceTable.OldMachineCode AND
					TargetTable.LotNo = SourceTable.OldLotNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					TimeCode = ISNULL(SourceTable.TimeCode,TargetTable.TimeCode),
					ProdUserID = ISNULL(SourceTable.ProdUserID,TargetTable.ProdUserID),
					Approver = ISNULL(SourceTable.Approver,TargetTable.Approver),
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					LotNo2 = ISNULL(SourceTable.LotNo2,TargetTable.LotNo2),
					LotNo3 = ISNULL(SourceTable.LotNo3,TargetTable.LotNo3),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					ChangesReasons = ISNULL(SourceTable.ChangesReasons,TargetTable.ChangesReasons),
					DetailContent = ISNULL(SourceTable.DetailContent,TargetTable.DetailContent),
					ItemCode = ISNULL(SourceTable.ItemCode,TargetTable.ItemCode),
					Inspector = ISNULL(SourceTable.Inspector,TargetTable.Inspector),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					Unusual = ISNULL(SourceTable.Unusual,TargetTable.Unusual)
			WHEN NOT MATCHED THEN
				INSERT
					(
						TimeCode,
						ProdUserID,
						Approver,
						LotNo,
						LotNo2,
						LotNo3,
						MaterialCode,
						MachineCode,
						ChangesReasons,
						DetailContent,
						ItemCode,
						Inspector,
						CreateDateTime,
						CreateUserID,
						Unusual
					)
				VALUES
					(
							SourceTable.TimeCode,
							SourceTable.ProdUserID,
							SourceTable.Approver,
							SourceTable.LotNo,
							SourceTable.LotNo2,
							SourceTable.LotNo3,
							SourceTable.MaterialCode,
							SourceTable.MachineCode,
							SourceTable.ChangesReasons,
							SourceTable.DetailContent,
							SourceTable.ItemCode,
							SourceTable.Inspector,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.Unusual
					);


			-- Process Delete Table
            MERGE STB_FourMChangHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,

							CASE
							    WHEN OldMachineCode IS NULL THEN MachineCode
							    ELSE OldMachineCode
							END AS OldMachineCode,

							CASE
							    WHEN OldLotNo IS NULL THEN LotNo
							    ELSE OldLotNo
							END AS OldLotNo,

							MaterialCode,
							MachineCode,
							LotNo
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										
										OldMaterialCode VARCHAR(50),
										OldMachineCode VARCHAR(20),
										OldLotNo VARCHAR(18),
										MaterialCode VARCHAR(50),
										MachineCode VARCHAR(20),
										LotNo VARCHAR(18)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.MachineCode = SourceTable.MachineCode AND
					TargetTable.LotNo = SourceTable.LotNo
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
        PRINT 'Loop was removed'
    END
END
