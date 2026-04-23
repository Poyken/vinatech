CREATE PROC [dbo].[usp_VN_STB_VN_DETAILMODULES]
@GROUPID NVARCHAR(50),
@LOTNO NVARCHAR(50),
@QTYACT NVARCHAR(50),
@MaterialCode NVARCHAR(50),
@MaterialName NVARCHAR(100),
@LineCode NVARCHAR(50),
@RouteCode NVARCHAR(50),
@RouteName NVARCHAR(50),
@InputProdQty NVARCHAR(50),
@DefectQty NVARCHAR(50),
@ProdQty NVARCHAR(50),
@CREATEDATEPACKED DATETIME,
@CREATEUSSERID NVARCHAR(50),
@STATUSAGAING NVARCHAR(50)
AS
BEGIN
		 INSERT INTO STB_VN_DETAILMODULES
		 (
			GROUPID,
			LOTNO,
			QTYACT,
			MaterialCode,
			MaterialName,
			LineCode,
			RouteCode,
			RouteName,
			InputProdQty,
			DefectQty,
			ProdQty,
			CREATEDATEPACKED,
			CREATEDATETIME,
			CREATEUSSERID,
			STATUSAGAING
		 )
		 VALUES
		 (
			@GROUPID,
			@LOTNO,
			@QTYACT,
			@MaterialCode,
			@MaterialName,
			@LineCode,
			@RouteCode,
			@RouteName,
			@InputProdQty,
			@DefectQty,
			@ProdQty,
			@CREATEDATEPACKED,
			GETDATE(),
			@CREATEUSSERID,
			@STATUSAGAING
		 )
END