CREATE PROC [dbo].[usp_VN_SubMenu] -- exec usp_VN_SubMenu 'CDMM06','6'
@CODEMM NVARCHAR(50),
@IDPermission INT
AS
BEGIN
			SELECT
					CODESM,
					NAMESUB,
					VN,
					EN,
					KR
					
			FROM	
					STB_VN_SubMenu WITH (NOLOCK)
			WHERE
					
					CODEMM = @CODEMM AND IDPermission =@IDPermission AND IsUed = 1
					
END