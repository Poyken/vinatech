-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-03-31
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사그룹을 조회합니다
-- Modified:
-- =============================================
CREATE  PROCEDURE [dbo].[usp_ExpectedShip_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUtcOffset INT,
	@pID nvarchar(50) = null,
	@pSize nvarchar(50) = null,
	@pCustomer nvarchar(50)=null
AS
BEGIN
	SET NOCOUNT ON;
	    
	SELECT
		ES.ID AS OldID,
	    ES.ID,
		ES.Size,
		ES.Quality,
		ES.Customer,
		dbo.fnGetLocalTime(ES.ShippingDate, @pUtcOffset) AS ShippingDate,
		dbo.fnGetLocalTime(ES.ProdSchedule, @pUtcOffset) as ProdSchedule,
		ES.QC_ESR,
		ES.QC_SD,
		ES.QC_CAPA,
		ES.QC_ETC,
		ES.Status,
		ES.CreateDateTime,
	    ES.CreateUserID,
	    ES.ChangeDateTime,
	    ES.ChangeUserID
	        
	FROM
	        stb_ExpectedShip ES WITH(NOLOCK)
			
	WHERE
	        --((@QcInspectionGroupCode = '*') OR (QIG.QcInspectionGroupCode = @QcInspectionGroupCode)) 
			1=1 
			and (@pID is null or ES.ID= @pID)
			and (@pSize is null or ES.Size= @pSize)
			and (@pCustomer is null or ES.Customer = @pCustomer)
	order by ShippingDate	
END



