create PROC [dbo].[usp_NotCounterMeasure_qcaudit]
AS
BEGIN
	            select 
            DefectReportNo,DefectDivisionCode,PublishDeptCode,PublishEmpID,ReceiveDeptCode,OccurProcessCode,MachineCode,
            ProdWorkerCode,JobDate,LotNo,MaterialCode,MaterialName,MaterialSpec,DefectCode,DefectLotSize,DefectErrorCnt,
            DefectSampleCnt,LotLimitCnt,ActionContent,ActionWorkerCode,QcOpinionContent,IsCustomerSendRequired,ProdCauseContent,
            ProdCauseImage,ProdMeasuresContent,ProdProcessContent,ProdProcessResultCode,IsProdHeadConfirm,ProdHeadComment,
            IsQcHeadConfirm,QcHeadComment,CreateDateTime,CreateUserID,ChangeDateTime,ChangeUserID,ProdMeasuresContent
            from STB_QcDefectReport 
            where CreateDateTime between '2021-05-05' and getdate()-2 
            and (lotno like 'VV%' or lotno like 'MV%' or (LotNo like 'VJ%' and MaterialCode='ECVT27-369') ) 
            and MachineCode like 'VV%' 
            and ProdMeasuresContent is  null
            order by JobDate
END