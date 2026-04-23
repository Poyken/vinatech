-- =============================================

-- =============================================
CREATE  PROCEDURE [dbo].[usp_ExportReference_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUtcOffset INT,
	@pFromDate date = null,
	@pToDate date = null,
	@pCustomer nvarchar(50) = null,
	@pDescription nvarchar(500) = null
AS
BEGIN
	SET NOCOUNT ON;
     
	
	    
	SELECT
	        ID,
		    No,
			Customer,
			dbo.fnGetLocalTime(DateBasic, @pUtcOffset) AS DateBasic, 
			Description,
			case when status_confirm = 1 then 'Confirmed'
			else 'Not confirm' end as status,
			CreateDateTime,
			CreateUserID,
			ChangeDateTime ,
			ChangeUserID 
			from Stb_ExportReference
			where (DateBasic between @pFromDate and @pToDate)
			AND (@pCustomer is null or @pCustomer ='' or Customer = @pCustomer)
			AND (@pDescription is null or @pDescription ='' or Description = @pDescription)
END


