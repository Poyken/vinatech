-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-02-22
-- Description:	Nếu bị lỗi k gộp được box thì kiểm tra xem có phải lỗi do tạo các công đoạn sau khi đã hoàn thành sản xuất hay không. 
-- ============================================= exec usp_UpdateAndDeleteBarcodeMargeBoxErrorB523 '','',
CREATE PROCEDURE [dbo].[usp_UpdateAndDeleteBarcodeMargeBoxErrorB523]
@Barcode VARCHAR(20),-- Enter a lot number for delete
@RouteCode VARCHAR(20) -- Enter a route code for delete (just last route .. V-28 and V-28_BG)
AS
BEGIN
Declare @ProdQty NUMERIC(20,5) 
-- Check a summary data
SELECT *
  FROM STB_ProdRouteSummary PRS
  INNER JOIN STB_ProdRouteHist PRH
    ON PRS.CompanyCode = PRH.CompanyCode
   AND PRS.WorkCenterCode = PRH.WorkCenterCode
   AND PRS.PONo = PRH.PONo
   AND PRS.MaterialCode = PRH.MaterialCode
   AND PRS.RouteCode = PRH.RouteCode
   AND PRS.LineCode = PRH.LineCode
   AND PRS.JobDate = PRH.JobDate
   AND PRS.ShiftCode = PRH.ShiftCode
 WHERE PRH.ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)
   AND PRH.RouteCode = @RouteCode

-- if target row is multi
IF @@ROWCOUNT <> 1 BEGIN
   PRINT 'It cannot be processed automatically.'
   rollback
END ELSE BEGIN
   SELECT @ProdQty = ProdQty -- set Prod Qty
     FROM STB_ProdRouteHist
    WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)
      AND RouteCode = @RouteCode
END

-- Update a STB_ProdRouteSummary data
UPDATE PRS
    SET OutputQty = OutputQty - @ProdQty
   FROM STB_ProdRouteSummary PRS
  INNER JOIN STB_ProdRouteHist PRH
    ON PRS.CompanyCode = PRH.CompanyCode
   AND PRS.WorkCenterCode = PRH.WorkCenterCode
   AND PRS.PONo = PRH.PONo
   AND PRS.MaterialCode = PRH.MaterialCode
   AND PRS.RouteCode = PRH.RouteCode
   AND PRS.LineCode = PRH.LineCode
   AND PRS.JobDate = PRH.JobDate
   AND PRS.ShiftCode = PRH.ShiftCode
 WHERE PRH.ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)
   AND PRH.RouteCode = @RouteCode

-- Delete a STB_ProdRouteHist data
-- Check data
SELECT * FROM STB_ProdRouteHist 
 WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)
   AND RouteCode = @RouteCode

-- if target row is multi
IF @@ROWCOUNT <> 1 BEGIN
   PRINT 'It cannot be processed automatically.'
   rollback
END ELSE BEGIN
   DELETE FROM STB_ProdRouteHist 
    WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)
       AND RouteCode = @RouteCode
END

END
