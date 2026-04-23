-- =============================================
-- Author:
-- Create date:
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VietNam_FinishGood_BG_get]
	-- Add the parameters for the stored procedure here
	    @pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pPublicCode VARCHAR(20) = NULL,
		@pLotNo  NVARCHAR(50) = NULL,
		@pPackQty INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @PublicCode VARCHAR(50) = CASE WHEN ISNULL(@pPublicCode,'') = '' THEN '%' ELSE @pPublicCode END
	DECLARE @LotNo NVARCHAR(50) = CASE WHEN ISNULL(@pLotNo,'') = '' THEN '%' ELSE @pLotNo END
	DECLARE @PackQty INT = CASE WHEN ISNULL(@pPackQty,'') = '' THEN 0 ELSE @pPackQty END
	DECLARE	@PackingID NVARCHAR(50)
	DECLARE @MaterialCode NVARCHAR(50)
	DECLARE @MaterialName NVARCHAR(100)
	DECLARE @ProductionSize NVARCHAR(50)
	DECLARE @TypeProduction NVARCHAR(50)
	DECLARE @PartNo  NVARCHAR(50)
	DECLARE @IDCODE NVARCHAR(100)
	DECLARE @IsProdFinish BIT

	select @PartNo = PartNo from PublicCodeAndPartNo where PublicCode =@PublicCode

	SELECT TOP 1 @PackingID = PackingID 
                FROM STB_SavePackingTime_VVT 
                WHERE LotNo = @LotNo AND isPrinted = 1;
    
	SELECT @IsProdFinish = IsProdFinish
	  FROM STB_SetInfo SI WITH(NOLOCK)
	LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
	 WHERE Barcode = @LotNo

	 IF @@ROWCOUNT = 0 BEGIN
		SELECT @IsProdFinish = IsProdFinish
		  FROM STB_SetInfo
		 WHERE Barcode = REPLACE(@LotNo, 'VV', 'VV')
	END

	IF @IsProdFinish <> CONVERT(BIT, 1) BEGIN
		RAISERROR(N'Lot này chưa được đóng gói vui lòng liên hệ với sản xuất', 16, 1, @LotNo)
	END

	IF EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_BG_Test_20251225 WHERE LotNo = @pLotNo)
	BEGIN
	RAISERROR(N'Lot này đã được nhập kho', 16, 1, @LotNo)
	END

	--GEN ID
    EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_FINISHGOODS_BG_Test_20251225', @IDCODE OUTPUT;
	SET @IDCODE = 'FGVN_BG' + @IDCODE;

	-- CHECK MÃ LOT VỚI PARTNO XEM CÓ KHỚP KHÔNG
IF (
    (SELECT LEFT(Partno, CHARINDEX('(', Partno + '(') - 1) AS CleanPartNo FROM PublicCodeAndPartNo WHERE PublicCode = @PublicCode) 
    NOT LIKE 
    '%' + (
    SELECT 
    LEFT(FinalName, CHARINDEX(' ', FinalName + ' ') - 1) AS FinalPartNo
FROM (
    SELECT 
        CASE 
            WHEN CHARINDEX('-', CleanedName) > 0 
            THEN LEFT(CleanedName, CHARINDEX('-', CleanedName) - 1)
            ELSE CleanedName 
        END AS FinalName
    FROM (
        SELECT 
            LTRIM(REPLACE(ModelName, 'HY-CAP', '')) AS CleanedName
        FROM Stb_ModelBasicInfo 
        WHERE ModelCode = (SELECT TOP 1 MaterialCode FROM STB_SetInfo WHERE Barcode = @LotNo)
    ) AS SubStep1
) AS SubStep2
    ) + '%'
)
	BEGIN
	RAISERROR(N'Mã lot với PartNo không khớp', 16, 1, @LotNo)
	END
	SELECT 
	        @IDCODE as IDCODE,
			@PackingID as PackingID,
			@LotNo as LotNo,
			MM.MaterialCode,
			MM.MaterialName,
			@PackQty as PackQty,
			@pProcessUserID as EmpNo,
			GETDATE() as CreateDatePacked,
			 CASE 
                        WHEN CHARINDEX('(', MM.MaterialName) > 0 AND CHARINDEX(')', MM.MaterialName) > CHARINDEX('(', MM.MaterialName)
                        THEN SUBSTRING(
                            MM.MaterialName, 
                            CHARINDEX('(', MM.MaterialName) + 1, 
                            CHARINDEX(')', MM.MaterialName) - CHARINDEX('(', MM.MaterialName) - 1
                        )
                        ELSE NULL
                    END as ProductionSize,
			@PublicCode as PublicCode,
			@PartNo as PartNo,
			CASE WHEN LEFT(@LotNo, 1) = 'M' THEN N'Hàng Module' ELSE N'Hàng Cell' END as TypeProduction,
			N'Nhập' as StatusSystem,
		   GETDATE() as CreateDate,
		   @pProcessUserID as USERID,
		   '' as INPUTFORM,
		   VFBG.Levels as Levels,
		   VFBG.SoPhieuNhapKho,
		   'E62' as LoaiHinhToKhai,
		   'VVT_F2' as CODELOCATION
			
		 FROM STB_MaterialMaster MM
                INNER JOIN Stb_SetInfo SI ON MM.MaterialCode = SI.MaterialCode
				LEFT JOIN STB_VN_FINISHGOODS_BG_Test_20251225 VFBG ON SI.Barcode = VFBG.LotNo 
                WHERE SI.Barcode = @LotNo;

END
