-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-09-18
-- Description:	test
-- =============================================
CREATE PROCEDURE [dbo].[usp_DemoTest]
	-- Add the parameters for the stored procedure here
	@pBarcode varchar(50)=NULL,
	@pFarad VARCHAR(50)=NULL,
	@pGrade varchar(50)=NULL,
	@pVoltage varchar(50)=NULL
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	  DECLARE @QRCode NVARCHAR(500);
	  SET @QRCode = CONCAT(@pBarcode,',',@pGrade);
	   SELECT  
       
        @pBarcode AS Barcode,
        @QRCode AS QRCode,
		@pGrade AS Grade,
		@pVoltage as Voltage,
		'Report' AS CommandType
END
