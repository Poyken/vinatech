-- =============================================
-- Author:	    Anonymous()
-- Create date: 2019-03-26
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
Create PROCEDURE [dbo].[usp_DoCreateHelaInBoxBarcode_20210819]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBatchID VARCHAR(20),
    @pBaseDate DATETIME,
	@pAddPackageLabelQty INT
AS
BEGIN
	SET NOCOUNT ON;

	Declare @PackageID VARCHAR(20)
	Declare @cnt INT = 0

	Declare @BatchID VARCHAR(20) = @pBatchID
	Declare @BaseDate VARCHAR(8) = CONVERT(VARCHAR(8), @pBaseDate, 112)
	Declare @AddPackageLabelQty INT = @pAddPackageLabelQty

	WHILE @AddPackageLabelQty > @cnt 
	
	BEGIN
		SELECT @PackageID = CONVERT(VARCHAR(20), CONVERT(NUMERIC(13), ISNULL(MAX(PackageID), @BaseDate + '00000')) + 1)
		  FROM STB_HelaBarcode
		 WHERE PackageID LIKE REPLACE(@BaseDate, '-', '') + '%'

		INSERT INTO STB_HelaBarcode (PackageID, BatchID) VALUES (@PackageID, @BatchID)

		SET @cnt = @cnt + 1
	END


END
