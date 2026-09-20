-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-23
-- Browsable : false
-- Group : 마지막번호 관리
-- Description:	자재코드,헤더 기준으로 신규번호를 리턴합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetNewSerialNoForBarcode]
	@pProcessUserID VARCHAR(20),
	@pMaterialCode VARCHAR(50) = '',
	@pHeader VARCHAR(20) = '',          -- 2020.06.08 수정
	@pSerialNo INT OUTPUT
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @Header VARCHAR(20) = @pHeader
	DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode
	DECLARE @SerialNo INT

	SELECT
			@SerialNo = SI.SerialNo
	FROM
			STB_SerialInfo SI                                    -- SELECT * FROM STB_SerialInfo
	WHERE 1=1
	AND SI.MaterialCode = @MaterialCode 
	AND SI.Header = @Header

	SET @SerialNo = ISNULL(@SerialNo, 0) + 1

	UPDATE	STB_SerialInfo
	SET
			SerialNo = @SerialNo,
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
				CreateUserID
			)
			VALUES
			(
				@MaterialCode,
				@Header,
				@SerialNo,
				GETDATE(),



				@pProcessUserID
			)
	END

	SET @pSerialNo = @SerialNo

END
