-- Procedure: usp_DoRegistUser
-- =============================================
-- Author:		Kim Han Young
-- Browsable : false
-- Create date: 2016-01-21
-- Description:	Regist user
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoRegistUser]
	@pUserID VARCHAR(20),
	@pPassword VARCHAR(20),
	@pUserName NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @Password VARCHAR(20) = @pPassword
	    
    IF EXISTS ( SELECT 1 FROM STB_UserInfo WHERE UserID = @pUserID) BEGIN
		RAISERROR('Exist ID',16,1)
		RETURN
    END

	-- 비밀번호 길이 체크 2023.07.11 By Jackaroe
	PRINT 'Password Length ::::: ' + CONVERT(VARCHAR, LEN(@Password))

	IF LEN(@Password) < 8 BEGIN
		RAISERROR('비밀번호 길이는 최소 8자리 이상입니다.(Password length is at least 8 characters.)',16,1)
		RETURN
    END

	-- 영문자, 특수문자 조합 체크 2023.07.11 By Jackaroe
	IF @Password LIKE '%[\!\@\#\$\%\^\&\*\(\)]%' BEGIN
		-- 입력 받은 문자열에서 특수문자를 제거
		SET @Password = dbo.GET_REGEX_REPLACE(@Password, '[\!\@\#\$\%\^\&\*\(\)0-9]', '')

		PRINT 'After Regex replace ::::: ' + @Password

		PRINT 'Password Length ::::: ' + CONVERT(VARCHAR, LEN(@Password))

		IF @Password LIKE '%[a-zA-Z]%' BEGIN
			PRINT 'OK'
		END ELSE BEGIN
			RAISERROR('비밀번호는 영문자가 포함되어야 합니다.(Password must contain alphabetic characters.)',16,1)
			RETURN
		END
    END ELSE BEGIN
		RAISERROR('비밀번호는 특수문자가 포함되어야 합니다.(Password must contain special characters.)',16,1)
		RETURN
	END

	DECLARE @DefaultSystemCode VARCHAR(20)

	SELECT
			@DefaultSystemCode = CCI.ConstValue
	FROM
			STB_ConstCodeInfo CCI
	WHERE
			CCI.ConstName = 'DefaultSystemCode'

    
    INSERT INTO STB_UserInfo 
    (
		UserID,
		Password,
		UserName,
		AllowFlag,
		SystemCode,
		CreateDateTime
    )
    VALUES
    (
		@pUserID,
		PWDENCRYPT(@pPassword),
		@pUserName,
		'Request',
		@DefaultSystemCode,
		GETDATE()
    )
END
GO

