-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-03-31
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사그룹을 조회합니다
-- Modified:
-- =============================================
CREATE  PROCEDURE [dbo].[usp_SDValueTest]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pIDParam nvarchar(50)= null

AS
BEGIN
	SET NOCOUNT ON;
         
	SELECT
	        IDParam,
			ID,
			V1,
			V2,
			DV,
			Result
	FROM
	        stb_SDValueTest SDValue WITH(NOLOCK)
	WHERE 1=1
			and (@pIDParam is null or SDValue.IDParam=@pIDParam)
			order by ID
END
