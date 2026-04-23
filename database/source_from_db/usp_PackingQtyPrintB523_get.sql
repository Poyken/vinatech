-- =============================================
-- Author:		DinhManh
-- Create date: 2025-11-17
-- Description:	get Packing Qty Print B523 config
-- =============================================
CREATE PROCEDURE usp_PackingQtyPrintB523_get
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pModelCode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ModelCode VARCHAR(50) = CASE WHEN ISNULL(@pModelCode,'') = '' THEN '%' ELSE @pModelCode END

	SELECT 
			PQP.ID,
			PQP.MaterialCode,
			MBI.ModelName,
			case when substring(MBI.ModelName,1,3) in ('VEC','WEC') then RTRIM(LTRIM(substring(MBI.ModelName,1,11))) 
						when substring(MBI.ModelName,1,3) in ('VEL') then RTRIM(LTRIM(substring(MBI.ModelName,1,14))) 
						when substring(MBI.ModelName,8,20) in ('WEM12R0126QG') then (RTRIM(LTRIM(SUBSTRING(MBI.ModelName, CHARINDEX(' ', MBI.ModelName)+1, 12)))) --Duy thêm tạm 
						else (RTRIM(LTRIM(SUBSTRING(MBI.ModelName, CHARINDEX(' ', MBI.ModelName), 12)))) end AS PartNo, 
			PQP.PackingQty,
			PQP.IsUsed,
			PQP.Notes,
			PQP.CreateDateTime,
			PQP.CreateUserID,
			PQP.ChangeDateTime,
			PQP.ChangeUserID
	FROM 
		STB_PackingQtyPrintB523_VVT PQP

		LEFT JOIN STB_ModelBasicInfo MBI ON PQP.MaterialCode = MBI.ModelCode

	WHERE
		PQP.MaterialCode LIKE @ModelCode
END
