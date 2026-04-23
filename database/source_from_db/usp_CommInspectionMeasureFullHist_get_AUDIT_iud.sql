CREATE PROCEDURE usp_CommInspectionMeasureFullHist_get_AUDIT_iud
(
    @사업장 VARCHAR(255),
    @LotNo VARCHAR(50),
    @품목코드 VARCHAR(50),
    @품목명 VARCHAR(255),
    @사이즈 VARCHAR(50),
    @라인코드 VARCHAR(50),
    @라인명 VARCHAR(255),
    @점검항목명 VARCHAR(255),
    @측정순번 INT,
    @LSL FLOAT,
    @USL FLOAT,
    @측정결과 FLOAT,
    @측정일시 DATETIME
)
AS
BEGIN
    INSERT INTO STB_CommInspMeasureHist_audit (사업장, LotNo, 품목코드, 품목명, 사이즈, 라인코드, 라인명, 점검항목명, 측정순번, LSL, USL, 측정결과, 측정일시)
    VALUES (@사업장, @LotNo, @품목코드, @품목명, @사이즈, @라인코드, @라인명, @점검항목명, @측정순번, @LSL, @USL, @측정결과, @측정일시);
END;