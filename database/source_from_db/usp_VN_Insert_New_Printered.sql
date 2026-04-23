CREATE PROC [dbo].[usp_VN_Insert_New_Printered]
		 @pBarcode NVARCHAR(50),
		 --@pMaterialName NVARCHAR(50),
		 --@pMaterialCode NVARCHAR(30),
		 @pLotQty INT,
		 @pLabelQty INT,
		 @pVoltage NVARCHAR(30),
		 @pFarad NVARCHAR(30),
		 @pRating NVARCHAR(30),
		 @pPartNo NVARCHAR(30),
         @pCreateUserID NVARCHAR(20) = NULL
     
AS
BEGIN

		DECLARE @Barcode NVARCHAR(50) = @pBarcode
		--DECLARE @MaterialName NVARCHAR(50) = @pMaterialName
		--DECLARE @MaterialCode NVARCHAR(30) = @pMaterialCode
		DECLARE @LotQty INT = @pLotQty
		DECLARE @LabelQty INT = @pLabelQty
		DECLARE @Voltage NVARCHAR(30) = @pVoltage
		DECLARE @Farad NVARCHAR(30) = @pFarad
		DECLARE @Rating NVARCHAR(30) = @pRating
		DECLARE @PartNo NVARCHAR(30) = @pPartNo
		DECLARE @CreateUserID NVARCHAR(20) =   @pCreateUserID 

		INSERT INTO STB_VN_NEW_PRINTER
		(
				Barcode,
				--MaterialName,
				--MaterialCode,
				LotQty,
				LabelQty,
				Voltage,
				Farad,
				Rating,
				PartNo,
				StatusPrinter,
				CreateDateTime,
				CreateUserID
		)
		VALUES
		(
				@Barcode,
				--@MaterialName,
				--@MaterialCode,
				@LotQty,
				@LabelQty,
				@Voltage,
				@Farad,
				@Rating,
				@PartNo,
				'1',
				DATEADD(HH, -2, GETDATE()),
				@CreateUserID
		)
		
END

--select * from STB_VN_NEW_PRINTER