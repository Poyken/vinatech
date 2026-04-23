
CREATE PROCEDURE [dbo].[USP_VINA_GetBomInfoByLotOrItem]
    @pProcessLanguage VARCHAR(20),
    @pProcessUserID VARCHAR(20),
    @pLotNumber      VARCHAR(50)  = NULL,   -- LOT 번호 (STB_SETINFO.LotNumber 기준 조회)
    @pMaterialCode   VARCHAR(50)  = NULL,   -- 품목코드 (직접 입력 시)
    @pBomVersion     VARCHAR(20)  = NULL    -- BOM 버전 (미입력 시 최신 Active 버전 자동 선택)
WITH RECOMPILE
AS
BEGIN
    SET NOCOUNT ON;

    -- ─────────────────────────────────────────────
    -- 1) 파라미터 결정: LOT → 품목코드 추출
    -- ─────────────────────────────────────────────
    DECLARE @MaterialCode   VARCHAR(50)
    DECLARE @BomVersion     VARCHAR(20)
    DECLARE @LotNumber      VARCHAR(50)  = ISNULL(@pLotNumber, '')
    DECLARE @ControlNo      VARCHAR(20)  = ''
    DECLARE @PONo           VARCHAR(20)  = ''
    DECLARE @DayPlanNo      VARCHAR(20)  = ''
    DECLARE @CustRevision   VARCHAR(20)  = ''

    IF @LotNumber <> ''
    BEGIN
        -- LOT 번호 → STB_SETINFO에서 품목코드, 관리번호, 작업지시번호 추출
        SELECT TOP 1
            @MaterialCode = S.MaterialCode,
            @ControlNo    = S.ControlNo,
            @PONo         = ISNULL(S.PONo, ''),
            @DayPlanNo    = ISNULL(S.DayPlanNo, '')
        FROM STB_SETINFO S WITH(NOLOCK)
        WHERE S.Barcode = @LotNumber
        ORDER BY S.ControlNo DESC

        IF @MaterialCode IS NULL
        BEGIN
            RAISERROR(N'LOT 번호 [%s]에 해당하는 품목 정보를 찾을 수 없습니다.', 16, 1, @LotNumber)
            RETURN
        END
    END
    ELSE IF ISNULL(@pMaterialCode, '') <> ''
    BEGIN
        SET @MaterialCode = @pMaterialCode
    END
    ELSE
    BEGIN
        RAISERROR(N'LOT 번호 또는 품목코드 중 하나는 필수 입력입니다.', 16, 1)
        RETURN
    END

    -- ─────────────────────────────────────────────
    -- 2) BomVersion 결정: 미입력 시 최신 Active 버전 자동
    -- ─────────────────────────────────────────────
    IF ISNULL(@pBomVersion, '') <> ''
        SET @BomVersion = @pBomVersion
    ELSE
    BEGIN
        -- STB_BomRevision_Map에서 IsActive=1 최신 버전
        SELECT TOP 1 @BomVersion = RM.BomVersion, @CustRevision = RM.CustomerRevision
        FROM STB_BomRevision_Map RM WITH(NOLOCK)
        WHERE RM.MaterialCode = @MaterialCode AND RM.IsActive = 1
        ORDER BY RM.BomVersion DESC

        -- RevisionMap에 없으면 BomHeader에서 최신 버전
        IF @BomVersion IS NULL
            SELECT TOP 1 @BomVersion = BH.BomVersion
            FROM STB_BomHeader BH WITH(NOLOCK)
            WHERE BH.MaterialCode = @MaterialCode
            ORDER BY BH.BomVersion DESC
    END

    IF @BomVersion IS NULL
    BEGIN
        RAISERROR(N'품목코드 [%s]에 등록된 BOM이 없습니다.', 16, 1, @MaterialCode)
        RETURN
    END

    -- CustomerRevision 보충 조회
    IF @CustRevision = ''
        SELECT @CustRevision = ISNULL(RM.CustomerRevision, '')
        FROM STB_BomRevision_Map RM WITH(NOLOCK)
        WHERE RM.MaterialCode = @MaterialCode AND RM.BomVersion = @BomVersion

    -- ─────────────────────────────────────────────────────────────
    -- 3) ResultSet #1: 헤더 정보 (모품목 기본 정보)
    -- ─────────────────────────────────────────────────────────────
    SELECT
        @MaterialCode    AS MaterialCode,     -- 모품목 코드
        MM.MaterialName,                      -- 모품목명
        MM.MaterialSpec,                      -- 모품목 규격
        @BomVersion      AS BomVersion,       -- BOM 버전 (예: 1000, 1001)
        @CustRevision    AS CustomerRevision, -- 고객 리비전 (예: A, 00)
        @LotNumber       AS LotNumber,        -- 입력된 LOT 번호 (직접 품목 입력 시 빈값)
        @ControlNo       AS ControlNo,        -- 관리번호 (STB_SETINFO)
        @PONo            AS PONo,             -- 작업지시번호
        @DayPlanNo       AS DayPlanNo,        -- 일일계획번호
        BH.BomUnit,                           -- BOM 기본 단위
        BH.BomHeaderDesc                      -- BOM 헤더 설명
    FROM STB_BomHeader BH WITH(NOLOCK)
    LEFT JOIN STB_MaterialMaster MM WITH(NOLOCK) ON MM.MaterialCode = BH.MaterialCode
    WHERE BH.MaterialCode = @MaterialCode AND BH.BomVersion = @BomVersion

    -- ─────────────────────────────────────────────
    -- 4) BOM 정전개 (CTE 재귀) → 임시 테이블 저장
    -- ─────────────────────────────────────────────
    DECLARE @BomCTE TABLE (
        BomSeq            INT IDENTITY(1,1),  -- 전개 순번 (정렬용)
        ParentBomSeq      INT,                -- 부모 순번 (트리 구성용)
        Levels            INT,                -- 전개 레벨 (0=모품목, 1=직접자식...)
        KeyValue          VARCHAR(500),       -- 행 고유키 (GUID)
        ParentKeyValue    VARCHAR(500),       -- 부모 고유키
        MaterialCode      VARCHAR(50),        -- 부모 품목코드
        BomVersion        VARCHAR(20),        -- 부모 BOM 버전
        BomUnit           VARCHAR(10),        -- 부모 BOM 단위
        ChildMaterialCode VARCHAR(50),        -- 자식 품목코드
        ChildBomVersion   VARCHAR(20),        -- 자식 BOM 버전
        ChildBomUnit      VARCHAR(10),        -- 자식 BOM 단위
        UnitQty           NUMERIC(20,5),      -- 단위 소요량
        UnitTotalQty      NUMERIC(20,5),      -- 누적 단위 소요량
        TotalQty          NUMERIC(20,5),      -- 총 소요량
        IsOptionItem      BIT,                -- 옵션 품목 여부
        RouteCode         VARCHAR(20),        -- 공정 코드
        BomRevision       VARCHAR(20),         -- BOM 리비전 (STB_BomDetail_Revision.ChildRevision)
		FindNum			  VARCHAR(50),		  -- 찾기번호
		RefDes			  VARCHAR(4000)		  -- 찾기 참조지시자
    )

    ;WITH CTE (Levels, KeyValue, ParentKeyValue, MaterialCode, BomVersion, BomUnit,
               ChildMaterialCode, ChildBomVersion, ChildBomUnit, UnitQty, UnitTotalQty, TotalQty, IsOptionItem)
    AS
    (
        -- Anchor: Level 0 (모품목 자체)
        SELECT 0, CONVERT(VARCHAR(50), NEWID()), CONVERT(VARCHAR(50), NULL),
               CONVERT(VARCHAR(50), NULL), CONVERT(VARCHAR(20), NULL), CONVERT(VARCHAR(10), NULL),
               BH.MaterialCode, BH.BomVersion, BH.BomUnit,
               CONVERT(NUMERIC(20,5), 1), CONVERT(NUMERIC(20,5), 1), CONVERT(NUMERIC(20,5), 1),
               CONVERT(BIT, 0)
        FROM STB_BomHeader BH WITH(NOLOCK)
        WHERE BH.MaterialCode = @MaterialCode AND BH.BomVersion = @BomVersion

        UNION ALL

        -- Recursive: 하위 레벨 전개
        SELECT C.Levels + 1, CONVERT(VARCHAR(50), NEWID()), C.KeyValue,
               BD.MaterialCode, BD.BomVersion, BD.HeaderBomUnit,
               BD.ChildMaterialCode, BD.ChildBomVersion, BD.BomUnit,
               CONVERT(NUMERIC(20,5), BD.UsedQty),
               CONVERT(NUMERIC(20,5), BD.UsedQty * C.UnitTotalQty),
               CONVERT(NUMERIC(20,5), BD.UsedQty * C.TotalQty),
               BD.IsOptionItem
        FROM VW_BomDetailWithHeaderBomUnit BD, CTE C
        WHERE BD.MaterialCode = C.ChildMaterialCode AND BD.BomVersion = C.ChildBomVersion
    )
    INSERT INTO @BomCTE
        (Levels, KeyValue, ParentKeyValue, MaterialCode, BomVersion, BomUnit,
         ChildMaterialCode, ChildBomVersion, ChildBomUnit, UnitQty, UnitTotalQty, TotalQty, IsOptionItem)
    SELECT Levels, KeyValue, ParentKeyValue, MaterialCode, BomVersion, BomUnit,
           ChildMaterialCode, ChildBomVersion, ChildBomUnit, UnitQty, UnitTotalQty, TotalQty, IsOptionItem
    FROM CTE

    -- 부모 순번 매핑
    UPDATE @BomCTE SET ParentBomSeq = (SELECT BomSeq FROM @BomCTE B2 WHERE B2.KeyValue = ParentKeyValue)

    -- RouteCode + BomRevision 일괄 채우기
    UPDATE BC SET
        RouteCode   = BD.RouteCode,
        BomRevision = DR.ChildRevision
    FROM @BomCTE BC
    LEFT JOIN STB_BomDetail BD WITH(NOLOCK)
        ON BD.MaterialCode = BC.MaterialCode AND BD.BomVersion = BC.BomVersion
       AND BD.ChildMaterialCode = BC.ChildMaterialCode AND BD.ChildBomVersion = BC.ChildBomVersion
    LEFT JOIN STB_BomDetail_Revision DR WITH(NOLOCK)
        ON DR.MaterialCode = BC.MaterialCode AND DR.BomVersion = BC.BomVersion
       AND DR.ChildMaterialCode = BC.ChildMaterialCode AND DR.ChildBomVersion = BC.ChildBomVersion
       AND GETDATE() BETWEEN DR.ValidFrom AND DR.ValidTo

    -- ─────────────────────────────────────────────────────────────────────
    -- 5) ResultSet #2: BOM 정전개 + 공급업체 (엑셀 양식)
    --    RowType='BOM' → BOM 품목 행 (리비전+FFF)
    --    RowType='AVL' → 해당 품목 공급업체 행 (BOM행 바로 아래)
    --    ★ 공급업체는 (MaterialCode + BOM리비전)으로 JOIN → 뻥튀기 방지
    -- ─────────────────────────────────────────────────────────────────────

    -- ── BOM 행 ──
    SELECT
        'BOM'                       AS RowType,          -- 행 구분 (BOM=품목행, AVL=공급업체행)
        BC.BomSeq,                                       -- 전개 순번 (정렬 기준)
        BC.ParentBomSeq,                                 -- 부모 순번 (트리 구성용)
        BC.Levels,                                       -- 전개 레벨 (0=모품목)
        REPLICATE('.', BC.Levels)
            + CONVERT(VARCHAR, ISNULL(BC.Levels,0))
                                    AS LevelString,      -- 레벨 시각화 문자열 (예: "..2")
        0                           AS SupplierSeq,      -- 공급업체 순번 (BOM행=0)

        -- ── BOM 기본 정보 ──
        BC.MaterialCode             AS ParentMaterialCode,  -- 부모 품목코드
        BC.BomVersion               AS ParentBomVersion,    -- 부모 BOM 버전
        BC.ChildMaterialCode,                               -- 자식(현재) 품목코드
        BC.ChildBomVersion,                                 -- 자식 BOM 버전
        MM.MaterialName,                                    -- 품목명 (STB_MaterialMaster)
        MM.MaterialSpec,                                    -- 품목 규격
        MM.MaterialTypeCode,                                -- 자재 유형 코드
        MT.MaterialTypeName,                                -- 자재 유형명 (STB_MaterialType)
        MM.ProductGroupCode,                                -- 제품 그룹 코드
        PG.ProductGroupName,                                -- 제품 그룹명 (STB_ProductGroup)
        BC.ChildBomUnit             AS BomUnit,             -- BOM 단위 (EA, KG 등)
        MM.MaterialUnit,                                    -- 자재 기본 단위
        BC.UnitQty,                                         -- 단위 소요량 (1개 생산 시)
        BC.UnitTotalQty,                                    -- 누적 단위 소요량 (상위 누적)
        BC.TotalQty,                                        -- 총 소요량
        BC.IsOptionItem,                                    -- 옵션 품목 여부 (0/1)
        BC.RouteCode,                                       -- 공정 코드

        -- ── 리비전 정보 ──
        BC.BomRevision,                                     -- BOM 리비전 (STB_BomDetail_Revision.ChildRevision)
        @CustRevision               AS CustomerRevision,    -- 고객 리비전 (STB_BomRevision_Map)

        -- ── FFF 속성 (STB_MaterialRevision) ──
        MR.Revision                 AS MaterialRevision,    -- 자재 리비전 코드 (예: A, 03)
        MR.SubClass,                                        -- 서브클래스 (FFF 분류)
        MR.LifecyclePhase,                                  -- 수명주기 단계 (Production, Prototype 등)
        MR.BomItemRev,                                      -- BOM 아이템 리비전
        MR.BomItemLifecycle,                                -- BOM 아이템 수명주기
        BC.FindNum,                                         -- Find Number (도면 참조번호)
        MR.ComponentType,                                   -- 부품 유형 (Assembly, Part 등)
        MR.SubstitutionPriority,                            -- 대체 우선순위
        BC.RefDes,                                          -- Reference Designator (회로 기호)
        MR.ProductLine,                                     -- 제품 라인
        MR.ModuleName,                                      -- 모듈명
        MR.SubSystem,                                       -- 서브시스템
        MR.CommodityCode,                                   -- 상품 분류 코드
        MR.PartType,                                        -- 부품 타입
        MR.UlReqd,                                          -- UL 인증 필요 여부
        MR.UlCritical,                                      -- UL 중요 부품 여부
        MR.RohsCompliant,                                   -- RoHS 준수 여부
        MR.MsdsReqd,                                        -- MSDS(물질안전보건자료) 필요 여부
        MR.DrawingNumber,                                   -- 도면 번호
        MR.MaterialSpec             AS RevMaterialSpec,     -- 리비전별 자재 규격
        MR.BomNotes,                                        -- BOM 비고/메모

        -- ── 공급업체 (BOM행에서는 NULL) ──
        CONVERT(VARCHAR(50), NULL)  AS SupplierType,        -- 공급업체 유형
        CONVERT(NVARCHAR(200), NULL) AS MfrName,            -- 제조사명
        CONVERT(VARCHAR(100), NULL) AS MfrPartNumber,       -- 제조사 부품번호
        CONVERT(VARCHAR(50), NULL)  AS MfrPartLifecycle,    -- 제조사 부품 수명주기
        CONVERT(NVARCHAR(200), NULL) AS SupplierName,       -- 공급업체명
        CONVERT(VARCHAR(100), NULL) AS SupplierPartNumber,  -- 공급업체 부품번호
        CONVERT(NVARCHAR(200), NULL) AS SupplierSite,       -- 공급업체 사이트(공장)
        CONVERT(VARCHAR(50), NULL)  AS PreferredStatus,     -- 선호 상태 (Preferred, Approved 등)
        CONVERT(VARCHAR(10), NULL)  AS AslEnabled,          -- ASL(Approved Supplier List) 등록 여부
        CONVERT(NVARCHAR(MAX), NULL) AS SupplierComments,   -- 공급업체 비고

        -- ── 품목 부가 정보 ──
        MM.MaterialSource,                                  -- 자재 원산지/출처
        ISNULL(MM.IsDelegate, CONVERT(BIT,0)) AS IsDelegate, -- 대표 품목 여부
        MM.IsInternalProd,                                  -- 사내 생산 여부
        MM.IsPurchase                                       -- 구매 품목 여부

    FROM @BomCTE BC
    LEFT JOIN STB_MaterialMaster MM WITH(NOLOCK) ON MM.MaterialCode = BC.ChildMaterialCode
    LEFT JOIN STB_MaterialType MT WITH(NOLOCK) ON MT.MaterialTypeCode = MM.MaterialTypeCode
    LEFT JOIN STB_ProductGroup PG WITH(NOLOCK) ON PG.ProductGroupCode = MM.ProductGroupCode
    -- 자재 리비전: BOM리비전 매치 우선, 없으면 최신 리비전
    OUTER APPLY (
        SELECT TOP 1 R.*
        FROM STB_MaterialRevision R WITH(NOLOCK)
        WHERE R.MaterialCode = BC.ChildMaterialCode
        ORDER BY CASE WHEN R.Revision = BC.BomRevision THEN 0 ELSE 1 END, R.Revision DESC
    ) MR

    UNION ALL

    -- ── AVL(공급업체) 행 ──
    -- ★ 핵심: MV.Revision = BC.BomRevision 으로 필터 → 리비전 매칭된 공급업체만 조회
    SELECT
        'AVL'                       AS RowType,             -- 공급업체 행 표시
        BC.BomSeq,                                          -- BOM 순번 (소속 BOM행 참조)
        BC.ParentBomSeq,                                    -- 부모 순번
        BC.Levels,                                          -- 레벨 (소속 BOM행과 동일)
        REPLICATE('.', BC.Levels)
            + CONVERT(VARCHAR, ISNULL(BC.Levels,0))
                                    AS LevelString,         -- 레벨 문자열
        MV.SupplierSeq,                                     -- 공급업체 순번 (1,2,3...)

        -- ── BOM 참조 (소속 품목 식별용) ──
        BC.MaterialCode             AS ParentMaterialCode,  -- 부모 품목코드
        BC.BomVersion               AS ParentBomVersion,    -- 부모 BOM 버전
        BC.ChildMaterialCode,                               -- 해당 품목코드
        BC.ChildBomVersion,                                 -- 해당 BOM 버전
        CONVERT(NVARCHAR(200), NULL) AS MaterialName,       -- (AVL행: NULL)
        CONVERT(NVARCHAR(200), NULL) AS MaterialSpec,       -- (AVL행: NULL)
        CONVERT(VARCHAR(50), NULL)   AS MaterialTypeCode,   -- (AVL행: NULL)
        CONVERT(NVARCHAR(200), NULL) AS MaterialTypeName,   -- (AVL행: NULL)
        CONVERT(VARCHAR(50), NULL)   AS ProductGroupCode,   -- (AVL행: NULL)
        CONVERT(NVARCHAR(200), NULL) AS ProductGroupName,   -- (AVL행: NULL)
        CONVERT(VARCHAR(10), NULL)   AS BomUnit,            -- (AVL행: NULL)
        CONVERT(VARCHAR(10), NULL)   AS MaterialUnit,       -- (AVL행: NULL)
        CONVERT(NUMERIC(20,5), NULL) AS UnitQty,            -- (AVL행: NULL)
        CONVERT(NUMERIC(20,5), NULL) AS UnitTotalQty,       -- (AVL행: NULL)
        CONVERT(NUMERIC(20,5), NULL) AS TotalQty,           -- (AVL행: NULL)
        CONVERT(BIT, NULL)           AS IsOptionItem,       -- (AVL행: NULL)
        CONVERT(VARCHAR(20), NULL)   AS RouteCode,          -- (AVL행: NULL)

        -- ── 리비전 ──
        MV.Revision                 AS BomRevision,         -- 공급업체가 연결된 리비전
        @CustRevision               AS CustomerRevision,    -- 고객 리비전

        -- ── FFF (AVL행에서는 NULL) ──
        CONVERT(VARCHAR(20), NULL)  AS MaterialRevision,    -- (AVL행: NULL)
        CONVERT(VARCHAR(200), NULL) AS SubClass,            -- (AVL행: NULL)
        CONVERT(VARCHAR(50), NULL)  AS LifecyclePhase,      -- (AVL행: NULL)
        CONVERT(VARCHAR(100), NULL) AS BomItemRev,          -- (AVL행: NULL)
        CONVERT(VARCHAR(50), NULL)  AS BomItemLifecycle,    -- (AVL행: NULL)
        CONVERT(VARCHAR(50), NULL)  AS FindNum,             -- (AVL행: NULL)
        CONVERT(VARCHAR(50), NULL)  AS ComponentType,       -- (AVL행: NULL)
        CONVERT(VARCHAR(10), NULL)  AS SubstitutionPriority,-- (AVL행: NULL)
        CONVERT(VARCHAR(4000), NULL) AS RefDes,             -- (AVL행: NULL)
        CONVERT(VARCHAR(100), NULL) AS ProductLine,         -- (AVL행: NULL)
        CONVERT(VARCHAR(100), NULL) AS ModuleName,          -- (AVL행: NULL)
        CONVERT(VARCHAR(100), NULL) AS SubSystem,           -- (AVL행: NULL)
        CONVERT(VARCHAR(100), NULL) AS CommodityCode,       -- (AVL행: NULL)
        CONVERT(VARCHAR(50), NULL)  AS PartType,            -- (AVL행: NULL)
        CONVERT(VARCHAR(10), NULL)  AS UlReqd,              -- (AVL행: NULL)
        CONVERT(VARCHAR(10), NULL)  AS UlCritical,          -- (AVL행: NULL)
        CONVERT(VARCHAR(10), NULL)  AS RohsCompliant,       -- (AVL행: NULL)
        CONVERT(VARCHAR(10), NULL)  AS MsdsReqd,            -- (AVL행: NULL)
        CONVERT(VARCHAR(100), NULL) AS DrawingNumber,       -- (AVL행: NULL)
        CONVERT(VARCHAR(100), NULL) AS RevMaterialSpec,     -- (AVL행: NULL)
        CONVERT(NVARCHAR(2000), NULL) AS BomNotes,          -- (AVL행: NULL)

        -- ── 공급업체 정보 (STB_MaterialVendor) ──
        MV.SupplierType,                                    -- 공급업체 유형 (Manufacturer, Distributor 등)
        MV.MfrName,                                         -- 제조사명
        MV.MfrPartNumber,                                   -- 제조사 부품번호 (Mfr P/N)
        MV.MfrPartLifecycle,                                -- 제조사 부품 수명주기
        MV.SupplierName,                                    -- 공급업체명
        MV.SupplierPartNumber,                              -- 공급업체 부품번호
        MV.SupplierSite,                                    -- 공급업체 사이트(공장 위치)
        MV.PreferredStatus,                                 -- 선호 상태 (Preferred, Approved 등)
        MV.AslEnabled,                                      -- ASL 등록 여부 (Y/N)
        MV.SupplierComments,                                -- 공급업체 비고/특이사항

        -- ── 부가 정보 (AVL행: NULL) ──
        CONVERT(NVARCHAR(200), NULL) AS MaterialSource,     -- (AVL행: NULL)
        CONVERT(BIT, NULL)           AS IsDelegate,         -- (AVL행: NULL)
        CONVERT(BIT, NULL)           AS IsInternalProd,     -- (AVL행: NULL)
        CONVERT(BIT, NULL)           AS IsPurchase          -- (AVL행: NULL)

    FROM @BomCTE BC
    INNER JOIN STB_MaterialVendor MV WITH(NOLOCK)
        ON MV.MaterialCode = BC.ChildMaterialCode
       AND MV.Revision = ISNULL(BC.BomRevision, 'A')       -- ★ 리비전 매칭 (뻥튀기 방지 핵심)
       AND MV.IsActive = 1                                  -- 활성 공급업체만

    ORDER BY BomSeq, RowType, SupplierSeq                   -- BOM행 → AVL행 순서

END
