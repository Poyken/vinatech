CREATE PROC usp_VN_MainMenu
AS
BEGIN
			SELECT
					CODEMM,
					NAMEMAIN,
					VN,
					EN,
					KR
			FROM 
					STB_VN_MainMenu WITH (NOLOCK)
			WHERE
					IsUed = 1
END