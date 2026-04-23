CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_iud]
    @pProcessUserID     VARCHAR(20)    = NULL,
    @pProcessLanguage   VARCHAR(20)    = NULL,
    @pProcessViewName   VARCHAR(50)    = NULL,
    @pXml               NVARCHAR(MAX)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @iDoc INT;
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;

    -- Xá»­ lÃ½ DELETE
    DELETE T FROM STB_VVT_SortingErrorData T
    JOIN OPENXML(@iDoc, '/DataSet/SortingData_DELETE', 2) WITH (SortingID INT) X 
    ON T.SortingID = X.SortingID;

    -- Xá»­ lÃ½ INSERT (KhÃ´ng cáº§n sinh Serial thá»§ cÃ´ng ná»¯a)
    INSERT INTO STB_VVT_SortingErrorData (
        SortingDate, Shift, PersonName, VendorCode, FactoryName, MaterialCode, LotNo, MaterialType, QtyCheck, QtyOK, Remark,
        ALBuiDust, ALMoDent, ALMepDeform, ALXuocScratch, ALBongNBPlating, ALSanRoughFace, ALBanDirty, ALBanBoDentGroup, ALBienSacDiscolor, ALLoiKhacOther,
        PLBuuNhom, PLBuuNhua, PLBuuRandom, PLBongTamNhieu, PLXuocScratch, PLBienDangDeform, PLMoDongExposed, PLBienDangCamSu, PLNutGoCrackWood, PLBienSacDiscolor, PLOther,
        CreateUserID, CreateDateTime
    )
    SELECT 
        SortingDate, Shift, PersonName, VendorCode, FactoryName, MaterialCode, LotNo, 
        CASE WHEN @pProcessViewName LIKE '%ALCASE%' THEN 'ALCASE' ELSE 'PLATE' END,
        QtyCheck, QtyOK, Remark,
        ALBuiDust, ALMoDent, ALMepDeform, ALXuocScratch, ALBongNBPlating, ALSanRoughFace, ALBanDirty, ALBanBoDentGroup, ALBienSacDiscolor, ALLoiKhacOther,
        PLBuuNhom, PLBuuNhua, PLBuuRandom, PLBongTamNhieu, PLXuocScratch, PLBienDangDeform, PLMoDongExposed, PLBienDangCamSu, PLNutGoCrackWood, PLBienSacDiscolor, PLOther,
        @pProcessUserID, GETDATE()
    FROM OPENXML(@iDoc, '/DataSet/SortingData_INSERT', 2) 
    WITH (
        SortingDate DATE, Shift VARCHAR(5), PersonName NVARCHAR(100), VendorCode VARCHAR(50), 
        FactoryName NVARCHAR(100), MaterialCode VARCHAR(50), LotNo VARCHAR(100), QtyCheck INT, QtyOK INT, Remark NVARCHAR(200),
        ALBuiDust INT, ALMoDent INT, ALBongNBPlating INT, ALMepDeform INT, ALXuocScratch INT, ALSanRoughFace INT, ALBanDirty INT, ALBanBoDentGroup INT, ALBienSacDiscolor INT, ALLoiKhacOther INT,
        PLBuuNhom INT, PLBuuNhua INT, PLBuuRandom INT, PLBongTamNhieu INT, PLXuocScratch INT, PLBienDangDeform INT, PLMoDongExposed INT, PLBienDangCamSu INT, PLNutGoCrackWood INT, PLBienSacDiscolor INT, PLOther INT
    );

    -- Xá»­ lÃ½ UPDATE
    UPDATE T SET
        SortingDate = X.SortingDate, Shift = X.Shift, PersonName = X.PersonName, MaterialCode = X.MaterialCode, QtyCheck = X.QtyCheck, QtyOK = X.QtyOK,
        ALBuiDust = X.ALBuiDust, ALMoDent = X.ALMoDent, ALBongNBPlating = X.ALBongNBPlating, 
        PLBuuNhom = X.PLBuuNhom, PLBuuNhua = X.PLBuuNhua, 
        ChangeUserID = @pProcessUserID, ChangeDateTime = GETDATE()
    FROM STB_VVT_SortingErrorData T
    JOIN OPENXML(@iDoc, '/DataSet/SortingData_UPDATE', 2) WITH (
        SortingID INT, SortingDate DATE, Shift VARCHAR(5), PersonName NVARCHAR(100), MaterialCode VARCHAR(50), QtyCheck INT, QtyOK INT,
        ALBuiDust INT, ALMoDent INT, ALBongNBPlating INT, PLBuuNhom INT, PLBuuNhua INT
    ) X ON T.SortingID = X.SortingID;

    EXEC sp_xml_removedocument @iDoc;
END