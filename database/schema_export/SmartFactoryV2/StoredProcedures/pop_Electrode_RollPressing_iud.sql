-- Procedure: pop_Electrode_RollPressing_iud
CREATE PROCEDURE [dbo].[pop_Electrode_RollPressing_iud]
  @ElectrodeLotNumber      VARCHAR(20),
  @MachineCode             VARCHAR(20),
  @WorkerCode              VARCHAR(20),
  @Temperature             NUMERIC(20,5),
  @Humidity                NUMERIC(20,5),
  @RollingDensityValue     NUMERIC(20,5),
  @RollingDensityResult    VARCHAR(10),
  @HeadGapInitLeft         VARCHAR(10),
  @HeadGapInitRight        VARCHAR(10),
  @ProdConTemp             NUMERIC(20,5),
  @ProdConSpeed            NUMERIC(20,5),
  @ProductionQty           NUMERIC(20,5),
  @GoodQty                 NUMERIC(20,5),
  @BadQty                  NUMERIC(20,5),
  @VisualInspectionResult  VARCHAR(1000),
  @NoEmp				   VARCHAR(20)
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRAN;

    ---------------------------------------------------------
    -- 1) 프레스 정보 MERGE
    ---------------------------------------------------------
    MERGE STB_ElectrodeRollPressingInfo AS Target
    USING (
        SELECT
            @ElectrodeLotNumber     AS ElectrodeLotNumber,
            @MachineCode            AS MachineCode,
            GETDATE()               AS WorkDate,
            @WorkerCode             AS WorkerCode,
            @Temperature            AS Temperature,
            @Humidity               AS Humidity,
            @RollingDensityValue    AS RollingDensityValue,
            @RollingDensityResult   AS RollingDensityResult,
            @HeadGapInitLeft        AS HeadGapInitLeft,
            @HeadGapInitRight       AS HeadGapInitRight,
            @ProdConTemp            AS ProdConTemp,
            @ProdConSpeed           AS ProdConSpeed,
            @ProductionQty          AS ProductionQty,
            @GoodQty                AS GoodQty,
            @BadQty                 AS BadQty,
            @VisualInspectionResult AS VisualInspectionResult,
            GETDATE()               AS CreateDateTime,
            @NoEmp					AS CreateUserID,
            GETDATE()               AS ChangeDateTime,
            @NoEmp					AS ChangeUserID
    ) AS Source
    ON Target.ElectrodeLotNumber = Source.ElectrodeLotNumber

    WHEN MATCHED THEN
      UPDATE SET
          Target.MachineCode            = ISNULL(Source.MachineCode, Target.MachineCode),
          Target.WorkDate               = ISNULL(Source.WorkDate, Target.WorkDate),
          Target.WorkerCode             = ISNULL(Source.WorkerCode, Target.WorkerCode),
          Target.Temperature            = ISNULL(Source.Temperature, Target.Temperature),
          Target.Humidity               = ISNULL(Source.Humidity, Target.Humidity),
          Target.RollingDensityValue    = ISNULL(Source.RollingDensityValue, Target.RollingDensityValue),
          Target.RollingDensityResult   = ISNULL(Source.RollingDensityResult, Target.RollingDensityResult),
          Target.HeadGapInitLeft        = ISNULL(Source.HeadGapInitLeft, Target.HeadGapInitLeft),
          Target.HeadGapInitRight       = ISNULL(Source.HeadGapInitRight, Target.HeadGapInitRight),
          Target.ProdConTemp            = ISNULL(Source.ProdConTemp, Target.ProdConTemp),
          Target.ProdConSpeed           = ISNULL(Source.ProdConSpeed, Target.ProdConSpeed),
          Target.ProductionQty          = ISNULL(Source.ProductionQty, Target.ProductionQty),
          Target.GoodQty                = ISNULL(Source.GoodQty, Target.GoodQty),
          Target.BadQty                 = ISNULL(Source.BadQty, Target.BadQty),
          Target.VisualInspectionResult = ISNULL(Source.VisualInspectionResult, Target.VisualInspectionResult),
          Target.ChangeDateTime         = Source.ChangeDateTime,
          Target.ChangeUserID           = Source.ChangeUserID

    WHEN NOT MATCHED THEN
      INSERT (
          ElectrodeLotNumber,
          MachineCode,
          WorkDate,
          WorkerCode,
          Temperature,
          Humidity,
          RollingDensityValue,
          RollingDensityResult,
          HeadGapInitLeft,
          HeadGapInitRight,
          ProdConTemp,
          ProdConSpeed,
          ProductionQty,
          GoodQty,
          BadQty,
          VisualInspectionResult,
          CreateDateTime,
          CreateUserID
      )
      VALUES (
          Source.ElectrodeLotNumber,
          Source.MachineCode,
          Source.WorkDate,
          Source.WorkerCode,
          Source.Temperature,
          Source.Humidity,
          Source.RollingDensityValue,
          Source.RollingDensityResult,
          Source.HeadGapInitLeft,
          Source.HeadGapInitRight,
          Source.ProdConTemp,
          Source.ProdConSpeed,
          Source.ProductionQty,
          Source.GoodQty,
          Source.BadQty,
          Source.VisualInspectionResult,
          Source.CreateDateTime,
          Source.CreateUserID
      );

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
  END CATCH
END

GO

