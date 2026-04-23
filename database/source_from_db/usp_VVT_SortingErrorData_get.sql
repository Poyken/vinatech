CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_get]
    @pProcessUserID     VARCHAR(20)    = NULL, 
    @pProcessLanguage   VARCHAR(20)    = NULL,
    @pProcessViewName   VARCHAR(50)    = NULL, 
    @pDateFrom          DATE           = NULL,
    @pDateTo            DATE           = NULL,
    @pMaterialCode      VARCHAR(50)    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Tá»± Ä‘á»™ng nháº­n diá»‡n ALCASE hay PLATE tá»« ViewName
    DECLARE @vMaterialType VARCHAR(20) = CASE 
        WHEN @pProcessViewName LIKE '%ALCASE%' THEN 'ALCASE'
        WHEN @pProcessViewName LIKE '%PLATE%'  THEN 'PLATE'
        ELSE NULL END;

    SELECT
        SortingID,
        CONVERT(VARCHAR(10), SortingDate, 23) AS SortingDate, -- Force YYYY-MM-DD
        Shift, PersonName, VendorCode, FactoryName, MaterialCode, LotNo, MaterialType, QtyCheck, QtyOK, Remark,
        ALBuiDust, ALMoDent, ALMepDeform, ALXuocScratch, ALBongNBPlating, ALSanRoughFace, ALBanDirty, ALBanBoDentGroup, ALBienSacDiscolor, ALLoiKhacOther,
        PLBuuNhom, PLBuuNhua, PLBuuRandom, PLBongTamNhieu, PLXuocScratch, PLBienDangDeform, PLMoDongExposed, PLBienDangCamSu, PLNutGoCrackWood, PLBienSacDiscolor, PLOther,
        -- Total calculation for UI (Single row total)
        CASE WHEN MaterialType = 'ALCASE' THEN
            ISNULL(ALBuiDust,0)+ISNULL(ALMoDent,0)+ISNULL(ALMepDeform,0)+ISNULL(ALXuocScratch,0)+ISNULL(ALBongNBPlating,0)+ISNULL(ALSanRoughFace,0)+ISNULL(ALBanDirty,0)+ISNULL(ALBanBoDentGroup,0)+ISNULL(ALBienSacDiscolor,0)+ISNULL(ALLoiKhacOther,0)
        ELSE
            ISNULL(PLBuuNhom,0)+ISNULL(PLBuuNhua,0)+ISNULL(PLBuuRandom,0)+ISNULL(PLBongTamNhieu,0)+ISNULL(PLXuocScratch,0)+ISNULL(PLBienDangDeform,0)+ISNULL(PLMoDongExposed,0)+ISNULL(PLBienDangCamSu,0)+ISNULL(PLNutGoCrackWood,0)+ISNULL(PLBienSacDiscolor,0)+ISNULL(PLOther,0)
        END AS TotalDefect
    FROM STB_VVT_SortingErrorData WITH(NOLOCK)
    WHERE (@pDateFrom IS NULL OR SortingDate >= @pDateFrom)
      AND (@pDateTo   IS NULL OR SortingDate <= @pDateTo)
      AND (@vMaterialType IS NULL OR MaterialType = @vMaterialType)
      AND (@pMaterialCode IS NULL OR MaterialCode LIKE '%' + @pMaterialCode + '%')
    ORDER BY SortingDate DESC, SortingID DESC;
END