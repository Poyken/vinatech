-- Procedure: STB_MaterialQcInfo_audit_iud
CREATE PROCEDURE [dbo].[STB_MaterialQcInfo_audit_iud]
    @등록일자 DATE,
    @품목코드 NVARCHAR(50),
    @품목명 NVARCHAR(100),
    @PartNo NVARCHAR(50),
    @사이즈 NVARCHAR(50),
    @제품검사번호 NVARCHAR(50),
    @Lot번호_변경후 NVARCHAR(50),
    @품목코드_변경후 NVARCHAR(50),
    @KoreaLabel NVARCHAR(50),
    @판정결과 NVARCHAR(50),
    @비고정보 NVARCHAR(MAX),
    @검사자코드 NVARCHAR(50),
    @검사자명 NVARCHAR(100),
    @검사항목명 NVARCHAR(100),
    @시료번호 NVARCHAR(50),
    @측정값 NVARCHAR(50),
    @라인코드 NVARCHAR(50),
    @라인명 NVARCHAR(100),
    @CLASSIFY NVARCHAR(50),
    @LotID_list NVARCHAR(MAX),
    @Holding_Hist NVARCHAR(MAX),
	@LSL DECIMAL(10, 2),
	@USL DECIMAL(10, 2)

AS
BEGIN
    SET NOCOUNT ON;
	  --update STB_MaterialQcInfo_audit set LSL = @LSL,USL =@USL  where  Lot번호_변경후 =@Lot번호_변경후
    INSERT INTO STB_MaterialQcInfo_audit (
        등록일자,
        품목코드,
        품목명,
        PartNo,
        사이즈,
        제품검사번호,
        Lot번호_변경후,
        품목코드_변경후,
        KoreaLabel,
        판정결과,
        비고정보,
        검사자코드,
        검사자명,
        검사항목명,
        시료번호,
        측정값,
        라인코드,
        라인명,
        CLASSIFY,
        LotID_list,
        Holding_Hist,
		LSL ,
		USL
    ) VALUES (
        @등록일자,
        @품목코드,
        @품목명,
        @PartNo,
        @사이즈,
        @제품검사번호,
        @Lot번호_변경후,
        @품목코드_변경후,
        @KoreaLabel,
        @판정결과,
        @비고정보,
        @검사자코드,
        @검사자명,
        @검사항목명,
        @시료번호,
        @측정값,
        @라인코드,
        @라인명,
        @CLASSIFY,
        @LotID_list,
        @Holding_Hist,
		@LSL ,
		@USL
    );

    --SELECT SCOPE_IDENTITY() AS InsertedId; -- (Optional) Return the ID of the inserted row

END
GO

