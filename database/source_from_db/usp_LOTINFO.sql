CREATE PROC [dbo].[usp_LOTINFO]
		 @pProcessUserID VARCHAR(20) ='',
		 @pProcessLanguage VARCHAR(20) ='',
		 @LOTnum VARCHAR (15)= '',
		 @FromDate VARCHAR (8)= '20191026',
		 @ToDate VARCHAR (8) = '20191031'
AS
	--Lot번호, 품목코드, 품목명, 라인코드, 라인명, 작업시작일시, 생산완료일시, 마킹문자, 진성불량수
	DECLARE @TimeSet VARCHAR(8)
	       SET @TimeSet = '08:30:00'

	DECLARE @OnlyToDate DATE = CONVERT(NVARCHAR(10),DATEADD(DAY,1,@ToDate),112);

	DECLARE @TEMP NVARCHAR(20);
	      SET @TEMP = CONVERT(NVARCHAR(10),@OnlyToDate,112)+' '+@TimeSet

	DECLARE @FinalToDate DATETIME;
	       SET @FinalToDate = CONVERT(NVARCHAR(18),@TEMP,120);

	print @FinalToDate

	SELECT SI.Barcode AS LOT번호,
			MM.MaterialName AS 품목명,
			SI.InputLineCode AS 라인코드,
			Li.LineName AS 라인명,
			SI.InputDateTime AS 작업시작일시,
			SI.ProdFinishDateTime AS 생산완료일시,
			SI.SIExtText07 AS 마킹문자, 
			SI.SIExtInt02   AS 진성불량수                                    -- 2020.01.28 추가

	FROM SmartFactoryV2.dbo.STB_SetInfo SI
			LEFT OUTER JOIN (select MaterialCode,MaterialName  from SmartFactoryV2.dbo.STB_MaterialMaster) MM			ON SI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN (select LineCode, LineName           from SmartFactoryV2.dbo.STB_LineInfo) LI                   ON SI.InputLineCode = LI.LineCode
	where SI.Barcode = @LOTnum
	  and (SI.InputDateTime BETWEEN @FromDate AND @FinalToDate) 
	  and (SI.ProdFinishDateTime BETWEEN @FromDate AND @FinalToDate)
