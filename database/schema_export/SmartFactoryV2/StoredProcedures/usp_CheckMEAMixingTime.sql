-- Procedure: usp_CheckMEAMixingTime
CREATE PROC usp_CheckMEAMixingTime
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pBarcode VARCHAR(20)
   ,@pCheckResult BIT OUTPUT
AS
BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode
	       ,@MixingTimeDiff1 NUMERIC(20,5)
		   ,@MixingTimeDiff2 NUMERIC(20,5)
		   ,@MixingTimeDiff3 NUMERIC(20,5)
		   ,@SonicationTimeDiff1 NUMERIC(20,5)
		   ,@SonicationTimeDiff2 NUMERIC(20,5)

	SELECT @MixingTimeDiff1 = DATEDIFF(second, StartDateTime, EndDateTime)
	  FROM STB_MEAElectrodeMixingHist
	 WHERE MEAMixingStepCode = 'MS001'

	SELECT @MixingTimeDiff2 = DATEDIFF(second, StartDateTime, EndDateTime)
	  FROM STB_MEAElectrodeMixingHist
	 WHERE MEAMixingStepCode = 'MS003'

	SELECT @MixingTimeDiff3 = DATEDIFF(second, StartDateTime, EndDateTime)
	  FROM STB_MEAElectrodeMixingHist
	 WHERE MEAMixingStepCode = 'MS005'

	SELECT @SonicationTimeDiff1 = DATEDIFF(second, StartDateTime, EndDateTime)
	  FROM STB_MEAElectrodeMixingHist
	 WHERE MEAMixingStepCode = 'MS002'

	SELECT @SonicationTimeDiff2 = DATEDIFF(second, StartDateTime, EndDateTime)
	  FROM STB_MEAElectrodeMixingHist
	 WHERE MEAMixingStepCode = 'MS004'

	IF @MixingTimeDiff1 < 60 * 60
	    OR @MixingTimeDiff2 < 60 * 60
		OR @MixingTimeDiff3 < 60 * 60
		OR @SonicationTimeDiff1 < 40 * 60
		OR @SonicationTimeDiff2 < 40 * 60 
	BEGIN
		SET @pCheckResult = CONVERT(BIT, 0)
	END ELSE BEGIN
		SET @pCheckResult = CONVERT(BIT, 1)
	END
END
GO

