CREATE PROCEDURE [dbo].[pop_Electrode_Coating_iud]
  @ElectrodeLotNumber      NVARCHAR(50),
  @MachineCode             VARCHAR(20),
  @WorkerCode              VARCHAR(20),
  @Temperature             NUMERIC(10, 2),
  @Humidity                NUMERIC(10, 2),
  @ElectrodeMaterialCode   VARCHAR(20),
  @MaterialLotNumber       VARCHAR(20),
  @OneSideHeadGapLeft      NUMERIC(10, 3),
  @OneSideHeadGapRight     NUMERIC(10, 3),
  @BothSideHeadGapLeft     NUMERIC(10, 3),
  @BothSideHeadGapRight    NUMERIC(10, 3),
  @OneSideCoatingWidth     NUMERIC(10, 3),
  @BothSideCoatingWidth    NUMERIC(10, 3),
  @UnwindingValue          NUMERIC(20, 5),
  @RewindingValue          NUMERIC(20, 5),
  @ProductionQty           NUMERIC(20, 5),
  @GoodQty                 NUMERIC(20, 5),
  @BadQty				   NUMERIC(20, 5),
  @RouteCode               VARCHAR(20),
  @SpecificComment1		   NVARCHAR(1000),
  @NoEmp                   VARCHAR(20)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @InOutNo       VARCHAR(20);
  DECLARE @Unit          VARCHAR(20);
  DECLARE @FinalInputQty NUMERIC(20,5);

  BEGIN TRY
    BEGIN TRAN;

    /* ============================================================
       1) 전극코팅 실적 등록/수정 (MERGE)
    ============================================================ */
    MERGE STB_ElectrodeCoatingInfo AS Target
    USING (
      SELECT
        @ElectrodeLotNumber AS ElectrodeLotNumber,
        @MachineCode        AS MachineCode,
        GETDATE()           AS WorkDate,
        @WorkerCode         AS WorkerCode,
        @Temperature        AS Temperature,
        @Humidity           AS Humidity,
        @ElectrodeMaterialCode AS ElectrodeMaterialCode,
        @MaterialLotNumber  AS MaterialLotNumber,
        @OneSideHeadGapLeft AS OneSideHeadGapLeft,
        @OneSideHeadGapRight AS OneSideHeadGapRight,
        @BothSideHeadGapLeft AS BothSideHeadGapLeft,
        @BothSideHeadGapRight AS BothSideHeadGapRight,
        @OneSideCoatingWidth AS OneSideCoatingWidth,
        @BothSideCoatingWidth AS BothSideCoatingWidth,
        @UnwindingValue     AS UnwindingValue,
        @RewindingValue     AS RewindingValue,
        @ProductionQty      AS ProductionQty,
        @GoodQty            AS GoodQty,
		@BadQty				AS BadQty,
		@SpecificComment1	AS SpecificComment1,
        GETDATE()           AS CreateDateTime,
        @NoEmp              AS CreateUserID,
        GETDATE()           AS ChangeDateTime,
        @NoEmp              AS ChangeUserID
    ) AS Source
    ON Target.ElectrodeLotNumber = Source.ElectrodeLotNumber

    WHEN MATCHED THEN
      UPDATE SET
        MachineCode           = ISNULL(Source.MachineCode,          Target.MachineCode),
        WorkDate              = ISNULL(Source.WorkDate,             Target.WorkDate),
        WorkerCode            = ISNULL(Source.WorkerCode,           Target.WorkerCode),
        Temperature           = ISNULL(Source.Temperature,          Target.Temperature),
        Humidity              = ISNULL(Source.Humidity,             Target.Humidity),
        ElectrodeMaterialCode = ISNULL(Source.ElectrodeMaterialCode,Target.ElectrodeMaterialCode),
        MaterialLotNumber     = ISNULL(Source.MaterialLotNumber,    Target.MaterialLotNumber),
        OneSideHeadGapLeft    = ISNULL(Source.OneSideHeadGapLeft,   Target.OneSideHeadGapLeft),
        OneSideHeadGapRight   = ISNULL(Source.OneSideHeadGapRight,  Target.OneSideHeadGapRight),
        BothSideHeadGapLeft   = ISNULL(Source.BothSideHeadGapLeft,  Target.BothSideHeadGapLeft),
        BothSideHeadGapRight  = ISNULL(Source.BothSideHeadGapRight, Target.BothSideHeadGapRight),
        OneSideCoatingWidth   = ISNULL(Source.OneSideCoatingWidth,  Target.OneSideCoatingWidth),
        BothSideCoatingWidth  = ISNULL(Source.BothSideCoatingWidth, Target.BothSideCoatingWidth),
        UnwindingValue        = ISNULL(Source.UnwindingValue,       Target.UnwindingValue),
        RewindingValue        = ISNULL(Source.RewindingValue,       Target.RewindingValue),
        ProductionQty         = ISNULL(Source.ProductionQty,        Target.ProductionQty),
        GoodQty               = ISNULL(Source.GoodQty,              Target.GoodQty),
		BadQty				  = ISNULL(Source.BadQty,               Target.BadQty),
		SpecificComment1      = ISNULL(Source.SpecificComment1,     Target.SpecificComment1),
        ChangeDateTime        = Source.ChangeDateTime,
        ChangeUserID          = Source.ChangeUserID

    WHEN NOT MATCHED THEN
      INSERT (ElectrodeLotNumber, MachineCode, WorkDate, WorkerCode, Temperature, Humidity,
              ElectrodeMaterialCode, MaterialLotNumber, OneSideHeadGapLeft, OneSideHeadGapRight,
              BothSideHeadGapLeft, BothSideHeadGapRight, OneSideCoatingWidth, BothSideCoatingWidth,
              UnwindingValue, RewindingValue, ProductionQty, GoodQty, BadQty, SpecificComment1,CreateDateTime, CreateUserID)
      VALUES (Source.ElectrodeLotNumber, Source.MachineCode, Source.WorkDate, Source.WorkerCode,
              Source.Temperature, Source.Humidity, Source.ElectrodeMaterialCode, Source.MaterialLotNumber,
              Source.OneSideHeadGapLeft, Source.OneSideHeadGapRight, Source.BothSideHeadGapLeft,
              Source.BothSideHeadGapRight, Source.OneSideCoatingWidth, Source.BothSideCoatingWidth,
              Source.UnwindingValue, Source.RewindingValue, Source.ProductionQty, Source.GoodQty, Source.BadQty, Source.SpecificComment1,
              Source.CreateDateTime, Source.CreateUserID);


    /* ============================================================
       2) 자재 사용이력 (이미 등록된 경우 제외)
    ============================================================ */
    SELECT TOP 1
        @InOutNo = MWIO.MaterialWarehouseInOutHistNo,
        @FinalInputQty = MLI.InitialQty,
        @Unit = MM.MaterialUnit
    FROM 
        STB_MaterialWarehouseInOutHist MWIO WITH (NOLOCK)
        LEFT JOIN STB_MaterialLotInfo MLI WITH (NOLOCK)
            ON MWIO.LotID = MLI.LotID
        LEFT JOIN STB_MaterialMaster MM WITH (NOLOCK)
            ON MLI.MaterialCode = MM.MaterialCode
    WHERE MWIO.LotID = @MaterialLotNumber
    ORDER BY MWIO.CreateDateTime DESC;

    IF @InOutNo IS NOT NULL
    BEGIN
		-- 재고 차감 처리
		UPDATE STB_MaterialLotInfo
		SET CurrentQty = CurrentQty - @FinalInputQty
		WHERE LotID = @MaterialLotNumber AND CurrentQty > 0;

        IF NOT EXISTS (
            SELECT 1 FROM STB_MaterialWarehouseUsageHist
            WHERE MaterialWarehouseInOutHistNo = @InOutNo
              AND DayPlanNo = @ElectrodeLotNumber
              AND MaterialLotId = @MaterialLotNumber
        )
        BEGIN
            INSERT STB_MaterialWarehouseUsageHist
            ( MaterialWarehouseInOutHistNo, DayPlanNo, MaterialLotId, MaterialCode,
              RouteCode, MachineCode, QtyUsed, Unit, NoEmp, OutDate )
            VALUES
            ( @InOutNo, @ElectrodeLotNumber, @MaterialLotNumber, @ElectrodeMaterialCode,
              @RouteCode, @MachineCode, @FinalInputQty, @Unit, @NoEmp, GETDATE() );
        END
    END

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
  END CATCH
END
