--exec usp_OutNVLStationery '','','VVT','VVT_F2','','','2024-10-01','2024-11-04'
/*
xuất kho có 2 SIOTypeCode là : 
 + TF : Xuất ở màn hình H144
 + Out : Xuất ở màn hình H145
*/
CREATE PROCEDURE [dbo].[usp_OutNVLStationery]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode nvarchar(20) = NULL,
	@pWorkCenterCode nvarchar(20) = NULL,
    @pStationeryCode NVARCHAR(20) = NULL,
	@pInvoiceNo NVARCHAR(20) = NULL,
	@pFromDate date = NULL ,
	@pToDate date = NULL

AS
BEGIN
     DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END

	 -- Update 2025-07-28 following Ms.Thao's request
	 IF @WorkCenterCode = 'VVT_F1' 
		BEGIN 
			SELECT  SPIOH.CompanyCode,
					CI.CompanyName,
					CI.CompanyNameL,
				
					SPIOH.WorkCenterCode,
					WCI.WorkCenterName,
					WCI.WorkCenterNameL,
					SIOTypeCode,
					SIOHistoryNo,
					SWarehouse,
					WS.WarehouseName,
					ToSWarehouse,
					WS1.WarehouseName as ToWarehouseName,
					StationeyCode,
					SI.StationeryName,
					SI.BasicUnit,
					SPIOH.Quanlity,
					SPIOH.VendorCode,
					CTI.CustomerName,
					SPIOH.Unitprice,
					SPIOH.EmpNo,
					ES.Name,
					convert(varchar, SPIOH.BasicDate, 111) as BasicDate, 
					SPIOH.InvoiceNo,
					SPIOH.Dept,
					SPIOH.Purpose,
					SPIOH.Description
			FROM Stb_StationeryIOHistory SPIOH
				LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
					ON SPIOH.WorkCenterCode = WCI.WorkCenterCode
				LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
					ON SPIOH.CompanyCode = CI.CompanyCode
				LEFT OUTER JOIN STB_StationeryInfo SI WITH(NOLOCK)
					on SPIOH.StationeyCode = SI.StationeryCode
				LEFT OUTER JOIN stb_WarehouseStationery WS WITH(NOLOCK)
					on SPIOH.SWarehouse = WS.WarehouseCode
				LEFT OUTER JOIN stb_WarehouseStationery WS1 WITH(NOLOCK)
					on SPIOH.ToSWarehouse = WS1.WarehouseCode

				LEFT OUTER JOIN STB_CustomerInfo CTI WITH(NOLOCK)
					on SPIOH.VendorCode = CTI.CustomerCode
				LEFT OUTER JOIN Stb_EmployeeStationery ES WITH(NOLOCK)
					ON SPIOH.EmpNo = ES.CodeEmp
			WHERE 1=1
			And --SIOTypeCode='OUT'
			( SIOTypeCode IN ('OUT', 'TF'))  -- update
			--And SWarehouse = 'KNVL'
			--and ToSWarehouse ='KSX'
			And (@pStationeryCode ='' or @pStationeryCode is null or  StationeyCode = @pStationeryCode)
			And (@pInvoiceNo ='' or @pInvoiceNo is null or  InvoiceNo = @pInvoiceNo)
			And (BasicDate between @pFromDate and @pToDate)
			AND ((@WorkCenterCode = '*') OR (SPIOH.WorkCenterCode = @WorkCenterCode))
		END


	ELSE
		BEGIN
			SELECT  SPIOH.CompanyCode,
					CI.CompanyName,
					CI.CompanyNameL,
				
					SPIOH.WorkCenterCode,
					WCI.WorkCenterName,
					WCI.WorkCenterNameL,
					SIOTypeCode,
					SIOHistoryNo,
					SWarehouse,
					WS.WarehouseName,
					ToSWarehouse,
					WS1.WarehouseName as ToWarehouseName,
					StationeyCode,
					SI.StationeryName,
					SI.BasicUnit,
					SPIOH.Quanlity,
					SPIOH.VendorCode,
					CTI.CustomerName,
					SPIOH.Unitprice,
					SPIOH.EmpNo,
					ES.Name,
					convert(varchar, SPIOH.BasicDate, 111) as BasicDate, 
					SPIOH.InvoiceNo,
					SPIOH.Dept,
					SPIOH.Purpose,
					SPIOH.Description
			FROM Stb_StationeryIOHistory SPIOH
				LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
					ON SPIOH.WorkCenterCode = WCI.WorkCenterCode
				LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
					ON SPIOH.CompanyCode = CI.CompanyCode
				LEFT OUTER JOIN STB_StationeryInfo SI WITH(NOLOCK)
					on SPIOH.StationeyCode = SI.StationeryCode
				LEFT OUTER JOIN stb_WarehouseStationery WS WITH(NOLOCK)
					on SPIOH.SWarehouse = WS.WarehouseCode
				LEFT OUTER JOIN stb_WarehouseStationery WS1 WITH(NOLOCK)
					on SPIOH.ToSWarehouse = WS1.WarehouseCode

				LEFT OUTER JOIN STB_CustomerInfo CTI WITH(NOLOCK)
					on SPIOH.VendorCode = CTI.CustomerCode
				LEFT OUTER JOIN Stb_EmployeeStationery ES WITH(NOLOCK)
					ON SPIOH.EmpNo = ES.CodeEmp
			WHERE 1=1
			And --SIOTypeCode='OUT'
			SIOTypeCode='TF'
			--And SWarehouse = 'KNVL'
			--and ToSWarehouse ='KSX'
			And (@pStationeryCode ='' or @pStationeryCode is null or  StationeyCode = @pStationeryCode)
			And (@pInvoiceNo ='' or @pInvoiceNo is null or  InvoiceNo = @pInvoiceNo)
			And (BasicDate between @pFromDate and @pToDate)
			AND ((@WorkCenterCode = '*') OR (SPIOH.WorkCenterCode = @WorkCenterCode)) 
		END
END

