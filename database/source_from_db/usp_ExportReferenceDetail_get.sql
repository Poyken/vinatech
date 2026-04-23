-- =============================================

-- =============================================
CREATE  PROCEDURE [dbo].[usp_ExportReferenceDetail_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pExportReferenceNo int= NULL
AS
BEGIN
	SET NOCOUNT ON;
     
	
	    
	SELECT
	        ID,
		    ExportReference_ID,
			LotNo,
			MaterialCode,
			Quatity ,
			CreateDateTime ,
			CreateUserID ,
			ChangeDateTime ,
			ChangeUserID 
	FROM  stb_ExportReference_Detail
	WHERE ExportReference_ID=@pExportReferenceNo
END


