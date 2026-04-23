-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019.02.11
-- Browsable : true
-- Group : 생산관리
-- Description:	Lot 생산현황 조회(종합)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_AssyCardInfo_get]
	@pProcessUserID [varchar](20),
	@pProcessLanguage [varchar](20),
	@pBarcode [varchar](20) = NULL
WITH EXECUTE AS CALLER
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @Barcode VARCHAR(20) = @pBarcode

	-- 공통정보
	SELECT SI.MaterialCode
	      ,MM.MaterialName
		  ,SI.Barcode
		  ,SI.InputLineCode
		  ,SI.InputJobDate
		  ,SI.ProdQty
		  ,SI.SIExtText02 AS OvenInputDateTime
		  ,SI.SIExtText03 AS OvenOutputDateTime
		  ,SI.SIExtText04 AS HighTempStoringInputDateTime
		  ,SI.SIExtText05 AS HighTempStoringOutputDateTime
		  ,SI.SIExtText06 AS CommInspectionUserID
		  ,VWUI.UserName AS CommInspectionUserName
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON SI.MaterialCode = MM.MaterialCode
	  LEFT OUTER JOIN VW_UserInfo VWUI
	    ON SI.SIExtText06 = VWUI.UserID
	 WHERE Barcode = @Barcode

	 -- 실적등록정보
	 SELECT PRH.MaterialCode
	       ,MM.MaterialName
		   ,PRH.LineCode
		   ,PRH.RouteCode
		   ,PRH.WorkerCode
		   ,VWUI.UserName
		   ,PRH. MachineCode 
		   ,MM2.MachineName
		   ,PRH.ProdQty AS InputProdQty
		   ,DRI.DefectQty
		   ,(PRH.ProdQty - DRI.DefectQty) AS ProdQty
	   FROM STB_ProdRouteHist PRH
	   LEFT OUTER JOIN STB_MaterialMaster MM
	     ON PRH.MaterialCode = MM.MaterialCode
	   LEFT OUTER JOIN VW_UserInfo VWUI
	     ON PRH.WorkerCode = VWUI.UserID
	   LEFT OUTER JOIN STB_MachineMaster MM2
	     ON PRH.MachineCode = MM2.MachineCode
	   LEFT OUTER JOIN (SELECT ControlNo, FindRouteCode, SUM(DefectQty) AS DefectQty 
	                      FROM STB_DefectRepairInfo 
						 GROUP BY ControlNo, FindRouteCode) DRI
	     ON PRH.ControlNo = DRI.ControlNo
        AND PRH.RouteCode = DRI.FindRouteCode
	  WHERE PRH.ControlNo = (SELECT ControlNo
	                       FROM STB_SetInfo SI
						  WHERE Barcode = @Barcode
						)

	--라인 건조오븐 현황정보
	SELECT SI.SIExtText06 AS OvenCode
	      ,SI.SIExtText02 AS OvenInputDateTime
		  ,SI.SIExtText03 AS OvenOutputDateTime
	  FROM STB_SetInfo SI
	 WHERE InputLineCode = (SELECT InputLineCode 
	                          FROM STB_SetInfo 
							 WHERE Barcode = @Barcode
						   )
	   AND RTRIM(ISNULL(SI.SIExtText02, '')) <> ''
	   AND RTRIM(ISNULL(SI.SIExtText03, '')) = ''
	 ORDER BY OvenInputDateTime
END