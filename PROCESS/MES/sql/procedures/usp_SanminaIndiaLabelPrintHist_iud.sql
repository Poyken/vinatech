-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-12-28
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_SanminaIndiaLabelPrintHist_iud 
	-- Add the parameters for the stored procedure here
            @pProcessUserID VARCHAR(20),
		    @pProcessLanguage VARCHAR(20),
            @pSupplierName VARCHAR(50),
            @pSanminaPartNumber VARCHAR(50),
            @pPartDesc NVARCHAR(100),
            @pMFR VARCHAR(50),
            @pMPN VARCHAR(50),
            @pQuantity VARCHAR(10),
            @pPONumber VARCHAR(50),
            @pLotNo VARCHAR(50),
            @pLotCode VARCHAR(6),
            @pPackingDate VARCHAR(6),
            @pInspEmpID VARCHAR(10),
             @pInspEmpName NVARCHAR(100),
             @pCartonBoxNo VARCHAR(10),
             /*--vanduc edited vy Mrs.DuongHoa 20260703 up-date Sanmina label*/
             @pBoxSerialNo VARCHAR(30) = NULL
             /*--vanduc edited vy Mrs.DuongHoa 20260703 up-date Sanmina label*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO STB_SanminaIndiaLabelPrintHist (
            SupplierName,
            SanminaPartNumber,
            PartDesc,
            MFR,
            MPN,
            Quantity,
            PONumber,
            LotNo,
            LotCode,
            PackingDate,
            InspEmpID,
            InspEmpName,
            CartonBoxNo,
            PrintTime,
            PrintUserID,
            /*--vanduc edited vy Mrs.DuongHoa 20260703 up-date Sanmina label*/
            BoxSerialNo
            /*--vanduc edited vy Mrs.DuongHoa 20260703 up-date Sanmina label*/
    )
    values (
            @PSupplierName,
            @PSanminaPartNumber,
            @PPartDesc,
            @PMFR,
            @PMPN,
            @PQuantity,
            @PPONumber,
            @PLotNo,
            @PLotCode,
            @PPackingDate,
            @PInspEmpID,
            @PInspEmpName,
            @PCartonBoxNo,
            GETDATE(),
            @pProcessUserID,
            /*--vanduc edited vy Mrs.DuongHoa 20260703 up-date Sanmina label*/
            @pBoxSerialNo
            /*--vanduc edited vy Mrs.DuongHoa 20260703 up-date Sanmina label*/
    )

END

-- Safety validation bypass:
-- BEGIN TRAN
-- ROLLBACK TRAN
