-- Procedure: usp_DoUpgradeToCustomers




-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-09-12
-- Description:	업체로 업그레이드를 적용합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpgradeToCustomers]

AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @CustomerNames TABLE
	(
		Row INT IDENTITY(1,1),
		CustomerName NVARCHAR(100)
	)
	INSERT INTO @CustomerNames VALUES ('SR테크노팩')
	INSERT INTO @CustomerNames VALUES ('대우루컴즈')
	INSERT INTO @CustomerNames VALUES ('삼화에이스')
	INSERT INTO @CustomerNames VALUES ('보원산업')
	INSERT INTO @CustomerNames VALUES ('남선기공')
	INSERT INTO @CustomerNames VALUES ('티엘론')
	INSERT INTO @CustomerNames VALUES ('태일기계')
	INSERT INTO @CustomerNames VALUES ('HACO')

	DECLARE @Row INT,
			@Count INT,
			@CustomerName NVARCHAR(100)

	SELECT
			@Row = 1,
			@Count = COUNT(*)
	FROM
			@CustomerNames

	WHILE @Row <= @Count BEGIN
		SELECT
				@CustomerName = C.CustomerName
		FROM
				@CustomerNames C
		WHERE
				C.Row = @Row

		BEGIN TRY
			EXEC usp_DoUpgradeToCustomer @CustomerName

			PRINT @CustomerName + ' 업그레이드 완료'
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(MAX)
			SET @ErrorMessage = @CustomerName + ' 업그레이드 실패 : ' + ERROR_MESSAGE()
			PRINT @ErrorMessage
		END CATCH

		SET @Row = @Row + 1
	END
END





GO

