CREATE PROC usp_VN_StatuMachine
@Lang NVARCHAR(50)
AS
BEGIN
IF @Lang = 'en-US'
BEGIN
		SELECT
				CODEIDM,
				Stagename AS Stagename
		FROM
				STB_VN_STAGEMACHINES_MATERS WITH(NOLOCK)
		WHERE
				Actives = 1
END
IF @Lang = 'vi-VN'
BEGIN
SELECT
				CODEIDM,
				Vietnamese AS Stagename
		FROM
				STB_VN_STAGEMACHINES_MATERS WITH(NOLOCK)
		WHERE
				Actives = 1
END
IF @Lang = 'ko-KR'
BEGIN
SELECT
				CODEIDM,
				Korean AS Stagename
		FROM
				STB_VN_STAGEMACHINES_MATERS WITH(NOLOCK)
		WHERE
				Actives = 1
END
END
