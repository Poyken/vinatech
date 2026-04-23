
 CREATE PROC [dbo].[usp_VN_insert_Transfer] -- EXEC usp_VN_insert_Transfer 'vc','V-22_BG','a','b','c','e','es'  ---,'rs' --,'sd'---,'gs'
@pBarcode NVARCHAR(100),
@pRouteCode NVARCHAR(100),
@SECURITYAPPERVOER_BN NVARCHAR(50),
@PERSONAPPROVER_BN NVARCHAR(50),
@PERSONAPPROVER_BG NVARCHAR(50),
@SECURITYAPPERVOER_BG NVARCHAR(50),
@FACTORYCODE NVARCHAR(50),
@CREATEBY NVARCHAR(50)
 AS
 BEGIN

SET NOCOUNT ON;

DECLARE @Barcode   NVARCHAR(50)
DECLARE @ControlNo NVARCHAR(50)
DECLARE @RouteCode NVARCHAR(50)
DECLARE @RouteName NVARCHAR(50)
DECLARE @LineCode  NVARCHAR(50)
DECLARE @LineName  NVARCHAR(50)
DECLARE @PONo      NVARCHAR(50)
DECLARE @MaterialCode NVARCHAR(50)
DECLARE @MaterialName NVARCHAR(50)
DECLARE @ProdQty      NVARCHAR(50)
DECLARE @CreateUserID   NVARCHAR(50)
DECLARE @CreateDateTime NVARCHAR(50)
DECLARE @DayPlanNo      NVARCHAR(50)


 
SELECT  DISTINCT @Barcode = A.Barcode,
				 @ControlNo = A.ControlNo,
				 @RouteCode = B.RouteCode,
				 @RouteName = E.RouteName,
				 @LineCode = B.LineCode,
				 @LineName = C.LineName,
				 @PONo = B.PONo,
				 @MaterialCode = D.MaterialCode,
				 @MaterialName = D.MaterialName,
				 @ProdQty = B.ProdQty,
				 @CreateUserID = A.CreateUserID,
				 @CreateDateTime = A.CreateDateTime,
				 @DayPlanNo = B.DayPlanNo,
				 @CreateUserID = A.CreateUserID,
				 @CreateDateTime = A.CreateDateTime
 FROM 
		 STB_SetInfo A WITH(NOLOCK)
		 LEFT OUTER JOIN  STB_ProdRouteHist B WITH(NOLOCK) ON A.ControlNo=B.ControlNo	
		 LEFT OUTER JOIN STB_MaterialMaster D WITH(NOLOCK) ON A.MaterialCode = D.MaterialCode
		 LEFT OUTER JOIN STB_LineInfo C WITH(NOLOCK) ON A.InputLineCode = C.LineCode
		 LEFT OUTER JOIN STB_RouteInfo E WITH(NOLOCK) ON E.RouteCode = B.RouteCode
		
WHERE
		 A.Barcode = @pBarcode AND E.RouteCode = @pRouteCode

	

INSERT INTO STB_VN_STAGES_TRANSFER 
(
Barcode,
ControlNo,
RouteCode,
RouteName,
LineCode,
LineName,
PONo,
MaterialCode,
MaterialName,
ProdQty,
DayPlanNo,
SECURITYAPPERVOER_BN,
PERSONAPPROVER_BN,
SECURITYAPPERVOER_BG,
PERSONAPPROVER_BG,
FACTORYCODE,
CREATEBY,
DATEBY,
CreateUserID,
CreateDateTime
)
VALUES
(
@Barcode,
@ControlNo,
@RouteCode,
@RouteName,
@LineCode,
@LineName,
@PONo,
@MaterialCode,
@MaterialName,
@ProdQty,
@DayPlanNo,
@SECURITYAPPERVOER_BN,
@PERSONAPPROVER_BN,
@SECURITYAPPERVOER_BG,
@PERSONAPPROVER_BG,
@FACTORYCODE,
@CREATEBY,
GETDATE(),
@CreateUserID,
@CreateDateTime
)

 END


 -- select * from STB_VN_STAGES_TRANSFER
 -- delete  STB_VN_STAGES_TRANSFER