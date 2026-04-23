-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_StrippingElectrode_get_VietNam]
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pLotNo VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @LotNo VARCHAR(50) = @pLotNo
	BEGIN

			SELECT
    top 1
				--CASE 
    --                WHEN DATEPART(HOUR, GETDATE()) >= 10 AND DATEPART(HOUR, GETDATE()) < 22 
    --                THEN 'Ca A' 
    --                ELSE 'Ca B' 
    --            END AS CaLamViec,
	            '' AS CaLamViec,
				vvt.PartNo as Model,
                vvt.Farad,
				CONCAT(vvt.SlittingCode,SlittingSize) as LoaiDienCuc,
				'' as Cell_Line,
				'' as MayMai,
				ESR.Barcode as LotNo,
				CASE 
                WHEN MM.MaterialName LIKE '%(+)%' THEN N'(+) Cực dương'
                 ELSE N'(-) Cực âm'
                END AS DienCuc,
				ES1.KhoangCachVetMai as TieuChuanChieuDai,
				'' as CaiDatChieuDai,
				'' as CongNhan,
				'' as QcPart,
				'' as Khac
						
				FROM
						STB_ElectrodeSlittingResult ESR WITH(NOLOCK)
						LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)	ON ESR.ElectrodeLotNumber = SI.Barcode
						LEFT OUTER JOIN STB_MaterialMaster MM ON MM.MaterialCode = SI.MaterialCode
						JOIN stb_slittinglocationconfig_vvt vvt WITH(NOLOCK)
						ON (
                          SlittingCode LIKE '%' + MM.MaterialSource + '%' 
                          AND (
                         (
						 REPLACE(SlittingCode, SlittingSize, '') + SlittingSize) LIKE '%' + MM.MaterialThickness + '%' 
                          OR MaterialName LIKE '%' + REPLACE(SlittingCode, SlittingSize, '') + '%' + SlittingSize + '%' 
                         )
						 )
						   AND Width = ESR.SlittingWidth 
                           AND vvt.WarehouseLocation IN ('VVT_F1','VVT_F2')
                        LEFT OUTER JOIN Stb_ElectrodeSpecification_V1 ES1 WITH(NOLOCK) ON vvt.PartNo = ES1.Model
                        AND vvt.Farad = ES1.farad and  
                       CASE 
                       WHEN MM.MaterialName LIKE '%(+)%' THEN N'(+) Cực dương'
                       ELSE N'(-) Cực âm'
                       END = ES1.Cuc
				WHERE
						ESR.Barcode = @LotNo
		END
		END
