
CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_ALCase_iud]
    @pProcessUserID     VARCHAR(20) = NULL,
    @pProcessLanguage   VARCHAR(20) = NULL,
    @pProcessViewName   VARCHAR(50) = NULL,
    @pXml               NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'VVT_SortingErrorData_ALCase') + '_INSERT'
    DECLARE @iDoc INT
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO STB_VVT_SortingErrorData_ALCase (
            [Date], [Shift], [Person], [Vendor], [Factory], MaterialCode, LotNo, [QtyCheck], [QtyOK], 
            BurrAl, BurrPlastic, BurrRubber, PlasticPeeling, Scratch, Deform, ExposedCopper, 
            RubberDeform, CrackWood, Discoloration, OtherError, Total, CreateUserID, CreateDateTime, ChangeUserID, ChangeDateTime
        )
        SELECT 
            T.[Date], T.[Shift], 
            COALESCE(T.xP, T.xP2, Person), 
            COALESCE(T.xV, T.xV2, Vendor), 
            COALESCE(T.xF, T.xF2, Factory), 
            COALESCE(T.xM, T.xM2, T.xM3, T.xM4, Marterial, Material_Code),
            COALESCE(T.xL, T.xL2, LotNo), 
            ISNULL(TRY_CAST(COALESCE(T.xQC, T.xQC2, T.xQC3) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.xQO, T.xQO2, T.xQO3) AS INT), 0),
            ISNULL(TRY_CAST(T.B1 AS INT), 0), ISNULL(TRY_CAST(T.B2 AS INT), 0), 
            ISNULL(TRY_CAST(T.B3 AS INT), 0), ISNULL(TRY_CAST(T.B4 AS INT), 0), 
            ISNULL(TRY_CAST(T.B5 AS INT), 0), ISNULL(TRY_CAST(T.B6 AS INT), 0), 
            ISNULL(TRY_CAST(T.B7 AS INT), 0), ISNULL(TRY_CAST(T.B8 AS INT), 0), 
            ISNULL(TRY_CAST(T.B9 AS INT), 0), ISNULL(TRY_CAST(T.B10 AS INT), 0), 
            ISNULL(TRY_CAST(T.B11 AS INT), 0),
            ISNULL(TRY_CAST(T.Total AS INT), 0), @pProcessUserID, GETDATE(), @pProcessUserID, GETDATE()
        FROM OPENXML(@iDoc, @InsertTableName, 2) WITH (
            [Date] DATE, [Shift] NVARCHAR(50), 
            xP NVARCHAR(100) '@*[local-name()="Person"]', xP2 NVARCHAR(100) '@Person', Person NVARCHAR(100),
            xV NVARCHAR(100) '@*[local-name()="Vendor"]', xV2 NVARCHAR(100) '@Vendor', Vendor NVARCHAR(100),
            xF NVARCHAR(100) '@*[local-name()="Factory"]', xF2 NVARCHAR(100) '@Factory', Factory NVARCHAR(100),
            xM NVARCHAR(100) '@*[local-name()="Material Code"]', xM2 NVARCHAR(100) '@MaterialCode', xM3 NVARCHAR(100) '@Material_Code', xM4 NVARCHAR(100) '@Marterial', Marterial NVARCHAR(100), Material_Code NVARCHAR(100),
            xL NVARCHAR(100) '@*[local-name()="Lot no"]', xL2 NVARCHAR(100) '@LotNo', LotNo NVARCHAR(100),
            xQC VARCHAR(50) '@*[local-name()="Q''Ty Check"]', xQC2 VARCHAR(50) '@*[local-name()="Qty Check"]', xQC3 VARCHAR(50) '@QtyCheck',
            xQO VARCHAR(50) '@*[local-name()="Q''ty OK"]', xQO2 VARCHAR(50) '@*[local-name()="Qty OK"]', xQO3 VARCHAR(50) '@QtyOK',
            B1 VARCHAR(50) '@*[local-name()="Burr nhômBurr Al"]', 
            B2 VARCHAR(50) '@*[local-name()="Burr NhựaBurr Plastic"]', 
            B3 VARCHAR(50) '@*[local-name()="Burr caosu"]', 
            B4 VARCHAR(50) '@*[local-name()="Bong tấm nhựa"]',
            B5 VARCHAR(50) '@*[local-name()="Xước Scratch"]', 
            B6 VARCHAR(50) '@*[local-name()="Biến dạngDeform"]', 
            B7 VARCHAR(50) '@*[local-name()="Hở đồngExposed copper"]',
            B8 VARCHAR(50) '@*[local-name()="Biến dạng cao suDeform caosu"]', 
            B9 VARCHAR(50) '@*[local-name()="Nứt gỗCrack Wood"]', 
            B10 VARCHAR(50) '@*[local-name()="Biến sắcDiscoloration"]', 
            B11 VARCHAR(50) '@Other',
            Total VARCHAR(50)
        ) AS T;
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
