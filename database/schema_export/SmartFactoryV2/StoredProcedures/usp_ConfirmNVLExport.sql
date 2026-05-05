-- Procedure: usp_ConfirmNVLExport
-- =============================================
-- Author:		Mr.Duy
-- Create date: 18.12.2023
-- Description:	Xác nhận gửi NVL từ kho này sang kho khác
-- =============================================
CREATE PROCEDURE [dbo].[usp_ConfirmNVLExport]
		@pProcessUserID varchar(20),
		@pProcessLanguage varchar(20),
		@pFromDate DATETIME = NULL,
		@pToDate DATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @FromDate DATETIME  = @pFromDate
	DECLARE @ToDate DATETIME    = @pToDate

	--select MaterialWarehouseInOutHistNo,CompanyCode,WorkCenterCode,SourceMaterialWarehouseCode,TargetMaterialWarehouseCode,WarehouseInOutCode,
	--LotID,WorkerCode,CreateDateTime,CreateUserID,Status_Confirm_Export
	--from STB_MaterialWarehouseInOutHist 
	-- where CompanyCode='VVT' and CreateDateTime>=@FromDate+'00:00:00' and CreateDateTime<=@pToDate+'23:59:59.999' and  Status_Confirm_Export =0 and WarehouseInOutCode='O'
	 --and TargetMaterialWarehouseCode='ROH_BG_WH'
	 select ioh.MaterialWarehouseInOutHistNo,ioh.CompanyCode,ioh.WorkCenterCode,ioh.SourceMaterialWarehouseCode,ioh.TargetMaterialWarehouseCode,ioh.WarehouseInOutCode,ioh.LineCode,
	ioh.LotID,ioh.WorkerCode,ioh.CreateDateTime,ioh.CreateUserID,ioh.Status_Confirm_Export,isnull(MLI.MaterialCode,MdLI.MaterialCode) as MaterialCode,	MM.MaterialName,
	isnull(MLI.CurrentQty,mdli.StockQty) AS StockQty
FROM
		(
		select  MaterialDocDetailNo,MaterialLotNo,lotno,LotID,MaterialLocationCode,MaterialCode,StockQty,LotAttr09,replace(replace(replace(ltrim(rtrim(isnull(LotAttr10,''))),'--','-' ),'--','-' ),' ','' )as LotAttr10
		from STB_MaterialdocLotInfo  WITH(NOLOCK) 
		union all 
		select '',MaterialLotNo,lotno,LotID,MaterialLocationCode,MaterialCode,currentqty,LotAttr09,replace(replace(replace(ltrim(rtrim(isnull(LotAttr10,''))),'--','-' ),'--','-' ),' ','' )as LotAttr10
		from STB_MaterialLotInfo  WITH(NOLOCK) 
		where lotid like 'SP%' 
		) mdli --with(nolock) 
		left outer join STB_MaterialLotInfo mli  with(nolock) on mdli.LotID = mli.LotID
		left outer join STB_MaterialWarehouseInOutHist ioh  with(nolock) on mdli.LotID = ioh.LotID
		left outer join STB_MaterialDocDetail mdd  with(nolock) on mdd.MaterialDocDetailNo = mdli.MaterialDocDetailNo
		left outer join STB_MaterialDocInfo mdi with(nolock)  on mdd.MaterialDocNo = mdi.MaterialDocNo
			LEFT OUTER jOIN STB_MaterialMaster MM WITH(NOLOCK)			ON	MdLI.MaterialCode = MM.MaterialCode
		Where  ioh.CompanyCode='VVT' and ioh.CreateDateTime>=@FromDate+'00:00:00' and ioh.CreateDateTime<=@pToDate+'23:59:59.999' 
		--and  ioh.Status_Confirm_Export =0 
		and ioh.WarehouseInOutCode='O'
			and (ioh.SourceMaterialWarehouseCode='ROH_BG_WH' or ioh.SourceMaterialWarehouseCode='ROH_VN_WH')
			and (ioh.TargetMaterialWarehouseCode='ROH_VN_WH' or ioh.TargetMaterialWarehouseCode in ('ROH_BG_WH','ROUTE_VN_WH'))
END



GO

