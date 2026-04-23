
-- exec usp_OutKSXStationery '','','','','VVT_F1','','2023-01-01','2024-01-24'
CREATE PROCEDURE [dbo].[usp_OutKSXStationery] 
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
				LF.LineName,
				ES.Name,
				convert(varchar, SPIOH.BasicDate, 111) as BasicDate, 
				SPIOH.InvoiceNo,
				SPIOH.LineCode,
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
			left outer join STB_LineInfo LF with(nolock)
			    on SPIOH.LineCode = LF.LineCode
		WHERE SIOTypeCode='OUT'
		And SWarehouse = 'KSX'
		And (@pStationeryCode ='' or @pStationeryCode is null or  StationeyCode = @pStationeryCode)
		And (@pInvoiceNo ='' or @pInvoiceNo is null or  InvoiceNo = @pInvoiceNo)
		And (BasicDate between @pFromDate and @pToDate)
		And (@pWorkCenterCode = '' OR  @pWorkCenterCode IS NULL OR SPIOH.WorkCenterCode = @pWorkCenterCode)


END

select * from Stb_StationeryIOHistory