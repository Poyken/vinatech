-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022.05.26
-- Description:	SmartFactoryV2에 쌓인 라이별 품목정보를 110.11.27.7에 입력한다.
-- =============================================
CREATE PROC usp_MaterialCodeByLine_itf
AS 
BEGIN
	INSERT INTO erpsvr.vinatech.dbo.STB_MaterialCodeByLine (LineCode, MaterialCode, CreateDateTime)
		SELECT LineCode, MaterialCode, CreateDateTime
		  FROM STB_MaterialCodeByLine
		 WHERE CreateDateTime > DATEADD(hour, -2, GETDATE())
END
