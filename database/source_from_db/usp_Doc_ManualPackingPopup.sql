-- =============================================
-- Author : Kangs(kilee@vian.co.kr)
-- Group :  제품관리 PackingID 팝업
-- Browsable : true
-- Create date : 2020-07-24
-- Description : 수동포장 PackingID 팝업
-- Modified :
-- usp_Doc_ManualPackingPopup
-- =============================================
CREATE PROCEDURE [dbo].[usp_Doc_ManualPackingPopup]
AS
BEGIN
	SET NOCOUNT ON;

	-- 기존 로직의 경우 일자별 일련번호 기준을 잡을 수 없으며,
	-- 데이터가 누적될 수록 속도 저하가 심하게 발생하여, (Nested Loop)
	-- 아래와 같이 수정함. 
	-- 기준데이터-STB_ManualPacking-는 2025년 11월 13일까지 생성되어 있음.
	-- 2020-08-14 By Jackaroe

	DECLARE @Year INT
	DECLARE @Month INT
	DECLARE @YearCode VARCHAR(1)
	DECLARE @MonthCode VARCHAR(1)
	DECLARE @DayCode VARCHAR(2)
	
	SET @Year = DATEPART(YEAR, GETDATE())
	SET @Month = DATEPART(MONTH, GETDATE())

	SELECT @YearCode = YI.YearCode FROM STB_YearInfo YI WHERE YI.Year = @Year
	SET @MonthCode = CHAR(@Month + 73)
	SET @DayCode = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY, GETDATE())),2)   

	SELECT TOP 1 PackingID 
	  FROM STB_ManualPacking
	 WHERE PackingID NOT IN (SELECT ISNULL(PackingID, '*') From STB_StocktakingPlanResult)
	   AND PackingID LIKE 'PT' + @YearCode + @MonthCode + @DayCode + '%'
	 ORDER BY PackingID ASC
END