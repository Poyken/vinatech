-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 모듈관리
-- Browsable : true
-- Create date : 2023-01-30
-- Description : 모듈 라벨 정보 조회
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModuleLabelInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProductNo VARCHAR(20) = NULL,
	@pRevisionNo VARCHAR(20) = NULL,
	@pBaseDate DATE,
	@pLabelQty INT = NULL
AS
BEGIN
	Declare @ProductNo VARCHAR(20) = @pProductNo
	       ,@RevisionNo VARCHAR(20) = CASE WHEN ISNULL(@pRevisionNo, '') = '' THEN '%' ELSE @pRevisionNo END
		   ,@BaseDate DATE = @pBaseDate
		   ,@LabelQty INT = @pLabelQty
		   ,@Year CHAR(2)
		   ,@WeekIndex CHAR(2)
		   ,@SerialHeader VARCHAR(20)

	-- 입력 받은 날짜의 년도와 해당 주차를 구함.
	SELECT @Year = CONVERT(CHAR(2), @BaseDate, 12)
	SELECT @WeekIndex = RIGHT('0'+CONVERT(VARCHAR(2), DATEPART(WEEK, @BaseDate)), 2)

	SET @SerialHeader = 'PLS' + RIGHT(@RevisionNo, 1) + @Year + @WeekIndex + 'V'
	--SET @SerialHeader = 'PLSV' + @Year + @WeekIndex

	SELECT MLI.ModuleSerialNo
          ,MLI.ProductNo
          ,MLI.RevisionNo
          ,MLI.CreateDateTime
          ,MLI.CreateUserID
          ,MLI.ChangeDateTime
          ,MLI.ChangeUserID
		  ,'Report' AS CommandType
		  ,SingleLotNo
	  FROM STB_ModuleLabelInfo MLI
	 WHERE ModuleSerialNo LIKE @SerialHeader + '%'
	 ORDER BY ModuleSerialNo
END