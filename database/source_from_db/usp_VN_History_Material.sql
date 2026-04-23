CREATE PROC usp_VN_History_Material
@pFrom DATETIME = NULL,
@pTo DATETIME  = NULL
AS
BEGIN
		SELECT
				*
		FROM
				STB_MaterialLotSnapshot WITH(NOLOCK)
		WHERE
				CONVERT(DATE,ChangeDateTime) BETWEEN @pFrom AND @pTo
END