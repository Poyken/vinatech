-- Procedure: usp_DoUpdateStringResource






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Update String Resource
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateStringResource]
	@pProcessLanguage VARCHAR(20),
	@pType VARCHAR(20),
	@pName NVARCHAR(200),
	@pValue NVARCHAR(500),
	@pDescription NVARCHAR(200) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	IF LEFT(@pValue,1) = '%' BEGIN
		SET @pValue = SUBSTRING(@pValue,2,100)
	END
	IF RIGHT(@pValue,1) = '%' BEGIN
		SET @pValue = LEFT(@pValue,LEN(@pValue) - 1)
	END
	
	IF @pValue = 'MaterialTypeCode' OR @pValue = 'FacilityProdItemPlanBom' BEGIN
		RAISERROR('언어가 원래대로 돌아가려고 합니다~.김한영차장에게 통보',16,1)
		RETURN
	END
	UPDATE STB_StringResources
	SET
			Value = @pValue,
			Description = @pDescription,
			ChangeDateTime = GETDATE()
	WHERE
			Language = @pProcessLanguage AND
			Name = @pName
			
	IF @@ROWCOUNT = 0 BEGIN
		EXEC usp_DoAddStringResource @pProcessLanguage = @pProcessLanguage,
									 @pType = @pType,
									 @pName = @pName,
									 @pValue = @pValue,
									 @pDescription = @pDescription
	END
END







GO

