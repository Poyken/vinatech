

CREATE PROCEDURE [dbo].[usp_InputNVLStationery]
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

		SELECT  SPIOH.CompanyCode,
				CI.CompanyName,
				CI.CompanyNameL,
				
				SPIOH.WorkCenterCode,
				WCI.WorkCenterName,
				WCI.WorkCenterNameL,
				SIOTypeCode,
				SIOHistoryNo,
				SWarehouse,
				WarehouseName,
				ToSWarehouse,
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
			LEFT OUTER JOIN STB_CustomerInfo CTI WITH(NOLOCK)
				on SPIOH.VendorCode = CTI.CustomerCode
			LEFT OUTER JOIN Stb_EmployeeStationery ES WITH(NOLOCK)
				ON SPIOH.EmpNo = ES.CodeEmp
		WHERE SPIOH.SIOTypeCode='IN'
		--And SWarehouse = 'KNVL'
		And (@pStationeryCode ='' or @pStationeryCode is null or  StationeyCode = @pStationeryCode)
		And (@pInvoiceNo ='' or @pInvoiceNo is null or  InvoiceNo = @pInvoiceNo)
		And (BasicDate between @pFromDate and @pToDate)
		AND ((@WorkCenterCode = '*') OR (SPIOH.WorkCenterCode = @WorkCenterCode)) 

END


