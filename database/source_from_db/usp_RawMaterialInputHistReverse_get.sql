-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2026-04-23
-- Browsable : true
-- Group : 공통관리
-- Description:	원자재투입이력 역추적
---- =============================================
CREATE PROC usp_RawMaterialInputHistReverse_get
    @pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pRawMaterialBarcode VARCHAR(50)
AS
BEGIN
    Declare @RawMaterialBarcode NVARCHAR(50) = @pRawMaterialBarcode

    ;WITH LotTrace_CTE AS (
        -- 1. 앵커 멤버: 최하위 자재가 처음으로 투입된 이력을 찾음
        SELECT 
            Barcode, 
            RawMaterialBarcode, 
            1 AS Level,
            -- 경로 추적을 위해 문자열 형태로 변환 (데이터 형식 불일치 방지)
            CAST(RawMaterialBarcode + ' -> ' + Barcode AS VARCHAR(MAX)) AS TracePath
        FROM STB_RawMaterialInputHist
        WHERE RawMaterialBarcode = @RawMaterialBarcode

        UNION ALL

        -- 2. 재귀 멤버: 이전 단계의 결과물(LotNo)을 자재(MaterialLotNo)로 사용하는 상위 단계를 찾음
        SELECT 
            H.Barcode,
            H.RawMaterialBarcode, 
            CTE.Level + 1 AS Level,
            CAST(CTE.TracePath + ' -> ' + H.Barcode AS VARCHAR(MAX)) AS TracePath
        FROM STB_RawMaterialInputHist H
        INNER JOIN LotTrace_CTE CTE ON H.RawMaterialBarcode = CTE.Barcode
    )
    SELECT 
        Level, 
        RawMaterialBarcode AS [Input_Lot], 
        Barcode AS [Output_Lot], 
        TracePath
    FROM LotTrace_CTE
    ORDER BY Level ASC;
END