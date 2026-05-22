
CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_Plate_iud]
    @pProcessUserID     VARCHAR(20) = NULL,
    @pProcessLanguage   VARCHAR(20) = NULL,
    @pProcessViewName   VARCHAR(50) = NULL,
    @pXml               NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'VVT_SortingErrorData_Plate') + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'VVT_SortingErrorData_Plate') + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'VVT_SortingErrorData_Plate') + '_DELETE'
    DECLARE @iDoc INT
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- A. XỬ LÝ XÓA (DELETE)
        DELETE T FROM STB_VVT_SortingErrorData_Plate T
        INNER JOIN (
            SELECT ID FROM OPENXML(@iDoc, @DeleteTableName, 3) WITH (ID INT)
        ) S ON T.ID = S.ID;

        -- B. XỬ LÝ CẬP NHẬT (UPDATE)
        UPDATE T SET 
            T.[Date] = S.[Date], T.[Shift] = S.[Shift], T.Person = S.Person, T.Vendor = S.Vendor, T.Factory = S.Factory,
            T.MaterialCode = S.MaterialCode, T.LotNo = S.LotNo, T.QtyCheck = S.QtyCheck, T.QtyOK = S.QtyOK,
            T.Burr = S.Burr, T.Dent = S.Dent, T.Deform = S.Deform, T.Scratch = S.Scratch, T.NGPlating = S.NGPlating,
            T.RoughFace = S.RoughFace, T.Dirty = S.Dirty, T.DentBottom = S.DentBottom, T.Discolor = S.Discolor,
            T.OtherError = S.OtherError, T.Total = S.Total, T.ChangeUserID = @pProcessUserID, T.ChangeDateTime = GETDATE()
        FROM STB_VVT_SortingErrorData_Plate T
        INNER JOIN (
            SELECT * FROM OPENXML(@iDoc, @UpdateTableName, 3) WITH (
                ID INT, [Date] DATE, [Shift] NVARCHAR(10), Person NVARCHAR(100), Vendor NVARCHAR(100), Factory NVARCHAR(100),
                MaterialCode NVARCHAR(50), LotNo NVARCHAR(50), QtyCheck INT, QtyOK INT,
                Burr INT, Dent INT, Deform INT, Scratch INT, NGPlating INT, RoughFace INT,
                Dirty INT, DentBottom INT, Discolor INT, OtherError INT, Total INT
            )
        ) S ON T.ID = S.ID;

        -- C. XỬ LÝ LƯU MỚI (INSERT)
        INSERT INTO STB_VVT_SortingErrorData_Plate (
            [Date], [Shift], [Person], [Vendor], [Factory], MaterialCode, LotNo, [QtyCheck], [QtyOK], 
            Burr, Dent, Deform, Scratch, NGPlating, RoughFace, Dirty, DentBottom, Discolor, OtherError, Total, 
            CreateUserID, CreateDateTime, ChangeUserID, ChangeDateTime
        )
        SELECT 
            COALESCE(T.D1, T.D2, GETDATE()), T.[Shift], 
            COALESCE(T.atP, T.Person), 
            COALESCE(T.atV, T.Vendor), 
            COALESCE(T.atF, T.Factory), 
            COALESCE(T.A_Mat, T.A_MatU, T.A_MatS, T.MaterialCode, T.Material_Code, T.Marterial),
            COALESCE(T.A_Lot, T.LotNo, T.Lot_no), 
            ISNULL(TRY_CAST(COALESCE(T.A_QC, T.QtyCheck) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.A_QO, T.QtyOK) AS INT), 0),
            ISNULL(TRY_CAST(COALESCE(T.A_B1, T.Burr) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.A_B2, T.Dent) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB3, T.Deform) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB4, T.Scratch) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB5, T.NGPlating) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB6, T.RoughFace) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB7, T.Dirty) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB8, T.DentBottom) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB9, T.Discolor) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB10, T.OtherError) AS INT), 0),
            ISNULL(TRY_CAST(T.Total AS INT), 0), 
            @pProcessUserID, GETDATE(), @pProcessUserID, GETDATE()
        FROM OPENXML(@iDoc, @InsertTableName, 3) WITH (
            D1 DATE '@Date', D2 DATE 'Date', [Date] DATE, [Shift] NVARCHAR(50), 
            atP NVARCHAR(100) '@Person', Person NVARCHAR(100),
            atV NVARCHAR(100) '@Vendor', Vendor NVARCHAR(100),
            atF NVARCHAR(100) '@Factory', Factory NVARCHAR(100),
            A_Mat NVARCHAR(100) '@MaterialCode', A_MatU NVARCHAR(100) '@Material_Code', A_MatS NVARCHAR(100) '@Material_x0020_Code', 
            MaterialCode NVARCHAR(100), Material_Code NVARCHAR(100), Marterial NVARCHAR(100),
            A_Lot NVARCHAR(100) '@LotNo', LotNo NVARCHAR(100), Lot_no NVARCHAR(100),
            A_QC VARCHAR(50) '@QtyCheck', QtyCheck VARCHAR(50),
            A_QO VARCHAR(50) '@QtyOK', QtyOK VARCHAR(50),
            A_B1 VARCHAR(50) '@Burr', Burr VARCHAR(50),
            A_B2 VARCHAR(50) '@Dent', Dent VARCHAR(50),
            atB3 VARCHAR(50) '@Deform', Deform VARCHAR(50),
            atB4 VARCHAR(50) '@Scratch', Scratch VARCHAR(50),
            atB5 VARCHAR(50) '@NGPlating', NGPlating VARCHAR(50),
            atB6 VARCHAR(50) '@RoughFace', RoughFace VARCHAR(50),
            atB7 VARCHAR(50) '@Dirty', Dirty VARCHAR(50),
            atB8 VARCHAR(50) '@DentBottom', DentBottom VARCHAR(50),
            atB9 VARCHAR(50) '@Discolor', Discolor VARCHAR(50),
            atB10 VARCHAR(50) '@OtherError', OtherError VARCHAR(50),
            Total VARCHAR(50)
        ) AS T
        WHERE COALESCE(T.D1, T.D2, T.A_Mat, T.MaterialCode, T.Marterial) IS NOT NULL;

        COMMIT TRANSACTION;
        EXEC sp_xml_removedocument @iDoc;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        IF @iDoc IS NOT NULL EXEC sp_xml_removedocument @iDoc;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;

