
-- =============================================
-- Author:	    Kangs (kilee@vina.co.kr)
-- Create date: 2021-04-29
-- Browsable : true
-- Group : 생산관리 > 생산계획
-- Description:	4M변경관리
-- Modified:
-- =============================================
Create PROCEDURE [dbo].[usp_FourMLotNoHist_iud_20210504]
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
  DECLARE @OldLotNo VARCHAR(18)
  DECLARE @LotNo VARCHAR(18)
  DECLARE @Unusual_First VARCHAR(1000)
  DECLARE @LotNo2 VARCHAR(18)
  DECLARE @Unusual_Second VARCHAR(1000)
  DECLARE @LotNo3 VARCHAR(18)
  DECLARE @Unusual_Third VARCHAR(1000)
  DECLARE @CreateDateTime VARCHAR(19)
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime VARCHAR(19)
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_FourMLotNoHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_FourMLotNoHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLotNo IS NULL THEN LotNo
							    ELSE OldLotNo
							END AS OldLotNo,
							LotNo,
							Unusual_First,
							LotNo2,
							Unusual_Second,
							LotNo3,
							Unusual_Third,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldLotNo VARCHAR(18),
										LotNo VARCHAR(18),
										Unusual_First VARCHAR(1000),
										LotNo2 VARCHAR(18),
										Unusual_Second VARCHAR(1000),
										LotNo3 VARCHAR(18),
										Unusual_Third VARCHAR(1000),
										CreateDateTime VARCHAR(19),
										CreateUserID VARCHAR(20),
										ChangeDateTime VARCHAR(19),
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LotNo = SourceTable.LotNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					Unusual_First = ISNULL(SourceTable.Unusual_First,TargetTable.Unusual_First),
					LotNo2 = ISNULL(SourceTable.LotNo2,TargetTable.LotNo2),
					Unusual_Second = ISNULL(SourceTable.Unusual_Second,TargetTable.Unusual_Second),
					LotNo3 = ISNULL(SourceTable.LotNo3,TargetTable.LotNo3),
					Unusual_Third = ISNULL(SourceTable.Unusual_Third,TargetTable.Unusual_Third),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)

				
			


			WHEN NOT MATCHED THEN
				INSERT
					(
						LotNo,
						Unusual_First,
						LotNo2,
						Unusual_Second,
						LotNo3,
						Unusual_Third,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.LotNo,
							SourceTable.Unusual_First,
							SourceTable.LotNo2,
							SourceTable.Unusual_Second,
							SourceTable.LotNo3,
							SourceTable.Unusual_Third,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

						 --  2021.04.29 추가사항 111
					update STB_FourMLotNoHist
					   set  Unusual_First =  @Unusual_First
					     ,  Unusual_Second = @Unusual_Second
						 , Unusual_Third = @Unusual_Third
                    where 1=1
					and  lotno = @LotNo


			-- Process Update Table
            MERGE STB_FourMLotNoHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLotNo IS NULL THEN LotNo
							    ELSE OldLotNo
							END AS OldLotNo,
							LotNo,
							Unusual_First,
							LotNo2,
							Unusual_Second,
							LotNo3,
							Unusual_Third,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldLotNo VARCHAR(18),
										LotNo VARCHAR(18),
										Unusual_First VARCHAR(1000),
										LotNo2 VARCHAR(18),
										Unusual_Second VARCHAR(1000),
										LotNo3 VARCHAR(18),
										Unusual_Third VARCHAR(1000),
										CreateDateTime VARCHAR(19),
										CreateUserID VARCHAR(20),
										ChangeDateTime VARCHAR(19),
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LotNo = SourceTable.OldLotNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					Unusual_First = ISNULL(SourceTable.Unusual_First,TargetTable.Unusual_First),
					LotNo2 = ISNULL(SourceTable.LotNo2,TargetTable.LotNo2),
					Unusual_Second = ISNULL(SourceTable.Unusual_Second,TargetTable.Unusual_Second),
					LotNo3 = ISNULL(SourceTable.LotNo3,TargetTable.LotNo3),
					Unusual_Third = ISNULL(SourceTable.Unusual_Third,TargetTable.Unusual_Third),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						LotNo,
						Unusual_First,
						LotNo2,
						Unusual_Second,
						LotNo3,
						Unusual_Third,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.LotNo,
							SourceTable.Unusual_First,
							SourceTable.LotNo2,
							SourceTable.Unusual_Second,
							SourceTable.LotNo3,
							SourceTable.Unusual_Third,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			   --  2021.04.29 추가사항
					update STB_FourMLotNoHist
					   set  Unusual_First =  @Unusual_First
					     ,  Unusual_Second = @Unusual_Second
						 , Unusual_Third = @Unusual_Third
                    where 1=1
					and  lotno = @LotNo





			-- Process Delete Table
            MERGE STB_FourMLotNoHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLotNo IS NULL THEN LotNo
							    ELSE OldLotNo
							END AS OldLotNo,
							LotNo
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldLotNo VARCHAR(18),
										LotNo VARCHAR(18)
									) 
				) AS SourceTable
			ON
				(
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
