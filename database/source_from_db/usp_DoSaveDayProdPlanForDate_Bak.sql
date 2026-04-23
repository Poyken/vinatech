
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-07-31
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSaveDayProdPlanForDate_Bak]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    
    -- Declare Columns Variable
	DECLARE @OldDayPlanNo VARCHAR(20)
	DECLARE @DayPlanNo VARCHAR(20)
	DECLARE @PONo VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @LineCode VARCHAR(20)
	DECLARE @PlanDate DATE
	DECLARE @PlanShiftCode VARCHAR(1)
	DECLARE @ProdPrior INT
	DECLARE @PlanQty NUMERIC(20,4)
	DECLARE @PlanCT NUMERIC(10,2)
	DECLARE @PlanTable TABLE
	(
		DayPlanNo VARCHAR(20),
		PONo VARCHAR(20),
		LineCode VARCHAR(20),
		PlanShiftCode VARCHAR(1),
		PlanDate DATE,
		PlanQty NUMERIC(20,4)
	)

	DECLARE @iDoc INT
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

    BEGIN TRY
		DECLARE PlanData CURSOR FOR
		SELECT
				DayPlanNo,
				PONo,
				LineCode,
				PlanShiftCode,
				BandName,
				PlanQty
		FROM
				OPENXML(@idoc , @UpdateTableName , 2)
				WITH  (
							DayPlanNo VARCHAR(20),
							PONo VARCHAR(20),
							LineCode VARCHAR(20),
							PlanShiftCode VARCHAR(1),
							BandName DATETIMEOFFSET,
							PlanQty NUMERIC(20,4)
						)
		WHERE
				PlanQty IS NOT NULL

		OPEN PlanData
		WHILE 1 = 1 BEGIN
            FETCH NEXT FROM PlanData INTO
								@DayPlanNo,
								@PONo,
								@LineCode,
								@PlanShiftCode,
								@PlanDate,
								@PlanQty

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			IF @PlanQty = 0 
			
			BEGIN
				DELETE FROM	STB_DayProdPlan
				WHERE DayPlanNo = @DayPlanNo
			END ELSE 

			BEGIN
				IF ISNULL(@DayPlanNo,'') = ''
				BEGIN
					EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DayProdPlan',@DayPlanNo OUTPUT                

					INSERT INTO STB_DayProdPlan
						(
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
							CreateDateTime,
							CreateUserID
						)
						SELECT
							@DayPlanNo,
							POI.CompanyCode,
							POI.WorkCenterCode,
							POI.PONo,
							POI.MaterialCode,
							POI.BomVersion,
							@LineCode,
							@PlanDate,
							@PlanShiftCode,
							@PlanQty,
							0,
							0,
							GETDATE(),
							@pProcessUserID
						FROM
								STB_ProductionOrderInfo POI               --
						WHERE
								POI.PONo = @PONo
				END
			END
		END

		DECLARE SourceData CURSOR FOR
		SELECT
				CASE 	WHEN OldDayPlanNo IS NULL THEN DayPlanNo		ELSE OldDayPlanNo				END AS OldDayPlanNo,
				DayPlanNo,
				PONo,
				MaterialCode,
				LineCode,
				--PlanDate,
				PlanShiftCode,
				ProdPrior,
				PlanQty,
				PlanCT,
				BandName
		FROM
				OPENXML(@idoc , @UpdateTableName , 2)
				WITH  (
							OldDayPlanNo VARCHAR(20),
							DayPlanNo VARCHAR(20),
							PONo VARCHAR(20),
							MaterialCode VARCHAR(50),
							LineCode VARCHAR(20),
							--PlanDate DATETIMEOFFSET,
							PlanShiftCode VARCHAR(1),
							ProdPrior INT,
							PlanQty NUMERIC(20,4),
							PlanCT NUMERIC(10,2),
							BandName DATETIMEOFFSET
						)

        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
								@OldDayPlanNo,
								@DayPlanNo,
								@PONo,
								@MaterialCode,
								@LineCode,
								--@PlanDate,
								@PlanShiftCode,
								@ProdPrior,
								@PlanQty,
								@PlanCT,
								@PlanDate


            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			SELECT
					@DayPlanNo = DPP.DayPlanNo,
					@OldDayPlanNo = DPP.DayPlanNo
			FROM
					STB_DayProdPlan DPP
			WHERE
					DPP.PONo = @PONo AND
					DPP.PlanDate = @PlanDate AND
					DPP.PlanShiftCode = @PlanShiftCode

			UPDATE STB_DayProdPlan
			SET PlanQty = ISNULL(@PlanQty,PlanQty),
				 ProdPrior =   ISNULL(@ProdPrior,ProdPrior),
				 PlanCT =   ISNULL(@PlanCT,PlanCT),
				 ChangeDateTime = GETDATE(),
				 ChangeUserID = @pProcessUserID
			WHERE
				DayPlanNo = @OldDayPlanNo
		END
    END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
			
	CLOSE SourceData;
	DEALLOCATE SourceData;
			
	EXEC sp_xml_removedocument @idoc	
END
