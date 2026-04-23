-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_JabilMexicoLabelPrintHist_iud]  -- select * from STB_JabilMexicoLabelPrintHist
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pJabilPartNumber VARCHAR(50),
		@pVinatechPartNumber VARCHAR(50),
		@pPONumber VARCHAR(50),
		@pQuantity VARCHAR(10),
		@pLotCode VARCHAR(50),
		@pDateCode VARCHAR(4),
		@pCoO VARCHAR(10),
		@pMSL VARCHAR(10),
		@pLabelQty varchar(10)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO STB_JabilMexicoLabelPrintHist (
			JabilPartNumber ,
			VinatechPartNumber ,
			PONumber ,
			Quantity ,
			LotCode ,
			DateCode ,
			CoO ,
			MSL,
			LabelQty,
			PrintTime ,
			PrintUserID
		) 
		VALUES 
			(
				@pJabilPartNumber,
				@pVinatechPartNumber,
				@pPONumber,
				@pQuantity,
				@pLotCode,
				@pDateCode,
				@pCoO,
				@pMSL,
				@pLabelQty,
				GETDATE() ,
				@pProcessUserID
			)

END
