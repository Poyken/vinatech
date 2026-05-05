-- Procedure: pop_Electrode_Coating_iud
/* 2026-04-29 [김형진] - pop_Electrode_Coating_iud STB_RawMaterialInputHist 통합 */
/* 변경사항:
   - 2단계 INSERT 대상: STB_MaterialWarehouseUsageHist → STB_RawMaterialInputHist
   - 컬럼 매핑:
     * ElectrodeLotNumber → Barcode (생산 LOT)
     * MaterialLotNumber → LotMaterialCode / RawMaterialBarcode (원자재 LOT ID)
     * ElectrodeMaterialCode → MaterialCode
     * FinalInputQty → Qty
     * NoEmp → CreateUserID / WorkerCode
   - PK: usp_DoCreateSerial('STB_RawMaterialInputHist')
   - Source='MES_SP', InputType='COATING'
   - ★ 파라미터 시그니처 변경 없음 (MES SmartFactory 호환)
*/

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
  @BadQty                  NUMERIC(20, 5),
  @RouteCode               VARCHAR(20),
  @SpecificComment1        NVARCHAR(1000),
  @NoEmp                   VARCHAR(20)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @InOutNo       VARCHAR(20);
  DECLARE @Unit          VARCHAR(20);
  DECLARE @FinalInputQty NUMERIC(20,5);
  DECLARE @NewHistNo     VARCHAR(20);   -- ★ 신규: PK 채번용

  BEGIN TRY
    BEGIN TRAN;

    /* ============================================================
       1) 전극코팅 실적 등록/수정 (MERGE) — 변경 없음
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
        @BadQty             AS BadQty,
        @SpecificComment1   AS SpecificComment1,
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
        BadQty                = ISNULL(Source.BadQty,               Target.BadQty),
        SpecificComment1      = ISNULL(Source.SpecificComment1,     Target.SpecificComment1),
        ChangeDateTime        = Source.ChangeDateTime,
        ChangeUserID          = Source.ChangeUserID

    WHEN NOT MATCHED THEN
      INSERT (ElectrodeLotNumber, MachineCode, WorkDate, WorkerCode, Temperature, Humidity,
              ElectrodeMaterialCode, MaterialLotNumber, OneSideHeadGapLeft, OneSideHeadGapRight,
              BothSideHeadGapLeft, BothSideHeadGapRight, OneSideCoatingWidth, BothSideCoatingWidth,
              UnwindingValue, RewindingValue, ProductionQty, GoodQty, BadQty, SpecificComment1, CreateDateTime, CreateUserID)
      VALUES (Source.ElectrodeLotNumber, Source.MachineCode, Source.WorkDate, Source.WorkerCode,
              Source.Temperature, Source.Humidity, Source.ElectrodeMaterialCode, Source.MaterialLotNumber,
              Source.OneSideHeadGapLeft, Source.OneSideHeadGapRight, Source.BothSideHeadGapLeft,
              Source.BothSideHeadGapRight, Source.OneSideCoatingWidth, Source.BothSideCoatingWidth,
              Source.UnwindingValue, Source.RewindingValue, Source.ProductionQty, Source.GoodQty, Source.BadQty, Source.SpecificComment1,
              Source.CreateDateTime, Source.CreateUserID);


    /* ============================================================
       2) 자재 사용이력 (STB_RawMaterialInputHist 통합)
       ★ 변경: STB_MaterialWarehouseUsageHist → STB_RawMaterialInputHist
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

        -- ★ 중복 체크: STB_RawMaterialInputHist 대상으로 변경
        IF NOT EXISTS (
            SELECT 1 FROM STB_RawMaterialInputHist WITH (NOLOCK)
            WHERE Barcode = @ElectrodeLotNumber
              AND LotMaterialCode = @MaterialLotNumber
              AND Source = 'MES_SP'
              AND InputType = 'COATING'
              AND Status = 'ACTIVE'
        )
        BEGIN
            -- ★ PK 채번
            EXEC usp_DoCreateSerial 'STB_RawMaterialInputHist', @NewHistNo OUTPUT;

            INSERT INTO STB_RawMaterialInputHist
            (
              RawMaterialInputHistNo,   -- PK (Serial Generator)
              Barcode,                  -- 생산 LOT = ElectrodeLotNumber
              ProductGroupCode,         -- MaterialMaster에서 조회
              RawMaterialBarcode,       -- 원자재 LOT 바코드
              MaterialCode,             -- 자재 코드
              Qty,                      -- 투입 수량
              MaterialLotNo,            -- 원자재 LOT 관리 번호 (MaterialLotInfo.MaterialLotNo)
              LotMaterialCode,          -- 원자재 LOT ID
              MaterialWarehouseInOutHistNo, -- 불출이력 참조
              RouteCode,
              MachineCode,
              Unit,
              CreateDateTime,
              CreateUserID,
              WorkerCode,
              Source,                   -- 출처 구분
              InputType                 -- 투입 유형
            )
            VALUES
            (
              @NewHistNo,
              @ElectrodeLotNumber,                                         -- Barcode = 전극 LOT
              ISNULL(
                (SELECT TOP 1 MM.ProductGroupCode
                 FROM STB_MaterialMaster MM WITH(NOLOCK)
                 WHERE MM.MaterialCode = @ElectrodeMaterialCode),
                ''
              ),                                                           -- ProductGroupCode
              @MaterialLotNumber,                                          -- RawMaterialBarcode = 원자재 LOT ID
              @ElectrodeMaterialCode,                                      -- MaterialCode
              @FinalInputQty,                                              -- Qty
              ISNULL(
                (SELECT TOP 1 MLI2.MaterialLotNo
                 FROM STB_MaterialLotInfo MLI2 WITH(NOLOCK)
                 WHERE MLI2.LotID = @MaterialLotNumber),
                @MaterialLotNumber
              ),                                                           -- MaterialLotNo
              @MaterialLotNumber,                                          -- LotMaterialCode = 원자재 LOT ID
              @InOutNo,                                                    -- MaterialWarehouseInOutHistNo (불출이력 참조 유지)
              @RouteCode,
              @MachineCode,
              @Unit,
              GETDATE(),
              @NoEmp,
              @NoEmp,
              'MES_SP',                                                    -- Source: MES 프로시저에서 호출
              'COATING'                                                    -- InputType: 전극 코팅
            );
        END
    END

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
  END CATCH
END

GO

