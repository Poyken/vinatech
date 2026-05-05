-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2026-03-19
-- Description:	Thêm dữ liệu
-- =============================================
CREATE PROCEDURE [dbo].[usp_CodeForFactory_uid]
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

  DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_INSERT'
	DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_UPDATE'
	DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
	DECLARE @IUD_FLAG VARCHAR(10)
    
	DECLARE @Id INT, @MaterialCode VARCHAR(255), @PartNo VARCHAR(255), @Model VARCHAR(255)
	DECLARE @WorkCenterCode varchar(255), @IsUsed BIT, @CreatedBy varchar(50)
	DECLARE @CreatedDate DATETIME, @ModifiedBy VARCHAR(20), @ModifiedDate DATETIME

	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

	BEGIN TRY
		DECLARE SourceData CURSOR FOR
			-- Chúng ta gom tất cả về một kiểu SELECT thống nhất
			SELECT 'INSERT' AS IUD_FLAG, Id, MaterialCode, PartNo, Model, WorkCenterCode, IsUsed, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate
			FROM OPENXML(@idoc , @InsertTableName , 2)
			WITH (Id INT, MaterialCode varchar(255), PartNo varchar(255), Model varchar(255), WorkCenterCode VARCHAR(255), IsUsed BIT, CreatedBy varchar(50), CreatedDate DATETIME, ModifiedBy VARCHAR(50), ModifiedDate DATETIME)
			UNION ALL
			SELECT 'UPDATE' AS IUD_FLAG, Id, MaterialCode, PartNo, Model, WorkCenterCode, IsUsed, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate
			FROM OPENXML(@idoc , @UpdateTableName , 2)
			WITH (Id INT, MaterialCode varchar(255), PartNo varchar(255), Model varchar(255), WorkCenterCode VARCHAR(255), IsUsed BIT, CreatedBy varchar(50), CreatedDate DATETIME, ModifiedBy VARCHAR(50), ModifiedDate DATETIME)
			UNION ALL
			SELECT 'DELETE' AS IUD_FLAG, Id, MaterialCode, PartNo, Model, WorkCenterCode, IsUsed, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate
			FROM OPENXML(@idoc , @DeleteTableName , 2)
			WITH (Id INT, MaterialCode varchar(255), PartNo varchar(255), Model varchar(255), WorkCenterCode VARCHAR(255), IsUsed BIT, CreatedBy varchar(50), CreatedDate DATETIME, ModifiedBy VARCHAR(50), ModifiedDate DATETIME)

		OPEN SourceData
		WHILE 1 = 1 BEGIN
			FETCH NEXT FROM SourceData INTO @IUD_FLAG, @Id, @MaterialCode, @PartNo, @Model, @WorkCenterCode, @IsUsed, @CreatedBy, @CreatedDate, @ModifiedBy, @ModifiedDate
				
			IF @@FETCH_STATUS <> 0 BREAK

			-- CHỐNG LỖI NULL: Chỉ xử lý nếu có MaterialCode
			IF @MaterialCode IS NOT NULL AND LTRIM(RTRIM(@MaterialCode)) <> ''
			BEGIN
				IF @IUD_FLAG = 'INSERT' BEGIN
					INSERT INTO STB_ItemCode (MaterialCode, PartNo, Model, WorkCenterCode, IsUsed, CreatedBy, CreateDate)
					VALUES (@MaterialCode, @PartNo, @Model, @WorkCenterCode, 1, @pProcessUserID, GETDATE())
				END 
				
				IF @IUD_FLAG = 'UPDATE' BEGIN
					UPDATE STB_ItemCode
					SET MaterialCode = ISNULL(@MaterialCode, MaterialCode),
						PartNo = ISNULL(@PartNo, PartNo),
						Model = ISNULL(@Model, Model),
						WorkCenterCode = ISNULL(@WorkCenterCode, WorkCenterCode),
						IsUsed = ISNULL(@IsUsed, IsUsed),
						ModifiedBy = @pProcessUserID,
						ModifieDate = GETDATE()
					WHERE Id = @Id
				END
			END

			IF @IUD_FLAG = 'DELETE' BEGIN
				DELETE FROM STB_ItemCode WHERE Id = @Id
			END
		END
	END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR(@ERROR_MSG, 16, 1)
	END CATCH
			
	CLOSE SourceData;
	DEALLOCATE SourceData;
	EXEC sp_xml_removedocument @idoc
END
