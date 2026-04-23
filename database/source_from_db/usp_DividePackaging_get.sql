-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-04
-- Description:	Lịch sử tách packing chia tem nếu khách hàng mong muốn
-- EXEC usp_DividePackaging_get'','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_DividePackaging_get]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pDividePackagingID VARCHAR(50)=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
     -- Chuẩn hóa giá trị PackingID đầu vào
    -- Chuẩn hóa giá trị PackingID đầu vào
    DECLARE @DividePackagingID VARCHAR(50) = CASE 
                                                WHEN ISNULL(@pDividePackagingID, '') = '' THEN '%' 
                                                ELSE @pDividePackagingID 
                                             END;

    -- Giá trị mặc định cho LabelType
    DECLARE @LabelType VARCHAR(50) = 'BoxLabel';

    -- CTE lấy thông tin Label mới nhất
    ;WITH LabelInfo AS (
        SELECT
            RANK() OVER (PARTITION BY LI.LabelType, LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,
            LI.LabelType,
            LI.FormatName,
            LI.CommandType,
            LI.Dpi,
            LI.PrinterName
        FROM SmartFramework.dbo.STB_LabelInfo LI WITH (NOLOCK)
        WHERE LI.IsApproval = 1
          AND LI.ApplyDate <= GETDATE()
    )

    SELECT 
        DP.DividePackagingID,
        MLI.MaterialCode,
        MM.MaterialName,
        MLI.PackingID,

        -- FormatName theo điều kiện phức tạp
        CASE 
            WHEN MLI.WorkCenterCode = 'VVT_F3' THEN LI.FormatName + 'NewVietNam_HN'
            WHEN LI.FormatName LIKE '%삼성향%' THEN LI.FormatName + 'NewVietNam'
            ELSE (
                CASE 
                    WHEN '' <> '' THEN '포장라벨Sagecom'  -- biến bị thiếu nên để rỗng
                    ELSE '포장라벨NewVietNam'
                END
            )
        END AS FormatName,

        ISNULL(LI.CommandType, 'Report') AS CommandType,
        ISNULL(LI.Dpi, '200') AS Dpi,
        ISNULL(LI.PrinterName, '') AS PrinterName,

        0 AS LabelQty,
        0 AS LotQty,
        MLI.CurrentQty,
        MLI.LotNo,

        ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage, 
        ISNULL(PLS.Farad, MBI.MBIExtText05) AS Farad,
        CONVERT(VARCHAR, CONVERT(NUMERIC(20,1), MBI.MBISizeW)) AS MBISizeW,
        CONVERT(VARCHAR, CONVERT(NUMERIC(20,1), MBI.MBISizeH)) AS MBISizeH,
        ISNULL(PLS.Rating, '(' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')') AS Rating,
        
        ISNULL(MLI.StockAttrib1, '') AS StockAttrib1,
        COALESCE(NULLIF(CML.MarkingName, ''), SI.SIExtText07, 'notsave') AS MarkingLetter,

        ISNULL(SPS.VinylBagQty, 0) AS VinylBagQty,
        ISNULL(SPS.InnerBoxQty, 0) AS InnerBoxQty,
        ISNULL(SPS.OutBoxQty, 0) AS OutBoxQty,
        MM.MaterialUnit,

        0 AS QtySliptBox,
        0 AS QtySliptBox_Export

    FROM STB_DividePackaging DP
    LEFT JOIN STB_MaterialLotInfo MLI WITH (NOLOCK) 
        ON DP.PackingID = MLI.PackingID
    LEFT JOIN STB_MaterialMaster MM WITH (NOLOCK) 
        ON MM.MaterialCode = MLI.MaterialCode
    LEFT JOIN STB_ModelLabelInfo MLBI WITH (NOLOCK) 
        ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
    LEFT JOIN LabelInfo LI WITH (NOLOCK) 
        ON LI.LabelType = MLBI.LabelType AND LI.FormatName = MLBI.FormatName AND LI.RankIndex = 1
    LEFT JOIN STB_ModelBasicInfo MBI WITH (NOLOCK) 
        ON MLI.MaterialCode = MBI.ModelCode
    LEFT JOIN STB_PackingLabelSpec PLS WITH (NOLOCK) 
        ON MLI.LotID = PLS.LotID
    LEFT JOIN STB_SetInfo SI WITH (NOLOCK) 
        ON SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo
    LEFT JOIN STB_CreateMarkingLetterAndQtyForBarcode CML WITH (NOLOCK) 
        ON MLI.MarkingCode = CML.MarkingCode
    LEFT JOIN STB_PackingStandard SPS WITH (NOLOCK) 
        ON SPS.MaterialTypeCode = MM.MaterialTypeCode 
           AND SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size
    WHERE DP.PackingID LIKE @DividePackagingID  AND ISNULL(MLI.MaterialCode, '') <> ''

	 

   

END
