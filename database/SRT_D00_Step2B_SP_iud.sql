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
    @pProcessUserID     VARCHAR(20),
    @pProcessLanguage   VARCHAR(20),
    @pProcessViewName   VARCHAR(50),
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
                @MaterialCode, @LotNo, @MaterialType, ISNULL(@QtyCheck,0), ISNULL(@QtyOK,0), @Remark,
                ISNULL(@ALBuiDust,0), ISNULL(@ALMoDent,0), ISNULL(@ALMepDeform,0), ISNULL(@ALXuocScratch,0),
                ISNULL(@ALBongNBPlating,0), ISNULL(@ALSanRoughFace,0), ISNULL(@ALBanDirty,0),
                ISNULL(@ALBanBoDentGroup,0), ISNULL(@ALBienSacDiscolor,0), ISNULL(@ALLoiKhacOther,0),
                ISNULL(@PLBuuNhom,0), ISNULL(@PLBuuNhua,0), ISNULL(@PLBuuRandom,0),
                ISNULL(@PLBongTamNhieu,0), ISNULL(@PLXuocScratch,0), ISNULL(@PLBienDangDeform,0),
                ISNULL(@PLMoDongExposed,0), ISNULL(@PLBienDangCamSu,0), ISNULL(@PLNutGoCrackWood,0),
                ISNULL(@PLBienSacDiscolor,0), ISNULL(@PLOther,0),
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
            QtyCheck           = ISNULL(X.QtyCheck, 0),
            QtyOK              = ISNULL(X.QtyOK, 0),
            Remark             = X.Remark,
            ALBuiDust          = ISNULL(X.ALBuiDust, 0),
            ALMoDent           = ISNULL(X.ALMoDent, 0),
            ALMepDeform        = ISNULL(X.ALMepDeform, 0),
            ALXuocScratch      = ISNULL(X.ALXuocScratch, 0),
            ALBongNBPlating    = ISNULL(X.ALBongNBPlating, 0),
            ALSanRoughFace     = ISNULL(X.ALSanRoughFace, 0),
            ALBanDirty         = ISNULL(X.ALBanDirty, 0),
            ALBanBoDentGroup   = ISNULL(X.ALBanBoDentGroup, 0),
            ALBienSacDiscolor  = ISNULL(X.ALBienSacDiscolor, 0),
            ALLoiKhacOther     = ISNULL(X.ALLoiKhacOther, 0),
            PLBuuNhom          = ISNULL(X.PLBuuNhom, 0),
            PLBuuNhua          = ISNULL(X.PLBuuNhua, 0),
            PLBuuRandom        = ISNULL(X.PLBuuRandom, 0),
            PLBongTamNhieu     = ISNULL(X.PLBongTamNhieu, 0),
            PLXuocScratch      = ISNULL(X.PLXuocScratch, 0),
            PLBienDangDeform   = ISNULL(X.PLBienDangDeform, 0),
            PLMoDongExposed    = ISNULL(X.PLMoDongExposed, 0),
            PLBienDangCamSu    = ISNULL(X.PLBienDangCamSu, 0),
            PLNutGoCrackWood   = ISNULL(X.PLNutGoCrackWood, 0),
            PLBienSacDiscolor  = ISNULL(X.PLBienSacDiscolor, 0),
            PLOther            = ISNULL(X.PLOther, 0),
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
