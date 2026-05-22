
CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_ALCase_iud]
    @pProcessUserID     VARCHAR(20) = NULL,
    @pProcessLanguage   VARCHAR(20) = NULL,
    @pProcessViewName   VARCHAR(50) = NULL,
    @pXml               NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'VVT_SortingErrorData_ALCase') + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'VVT_SortingErrorData_ALCase') + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'VVT_SortingErrorData_ALCase') + '_DELETE'
    DECLARE @iDoc INT
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- A. XỬ LÝ XÓA (DELETE)
        DELETE T FROM STB_VVT_SortingErrorData_ALCase T
        INNER JOIN (
            SELECT ID FROM OPENXML(@iDoc, @DeleteTableName, 3) WITH (ID INT)
        ) S ON T.ID = S.ID;

        -- B. XỬ LÝ CẬP NHẬT (UPDATE)
        UPDATE T SET 
            T.[Date] = S.[Date], T.[Shift] = S.[Shift], T.Person = S.Person, T.Vendor = S.Vendor, T.Factory = S.Factory,
            T.MaterialCode = S.MaterialCode, T.LotNo = S.LotNo, T.QtyCheck = S.QtyCheck, T.QtyOK = S.QtyOK,
            T.BurrAl = S.BurrAl, T.BurrPlastic = S.BurrPlastic, T.BurrRubber = S.BurrRubber, T.PlasticPeeling = S.PlasticPeeling,
            T.Scratch = S.Scratch, T.Deform = S.Deform, T.ExposedCopper = S.ExposedCopper, T.RubberDeform = S.RubberDeform,
            T.CrackWood = S.CrackWood, T.Discoloration = S.Discoloration, T.OtherError = S.OtherError, T.Total = S.Total,
            T.ChangeUserID = @pProcessUserID, T.ChangeDateTime = GETDATE()
        FROM STB_VVT_SortingErrorData_ALCase T
        INNER JOIN (
            SELECT * FROM OPENXML(@iDoc, @UpdateTableName, 3) WITH (
                ID INT, [Date] DATE, [Shift] NVARCHAR(10), Person NVARCHAR(100), Vendor NVARCHAR(100), Factory NVARCHAR(100),
                MaterialCode NVARCHAR(50), LotNo NVARCHAR(50), QtyCheck INT, QtyOK INT,
                BurrAl INT, BurrPlastic INT, BurrRubber INT, PlasticPeeling INT, Scratch INT, Deform INT,
                ExposedCopper INT, RubberDeform INT, CrackWood INT, Discoloration INT, OtherError INT, Total INT
            )
        ) S ON T.ID = S.ID;

        -- C. XỬ LÝ LƯU MỚI (INSERT)
        INSERT INTO STB_VVT_SortingErrorData_ALCase (
            [Date], [Shift], [Person], [Vendor], [Factory], MaterialCode, LotNo, [QtyCheck], [QtyOK], 
            BurrAl, BurrPlastic, BurrRubber, PlasticPeeling, Scratch, Deform, ExposedCopper, 
            RubberDeform, CrackWood, Discoloration, OtherError, Total, CreateUserID, CreateDateTime, ChangeUserID, ChangeDateTime
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
            ISNULL(TRY_CAST(COALESCE(T.A_B1, T.BurrAl) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.A_B2, T.BurrPlastic) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB3, T.BurrRubber) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB4, T.PlasticPeeling) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB5, T.Scratch) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB6, T.Deform) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB7, T.ExposedCopper) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB8, T.RubberDeform) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB9, T.CrackWood) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB10, T.Discoloration) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB11, T.OtherError) AS INT), 0),
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
            A_B1 VARCHAR(50) '@BurrAl', BurrAl VARCHAR(50),
            A_B2 VARCHAR(50) '@BurrPlastic', BurrPlastic VARCHAR(50),
            atB3 VARCHAR(50) '@BurrRubber', BurrRubber VARCHAR(50),
            atB4 VARCHAR(50) '@PlasticPeeling', PlasticPeeling VARCHAR(50),
            atB5 VARCHAR(50) '@Scratch', Scratch VARCHAR(50),
            atB6 VARCHAR(50) '@Deform', Deform VARCHAR(50),
            atB7 VARCHAR(50) '@ExposedCopper', ExposedCopper VARCHAR(50),
            atB8 VARCHAR(50) '@RubberDeform', RubberDeform VARCHAR(50),
            atB9 VARCHAR(50) '@CrackWood', CrackWood VARCHAR(50),
            atB10 VARCHAR(50) '@Discoloration', Discoloration VARCHAR(50),
            atB11 VARCHAR(50) '@OtherError', OtherError VARCHAR(50),
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

