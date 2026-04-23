CREATE PROCEDURE [dbo].[usp_GetElectrodeCommInspectionHistory_AUDIT_iud]
    @사업장 NVARCHAR(255)=null,
    @품목코드 NVARCHAR(50)=null,
    @품목명 NVARCHAR(255)=null,
    @자재유형코드 NVARCHAR(50)=null,
    @자재그룹코드 NVARCHAR(50)=null,
    @LotNo NVARCHAR(50)=null,
    @점도측정값 DECIMAL(18, 2)=null,
    @압연밀도하한 DECIMAL(18, 2)=null,
    @압연밀도상한 DECIMAL(18, 2)=null,
    @전극두께_좌 DECIMAL(18, 2)=null,
    @전극두께_중 DECIMAL(18, 2)=null,
    @전극두께_우 DECIMAL(18, 2)=null,
    @밀도_좌 DECIMAL(18, 2)=null,
    @밀도_중 DECIMAL(18, 2)=null,
    @밀도_우 DECIMAL(18, 2)=null,
    @무게_좌 DECIMAL(18, 2)=null,
    @무게_중 DECIMAL(18, 2)=null,
    @무게_우 DECIMAL(18, 2)=null,
    @작업일자 DATE=null,
    @작업자명 NVARCHAR(100)=null,
    @비고내용 NVARCHAR(MAX)=null
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO STB_CommInspDocHistoryAudit (
        사업장, 품목코드, 품목명, 자재유형코드, 자재그룹코드, LotNo,
        점도측정값, 압연밀도하한, 압연밀도상한,
        전극두께_좌, 전극두께_중, 전극두께_우,
        밀도_좌, 밀도_중, 밀도_우,
        무게_좌, 무게_중, 무게_우,
        작업일자, 작업자명, 비고내용
    )
    VALUES (
        @사업장, @품목코드, @품목명, @자재유형코드, @자재그룹코드, @LotNo,
        @점도측정값, @압연밀도하한, @압연밀도상한,
        @전극두께_좌, @전극두께_중, @전극두께_우,
        @밀도_좌, @밀도_중, @밀도_우,
        @무게_좌, @무게_중, @무게_우,
        @작업일자, @작업자명, @비고내용
    );

    --SELECT SCOPE_IDENTITY() AS InsertedId; -- Trả về ID của bản ghi vừa được chèn

END