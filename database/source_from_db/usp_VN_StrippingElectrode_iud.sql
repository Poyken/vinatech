-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_StrippingElectrode_iud]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pCalamviec nvarchar(20)= NULL,
		@pModel nvarchar(50) = NULL,
		@pLoaiDienCuc varchar(50) = NULL,
		@pCell_Line nvarchar(50)= NULL,
		@pMayMai nvarchar(50)= NULL,
		@pLotNo nvarchar(100)= NULL,
		@pDienCuc nvarchar(50)= NULL,
		@pTieuChuanChieuDai nvarchar(50)= NULL,
		@pCaiDatChieuDai nvarchar(50) = NULL,
		@pCongNhan nvarchar(100) = NULL,
		@pQcPart nvarchar(50) = NULL,
		@pKhac nvarchar(255) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM STB_SlippingElectrode where LotNo = @pLotNo)
	  BEGIN
       UPDATE STB_SlippingElectrode
        SET 
            CaLamViec = @pCaLamViec,
            Model = @pModel,
            LoaiDienCuc = @pLoaiDienCuc,
            Cell_Line = @pCell_Line,
            MayMai = @pMayMai,
            DienCuc = @pDienCuc,
            TieuChuanChieuDai = @pTieuChuanChieuDai,
            CaiDatChieuDai = @pCaiDatChieuDai,
            CongNhan = @pCongNhan,
            QcPart = @pQcPart,
            Khac = @pKhac
        WHERE LotNo = @pLotNo;
      END
	ELSE
    -- Insert statements for procedure here
	  BEGIN
	   INSERT INTO  STB_SlippingElectrode(
		CaLamViec,
		Model,
		LoaiDienCuc,
		Cell_Line,
		MayMai,
		LotNo,
		DienCuc,
		TieuChuanChieuDai,
		CaiDatChieuDai,
		CongNhan,
		QcPart,
		Khac,
		CreatedDate
	     )
 	  VALUES
	  (
		@pCaLamViec,
		@pModel,
		@pLoaiDienCuc,
		@pCell_Line,
		@pMayMai,
		@pLotNo,
		@pDienCuc,
		@pTieuChuanChieuDai,
		@pCaiDatChieuDai,
		@pCongNhan,
		@pQcPart,
		@pKhac,
		GETDATE()
	 )
	 END

END
