-- Procedure: pop_Electrode_Weighing_iud
/* 2026-04-21 [김형진] - pop_Electrode_Weighing_iud 통합 */
/* 변경사항:
   - 7단계 INSERT 대상: STB_MaterialWarehouseUsageHist → STB_RawMaterialInputHist
   - 컬럼 매핑:
     * MaterialLotNo → MaterialLotNo (동일)
     * DayPlanNo → Barcode (생산 LOT)
     * MaterialLotId → LotMaterialCode (원자재 LOT ID)
     * MaterialCode → MaterialCode
     * QtyUsed → Qty
     * NoEmp → CreateUserID / WorkerCode
     * OutDate → CreateDateTime
   - PK: usp_DoCreateSerial('STB_RawMaterialInputHist')
   - Source='MES_SP', InputType='ELECTRODE'
   - ★ 파라미터 시그니처 변경 없음 (MES SmartFactory 호환)
*/

CREATE PROCEDURE [dbo].[pop_Electrode_Weighing_iud]
  @ElectrodeLotNumber      NVARCHAR(50),
  @ElectrodeStep           VARCHAR(10),
  @Seq                     INT,
  @ElectrodeMaterialCode   VARCHAR(20),
  @MaterialLotId           VARCHAR(20),
  @MaterialLotNo           VARCHAR(20),
  @InputQty1               NUMERIC(20, 3),
  @InputQty2               NUMERIC(20, 3),
  @StdMinVal               NUMERIC(20, 3),
  @StdMaxVal               NUMERIC(20, 3),
  @NoEmp                   VARCHAR(20),
  @Unit                    VARCHAR(20)  = NULL,
  @RouteCode               VARCHAR(20)  = NULL,
  @MachineCode             VARCHAR(20)  = NULL
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @CurrentQty     NUMERIC(20,3);
  DECLARE @FinalInputQty  NUMERIC(20,3);
  DECLARE @TotalQty       NUMERIC(20,3);
  DECLARE @InOutNo        VARCHAR(20);
  DECLARE @NewHistNo      VARCHAR(20);   -- ★ 신규: PK 채번용

  BEGIN TRY
    BEGIN TRAN;

    -- 1) 현재 재고 수량 조회 (UPDLOCK으로 동시성 제어)
    SELECT @CurrentQty = CurrentQty
    FROM STB_MaterialLotInfo WITH (UPDLOCK, HOLDLOCK)
    WHERE MaterialLotNo = @MaterialLotNo;

    -- 2) 불출 이력 조회 (주석 유지 — 현재 미사용)
    /*
    SELECT TOP 1
        @InOutNo = MaterialWarehouseInOutHistNo
    FROM STB_MaterialWarehouseInOutHist WITH (NOLOCK)
    WHERE LotID = @MaterialLotId
    ORDER BY CreateDateTime DESC;
    */

    -- 3) 투입 수량 결정
    IF @CurrentQty IS NULL
    BEGIN
      -- 불출 이력 없을 경우
      SET @FinalInputQty = @InputQty1;
    END
    ELSE IF @CurrentQty <= 0
    BEGIN
      -- 재고 없음
      SET @FinalInputQty = @CurrentQty;
    END
    ELSE IF @InputQty1 >= @CurrentQty
    BEGIN
      -- 재고 부족: 남은 재고 전량 사용
      SET @FinalInputQty = @CurrentQty;
    END
    ELSE
    BEGIN
      -- 정상 차감
      SET @FinalInputQty = @InputQty1;
    END

    -- 4) 재고 차감 처리
    UPDATE STB_MaterialLotInfo
    SET CurrentQty = CurrentQty - ROUND(@FinalInputQty, 2, 0)
    WHERE MaterialLotNo = @MaterialLotNo;

    -- 5) 총 투입량 계산
    SET @TotalQty = ISNULL(@FinalInputQty, 0) + ISNULL(@InputQty2, 0);

    -- 6) 실적 반영
    MERGE STB_ElectrodeMixStepInfo AS target
    USING (
      SELECT
        @ElectrodeLotNumber      AS ElectrodeLotNumber,
        @ElectrodeStep           AS ElectrodeStep,
        @Seq                     AS Seq,
        @ElectrodeMaterialCode   AS ElectrodeMaterialCode,
        @MaterialLotId           AS MaterialLotId,
        @FinalInputQty           AS InputQty1,
        @InputQty2               AS InputQty2,
        @StdMinVal               AS StdMinVal,
        @StdMaxVal               AS StdMaxVal,
        @TotalQty                AS TotalQty
    ) AS source
    ON (
      target.ElectrodeLotNumber = source.ElectrodeLotNumber
      AND target.ElectrodeStep  = source.ElectrodeStep
      AND target.SEQ            = source.SEQ
    )
    WHEN MATCHED THEN
      UPDATE SET 
        InputQty1         = target.InputQty1 + source.InputQty1,
        MaterialLotNumber = source.MaterialLotId,
        ChangeDateTime    = GETDATE(),
        ChangeUserID      = @NoEmp,
        InputQty2         = CASE WHEN source.InputQty2 > 0 THEN source.InputQty2 ELSE target.InputQty2 END,
        MixingInputTime   = GETDATE()
    WHEN NOT MATCHED THEN
      INSERT (ElectrodeLotNumber, ElectrodeStep, SEQ, ElectrodeMaterialCode, MaterialLotNumber,
              InputQty1, InputQty2, MixingInputTime, CreateDateTime, CreateUserID)
      VALUES (source.ElectrodeLotNumber, source.ElectrodeStep, source.SEQ, source.ElectrodeMaterialCode,
              source.MaterialLotId, source.InputQty1, source.InputQty2,
              GETDATE(), GETDATE(), @NoEmp);

    -- ★ 7) 사용 이력 기록 (STB_RawMaterialInputHist 통합)
    -- 기존: STB_MaterialWarehouseUsageHist → 통합 테이블로 전환
    IF @FinalInputQty > 0
    BEGIN
      -- PK 채번
      EXEC usp_DoCreateSerial 'STB_RawMaterialInputHist', @NewHistNo OUTPUT;

      INSERT INTO STB_RawMaterialInputHist
      (
        RawMaterialInputHistNo,   -- PK (Serial Generator)
        Barcode,                  -- 생산 LOT = ElectrodeLotNumber
        ProductGroupCode,         -- MaterialMaster에서 조회
        RawMaterialBarcode,       -- 원자재 LOT 바코드
        MaterialCode,             -- 자재 코드
        Qty,                      -- 투입 수량
        MaterialLotNo,            -- 원자재 LOT 관리 번호
        LotMaterialCode,          -- 원자재 LOT ID
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
        @ElectrodeLotNumber,                                           -- Barcode = 전극 LOT
        ISNULL(
          (SELECT TOP 1 MM.ProductGroupCode
           FROM STB_MaterialMaster MM WITH(NOLOCK)
           WHERE MM.MaterialCode = @ElectrodeMaterialCode),
          ''
        ),                                                             -- ProductGroupCode
        @MaterialLotNo,                                                -- RawMaterialBarcode = 원자재 LOT 관리번호
        @ElectrodeMaterialCode,                                        -- MaterialCode
        @FinalInputQty,                                                -- Qty
        @MaterialLotNo,                                                -- MaterialLotNo
        @MaterialLotId,                                                -- LotMaterialCode = 원자재 LOT ID
        @RouteCode,
        @MachineCode,
        @Unit,
        GETDATE(),
        @NoEmp,
        @NoEmp,
        'MES_SP',                                                      -- Source: MES 프로시저에서 호출
        'ELECTRODE'                                                    -- InputType: 전극 칭량
      );
    END

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
  END CATCH
END

GO

