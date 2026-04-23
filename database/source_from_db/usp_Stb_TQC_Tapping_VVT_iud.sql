-- =============================================
-- Author:		DinhManh
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_Stb_TQC_Tapping_VVT_iud
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
	--DECLARE @MaterialCode VARCHAR(50)
	DECLARE @id INT
	DECLARE @InspectionItems NVARCHAR(200)
	DECLARE @SampleQty INT
	DECLARE @LSL numeric(20, 5)
	DECLARE @USL numeric(20, 5)
	DECLARE @First numeric(20, 5)
	DECLARE @Middle numeric(20, 5)
	DECLARE @Last numeric(20, 5)
	DECLARE @Result VARCHAR(50)
	DECLARE @Remark NVARCHAR(MAX)
	DECLARE @LotNo VARCHAR(20) 
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)

	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
					'INSERT' AS IUD_FLAG,
							id,
							InspectionItems,
							SampleQty,
							LSL,
							USL,
							[First],
							Middle,
							[Last],
							Result,
							Remark,
							LotNo,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										id int,
										InspectionItems NVARCHAR(200),
										SampleQty INT,
										LSL numeric(20, 5),
										USL numeric(20, 5),
										[First] numeric(20, 5),
										Middle numeric(20, 5),
										[Last] numeric(20, 5),
										Result VARCHAR(50),
										Remark NVARCHAR(MAX),
										LotNo VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							id,
							InspectionItems,
							SampleQty,
							LSL,
							USL,
							[First],
							Middle,
							[Last],
							Result,
							Remark,
							LotNo,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										id int,
										InspectionItems NVARCHAR(200),
										SampleQty INT,
										LSL numeric(20, 5),
										USL numeric(20, 5),
										[First] numeric(20, 5),
										Middle numeric(20, 5),
										[Last] numeric(20, 5),
										Result VARCHAR(50),
										Remark NVARCHAR(MAX),
										LotNo VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							id,
							InspectionItems,
							SampleQty,
							LSL,
							USL,
							[First],
							Middle,
							[Last],
							Result,
							Remark,
							LotNo,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										id int,
										InspectionItems NVARCHAR(200),
										SampleQty INT,
										LSL numeric(20, 5),
										USL numeric(20, 5),
										[First] numeric(20, 5),
										Middle numeric(20, 5),
										[Last] numeric(20, 5),
										Result VARCHAR(50),
										Remark NVARCHAR(MAX),
										LotNo VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@id,
								@InspectionItems ,
								@SampleQty ,
								@LSL ,
								@USL ,
								@First ,
								@Middle ,
								@Last ,
								@Result ,
								@Remark ,
								@LotNo,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)

					IF EXISTS (SELECT 1 FROM Stb_TQC_Tapping_VVT WHERE id = @id)
					BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @id)
					END

					--IF @IsAutoKey = 1 BEGIN
     --                   EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_WidthSlitting',@MaterialCode OUTPUT
     --               END

					INSERT INTO Stb_TQC_Tapping_VVT
						(
							InspectionItems,
							SampleQty,
							LSL,
							USL,
							[First],
							Middle,
							[Last],
							Result,
							Remark,
							LotNo,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
						)
						VALUES
						(
							@InspectionItems ,
							@SampleQty ,
							@LSL ,
							@USL ,
							@First ,
							@Middle ,
							@Last ,
							@Result ,
							@Remark ,
							@LotNo,
							GETDATE(),
							@pProcessUserID,
							@ChangeDateTime,
						    @ChangeUserID
						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					UPDATE Stb_TQC_Tapping_VVT
						SET
							InspectionItems = ISNULL(@InspectionItems, InspectionItems),
							SampleQty = ISNULL (@SampleQty, SampleQty),
							LSL = ISNULL(@LSL, LSL),
							USL =ISNULL (@USL, USL),
							[First] = ISNULL(@First, First),
							Middle = ISNULL(@Middle, Middle),
							[Last] = ISNULL(@Last, Last),
							Result = ISNULL(@Result, Result),
							Remark = ISNULL(@Remark, Remark),
							LotNo = ISNULL(@LotNo, LotNo),
							CreateDateTime = ISNULL(@CreateDateTime, CreateDateTime),
							CreateUserID = ISNULL(@CreateUserID, CreateUserID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID

						WHERE
							id = @id

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM Stb_TQC_Tapping_VVT
						WHERE
							id = @id

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
