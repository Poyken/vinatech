CREATE PROC usp_DoSyncDefectReportData
	@pDefectReportNo VARCHAR(20)
AS
BEGIN
	Declare @DefectReportNo VARCHAR(20) = @pDefectReportNo

	DELETE FROM ERPSVR.VINATech.dbo.VECS_QC_RPT WHERE NCNFRMITY_NO = @DefectReportNo

	INSERT INTO ERPSVR.VINATech.dbo.VECS_QC_RPT
	(
		  NCNFRMITY_NO, NCNFRMITY_DIV_CD, PUB_DEPT, PUB_EMPID, RCV_DEPT
		, OCR_PRCS_CD, EQPMNT_CD, WORK_EMPID, WORK_DATE, LOTNO
		, PROD_NM, MODEL_NM, LOTNO2, LOTNO3
		, LOTNO4, LOTNO5, NCNFRMITY_CD, NCNFRMITY_LOT_SIZE
		, NCNFRMITY_ERROR_CNT, NCNFRMITY_SAMPLE_CNT, LOT_LIMIT_CNT, ACTNR_ACTN_CTNT, ACTNR_EMPID
		, QC_OPN_CTNT, CSTMR_SND_YN
		, PRDCT_CS_ANLS_CTNT, PRDCT_CNTR_MSRS_CTNT
		, PRCS_DEPT_PRCS_CTNT, QC_PRCS_INSTRCT_CD, PRCS_DEPT_LOSS_COST, PRCS_CTNT_MOD_USER_NM, PRCS_CTNT_CHECK_USER_NM
		, QC_MSRS_CMNT, QC_FLWUP_CHK_CTNT, QC_AS_CD
		, PRCS_HEAD_CONFIRM, PRCS_HEAD_CONFIRM_CTNT
		, REG_DATE, UDT_DATE
	)
	SELECT DefectReportNo ,DefectDivisionCode ,PublishDeptCode,PublishEmpID ,ReceiveDeptCode
	 ,OccurProcessCode ,MachineCode ,ProdWorkerCode ,CONVERT(CHAR(10), ISNULL(JobDate, CreateDateTime), 121) ,LotNo
	 ,ISNULL(MaterialName, '') ,ISNULL(MaterialSpec, '') ,LotNo2 ,LotNo3
	 ,LotNo4 ,LotNo5 ,DefectCode ,DefectLotSize
	 ,DefectErrorCnt ,DefectSampleCnt ,LotLimitCnt ,ActionContent ,ActionWorkerCode
	 ,QcOpinionContent 
	 ,CASE WHEN IsCustomerSendRequired = CONVERT(BIT, 1) THEN 'Y' ELSE 'N' END
	 ,ProdCauseContent ,ProdMeasuresContent
	 ,ProdProcessContent ,ProdProcessResultCode ,LossCost ,ProdProcessContentAuthorUserName ,ProdProcessContentCheckUserName
	 ,QcMeasuresContent ,QcFlwupCheckContent 
	 ,CASE WHEN IsQcAsSatisfaction = CONVERT(BIT, 1) THEN '01' ELSE '02' END
	 ,IsProdHeadConfirm ,ProdHeadComment
	 ,dbo.fnConvertDateTimeToVarchar('yyyymmddhhmiss', CreateDateTime)
	 ,dbo.fnConvertDateTimeToVarchar('yyyymmddhhmiss', ISNULL(ChangeDateTime, CreateDateTime))
	  FROM STB_QcDefectReport
	 WHERE DefectReportNo = @DefectReportNo
END