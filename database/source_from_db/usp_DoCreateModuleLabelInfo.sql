-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 모듈관리
-- Browsable : true
-- Create date : 2023-01-30
-- Description : 모듈 라벨 일련번호 생성
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateModuleLabelInfo]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProductNo VARCHAR(20),
	@pRevisionNo VARCHAR(20),
	@pBaseDate DATE,
	@pLabelQty INT
AS
BEGIN
	Declare @ProductNo VARCHAR(20) = @pProductNo
	       ,@RevisionNo VARCHAR(20) = @pRevisionNo
		   ,@BaseDate DATE = @pBaseDate
		   ,@LabelQty INT = @pLabelQty
		   ,@Year CHAR(2)
		   ,@WeekIndex CHAR(2)
		   ,@SerialHeader VARCHAR(20)
		   ,@StartIndex INT
		   ,@LoopCnt INT = 0

	-- 입력 받은 날짜의 년도와 해당 주차를 구함.
	SELECT @Year = CONVERT(CHAR(2), @BaseDate, 12)
	SELECT @WeekIndex = RIGHT('0'+CONVERT(VARCHAR(2), DATEPART(WEEK, @BaseDate)), 2)

	SET @SerialHeader = 'PLS' + RIGHT(@RevisionNo, 1) + @Year + @WeekIndex + 'V'

	SELECT @StartIndex = ISNULL(MAX(RIGHT(ModuleSerialNo, 4)), 0) + 1
	  FROM STB_ModuleLabelInfo
	 WHERE ModuleSerialNo LIKE @SerialHeader + '%'

	 WHILE @LoopCnt < @LabelQty BEGIN
		INSERT INTO STB_ModuleLabelInfo (
				 ModuleSerialNo
				,ProductNo
				,RevisionNo
				,CreateUserID
				) VALUES (
				@SerialHeader + RIGHT('00000' + CONVERT(VARCHAR, @StartIndex + @LoopCnt), 4)
			   ,@ProductNo
			   ,@RevisionNo
			   ,@pProcessUserID
			)

		SET @LoopCnt = @LoopCnt + 1
	 END
END