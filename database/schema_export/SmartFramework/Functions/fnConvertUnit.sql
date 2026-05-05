-- Function: fnConvertUnit
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2018-07-24
-- Description:	단위 변환
-- =============================================
CREATE FUNCTION [dbo].[fnConvertUnit]
(
	@pSourceUnit VARCHAR(20),
	@pTargetUnit VARCHAR(20),
	@pValue NUMERIC(38,19)
)
RETURNS NUMERIC(38,19)
AS
BEGIN
	--DECLARE @SourceUnit VARCHAR(20) = @pSourceUnit,
	--		@TargetUnit VARCHAR(20) = @pTargetUnit,
	--		@TempBasicUnit VARCHAR(20),			
	--		@ConvertRate NUMERIC(38,19),
	--		@Output NUMERIC(38,19) = @pValue
	
	--SELECT
	--		@ConvertRate = UC.ConvertRate
	--FROM
	--		STB_UnitConverter UC WITH(NOLOCK)
	--WHERE
	--		UC.TargetUnit = @SourceUnit

	--IF @ConvertRate IS NOT NULL BEGIN
	--	SET @Output = @Output * @ConvertRate
	--END

	--SET @ConvertRate = NULL

	--SELECT
	--		@ConvertRate = UC.ConvertRate
	--FROM
	--		STB_UnitConverter UC WITH(NOLOCK)
	--WHERE
	--		UC.TargetUnit = @TargetUnit

	--IF @ConvertRate IS NOT NULL BEGIN
	--	SET @Output = @Output / @ConvertRate
	--END

	--RETURN @Output

	DECLARE @SourceUnit VARCHAR(20) = @pSourceUnit,
			@TargetUnit VARCHAR(20) = @pTargetUnit,
			@TempBasicUnit VARCHAR(20),			
			@ConvertRate FLOAT(53),
			@Output NUMERIC(38,19) = @pValue,
			@BaseUnit VARCHAR(20)
	
	SELECT
			@ConvertRate = UC.ConvertRate,
			@BaseUnit = UC.BaseUnit
	FROM
			STB_UnitConverter UC WITH(NOLOCK)
	WHERE
			UC.TargetUnit = @SourceUnit

	IF @ConvertRate IS NOT NULL BEGIN
		SET @Output = @Output * @ConvertRate
	END

		SET @ConvertRate = NULL

		IF @TargetUnit <> ISNULL(@BaseUnit, '')
		BEGIN
				SELECT
						@ConvertRate = UC.ConvertRate
				FROM
						STB_UnitConverter UC WITH(NOLOCK)
				WHERE
						UC.TargetUnit = @TargetUnit

				IF @ConvertRate IS NOT NULL BEGIN
					SET @Output = @Output / @ConvertRate
				END ELSE BEGIN
					SET @Output = @pValue
				END
		END




	RETURN @Output
END

GO

