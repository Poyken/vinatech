-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_DigiKeySingleLevelPackage_get_Vietnam 
	-- Add the parameters for the stored procedure here
				@pProcessUserID VARCHAR(20)=null,
				@pProcessLanguage VARCHAR(20)=null,
				@pPackListNumber VARCHAR(50) = null,
				@pWeight VARCHAR(5) = null,
				@pPackageCount INT = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #tmp (Num INT)


	IF @pPackageCount >= 1 
	BEGIN
		

		DECLARE @Number INT = 1;
		DECLARE @TotalBox INT = 0
		WHILE @Number <= @pPackageCount
			BEGIN
				SET @TotalBox = @TotalBox + 1;
				INSERT INTO #tmp (Num) VALUES (@Number)
				SET @Number = @Number + 1;
			END
	END

	--DECLARE @rWeight NVARCHAR(15) 

	--SET @rWeight = @pWeight + ' lbs.'


		SELECT 
				@pPackListNumber AS PackListNumber,
				CONVERT(VARCHAR(3), #tmp.Num) + ' of ' + CONVERT(VARCHAR(3), @pPackageCount) as PackageCount,
				@pWeight as [Weight],
				@pPackageCount AS SUMPackage,
				1 AS LabelQty,
				'Report' AS CommandType

		FROM #tmp


	DROP TABLE #tmp
END

