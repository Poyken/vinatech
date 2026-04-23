-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-08-28
-- Browsable : true
-- Group : 품질관리 > E-Mail발송
-- Description: 부적합보고서 등록 시 호출되어 이메일을 발송한다.
-- Modified: 
-- 2020.10.15 베트남어 추가 (황명구님 요청)
-- 2020.10.20 베트남 작업자명 누락원인 해결 (엄제식님 요청)
-- 2020.10.21 작업자 및 발행자 추가 (이미정님 요청)
-- 2020.11.11 전극공정검사 공정검사로 (최은화님 요청)
-- 2021.06.17 생산일자, 제품검사일자, 출하검사일자 추가 (양규철님 요청)
-- 2021.08.02 Mr.tung add email list for Vietnam PQC inspection (DefectDivisionCode='09'  and PublishDeptCode='9100')

-- 2023.06.14 Mr.tung modified     substring(@DefectDivisionName,1,4) 

 -- 프로시저 실행 :  usp_DoSendEmailForDefectReport '','','VN200924-02'
-- ===========================================================
CREATE PROCEDURE [dbo].[usp_DoSendEmailForDefectReport]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pDefectReportNo VARCHAR(20)
AS

BEGIN
	Declare @DefectReportNo VARCHAR(20) = @pDefectReportNo
	       ,@SQLIMG VARCHAR(MAX)
           ,@IMG_PATH VARBINARY(MAX)
           ,@TIMESTAMP VARCHAR(MAX)
           ,@ObjectToken INT
		   ,@DefectDivisionName NVARCHAR(50)
		   ,@PublishDeptName NVARCHAR(50)
		   ,@ReceiveDeptName NVARCHAR(50)
		   ,@OccurProcessName NVARCHAR(50)
		   ,@MachineName NVARCHAR(50)
		   ,@DefectName NVARCHAR(50)
		   ,@EmailBody NVARCHAR(MAX)
		   ,@QcOpinionContent NVARCHAR(MAX)         --2020.08.07 추가
		   ,@WorkCenterCode varchar(20)
 		   -- 작업자, 작업일자, 모델(x), 제품명, LotNo, Lot크기, 시료수, 불량수, 불량률, Lot조치사항
		   ,@WorkerName NVARCHAR(100)
		   ,@PublishName NVARCHAR(100)  --2020.10.21추가
		   ,@JobDate DATE
		   ,@MaterialName VARCHAR(100)
		   ,@LotNo VARCHAR(20)
		   ,@DefectLotSize INT
		   ,@DefectSampleCnt INT
		   ,@DefectErrorCnt INT
		   ,@DefectRate NUMERIC(10, 3)
		   ,@DefectRateHN INT			-- Mr.Manh add on 2025-07-10  follow Ms.Trang QC Enesol
		   --,@DefectRate float               -- add by Mr.Tung on 2023-06-05 as QC Leader
		   ,@ActionContent NVARCHAR(MAX)
		   ,@MailSubject NVARCHAR(500)
		   -- 생산부문, 베트남부문
		  ,@ToAddress VARCHAR(MAX) = 'v.vietnamcorp@vina.co.kr;vn.productionsupport@vina.co.kr;vn.production1@vina.co.kr;vn.production2@vina.co.kr;vn.production@vina.co.kr;vvea01@vina.co.kr;vn.bacgiangcampus@vina.co.kr;vn.techproduction@vina.co.kr;lucas@vina.co.kr;group5@vina.co.kr;vvea04@vina.co.kr;vvea02@vina.co.kr;isjeong@vina.co.kr;vvmd01@vina.co.kr;vvmd02@vina.co.kr;vvqcbg2@vina.co.kr;vvbg2pro03@vina.co.kr;vvbg2pm01@vina.co.kr;vvbg2pro01@vina.co.kr;vvbg2pro02@vina.co.kr;vvpur06@vina.co.kr;v.electrode_prod@vina.co.kr;' -- 이수형 프로의 이메일을 베트남부문에서 본사로 변경 -- 전극생산부문 추가(이미정 프로 요청, 2026.03.13)
		  --,@ToAddress VARCHAR(MAX) = 'v.manufacturing@vina.co.kr;v.celltechnical@vina.co.kr;v.vietnamcorp@vina.co.kr;vn.productionsupport@vina.co.kr;vn.production1@vina.co.kr;vn.production2@vina.co.kr;vn.production@vina.co.kr;vvea01@vina.co.kr;vn.bacgiangcampus@vina.co.kr;vn.techproduction@vina.co.kr;lucas@vina.co.kr;group5@vina.co.kr' -- 이수형 프로의 이메일을 베트남부문에서 본사로 변경
		  ,@ToAddress_HN VARCHAR(MAX) = 'shlee@vina.co.kr;wschoi@vina.co.kr;v.hanam@vina.co.kr;'
		  --,@ToAddress_HN VARCHAR(MAX) ='vvea04@vina.co.kr'
		   -- 품질부문
		   --,@CcAddress VARCHAR(MAX) = 'vn.qc@vina.co.kr;'
		   ,@CcAddress VARCHAR(MAX) = 'v.qc@vina.co.kr;v.marketing@vina.co.kr;vn.qc@vina.co.kr;yjyu@vina.co.kr;vn.techproduction@vina.co.kr;yschoi@vina.co.kr;' -- Rollback 2024.09.05 By Jackaroe / If you need to change it, please contact me. (yjyu@vina.co.kr)  -- 2025-10-01 Mr.Manh add vn.techproduction@vina.co.kr following Mr.Viet's request -- 2026.04.06 최윤석부문장님 추가 (yschoi@vina.co.kr)
		   ,@CcAddress_HN VARCHAR(MAX) = 'vn.qc@vina.co.kr;veqc02@vina.co.kr;veqc03@vina.co.kr;vvea02@vina.co.kr;' -- Rollback 2024.09.05 By Jackaroe / If you need to change it, please contact me. (yjyu@vina.co.kr)
		  -- ,@CcAddress_HN VARCHAR(MAX) = 'vvea04@vina.co.kr'
		   ,@MaterialSpec NVARCHAR(50)

		   , @BasicDate DATE   -- 2021.06.17 추가 (양규철님)
		   , @OQCDate DATE   -- 2021.06.17 추가 (양규철님)
		   , @FOQCDate DATE   -- 2021.06.17 추가 (양규철님)

		   ,@QcDefectClassCode VARCHAR(10)

	select @WorkCenterCode= WorkCenterCode from STB_UserInfo where UserID=@pProcessUserID -- lấy ra nhà máy để check gửi mail
	/*if(@pProcessUserID='anhduy157')
	begin
		set @WorkCenterCode='VVT_F3'
	end*/
    SELECT @IMG_PATH = DefectImage FROM STB_QcDefectReport WHERE DefectReportNo = @DefectReportNo



	IF @IMG_PATH IS NOT NULL BEGIN 
		SET @TIMESTAMP = 'C:\MES\WebSite\images\qcRpt\' + replace(replace(replace(replace(convert(varchar,getdate(),121),'-',''),':',''),'.',''),' ','') + '.jpg'

		EXEC sp_OACreate 'ADODB.Stream', @ObjectToken OUTPUT
		EXEC sp_OASetProperty @ObjectToken, 'Type', 1
		EXEC sp_OAMethod @ObjectToken, 'Open'
		EXEC sp_OAMethod @ObjectToken, 'Write', NULL, @IMG_PATH
		EXEC sp_OAMethod @ObjectToken, 'SaveToFile', NULL, @TIMESTAMP, 2
		EXEC sp_OAMethod @ObjectToken, 'Close'
		EXEC sp_OADestroy @ObjectToken
	END ELSE BEGIN
		SET @TIMESTAMP = NULL
	END

	SELECT @DefectDivisionName = BC1.Description


	-- SELECT @DefectDivisionName = CASE WHEN @DefectDivisionName IN ('FOQC')  THEN '고객불만' ELSE  BC1.Description END 
		  ,@PublishDeptName = BC2.Description
		  ,@ReceiveDeptName = BC3.Description
		  ,@OccurProcessName = REPLACE(BC4.Description, '&', '_')
		  ,@MachineName = MM.MachineName

		  ,@DefectName = DI.BasicDefectName
		  ,@QcOpinionContent =  QDR.QcOpinionContent      --2020.08.07 추가

		  -- 작업자, 작업일자, 모델(x), 제품명, LotNo, Lot크기, 시료수, 불량수, 불량률, Lot조치사항
		  --,@WorkerName = EI2.EmployeeName                   -- 기존소스백업		 
		  , @WorkerName = isnull(EI2.EmployeeName, isnull((select top 1 WorkerName from [SmartFactoryV2].[dbo].[STB_ProdWorkerInfo] where WorkerCode=QDR.ProdWorkerCode),QDR.ProdWorkerCode) )  --작업자, 2020.10.20 수정 (엄제식님 요청)		  
		  , @PublishName = isnull(EI1.EmployeeName, isnull((select top 1 WorkerName from [SmartFactoryV2].[dbo].[STB_ProdWorkerInfo] where WorkerCode=QDR.PublishEmpID),QDR.PublishEmpID) )           --발행자, 2020.10.21 추가 (이미정님 요청)
		  ,@JobDate = QDR.JobDate
		  ,@MaterialName = MM2.MaterialName
		  ,@LotNo = QDR.LotNo
		  ,@DefectLotSize = QDR.DefectLotSize
		  ,@DefectSampleCnt = QDR.DefectSampleCnt
		  ,@DefectErrorCnt = QDR.DefectErrorCnt
		  ,@DefectRate = CONVERT(NUMERIC(20,2), CONVERT(NUMERIC(10,3), QDR.DefectErrorCnt) / CONVERT(NUMERIC(10,3), QDR.DefectSampleCnt) * 100) --기준 수량을 Lot수량에서 시료수량으로 변경 2020.12.28 최은화 과장님 요청
		  ,@DefectRateHN = CONVERT( INT, ROUND( CONVERT(NUMERIC(10,3), QDR.DefectErrorCnt) / CONVERT(NUMERIC(10,3), QDR.DefectSampleCnt) * 100, 0))		-- Mr.Manh add on 2025-07-10  follow Ms.Trang QC Enesol
		  --,@DefectRate = CONVERT(float, CONVERT(float, QDR.DefectErrorCnt) / CONVERT(float, QDR.DefectSampleCnt) * 100)               -- add by Mr.Tung on 2023-May-04 as QC Leader
		  ,@ActionContent = QDR.ActionContent
		  ,@MaterialSpec = QDR.MaterialSpec

		  -- Mr.tung add Production Date for Vietnam Factory on 2023-April-03
		  , @BasicDate=  isnull(MQI.BasicDate,(select top 1 InputJobDate  from STB_SetInfo with(nolock) where Barcode=MQI.MaterialQcNo	
													or Barcode = (select NewBarcode from STB_LotChangeMaterialHistory  with(nolock) where OldBarcode=MQI.MaterialQcNo)
												) )

		  , @OQCDate = CASE WHEN MQI.InspectionDocType = 'OQC'    Then  Convert(VarChar(20), MQI.DecisionDateTime) End  -- 2021.06.17 추가 (양규철님)
		  , @FOQCDate = CASE WHEN MQI.InspectionDocType = 'FOQC' Then Convert(VarChar(20), MQI.DecisionDateTime) End   -- 2021.06.17 추가 (양규철님)
		  , @QcDefectClassCode = QDR.QcDefectClassCode
	  FROM STB_QcDefectReport QDR
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1					ON QDR.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2					ON QDR.PublishDeptCode = BC2.ItemCode	   AND BC2.CodeGroup = 'PublishDeptCode'
			  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI1	    ON QDR.PublishEmpID = EI1.EmployeeNo	   
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3					ON QDR.ReceiveDeptCode = BC3.ItemCode	   AND BC3.CodeGroup = 'ReceiveDeptCode'
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4					ON QDR.OccurProcessCode = BC4.ItemCode	   AND (BC4.CodeGroup = 'OccurProcessCode' or BC4.CodeGroup = 'OccurProcessCode_HN')
			  LEFT OUTER JOIN STB_MachineMaster MM										ON QDR.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI2	    ON QDR.ProdWorkerCode = EI2.EmployeeNo
			  LEFT OUTER JOIN STB_DefectInfo DI												ON QDR.DefectCode = DI.DefectCode
			  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI3	    ON QDR.ActionWorkerCode = EI3.EmployeeNo
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5					ON QDR.ProdProcessResultCode = BC5.ItemCode	   AND BC5.CodeGroup = 'ProdProcessResultCode'
			  LEFT OUTER JOIN (
			                            SELECT DefectReportNo 
										 FROM STB_QcDefectReportReInspectionResult 
										GROUP BY DefectReportNo
									  ) QDRRR	    ON QDRRR.DefectReportNo = QDR.DefectReportNo
			  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	    ON AFM.FileID = QDR.ProdProcessResultFile
			  LEFT OUTER JOIN STB_MaterialMaster MM2 ON MM2.MaterialCode = QDR.MaterialCode

			  LEFT OUTER JOIN STB_MaterialQcInfo MQI ON MQI.MaterialQcNo = QDR.lotno
	 WHERE 1=1 
	   AND QDR.DefectReportNo = @DefectReportNo

	 -- 수신처에 따라 메일제목 변경 (원본백업)
	 --SET @MailSubject = CASE WHEN @ReceiveDeptName IN ('생산부문(베트남법인)', '품질부문(베트남법인)') 
	 --                        THEN '베트남 제품 부적합 발생 보고서_' + CONVERT(CHAR(5), GETDATE(), 101)
		--					 ELSE '본사 제품 부적합 발생 보고서_' + CONVERT(CHAR(5), GETDATE(), 101) END

		-- 2022.04.22 변경 (리미정)
			 SET @MailSubject = CASE WHEN substring(@ReceiveDeptName,1,11) IN ('생산부문(베트남법인)', '품질부문(베트남법인)') 
	                                           THEN '베트남 제품 부적합 발생 보고서_'  + CONVERT(CHAR(5), GETDATE(), 101) + '_'  + '[' + ISNULL(@DefectName, '')  + ']'
							                   ELSE '본사 제품 부적합 발생 보고서_' + CONVERT(CHAR(5), GETDATE(), 101) + '_' +  '[' + ISNULL(@DefectName, '')  + ']'     END

	IF @QcDefectClassCode = '02' BEGIN
		SET @MailSubject = REPLACE(@MailSubject,'부적합', '공정이상품')
	END

	-- 수신처가 베트남 생산부문이면 현지 스탭을 추가함. 2020.10.15 이미정 차장님 요청. By Jackaroe
	-- ngoại lệ khi là VVT_F3 sẽ không thêm
	IF  (substring(@ReceiveDeptName,1,11)  IN ('품질부문(베트남법인)', '생산부문(베트남법인)')  and @WorkCenterCode <> 'VVT_F3' )
	
	BEGIN
		SET @ToAddress = @ToAddress + 'v.vietnamlocalstaff@vina.co.kr;vn.qc@vina.co.kr;vn.bacgiangcampus@vina.co.kr;vn.techproduction@vina.co.kr;lucas@vina.co.kr;' -- Mr.Tung on 2022-June-20 OQC request add their email vn.qc@vina.co.kr
	END


	
	--Begin by Mr.tung on 13-Feb-2023
	declare @tmpDefectDivisionCode varchar(20);
	declare @tmpPublishDeptCode varchar(20);

	select top 1 
		@tmpDefectDivisionCode=DefectDivisionCode ,
		@tmpPublishDeptCode=PublishDeptCode
	from STB_QcDefectReport with(nolock)
	where DefectReportNo = @DefectReportNo

	if (@tmpDefectDivisionCode='09' and @tmpPublishDeptCode='9100' and @WorkCenterCode <> 'VVT_F3')begin
		SET @ToAddress = 'shlee@vina.co.kr;shnoh@vina.co.kr;tranviet@vina.co.kr;jksung@vina.co.kr;caohung@vina.co.kr;tranhang@vina.co.kr;nguyenanh@vina.co.kr;nguyenchien@vina.co.kr;trantrung@vina.co.kr;nguyendiep@vina.co.kr;vn.bacgiangcampus@vina.co.kr;vn.techproduction@vina.co.kr;lucas@vina.co.kr;'
		SET @CcAddress = ''
	end
	
	if ((@tmpDefectDivisionCode='09' and @tmpPublishDeptCode<>'9100') or (@tmpDefectDivisionCode<>'09' and @tmpPublishDeptCode='9100') and @WorkCenterCode <> 'VVT_F3') begin
		SET @ToAddress = 'nguyennha@vina.co.kr;tranhang@vina.co.kr;lucas@vina.co.kr;' 
		SET @CcAddress = 'nguyennha@vina.co.kr'
	end
	--end by Mr.tung on 13-Feb-2023



	--SET @EmailBody = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
 --   SET @EmailBody = @EmailBody + '<html><head>meta http-equiv="content-type" content="text/html; charset=UTF-8"><title>부적합보고서</title></head>'
 --   SET @EmailBody = @EmailBody + '<body>'
    SET @EmailBody =                     N'    <table width="1100" cellspacing="1" cellpadding="1" border="1">'
    SET @EmailBody = @EmailBody + N'      <colgroup>'
    SET @EmailBody = @EmailBody + N'        <col width="15%"><col width="14%"><col width="14%"><col width="14%"><col width="13%"><col width="13%"><col width="17%"> '
    SET @EmailBody = @EmailBody + N'      </colgroup>'
    SET @EmailBody = @EmailBody + N'      <tbody>'

    SET @EmailBody = @EmailBody + N'        <tr>'
    SET @EmailBody = @EmailBody + N'          <td height="20" valign="top" align="left">' + CASE WHEN substring(@DefectDivisionName,1,4) in ('원/부자', '원/부자재') THEN '■' ELSE '□' END + N'원/부자재<br/>Nguyên/Phụ liệu </b></td>'
    SET @EmailBody = @EmailBody + N'          <td height="20" valign="top" align="left">' + CASE WHEN substring(@DefectDivisionName,1,4) in ('공정검사', '전극공정', '전극공정검사') THEN '■' ELSE '□' END  + N'공정검사<br/>Kiểm tra công đoạn </b></td>'
    IF @QcDefectClassCode = '01' BEGIN
		SET @EmailBody = @EmailBody + N'          <td rowspan="2" colspan="4" valign="middle" align="center"><font size="+3"><b>부적합품 보고서<br/><font size="+1">(BÁO CÁO SẢN PHẨM KHÔNG PHÙ HỢP)</b></font></td>'
	END ELSE BEGIN
		SET @EmailBody = @EmailBody + N'          <td rowspan="2" colspan="4" valign="middle" align="center"><font size="+3"><b>공정이상품 보고서<br/><font size="+1">(BÁO CÁO SẢN PHẨM KHÔNG PHÙ HỢP)</b></font></td>'
	END
    
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff">NCR No.</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="20">'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="left">' + CASE WHEN substring(@DefectDivisionName,1,4) IN ('제품검사', '제품검사(베트남)' ) THEN '■' ELSE '□' END + N'제품검사<br/>Kiểm tra sản phẩm </b></td>'    
	--SET @EmailBody = @EmailBody + N'          <td valign="top" align="left">' + CASE WHEN @DefectDivisionName = '고객불만' THEN '■' ELSE '□' END + N'고객불만<br/>Claim của khách hàng</b></td>'
	--SET @EmailBody = @EmailBody + N'          <td valign="top" align="left">' + CASE WHEN @DefectDivisionName IN ('고객불만', 'FOQC')  THEN '■' ELSE '□' END + N'고객불만<br/>Claim của khách hàng</b></td>'
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="left">' + CASE WHEN substring(@DefectDivisionName,1,4) IN ('고객불만', 'FOQC', '출하검사(베트남)', '출하검사')  THEN '■' ELSE '□' END + N'출하검사<br/>Kiểm tra lô hàng</b></td>'
	
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + @DefectReportNo + '</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'
    
	SET @EmailBody = @EmailBody + N'        <tr height="20">'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>발행 부서 <br/>(Bộ phận phát hành)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>수신처 <br/>(Nơi tiếp nhận)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>발생 공정<br/>(Công đoạn phát hiện)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>설비명<br/>(Tên thiết bị)</b></td>' --modify Vietnamese by Mr.Tung as QC request on 2023-02-28
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>작업자<br/>(Người thực hiện)</b></td>'  --modify Vietnamese by Mr.Tung as QC request on 2023-02-28
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>발행자<br/>(Người ban hành)</b></td>'                              -- 추가부분 (발행자)
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>작업일자<br/>(Ngày thao tác)</b></td>'            
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="20">'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@PublishDeptName, '') + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@ReceiveDeptName, '') + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@OccurProcessName, '') + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@MachineName, '') + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@WorkerName, '') + '</td>'
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@PublishName, '') + '</td>'                       --추가부분 (발행자)
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(CHAR(10), @JobDate, 121) + '</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="20">'    
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>MODEL </b></td>'              
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>제품명 <br/>(Tên sản phẩm)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>Lot No. </b></td>'

	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>생산일자<br/> (Ngày sản xuất) </b></td>'                                          -- 2021.06.17 추가 (양규철님)
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>제품검사일자<br/> (Ngày kiểm tra sản phẩm) </b></td>'                        -- 2021.06.17 추가 (양규철님)
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>출하검사일자<br/> (Ngày kiểm tra trước khi xuất hàng) </b></td>'            -- 2021.06.17 추가 (양규철님)

    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="middle" align="center" bgcolor="#ccccff"><b>부적합명 <br/>(Tên lỗi)</b></td>'                  -- Colspan = "4" -> "2" 로 변경  -> 2021.06.17 변경
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="20">'
 -- SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">-</td>'        -- 원본백업
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@MaterialSpec, '') + '</td>'      --규격추가 (2020.10.20 추가, 엄제식 요청)
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@MaterialName, '') + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@LotNo, '') + '</td>'

	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(CONVERT(CHAR(10), @BasicDate, 121), '') + '</td>'     -- 2021.06.17 추가 (양규철님)
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(CONVERT(CHAR(10), @OQCDate, 121), '') + '</td>'    -- 2021.06.17 추가 (양규철님)
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(CONVERT(CHAR(10), @FOQCDate, 121), '') + '</td>'   -- 2021.06.17 추가 (양규철님)

    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="2" valign="top" align="center">' + ISNULL(@DefectName, '') + '</td>'												  
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr>'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="top" align="center" bgcolor="#ccccff"><b>부적합 세부 내용 <br/>(Nội dung chi tiết lỗi)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="top" align="center" bgcolor="#ccccff"><b>부적합 현상<br/>(Hiện trạng lỗi)</b></td>'
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>LOT 크기<br/>(Độ lớn LOT)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(VARCHAR(100), ISNULL(@DefectLotSize, 0)) + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>시료수 <br/>(Số lượng mẫu thử)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(VARCHAR(100), ISNULL(@DefectSampleCnt, 0)) + '</td>'
    SET @EmailBody = @EmailBody + N'          <td rowspan="4" colspan="4" valign="middle" align="center">' + CASE WHEN @TIMESTAMP IS NULL THEN 'No Image' 
																												  ELSE '<img src="http://mes.hycap.co.kr:9952/images/qcRpt/' + RIGHT(@TIMESTAMP, 21) + '" width="300" height="250" />' END + '</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>불량수<br/>(Số lượng NG)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(VARCHAR(100), ISNULL(@DefectErrorCnt, 0)) + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>불량률<br/>(Tỷ lệ NG)</b></td>'
  --SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(VARCHAR(100), ISNULL(@DefectRate, 0)) + '</td>'  -- old code
  ------------------ Mr.Manh update 2025-07-10 follow Ms.Trang QC Enesol
  IF (@WorkCenterCode <> 'VVT_F3')
   BEGIN
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(VARCHAR(100), ISNULL(@DefectRate, 0)) + '</td>'
   END
  ELSE
   BEGIN
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(VARCHAR(100), ISNULL(@DefectRateHN, 0)) + '% </td>'
   END
 ---------- END UPDATE

    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="100">'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="top" align="left"><b>* Lot 조치사항 (Mục xử lý Lot)</b> : ' + ISNULL(@ActionContent, '') + '</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'
    SET @EmailBody = @EmailBody + N'        <tr height="100">'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="top" align="left"><b>* 품질부서 의견 (Ý kiến của bộ phận Chất lượng)  </b> : ' + ISNULL(@QcOpinionContent, '') + '</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'
    SET @EmailBody = @EmailBody + N'      </tbody>'
    SET @EmailBody = @EmailBody + N'    </table>'
    --SET @EmailBody = @EmailBody + '    <br>'
    --SET @EmailBody = @EmailBody + '  </body>'
    --SET @EmailBody = @EmailBody + '</html>'
	if(@WorkCenterCode <> 'VVT_F3')
	BEGIN
	EXEC usp_DoAddDefectReportMail @pProcessUserID = @pProcessUserID
			                ,@pProcessLanguage = @pProcessLanguage
							,@pToMailAddress= @ToAddress
							,@pCcMailAddress= @CcAddress
							,@pMailSubject = @MailSubject
							,@pMailContents = @EmailBody
	END
	ELSE
	BEGIN
		EXEC usp_DoAddDefectReportMail @pProcessUserID = @pProcessUserID
			                ,@pProcessLanguage = @pProcessLanguage
							,@pToMailAddress= @ToAddress_HN
							,@pCcMailAddress= @CcAddress_HN
							,@pMailSubject = @MailSubject
							,@pMailContents = @EmailBody
	END
	-- 부적합 보고서 첨부 이미지의 최종경로 저장 2020.11.03 By Jackaroe
	UPDATE STB_QcDefectReport
	     SET DefectImageUrl = CASE WHEN @TIMESTAMP IS NULL THEN 'No Image' ELSE 'http://mes.hycap.co.kr:9952/images/qcRpt/' + RIGHT(@TIMESTAMP, 21) END
	 WHERE DefectReportNo = @DefectReportNo


END
