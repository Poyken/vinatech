-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_StrippingElectrode_get_V1]
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pLotNo NVARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @LotNo VARCHAR(50) = @pLotNo

	--DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00'
	--DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00'

    SELECT
	    SE.CreatedDate AS Ngay,
		SE.CaLamViec ,
		SE.Model,
		SE.LoaiDienCuc,
		SE.Cell_Line,
		SE.MayMai,
		SE.LotNo,
		SE.DienCuc,
		SE.TieuChuanChieuDai,
		SE.CaiDatChieuDai,
		PWI.WorkerName as CongNhan,
		SE.QcPart,
		SE.Khac
		
	from STB_SlippingElectrode SE WITH(NOLOCK)
	LEFT OUTER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK)	ON SE.CongNhan = PWI.WorkerCode
	LEFT OUTER JOIN STB_ElectrodeSlittingResult ESR WITH(NOLOCK)	ON SE.LotNo = ESR.Barcode
	--where PAC.CREATEDATE BETWEEN @FromDate AND @ToDate
	where ESR.ElectrodeLotNumber = @LotNo

	ORDER BY SE.CreatedDate asc


END
