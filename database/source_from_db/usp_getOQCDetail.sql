
CREATE PROCEDURE [dbo].[usp_getOQCDetail] --exec usp_getOQCDetail 'VVT','','2022-06-01','2022-06-30'
	@pCompanyCode varchar(20) = NULL,
	@pBarcode varchar(20) = NULL,
	@pFromDate date = NULL,
	@pToDate date = NULL

AS
BEGIN

;with table1 as
(
select distinct MQI.CompanyCode,SI.ControlNo,SI.InputLineCode, MQI.QcQty,SI.ProdQty,li.LineName,SI.InputJobDate,MQI.BasicDate, MQI.materialqcno, MQI.MaterialCode,MM.MaterialName, InspectionDocType, MIIExtText01 ,PWI.WorkerName,DTL.description,
case when DTL.QcInspectionItemCode = 'IQC_GPD_18' then 'SD'
	when DTL.QcInspectionItemCode = 'IQC_GPD_19' then 'ESR'
	when DTL.QcInspectionItemCode = 'IQC_GPD_20' then N'Điện dung'
    else N'Ngoại quan' end  as HangMucKiemTra,
case when DTL.QcInspectionItemCode = 'IQC_GPD_18' then sum(sampleQty)  else 0 end  SLSD ,
case when DTL.QcInspectionItemCode = 'IQC_GPD_19' then sum(sampleQty)  else 0 end  SLESR ,
case when DTL.QcInspectionItemCode = 'IQC_GPD_20' then sum(sampleQty)  else 0 end  SLCap ,
case when DTL.QcInspectionItemCode not in ('IQC_GPD_20','IQC_GPD_19','IQC_GPD_18')  then sum(sampleQty) else 0 end SLNgoaiQuan,
case when DTL.QcInspectionItemCode = 'IQC_GPD_18' then sum(DTL.PassedSampleQty)  else 0 end  SLSDPass ,
case when DTL.QcInspectionItemCode = 'IQC_GPD_19' then sum(DTL.PassedSampleQty)  else 0 end SLESRPass ,
case when DTL.QcInspectionItemCode = 'IQC_GPD_20' then sum(DTL.PassedSampleQty)  else 0 end  SLCapPass ,
case when DTL.QcInspectionItemCode not in ('IQC_GPD_20','IQC_GPD_19','IQC_GPD_18') then sum(DTL.PassedSampleQty) else 0 end slngoaiquanpass,
case when DTL.QcInspectionItemCode = 'IQC_GPD_18' then sum(DTL.DefectSampleQty)  else 0 end  SLSDDefect ,
case when DTL.QcInspectionItemCode = 'IQC_GPD_19' then sum(DTL.DefectSampleQty)  else 0 end  SLESRDefect ,
case when DTL.QcInspectionItemCode = 'IQC_GPD_20' then sum(DTL.DefectSampleQty)  else 0 end  SLCapDefect ,
case when DTL.QcInspectionItemCode not in ('IQC_GPD_20','IQC_GPD_19','IQC_GPD_18') then sum(DTL.DefectSampleQty) else 0 end SLNgoaiQuanDefect
from STB_MaterialQcInfo MQI
LEFT OUTER JOIN STB_ProdWorkerInfo PWI   ON PWI.WorkerCode = MQI.MIIExtText01  
left outer join STB_MaterialQcDetail DTL ON MQI.MaterialQcNo = DTL.MaterialQcNo
LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON MQI.MaterialCode = MM.MaterialCode
LEFT OUTER JOIN STB_SetInfo SI ON MQI.MaterialQcNo = SI.Barcode --OR SI.Barcode = (SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = 'VVMO083R060612')
LEFT OUTER JOIN STB_LineInfo LI ON li.LineCode = SI.InputLineCode
where MQI.InspectionDocType = 'OQC' and (dtl.MaterialQcNo=@pBarcode or @pBarcode ='' or @pBarcode is null)
and (MQI.BasicDate between @pFromDate and @pToDate)
and (MQI.CompanyCode = @pCompanyCode or @pCompanyCode ='' or @pCompanyCode is null)

group by  MQI.CompanyCode, MQI.materialqcno, MQI.MaterialCode,MM.MaterialName,qcqty,prodqty, InspectionDocType, MIIExtText01 ,PWI.WorkerName,QcInspectionItemCode,ControlNo,InputLineCode,InputJobDate,BasicDate,LineName,description)


select distinct CompanyCode,ControlNo,materialqcno,MaterialCode,MaterialName,QcQty,ProdQty, InputLineCode,LineName,InputJobDate,basicdate,  InspectionDocType, MIIExtText01 ,WorkerName,HangMucKiemTra,max(description) as description,
case when HangMucKiemTra ='SD' then sum(SLSD) 
	 when HangMucKiemTra ='ESR' then sum(SLESR)
	 when HangMucKiemTra=N'Điện dung' then sum(SLCap)
	 else sum(SLNgoaiQuan) end SLKT,
case when HangMucKiemTra ='SD' then sum(SLSDPass) 
	 when HangMucKiemTra ='ESR' then sum(SLESRPass)
	 when HangMucKiemTra=N'Điện dung' then sum(SLCapPass)
	 else sum(slngoaiquanpass) end SLOK,
case when HangMucKiemTra ='SD' then sum(SLSDDefect) 
	 when HangMucKiemTra ='ESR' then sum(SLESRDefect)
	 when HangMucKiemTra=N'Điện dung' then sum(SLCapDefect)
	 else sum(SLNgoaiQuanDefect) end SLNG,
case when HangMucKiemTra ='SD' then (case when sum(SLSDDefect)=0 then 0 else    (cast(sum(SLSDDefect) as float) / cast( sum(SLSDPass) as float)) * 100 end)
	when HangMucKiemTra ='ESR' then (case when sum(SLESRDefect)=0 then 0 else  ( cast(sum(SLESRDefect) as float)/ cast(sum(SLESRPass) as float)) *100 end)
	when HangMucKiemTra =N'Điện dung' then (case when sum(SLCapDefect)=0 then 0 else  ( cast(sum(SLCapDefect) as float)/ cast(sum(SLCapPass) as float))*100 end)
else (case when sum(SLNgoaiQuanDefect) =0 then 0 else ( cast(sum(SLNgoaiQuanDefect) as float) / cast(sum(slngoaiquanpass) as float))*100 end) end as NGRate
from table1
group by CompanyCode, materialqcno, MaterialCode,MaterialName, qcqty, prodqty, InspectionDocType, MIIExtText01 ,WorkerName,HangMucKiemTra,ControlNo,InputLineCode,InputJobDate,BasicDate,LineName

END


select * from STB_SetInfo SI

  where (SI.Barcode = 'VVMO083R060612' OR SI.Barcode = (SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = 'VVMO083R060612'))     