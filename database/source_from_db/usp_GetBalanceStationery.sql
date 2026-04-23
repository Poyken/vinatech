

CREATE PROCEDURE [dbo].[usp_GetBalanceStationery]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pWorkCenterCode nvarchar(20) = NULL,
    @pStationeryCode NVARCHAR(20) = NULL,
	@pWarehousecode NVARCHAR(50) = NULL
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
				StationeyCode,
				SI.StationeryName,
				SI.BasicUnit,
				Quanlity,
				SPIOH.Description,
				SPIOH.CreateDateTime,
				SPIOH.CreateUserID,
				SPIOH.ChangeDateTime,
				SPIOH.ChangeUserID
		FROM Stb_StationeryIOHistory SPIOH
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON SPIOH.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON SPIOH.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_StationeryInfo SI WITH(NOLOCK)
				on SPIOH.StationeyCode = SI.StationeryCode
			LEFT OUTER JOIN stb_WarehouseStationery WS WITH(NOLOCK)
				on SPIOH.SWarehouse = WS.WarehouseCode
		WHERE 
		1=1
		--SIOTypeCode='BALANCE'
		And (@pWarehousecode ='' or @pWarehousecode is null  or SWarehouse = @pWarehousecode)
		And (@pStationeryCode ='' or @pStationeryCode is null or  StationeyCode = @pStationeryCode)

END

