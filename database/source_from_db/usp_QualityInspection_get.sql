-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-03-31
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사그룹을 조회합니다
-- Modified:
-- =============================================
CREATE  PROCEDURE [dbo].[usp_QualityInspection_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUtcOffset INT,
	@pno nvarchar(50) = null,
	@pSize nvarchar(50) = null,
	@pWEC_VEC nvarchar(50)=null,
	@pCustomer nvarchar(50)=null
AS
BEGIN
	SET NOCOUNT ON;
	    
	SELECT
		QI.ID AS OldID,
	    QI.ID,
		QI.No,
		QI.Category,
		QI.Size,
		QI.FARAT,
		QI.HQ,
		QI.WEC_VEC,
		QI.Customer,
		QI.PROD_ESR,
		QI.PROD_SD,
		QI.PROD_CAPA,
		QI.PROD_AGING,
		QI.QC_ESR,
		QI.QC_SD,
		QI.QC_CAPA,
		QI.QC_ETC,
		QI.OQC_ExternalAppearance,
		QI.TQC_ESR,
		QI.TQC_SD,
		QI.TQC_CAP,
		QI.TQC_ExternalAppearance,
		QI.REMARK,
		QI.CreateDateTime,
	    QI.CreateUserID,
	    QI.ChangeDateTime,
	    QI.ChangeUserID
	        
	FROM
	        Stb_QualityInspection QI WITH(NOLOCK)
			
	WHERE
	        --((@QcInspectionGroupCode = '*') OR (QIG.QcInspectionGroupCode = @QcInspectionGroupCode)) 
			1=1 
			and (@pno is null or @pno='' or  QI.no = @pno)
			and (@pSize is null or @pSize ='' or QI.Size= @pSize)
			and (@pWEC_VEC is null or @pWEC_VEC='' or QI.WEC_VEC = @pWEC_VEC)
			and (@pCustomer is null or @pCustomer='' or QI.Customer = @pCustomer)
	order by no		
END


