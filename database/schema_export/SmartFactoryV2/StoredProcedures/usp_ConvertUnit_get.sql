-- Procedure: usp_ConvertUnit_get
-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-04-04
-- Description:	Lấy dữ liệu chuyển đổi đơn vị
-- =============================================
CREATE PROCEDURE usp_ConvertUnit_get
	@pProcessUserID VARCHAR(20) =NULL,
	@pProcessLanguage VARCHAR(20) =NULL,
	@pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT UC.MaterialCode,MM.MaterialName,ConvertRate,TargetUnit,BaseUnit,UC.CreateDateTime,UC.CreateUserID,UC.ChangeDateTime,UC.ChangeUserID from STB_UnitConversion UC
	left join STB_MaterialMaster MM on uc.MaterialCode = MM.MaterialCode
END

GO

