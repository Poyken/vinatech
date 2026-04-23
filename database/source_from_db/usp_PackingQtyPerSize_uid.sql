-- =============================================
-- Author:		DinhManh
-- Create date: 2025-01-10
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[usp_PackingQtyPerSize_uid] 
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50) = null,
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
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
	DECLARE @IDX INT
	DECLARE @ProdSize VARCHAR(10)
	DECLARE @PackingQty INT
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)
	DECLARE @IsUsed BIT


	DECLARE @iDoc INT


	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		BEGIN TRY
			
			-- Process Insert Table
			MERGE STB_PackingQtyPerSize AS TargetTable
			USING
				(
					SELECT
						IDX,
						ProdSize,
						PackingQty,
						GETDATE() AS CreateDateTime,
						@pProcessUserID AS CreateUserID,
						GETDATE() AS ChangeDateTime,
						@pProcessUserID AS ChangeUserID,
						IsUsed
					FROM
						OPENXML(@idoc , @InsertTableName , 2)
						WITH	(
									IDX INT,
									ProdSize VARCHAR(10),
									PackingQty INT,
									CreateDateTime DATETIMEOFFSET,
									CreateUserID VARCHAR(20),
									ChangeDateTime DATETIMEOFFSET,
									ChangeUserID VARCHAR(20),
									IsUsed BIT
								)
				) AS SourceTable
			ON
				(
					TargetTable.IDX = SourceTable.IDX
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProdSize = ISNULL(SourceTable.ProdSize, TargetTable.ProdSize),
					PackingQty = ISNULL(SourceTable.PackingQty, TargetTable.PackingQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed)

			WHEN NOT MATCHED THEN
				INSERT
					(
						ProdSize,
						PackingQty,
						CreateDateTime,
						CreateUserID,
						IsUsed
					)
				VALUES
					(
						SourceTable.ProdSize,
						SourceTable.PackingQty,
						SourceTable.CreateDateTime,
						SourceTable.CreateUserID,
						SourceTable.IsUsed
					);



			-- Process Update Table
			MERGE STB_PackingQtyPerSize AS TargetTable
			USING
				(
					SELECT
						IDX,
						ProdSize,
						PackingQty,
						GETDATE() AS CreateDateTime,
						@pProcessUserID AS CreateUserID,
						GETDATE() AS ChangeDateTime,
						@pProcessUserID AS ChangeUserID,
						IsUsed

					FROM
						OPENXML(@idoc , @UpdateTableName , 2)
						WITH	(
									IDX INT,
									ProdSize VARCHAR(10),
									PackingQty INT,
									CreateDateTime DATETIMEOFFSET,
									CreateUserID VARCHAR(20),
									ChangeDateTime DATETIMEOFFSET,
									ChangeUserID VARCHAR(20),
									IsUsed BIT
								)
				) AS SourceTable
			ON
				(
					TargetTable.IDX = SourceTable.IDX 
				)
			WHEN MATCHED THEN
				UPDATE SET
					ProdSize = ISNULL(SourceTable.ProdSize, TargetTable.ProdSize),
					PackingQty = ISNULL(SourceTable.PackingQty, TargetTable.PackingQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed)

			WHEN NOT MATCHED THEN
				INSERT
					(
						ProdSize,
						PackingQty,
						CreateDateTime,
						CreateUserID,
						IsUsed
					)
				VALUES
					(
						SourceTable.ProdSize,
						SourceTable.PackingQty,
						SourceTable.CreateDateTime,
						SourceTable.CreateUserID,
						SourceTable.IsUsed
					);



			-- Process Delete Table
			MERGE STB_PackingQtyPerSize AS TargetTable
			USING
				(
					SELECT
						IDX,
						ProdSize,
						PackingQty,
						GETDATE() AS CreateDateTime,
						@pProcessUserID AS CreateUserID,
						GETDATE() AS ChangeDateTime,
						@pProcessUserID AS ChangeUserID,
						IsUsed
					FROM
						OPENXML(@idoc , @DeleteTableName , 2)
						WITH	(
									IDX INT,
									ProdSize VARCHAR(10),
									PackingQty INT,
									CreateDateTime DATETIMEOFFSET,
									CreateUserID VARCHAR(20),
									ChangeDateTime DATETIMEOFFSET,
									ChangeUserID VARCHAR(20),
									IsUsed BIT
								)
				) AS SourceTable
			ON
				(
					TargetTable.IDX = SourceTable.IDX 
				)

			WHEN MATCHED THEN
				DELETE;
	
		END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH

		EXEC sp_xml_removedocument @idoc




END
