-- ============================================================
-- BƯỚC 2B: TẠO SP INSERT/UPDATE/DELETE - usp_VVT_SortingErrorData_iud
-- Database: SmartFactoryV2
-- Màn hình: SRT_D00 - Sorting Error Data
-- ============================================================

USE SmartFactoryV2;
GO

IF OBJECT_ID('dbo.usp_VVT_SortingErrorData_iud', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_VVT_SortingErrorData_iud;
GO

CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_iud]
    @pProcessUserID     VARCHAR(20)   = NULL,
    @pProcessLanguage   VARCHAR(20)   = NULL,
    @pProcessViewName   VARCHAR(50)   = NULL,
    @pXml               NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_DELETE'
    DECLARE @iDoc INT
    DECLARE @SortingErrorNo VARCHAR(20)
    DECLARE @ERROR_MSG NVARCHAR(MAX)

    -- Khai báo các biến tương ứng với cột của bảng
    DECLARE
        @OldSortingErrorNo  VARCHAR(20),
        @SortingDate        DATE,
        @Shift              VARCHAR(5),
        @PersonName         NVARCHAR(100),
        @VendorCode         VARCHAR(50),
        @FactoryName        NVARCHAR(100),
        @MaterialCode       VARCHAR(50),
        @LotNo              VARCHAR(100),
        @MaterialType       VARCHAR(20),
        @QtyCheck           INT,
        @QtyOK              INT,
        @Remark             NVARCHAR(200),
        -- AL Case
        @ALBuiDust          INT, @ALMoDent           INT, @ALMepDeform        INT,
        @ALXuocScratch      INT, @ALBongNBPlating     INT, @ALSanRoughFace     INT,
        @ALBanDirty         INT, @ALBanBoDentGroup    INT, @ALBienSacDiscolor  INT,
        @ALLoiKhacOther     INT,
        -- Plate
        @PLBuuNhom          INT, @PLBuuNhua           INT, @PLBuuRandom        INT,
        @PLBongTamNhieu     INT, @PLXuocScratch        INT, @PLBienDangDeform   INT,
        @PLMoDongExposed    INT, @PLBienDangCamSu      INT, @PLNutGoCrackWood   INT,
        @PLBienSacDiscolor  INT, @PLOther              INT

    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ============================================================
        -- XỬ LÝ INSERT
        -- ============================================================
        DECLARE cur_insert CURSOR FOR
        SELECT
            OldSortingErrorNo, SortingErrorNo, SortingDate, Shift, PersonName,
            VendorCode, FactoryName, MaterialCode, LotNo, MaterialType,
            QtyCheck, QtyOK, Remark,
            ALBuiDust, ALMoDent, ALMepDeform, ALXuocScratch, ALBongNBPlating,
            ALSanRoughFace, ALBanDirty, ALBanBoDentGroup, ALBienSacDiscolor, ALLoiKhacOther,
            PLBuuNhom, PLBuuNhua, PLBuuRandom, PLBongTamNhieu, PLXuocScratch,
            PLBienDangDeform, PLMoDongExposed, PLBienDangCamSu, PLNutGoCrackWood,
            PLBienSacDiscolor, PLOther
        FROM OPENXML(@iDoc, @InsertTableName, 2) WITH (
            OldSortingErrorNo  VARCHAR(20),  SortingErrorNo  VARCHAR(20),
            SortingDate        DATE,          Shift           VARCHAR(5),
            PersonName         NVARCHAR(100), VendorCode      VARCHAR(50),
            FactoryName        NVARCHAR(100), MaterialCode    VARCHAR(50),
            LotNo              VARCHAR(100),  MaterialType    VARCHAR(20),
            QtyCheck           INT,           QtyOK           INT,
            Remark             NVARCHAR(200),
            ALBuiDust          INT,  ALMoDent           INT,  ALMepDeform        INT,
            ALXuocScratch      INT,  ALBongNBPlating     INT,  ALSanRoughFace     INT,
            ALBanDirty         INT,  ALBanBoDentGroup    INT,  ALBienSacDiscolor  INT,
            ALLoiKhacOther     INT,
            PLBuuNhom          INT,  PLBuuNhua           INT,  PLBuuRandom        INT,
            PLBongTamNhieu     INT,  PLXuocScratch        INT,  PLBienDangDeform   INT,
            PLMoDongExposed    INT,  PLBienDangCamSu      INT,  PLNutGoCrackWood   INT,
            PLBienSacDiscolor  INT,  PLOther              INT
        )

        OPEN cur_insert
        FETCH NEXT FROM cur_insert INTO
            @OldSortingErrorNo, @SortingErrorNo, @SortingDate, @Shift, @PersonName,
            @VendorCode, @FactoryName, @MaterialCode, @LotNo, @MaterialType,
            @QtyCheck, @QtyOK, @Remark,
            @ALBuiDust, @ALMoDent, @ALMepDeform, @ALXuocScratch, @ALBongNBPlating,
            @ALSanRoughFace, @ALBanDirty, @ALBanBoDentGroup, @ALBienSacDiscolor, @ALLoiKhacOther,
            @PLBuuNhom, @PLBuuNhua, @PLBuuRandom, @PLBongTamNhieu, @PLXuocScratch,
            @PLBienDangDeform, @PLMoDongExposed, @PLBienDangCamSu, @PLNutGoCrackWood,
            @PLBienSacDiscolor, @PLOther

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Tự động lọc MaterialType dựa trên ViewName nếu tham số XML để trống
            IF (ISNULL(@MaterialType, '') = '')
            BEGIN
                IF (@pProcessViewName LIKE '%ALCASE%') SET @MaterialType = 'ALCASE';
                IF (@pProcessViewName LIKE '%PLATE%')  SET @MaterialType = 'PLATE';
            END

            -- Validate bắt buộc
            IF ISNULL(@SortingDate, '') = '' OR ISNULL(@MaterialType, '') = ''
            BEGIN
                RAISERROR(N'Ngày Sorting và Loại Vật Liệu không được để trống!', 16, 1);
                RETURN;
            END

            -- Tạo serial number mới
            EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VVT_SortingErrorData', @SortingErrorNo OUTPUT

            INSERT INTO STB_VVT_SortingErrorData (
                SortingErrorNo, SortingDate, Shift, PersonName, VendorCode, FactoryName,
                MaterialCode, LotNo, MaterialType, QtyCheck, QtyOK, Remark,
                ALBuiDust, ALMoDent, ALMepDeform, ALXuocScratch, ALBongNBPlating,
                ALSanRoughFace, ALBanDirty, ALBanBoDentGroup, ALBienSacDiscolor, ALLoiKhacOther,
                PLBuuNhom, PLBuuNhua, PLBuuRandom, PLBongTamNhieu, PLXuocScratch,
                PLBienDangDeform, PLMoDongExposed, PLBienDangCamSu, PLNutGoCrackWood,
                PLBienSacDiscolor, PLOther,
                CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID
            )
            VALUES (
                @SortingErrorNo, @SortingDate, @Shift, @PersonName, @VendorCode, @FactoryName,
                @MaterialCode, @LotNo, @MaterialType, @QtyCheck, @QtyOK, @Remark,
                @ALBuiDust, @ALMoDent, @ALMepDeform, @ALXuocScratch, @ALBongNBPlating,
                @ALSanRoughFace, @ALBanDirty, @ALBanBoDentGroup, @ALBienSacDiscolor, @ALLoiKhacOther,
                @PLBuuNhom, @PLBuuNhua, @PLBuuRandom, @PLBongTamNhieu, @PLXuocScratch,
                @PLBienDangDeform, @PLMoDongExposed, @PLBienDangCamSu, @PLNutGoCrackWood,
                @PLBienSacDiscolor, @PLOther,
                GETDATE(), @pProcessUserID, GETDATE(), @pProcessUserID
            )

            FETCH NEXT FROM cur_insert INTO
                @OldSortingErrorNo, @SortingErrorNo, @SortingDate, @Shift, @PersonName,
                @VendorCode, @FactoryName, @MaterialCode, @LotNo, @MaterialType,
                @QtyCheck, @QtyOK, @Remark,
                @ALBuiDust, @ALMoDent, @ALMepDeform, @ALXuocScratch, @ALBongNBPlating,
                @ALSanRoughFace, @ALBanDirty, @ALBanBoDentGroup, @ALBienSacDiscolor, @ALLoiKhacOther,
                @PLBuuNhom, @PLBuuNhua, @PLBuuRandom, @PLBongTamNhieu, @PLXuocScratch,
                @PLBienDangDeform, @PLMoDongExposed, @PLBienDangCamSu, @PLNutGoCrackWood,
                @PLBienSacDiscolor, @PLOther
        END
        CLOSE cur_insert; DEALLOCATE cur_insert;

        -- ============================================================
        -- XỬ LÝ UPDATE
        -- ============================================================
        UPDATE T SET
            SortingDate        = ISNULL(X.SortingDate, T.SortingDate),
            Shift              = X.Shift,
            PersonName         = X.PersonName,
            VendorCode         = X.VendorCode,
            FactoryName        = X.FactoryName,
            MaterialCode       = X.MaterialCode,
            LotNo              = X.LotNo,
            MaterialType       = ISNULL(X.MaterialType, T.MaterialType),
            QtyCheck           = X.QtyCheck,
            QtyOK              = X.QtyOK,
            Remark             = X.Remark,
            ALBuiDust          = X.ALBuiDust,
            ALMoDent           = X.ALMoDent,
            ALMepDeform        = X.ALMepDeform,
            ALXuocScratch      = X.ALXuocScratch,
            ALBongNBPlating    = X.ALBongNBPlating,
            ALSanRoughFace     = X.ALSanRoughFace,
            ALBanDirty         = X.ALBanDirty,
            ALBanBoDentGroup   = X.ALBanBoDentGroup,
            ALBienSacDiscolor  = X.ALBienSacDiscolor,
            ALLoiKhacOther     = X.ALLoiKhacOther,
            PLBuuNhom          = X.PLBuuNhom,
            PLBuuNhua          = X.PLBuuNhua,
            PLBuuRandom        = X.PLBuuRandom,
            PLBongTamNhieu     = X.PLBongTamNhieu,
            PLXuocScratch      = X.PLXuocScratch,
            PLBienDangDeform   = X.PLBienDangDeform,
            PLMoDongExposed    = X.PLMoDongExposed,
            PLBienDangCamSu    = X.PLBienDangCamSu,
            PLNutGoCrackWood   = X.PLNutGoCrackWood,
            PLBienSacDiscolor  = X.PLBienSacDiscolor,
            PLOther            = X.PLOther,
            ChangeDateTime     = GETDATE(),
            ChangeUserID       = @pProcessUserID
        FROM STB_VVT_SortingErrorData T
        JOIN (
            SELECT * FROM OPENXML(@iDoc, @UpdateTableName, 2) WITH (
                OldSortingErrorNo  VARCHAR(20),  SortingDate DATE, Shift VARCHAR(5),
                PersonName NVARCHAR(100), VendorCode VARCHAR(50), FactoryName NVARCHAR(100),
                MaterialCode VARCHAR(50), LotNo VARCHAR(100), MaterialType VARCHAR(20),
                QtyCheck INT, QtyOK INT, Remark NVARCHAR(200),
                ALBuiDust INT, ALMoDent INT, ALMepDeform INT, ALXuocScratch INT,
                ALBongNBPlating INT, ALSanRoughFace INT, ALBanDirty INT,
                ALBanBoDentGroup INT, ALBienSacDiscolor INT, ALLoiKhacOther INT,
                PLBuuNhom INT, PLBuuNhua INT, PLBuuRandom INT, PLBongTamNhieu INT,
                PLXuocScratch INT, PLBienDangDeform INT, PLMoDongExposed INT,
                PLBienDangCamSu INT, PLNutGoCrackWood INT, PLBienSacDiscolor INT, PLOther INT
            )
        ) X ON T.SortingErrorNo = X.OldSortingErrorNo;

        -- ============================================================
        -- XỬ LÝ DELETE
        -- ============================================================
        DELETE T
        FROM STB_VVT_SortingErrorData T
        JOIN (
            SELECT OldSortingErrorNo
            FROM OPENXML(@iDoc, @DeleteTableName, 2) WITH (OldSortingErrorNo VARCHAR(20))
        ) X ON T.SortingErrorNo = X.OldSortingErrorNo;

        COMMIT TRANSACTION;
        EXEC sp_xml_removedocument @iDoc;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        EXEC sp_xml_removedocument @iDoc;
        SET @ERROR_MSG = ERROR_MESSAGE();
        RAISERROR(@ERROR_MSG, 16, 1);
    END CATCH
END
GO

PRINT 'Tạo SP usp_VVT_SortingErrorData_iud thành công!';
GO
