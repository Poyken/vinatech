-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_PACLabelCartonWeight_get_Vietnam]	-- usp_PACLabelCartonWeight_get_Vietnam '', '', '3', '0'
	-- Add the parameters for the stored procedure here
				@pProcessUserID VARCHAR(20)=null,
				@pProcessLanguage VARCHAR(20)=null,
				@pNumberLabel INT = 1,
				@pIsWeightLabel BIT = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #tmp (Num INT)


	IF @pNumberLabel >= 1 
	BEGIN
		

		DECLARE @Number INT = 1;
		DECLARE @TotalBox INT = 0
		WHILE @Number <= @pNumberLabel
			BEGIN
				SET @TotalBox = @TotalBox + 1;
				INSERT INTO #tmp (Num) VALUES (@Number)
				SET @Number = @Number + 1;
			END
	END

	IF @pIsWeightLabel = 0 OR @pIsWeightLabel IS NULL
		BEGIN
			SELECT 
					'Carton Number Label'  as TypeLabel,
					CONVERT(VARCHAR(3), #tmp.Num) + 'A' as NumberCarton,
					'' AS Weight,
					0 AS LabelQty,
					'Report' AS CommandType

			FROM #tmp
		END
	ELSE
		BEGIN
			SELECT
					'Weight Label'  as TypeLabel,
					'' as NumberCarton,
					'8.3 KG' AS Weight,
					0 AS LabelQty,
					'Report' AS CommandType
		END

	DROP TABLE #tmp
END

