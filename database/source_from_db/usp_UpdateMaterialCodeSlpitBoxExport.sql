-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-06-11
-- Description:	Thay đổi mã hàng khi tách lot màn hình HN543
-- ============================================= PKPO0500157
CREATE PROCEDURE usp_UpdateMaterialCodeSlpitBoxExport
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProcessViewName VARCHAR(50),
						@pXml NVARCHAR(MAX) = NULL,
						@pPackingID VARCHAR(50)=null,
						@pMaterialCode VARCHAR(50)=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(30) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName

	DECLARE @iDoc INT

	declare	@PackingID		varchar(50)   
	declare @MaterialCode	varchar(50) 
	declare	@OldMaterialCode	varchar(50)   
	

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
		DECLARE SourceData CURSOR FOR
            SELECT
						PackingID,
						MaterialCode
			FROM
					OPENXML(@idoc , @TableName , 2)
					WITH (
								PackingID VARCHAR(50),
								MaterialCode VARCHAR(50) 

						 )

        OPEN SourceData
			WHILE 1=1 BEGIN
		  FETCH NEXT FROM SourceData INTO
								@PackingID,
								@MaterialCode
            IF @@FETCH_STATUS <> 0 BEGIN 
				BREAK 
			END 
		-- LẤy ra mã code cũ
		select @OldMaterialCode =MaterialCode from STB_DividePackaging where PackingID=@PackingID

		-- Cập nhật thay đổi
		update STB_DividePackaging
		set MaterialCode=@MaterialCode
		where PackingID=@PackingID

		-- Lưu lịch sử thay đổi 
		INSERT INTO STB_HistoryChangeMaterialSlpitBoxExport_HN
			(PackingID,OldMaterialCode, NewMaterialCode,CreateDatetime,CreateUserID)
		VALUES
			(@PackingID,@OldMaterialCode,@MaterialCode,getdate(),@ProcessUserID) 
		END
END
