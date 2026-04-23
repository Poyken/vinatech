CREATE PROC [dbo].[usp_LotInfo_get]
				 @pProcessUserID		Varchar(20) = '',
				 @pProcessLanguage  Varchar(20) = '',
				 @pLOTnum				Varchar(15) = '',
				 @pFromDate			Date, 
				 @pToDate				Date 
AS

	BEGIN

	--Lot번호, 품목코드, 품목명, 라인코드, 라인명, 작업시작일시, 생산완료일시, 마킹문자
		DECLARE
		@FromDate DateTime = CONVERT(VARCHAR(10),                      @pFromDate, 121) + ' 08:30:00',
		@ToDate    DateTime = CONVERT(VARCHAR(10), DateAdd (day, 1, @pTodate),   121) + ' 08:29:59'

		
			SELECT
					X.Barcode						AS LOT번호,
					X.MaterialName					AS 품목명,
					X.InputLineCode					AS 라인코드,
					X.LineName						AS 라인명,
					X.InputDateTime					AS 작업시작일시,
					X.ProdFinishDateTime			AS 생산완료일시,
					X.SIExtText07						AS 마킹문자,
					B.ControlNO						AS 컨트롤NO,
					B.FindRouteCode				AS 공정코드,
					B.RouteName					AS 공정명,
					X.ProdQty							AS 투입량,
					X.ProdQty - B.DefectQtyTotal  AS 양품수량,
					B.DefectQtyTotal					AS 불량수량,
					X.SIExtInt02						AS 진성불량수           -- 2020.01.28 추가
			FROM (
						select	SI.Barcode ,
								MM.MaterialName ,
								SI.InputLineCode ,
								Li.LineName ,
								SI.InputDateTime ,
								SI.ProdFinishDateTime ,
								SI.SIExtText07,
								SI.ControlNo,
								PRH.ProdQty,
								PRH.RouteCode,
								SI.SIExtInt02                                     -- 2020.01.28 추가
						from SmartFactoryV2.dbo.STB_SetInfo SI
								LEFT OUTER JOIN SmartFactoryV2.dbo.STB_MaterialMaster MM			ON SI.MaterialCode = MM.MaterialCode
								LEFT OUTER JOIN SmartFactoryV2.dbo.STB_LineInfo LI				    ON SI.InputLineCode = LI.LineCode
								LEFT OUTER JOIN SmartFactoryV2.dbo.STB_ProdRouteHist PRH			ON PRH.ControlNo = SI.ControlNo
						where (SI.Barcode = @pLOTnum
						   and (SI.InputDateTime BETWEEN @pFromDate AND @ToDate) ) OR (@pLOTnum = '' and (SI.InputDateTime BETWEEN @pFromDate AND @ToDate))
						) X
			LEFT JOIN
			( SELECT DRI.FindRouteCode,
						RI.RouteName,
							SI.ControlNo,
						sum(DRI.DefectQty) AS DefectQtyTotal
				FROM SmartFactoryV2.dbo.STB_SetInfo SI
						LEFT OUTER JOIN SmartFactoryV2.dbo.STB_ProdRouteHist PRH		ON SI.ControlNo = PRH.ControlNo
						LEFT OUTER JOIN SmartFactoryV2.dbo.STB_RouteInfo RI			    ON PRH.RouteCode = RI.RouteCode
						INNER JOIN SmartFactoryV2.dbo.STB_DefectRepairInfo DRI			ON DRI.ControlNo = PRH.ControlNo
				where DRI.DefectCode != 'MISSING' and DRI.DefectCode != 'FINISH' and DRI.FindRouteCode = PRH.RouteCode
				Group BY DRI.FindRouteCode,SI.ControlNo, RI.RouteName
			) B	
			ON  X.ControlNo = B.ControlNo and  X.RouteCode = B.FindRouteCode 

	END
