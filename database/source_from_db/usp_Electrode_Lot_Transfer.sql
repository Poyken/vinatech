-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-08-08
-- Description:	Lấy danh sách lot điện cực đã cắt chưa bắn lên hệ thống.
-- ============================================= exec usp_Electrode_Lot_Transfer'','','2024-07-20','2024-08-09'
CREATE PROCEDURE [dbo].[usp_Electrode_Lot_Transfer]
		@pProcessUserID varchar(20)=NULL,
		@pProcessLanguage varchar(20)=NULL,
		@pFromDate DATETIME = NULL,
		@pToDate DATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FromDate DATETIME  = @pFromDate
	DECLARE @ToDate DATETIME    = @pToDate


	select ESR.*,MM.MaterialCode,MM.MaterialName
	  FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK) 
	  left outer join STB_RawMaterialInputHist ss WITH(NOLOCK)  on ESR.Barcode = ss.LotMaterialCode
	  LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)   ON ESR.ElectrodeLotNumber = SI.Barcode
	  LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode = SI.MaterialCode
	  where 
	  1=1
	  and ss.LotMaterialCode is null -- lấy ra danh sách không thuộc bảng stb_slittingStock_VVT
	  and ESR.WorkCenterCode='VVT_F1'
	  and	ESR.CreateDateTime>=@FromDate
	  and ESR.CreateDateTime<=@ToDate
END
