-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 2020.06.30
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrolyteMoistureMeasureHist_get_AUDIT_iud]
    @측정일자 DATE,
    @주야구분코드 NVARCHAR(50),
    @주야구분명 NVARCHAR(255),
    @검사자코드 NVARCHAR(50),
    @검사자명 NVARCHAR(255),
    @사업장코드 NVARCHAR(50),
    @사업장명 NVARCHAR(255),
    @작업장코드 NVARCHAR(50),
    @작업장명 NVARCHAR(255),
    @라인코드 NVARCHAR(50),
    @라인명 NVARCHAR(255),
    @설비코드 NVARCHAR(50),
    @설비명 NVARCHAR(255),
    @유의사항 NVARCHAR(MAX),
    @제품사이즈 NVARCHAR(255),
    @품목코드 NVARCHAR(50),
    @품목명 NVARCHAR(255),
    @온도 DECIMAL(18, 2),
    @노점온도 DECIMAL(18, 2),
    @시료무게 DECIMAL(18, 2),
    @전해액수분측정값 DECIMAL(18, 2),
    @원자재 NVARCHAR(255),
    @합격여부 NVARCHAR(10),
    @비고 NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO STB_MoistureMeasureHist_audit (
        측정일자, 주야구분코드, 주야구분명, 검사자코드, 검사자명,
        사업장코드, 사업장명, 작업장코드, 작업장명,
        라인코드, 라인명, 설비코드, 설비명,
        유의사항, 제품사이즈, 품목코드, 품목명,
        온도, 노점온도, 시료무게, 전해액수분측정값,
        원자재, 합격여부, 비고
    )
    VALUES (
        @측정일자, @주야구분코드, @주야구분명, @검사자코드, @검사자명,
        @사업장코드, @사업장명, @작업장코드, @작업장명,
        @라인코드, @라인명, @설비코드, @설비명,
        @유의사항, @제품사이즈, @품목코드, @품목명,
        @온도, @노점온도, @시료무게, @전해액수분측정값,
        @원자재, @합격여부, @비고
    );

    --SELECT SCOPE_IDENTITY() AS InsertedId; -- Trả về ID của bản ghi vừa được chèn

END