-- =============================================
-- Author:		MR.Duy
-- Create date: 2025-02-17
-- Description:	Lấy loại phế cho báo phế hà nam
-- =============================================
CREATE PROCEDURE  [usp_TypeWaste_B598]
AS
BEGIN
	SELECT ID, NameTypeWaste 
	FROM STB_TypeWaste WITH(NOLOCK)
END