
-- =============================================
CREATE PROCEDURE [dbo].[usp_Materialattribute_popup_VN]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
	--@pMaterialCode VARCHAR(50) = NULL,
	--@pAttribType VARCHAR(1) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode
	--DECLARE @AttribType VARCHAR(1) = @pAttribType

	CREATE TABLE #STB_MaterialAttribute
	(
			AttribType NVARCHAR(10),
			StockAttrib NVARCHAR(10) PRIMARY KEY(StockAttrib),
			StockAttribDesc NVARCHAR(10)
	)

	INSERT INTO #STB_MaterialAttribute (AttribType,StockAttrib,StockAttribDesc) VALUES ('1','A','A')
	INSERT INTO #STB_MaterialAttribute (AttribType,StockAttrib,StockAttribDesc) VALUES ('1','B','B')
	INSERT INTO #STB_MaterialAttribute (AttribType,StockAttrib,StockAttribDesc) VALUES ('1','C','C')
	INSERT INTO #STB_MaterialAttribute (AttribType,StockAttrib,StockAttribDesc) VALUES ('1','D','D')
	INSERT INTO #STB_MaterialAttribute (AttribType,StockAttrib,StockAttribDesc) VALUES ('1','S','S')

	SELECT
		AttribType,
		StockAttrib,
		StockAttribDesc
	FROM
			#STB_MaterialAttribute MA WITH(NOLOCK)

DROP TABLE #STB_MaterialAttribute
	
END
