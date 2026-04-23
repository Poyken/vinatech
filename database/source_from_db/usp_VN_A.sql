CREATE PROC usp_VN_A
@ABC NVARCHAR(50)
AS
BEGIN

DECLARE @Barcode NVARCHAR(50)

SELECT
	@Barcode = PRH.RouteCode
 FROM STB_ProdRouteHist PRH
 WHERE PRH.ControlNo = ( SELECT ControlNo
									   FROM STB_SetInfo SI
									  WHERE Barcode = @ABC
									  ) AND PRH.RouteCode = 'V-28'

if @Barcode IS NOT NULL
BEGIN
		SELECT
	 PRH.RouteCode
 FROM STB_ProdRouteHist PRH
 WHERE PRH.ControlNo = ( SELECT ControlNo
									   FROM STB_SetInfo SI
									  WHERE Barcode = @ABC
									  ) AND PRH.RouteCode = 'V-28'
END

ELSE
BEGIN
	 SELECT PRH.RouteCode
 FROM STB_ProdRouteHist PRH
 WHERE PRH.ControlNo = ( SELECT ControlNo

									   FROM STB_SetInfo SI
									  WHERE Barcode = @ABC
									  ) AND PRH.RouteCode = 'E-28'
END


END