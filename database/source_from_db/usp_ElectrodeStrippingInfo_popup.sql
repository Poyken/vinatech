
CREATE PROCEDURE [dbo].[usp_ElectrodeStrippingInfo_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT 
	CONCAT(Model, '-', Farad, 'F', '',Cuc,'','',Id,'') as ModelCode,
	Model,
	Farad,
	Cuc as DienCuc,
	KhoangCachVetMai as TieuChuanChieuDai,
	KhoangCachVetMai as CaiDatChieuDai

	FROM
			Stb_ElectrodeSpecification_V1 WITH(NOLOCK)
END