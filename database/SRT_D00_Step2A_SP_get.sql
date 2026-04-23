-- ============================================================
-- BƯỚC 2A: TẠO SP SEARCH - usp_VVT_SortingErrorData_get
-- Database: SmartFactoryV2
-- Màn hình: SRT_D00 - Sorting Error Data
-- ============================================================

USE SmartFactoryV2;
GO

IF OBJECT_ID('dbo.usp_VVT_SortingErrorData_get', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_VVT_SortingErrorData_get;
GO

CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_get]
    @pProcessUserID     VARCHAR(20)    = NULL,
    @pProcessLanguage   VARCHAR(20)    = NULL,
    @pProcessViewName   VARCHAR(50)    = NULL,
    @pSortingDateFrom   DATE           = NULL,
    @pSortingDateTo     DATE           = NULL,
    @pMaterialType      VARCHAR(20)    = NULL, 
    @pFactoryName       NVARCHAR(100)  = NULL,
    @pMaterialCode      VARCHAR(50)    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Tự động lọc MaterialType dựa trên ViewName nếu tham số pMaterialType để trống
    DECLARE @vMaterialType VARCHAR(20) = @pMaterialType;
    IF (ISNULL(@vMaterialType, '') = '')
    BEGIN
        IF (@pProcessViewName LIKE '%ALCASE%') SET @vMaterialType = 'ALCASE';
        IF (@pProcessViewName LIKE '%PLATE%')  SET @vMaterialType = 'PLATE';
    END

    -- DỮ LIỆU CHI TIẾT
    SELECT
        SED.SortingErrorNo,
        SED.SortingDate,
        SED.Shift,
        SED.PersonName,
        SED.VendorCode,
        SED.FactoryName,
        SED.MaterialCode,
        SED.LotNo,
        SED.MaterialType,
        SED.QtyCheck,
        SED.QtyOK,
        SED.Remark,

        -- Lỗi AL Case
        SED.ALBuiDust, SED.ALMoDent, SED.ALMepDeform, SED.ALXuocScratch, SED.ALBongNBPlating,
        SED.ALSanRoughFace, SED.ALBanDirty, SED.ALBanBoDentGroup, SED.ALBienSacDiscolor, SED.ALLoiKhacOther,

        -- Lỗi Plate
        SED.PLBuuNhom, SED.PLBuuNhua, SED.PLBuuRandom, SED.PLBongTamNhieu, SED.PLXuocScratch,
        SED.PLBienDangDeform, SED.PLMoDongExposed, SED.PLBienDangCamSu, SED.PLNutGoCrackWood, 
        SED.PLBienSacDiscolor, SED.PLOther,

        -- Tổng lỗi & Tỷ lệ
        CASE
            WHEN SED.MaterialType = 'ALCASE' THEN
                ISNULL(SED.ALBuiDust,0) + ISNULL(SED.ALMoDent,0) + ISNULL(SED.ALMepDeform,0)
                + ISNULL(SED.ALXuocScratch,0) + ISNULL(SED.ALBongNBPlating,0) + ISNULL(SED.ALSanRoughFace,0)
                + ISNULL(SED.ALBanDirty,0) + ISNULL(SED.ALBanBoDentGroup,0) + ISNULL(SED.ALBienSacDiscolor,0)
                + ISNULL(SED.ALLoiKhacOther,0)
            WHEN SED.MaterialType = 'PLATE' THEN
                ISNULL(SED.PLBuuNhom,0) + ISNULL(SED.PLBuuNhua,0) + ISNULL(SED.PLBuuRandom,0)
                + ISNULL(SED.PLBongTamNhieu,0) + ISNULL(SED.PLXuocScratch,0) + ISNULL(SED.PLBienDangDeform,0)
                + ISNULL(SED.PLMoDongExposed,0) + ISNULL(SED.PLBienDangCamSu,0) + ISNULL(SED.PLNutGoCrackWood,0)
                + ISNULL(SED.PLBienSacDiscolor,0) + ISNULL(SED.PLOther,0)
            ELSE 0
        END AS TotalDefect,
        0 AS DefectRate, -- Có thể tính ở Grid

        SED.CreateDateTime, SED.CreateUserID, SED.ChangeDateTime, SED.ChangeUserID
    FROM STB_VVT_SortingErrorData SED WITH(NOLOCK)
    WHERE
        (@pSortingDateFrom IS NULL OR SED.SortingDate >= @pSortingDateFrom)
        AND (@pSortingDateTo IS NULL OR SED.SortingDate <= @pSortingDateTo)
        AND (@vMaterialType IS NULL OR SED.MaterialType = @vMaterialType)
        AND (@pFactoryName IS NULL OR SED.FactoryName LIKE '%' + @pFactoryName + '%')
        AND (@pMaterialCode IS NULL OR SED.MaterialCode LIKE '%' + @pMaterialCode + '%')

    ORDER BY SortingDate DESC, SortingErrorNo DESC;
END
GO

PRINT 'Tạo SP usp_VVT_SortingErrorData_get thành công!';
GO
