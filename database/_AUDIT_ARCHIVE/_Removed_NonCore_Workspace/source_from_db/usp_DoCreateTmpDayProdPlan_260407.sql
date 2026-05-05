-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-04-07
-- Description:	<Description,,>
-- exec usp_DoCreateTmpDayProdPlan_260407 'VVQM073R050526'
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateTmpDayProdPlan_260407] 
	-- Add the parameters for the stored procedure here
	@pBarcode VARCHAR(50) = NULL

	--select * from STB_DayProdPlan
	--where PONo = '260226000009'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DayPlanNo VARCHAR(50) = NULL,
			@CompanyCode VARCHAR(10) = NULL,
			@WorkCenterCode VARCHAR(10) = NULL,
			@PONo VARCHAR(50) = NULL,
			@MaterialCode VARCHAR(30) = NULL,
			@BomVersion VARCHAR(10) = NULL,
			@LineCode VARCHAR(20) = NULL,
			@PlanDate VARCHAR(20) = NULL,
			@PlanShiftCode VARCHAR(2) = NULL,
			@PlanQty VARCHAR(20) 
			



	SELECT	@DayPlanNo = DayPlanNo,
			@PONo = PONo,
			@MaterialCode = MaterialCode,
			@LineCode = InputLineCode,
			@PlanDate = InputJobDate,
			@PlanShiftCode = InputShiftCode
	FROM STB_SetInfo WHERE Barcode = @pBarcode

	select * from STB_SetInfo where Barcode='VVQM073R050526'
    
	IF EXISTS (SELECT 1 FROM STB_DayProdPlan WHERE DayPlanNo = @DayPlanNo)
		BEGIN
			RAISERROR(N'Kế hoạch ngày đã có trên hệ thống', 16, 1)
			RETURN;
		END

	ELSE
		BEGIN
			
			SELECT @PlanQty = SUM(ProdQty)
			FROM STB_SetInfo
			WHERE DayPlanNo = @DayPlanNo

			SELECT TOP 1 
			@CompanyCode = CompanyCode,
			@WorkCenterCode = WorkCenterCode,
			@BomVersion = BomVersion
			FROM STB_DayProdPlan
			WHERE PONo = @PONo


			INSERT INTO STB_DayProdPlan (
				DayPlanNo,
				CompanyCode,
				WorkCenterCode,
				PONo,
				MaterialCode,
				BomVersion,
				LineCode,
				PlanDate,
				PlanShiftCode,
				PlanQty,
				IsFixed,
				IsCancel,
				CurrentTarget,
				CreateDateTime,
				CreateUserID
			) values (
				
				@DayPlanNo,
				@CompanyCode,
				@WorkCenterCode,
				@PONo,
				@MaterialCode,
				@BomVersion,
				@LineCode,
				@PlanDate,
				@PlanShiftCode,
				@PlanQty,
				1,
				0,
				'0.0000',
				GETDATE(),
				'tmpMissing'
			)

			Print (@DayPlanNo + '|' + @pBarcode + ' Create Done!')



		END


END
