-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-21
-- Description:	Thực hiện lưu trạng thái
-- =============================================
CREATE PROCEDURE [dbo].[usp_InventoryFindGoods_uid]
	-- Add the parameters for the stored procedure here
    @pProcessUserID varchar(20)= NULL,
    @pProcessLanguage varchar(20)= NULL,
    @pXml NVARCHAR(MAX) = null,
	@pProcessViewName VARCHAR(50)=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID;
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage;
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName;
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE';
    DECLARE @ERROR_MSG NVARCHAR(MAX);
    DECLARE @CommentType NVARCHAR(100);
    DECLARE @PackingID VARCHAR(50);
	DECLARE @Note NVARCHAR(500);
    DECLARE @iDoc INT;

	IF (@pProcessUserID NOT IN ('HaiTrieu','hoangxuan','hoangphuong'))
    BEGIN
        RAISERROR(N'Bạn không có quyền vui lòng liên hệ EA !',16,1);
        RETURN;
    END
	 -- load XML
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;
	 BEGIN TRY
        DECLARE cur CURSOR FOR
        SELECT
            CommentType,
            PackingID,
			Note
        FROM OPENXML(@iDoc , @UpdateTableName , 3)
        WITH (
            CommentType NVARCHAR(100),
            PackingID VARCHAR(50),
			Note NVARCHAR(500)
        );

        OPEN cur;
        WHILE 1=1
        BEGIN
            FETCH NEXT FROM cur INTO @CommentType, @PackingID,@Note;
            IF @@FETCH_STATUS <> 0 BREAK;
		    -- trường hợp 1
           IF EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_HN_New WHERE PackingID = @PackingID)
            BEGIN
                UPDATE STB_VN_FINISHGOODS_HN_New
                SET CommentType = ISNULL(@CommentType, CommentType),
				   Note=ISNULL(@Note, Note)
                WHERE PackingID = @PackingID;
            END
          END
		  -- trường hợp 2
		  IF EXISTS (SELECT 1 FROM FinishGoodMESInstock_HN WHERE PackingID = @PackingID)
            BEGIN
                UPDATE FinishGoodMESInstock_HN
                SET CommentType = ISNULL(@CommentType, CommentType),
				Note=ISNULL(@Note, Note)
                WHERE PackingID = @PackingID;
            END

        CLOSE cur;
        DEALLOCATE cur;
    END TRY
    BEGIN CATCH
        SET @ERROR_MSG = ERROR_MESSAGE();
        RAISERROR(@ERROR_MSG,16,1);
    END CATCH;

    EXEC sp_xml_removedocument @iDoc;
END



