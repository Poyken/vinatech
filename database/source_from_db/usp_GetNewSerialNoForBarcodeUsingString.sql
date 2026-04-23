-- =============================================
-- Author: Jackaroe (yjyu@vina.co.kr)
-- Create date: 2024-04-12
-- Browsable : false
-- Group : 일련번호 채번(문자포함)
-- =============================================
CREATE PROCEDURE usp_GetNewSerialNoForBarcodeUsingString
	@pProcessUserID VARCHAR(20),
	@pMaterialCode VARCHAR(50) = '',
	@pHeader VARCHAR(20) = '',
	@pSerialNo VARCHAR(20) OUTPUT
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @Header VARCHAR(20) = @pHeader
	DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode
	DECLARE @SerialNo VARCHAR(20)

	SELECT
			@SerialNo = SI.StrSerialNo
	FROM
			STB_SerialInfo SI                                    -- SELECT * FROM STB_SerialInfo
	WHERE 1=1
	AND SI.MaterialCode = @MaterialCode 
	AND SI.Header = @Header

	IF @SerialNo IS NULL BEGIN 
		SET @SerialNo = '01'
	END ELSE BEGIN
		IF LEFT(@SerialNo, 1) BETWEEN '0' AND '8' BEGIN
			SET @SerialNo = RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, @SerialNo) + 1), 2)
		END ELSE BEGIN
			SET @SerialNo = dbo.fnGetBarcodeSerialNoUsingNewRule(@SerialNo)
		END
	END

	UPDATE	STB_SerialInfo
	SET
			StrSerialNo = @SerialNo,
			ChangeDateTime = GETDATE(),
			ChangeUserID = @pProcessUserID
	WHERE
			MaterialCode = @MaterialCode AND
			Header = @Header

	IF @@ROWCOUNT = 0 
	
	BEGIN
			INSERT INTO STB_SerialInfo
			(
				MaterialCode,
				Header,
				SerialNo,
				CreateDateTime,
				CreateUserID,
				StrSerialNo
			)
			VALUES
			(
				@MaterialCode,
				@Header,
				0,
				GETDATE(),
				@pProcessUserID,
				@SerialNo
			)
	END

	SET @pSerialNo = @SerialNo

END
