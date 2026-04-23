-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_FinishGood_BG_StockIn_iud]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20) = NULL,
		@pProcessLanguage VARCHAR(20) = NULL,
		@pIDCODE NVARCHAR(100) = NULL,
        @pPackingID NVARCHAR(50) = NULL,
        @pLotNo NVARCHAR(50) = NULL,
        @pMaterialCode NVARCHAR(50) = NULL,
        @pMaterialName NVARCHAR(100) = NULL,
        @pPackQty INT = NULL,
        @pEmpNo NVARCHAR(50) = NULL,
        @pCreatDatePacked NVARCHAR(50) = NULL,
        @pPartNo NVARCHAR(50) = NULL,
        @pPublicCode NVARCHAR(50) = NULL,
        @pProductionSize NVARCHAR(50) = NULL,
        @pTypeProduction NVARCHAR(50) = NULL,
        @pStatusSystem NVARCHAR(50) = NULL,
        @pCreateDate DATETIME = NULL,
        @pUSERID NVARCHAR(50) = NULL,
        @pCreateDateChange DATETIME = NULL,
        @pUSERIDChange NVARCHAR(50) = NULL,
        @pINPUTFROM NVARCHAR(100) = NULL,
        @pCODELOCATION NVARCHAR(10) = NULL,
        @pLevels NVARCHAR(50) = NULL,
        @pSoPhieuNhapKho NVARCHAR(50) = NULL,
        @pLoaiHinhToKhai NVARCHAR(50) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
     DECLARE @IDCODE NVARCHAR(100);
    -- Insert statements for procedure here
    -- IF EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_BG_Test_20251225 WHERE LotNo = @pLotNo)
    --            --BEGIN
    --            --    UPDATE STB_VN_FINISHGOODS_BG_Test_20251225
    --            --SET
    --            --    PackingID       = ISNULL(@pPackingID, PackingID),
    --            --    MaterialCode    = ISNULL(@pMaterialCode, MaterialCode),
    --            --    MaterialName    = ISNULL(@pMaterialName, MaterialName),
    --            --    PackQty         = ISNULL(@pPackQty, PackQty),
    --            --    PartNo          = ISNULL(@pPartNo, PartNo),
    --            --    PublicCode      = ISNULL(@pPublicCode, PublicCode),
    --            --    ProductionSize  = ISNULL(@pProductionSize, ProductionSize),
    --            --    TypeProduction  = ISNULL(@pTypeProduction, TypeProduction),
    --            --    SoPhieuNhapKho  = ISNULL(@pSoPhieuNhapKho, SoPhieuNhapKho),
    --            --    Levels = ISNULL(@pLevels,Levels),
    --            --    LoaiHinhToKhai = ISNULL(@pLoaiHinhToKhai,LoaiHinhToKhai),
    --            --    CreateDateChange = GETDATE(),
    --            --    USERIDChange    = @pProcessUserID
    --            --WHERE LotNo = @pLotNo;
    --            --PRINT(N'Thay đổi thành công')
    --            --END
                 
    --            BEGIN
    --            RAISERROR(N'Lot này đã được nhập kho', 16, 1, @pLotNo)
    --            END
    --ELSE
    BEGIN
	INSERT INTO  STB_VN_FINISHGOODS_BG_Test_20251225(
		 IDCODE, PackingID, LotNo, MaterialCode, MaterialName, PackQty, EmpNo,
                    CreatDatePacked, PartNo, PublicCode, ProductionSize, TypeProduction,
                    StatusSystem, CreateDate, USERID, CreateDateChange, USERIDChange, 
                    INPUTFROM, CODELOCATION, Flag, MethodActions, Levels, SoPhieuNhapKho,LoaiHinhToKhai
	)
	VALUES
	 (
		   @pIDCODE, @pPackingID, @pLotNo, @pMaterialCode, @pMaterialName, @pPackQty, @pProcessUserID,
                    GETDATE(), @pPartNo, @pPublicCode, @pProductionSize, @pTypeProduction,
                    N'Nhập', GETDATE(), @pProcessUserID, NULL, NULL, 
                    'NSX', 'VVT_F2', 1, N'Nhập từ file excel',@pLevels,@pSoPhieuNhapKho,@pLoaiHinhToKhai
	 )
     END
END