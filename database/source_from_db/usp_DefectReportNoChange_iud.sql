-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2020-09-14
-- Browsable : true
-- Group : 품질관리 > 수입검사 > 시료별수입검사 > 검사LotNo 변경 Button
-- Description:	
-- Modified: 
-- Select IQCSampleLotList, DescText, * from STB_MaterialQcInfo where MaterialQcNo = '20090900001'


-- =============================================
Create PROCEDURE [dbo].[usp_DefectReportNoChange_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialQcNo VARCHAR(20),
	@pDefectReportNo NVARCHAR(MAX) = NULL
AS
BEGIN
	Declare @MaterialQcNo VARCHAR(20) = @pMaterialQcNo
	       ,   @DefectReportNo NVARCHAR(MAX) = ISNULL(@pDefectReportNo, '')

 
-- Select DefectReportNo, * from STB_IQcDefectReport                 -- 부적합번호 : DefectReportNo
--where 1=1
--  and DefectReportNo in ('VNI201105-01','1111')


	UPDATE STB_IQcDefectReport
	      SET DefectReportNo = @DefectReportNo
	 WHERE LotNo = @MaterialQcNo

END