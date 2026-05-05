-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2020-10-23
-- Browsable : True
-- Group : 품질관리> 부적합보고서 등록 메일설정부분 > [수입검사]용 메일
-- Description: 부적합보고서 등록 시 호출되어 이메일을 발송한다.
-- Modified: 
-- 2020.10.23 박진호님 요청
-- 2020.12.01 법인 부적합 메일그룹 추가 (박진호님 요청)
-- 2020.12.08 시료수, 불량수, 불량률 SQL문 수정 (박진호님 요청)
-- 2020.12.09 불량수(%)수식변경 (박진호요청)
-- 2021.07.16 부적합 발행부서 기준으로 메일 제목 수정 (이미정 차장 요청) #210716

 -- 프로시저 실행 :  usp_DoSendEmailForDefectReportIQC '','','VVNI210323-01'
  --,@ActionContent = QDR.ActionContent --add by Mr.Tung on 2022-07-25
-- =============================================
Create PROCEDURE [dbo].[usp_DoSendEmailForDefectReportIQC_20220103]
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
			   ,@WorkerName NVARCHAR(100)
			   ,@PublishName NVARCHAR(100)  
			   ,@JobDate DATE

			   ,@MaterialCode VARCHAR(30)
			   ,@MaterialName VARCHAR(100)
			   ,@LotNo VARCHAR(20)			   
			   ,@DefectSampleCnt INT
			   ,@DefectErrorCnt INT
			  , @DefectRate NUMERIC(10, 3)
			  , @ActionContent NVARCHAR(MAX)
			  , @MailSubject NVARCHAR(500)		   
			  , @MaterialSpec NVARCHAR(50)
			  , @ImmediateAction NVARCHAR(MAX)		
			  , @CauseInvestigation NVARCHAR(MAX)		
			  , @PreventionRecurrence NVARCHAR(MAX)		
			  , @DetectionCounterMeasures NVARCHAR(MAX)		  
			  , @CheckingCorrectiveAction NVARCHAR(MAX)		
			  , @Validation NVARCHAR(50)		
			  , @ActionCode NVARCHAR(10)		
			  , @QcOpinionContent NVARCHAR(MAX)		
			  , @IsQcHeadConfirm  NVARCHAR(500)		
			  , @Payment   NVARCHAR(100)		
			  , @CorrectiveActionCode NVARCHAR(10)		
			  , @CorrectiveActionName NVARCHAR(100)		
			  --, @DefectImage NVARCHAR(500)		
			  --, @DefectImage2 NVARCHAR(500)		
			  , @DefectLotSize INT		
		      , @IQCSampleLotList NVARCHAR(50)
			  , @ProdProcessResultCode NVARCHAR(50)
			  , @ProdProcessResultName NVARCHAR(50)
			  , @IsProdHeadConfirm  NVARCHAR(50)			  
			  , @CreateDateTime DATE
			  , @CreateUserID NVARCHAR(50)
			  , @ChangeDateTime DATE
			  , @ChangeUserID  NVARCHAR(50)
			  , @IsReInspectionResult  NVARCHAR(50)
			  , @ProdProcessResultFile	NVARCHAR(50)	   
			  , @FileData NVARCHAR(50)
			  , @DefectiveRate INT
			  , @ProductGroupName VARCHAR(40)

			   --생산부문, 베트남부문
			   ,@ToAddress VARCHAR(MAX) = 'v.manufacturing@vina.co.kr;v.celltechnical@vina.co.kr;v.vietnamcorp@vina.co.kr;'        
			   -- 품질부문
			   ,@CcAddress VARCHAR(MAX) = 'v.qc@vina.co.kr;v.vietnamiqcrelative@vina.co.kr;v.purchasing@vina.co.kr' + ';vn.production@vina.co.kr;v.vietnamlocalstaff@vina.co.kr;vn.purchase@vina.co.kr;vn.qc@vina.co.kr;'   -- Mr.Tung on 2022-June-20 OQC request add their email vn.qc@vina.co.kr --add by Mr.Tung on 04-10-2021 & 10-11-2021 & 2022-April-29 as Mr.Quyen/Mr.Kien request                    -- 2020.12.07 베트남 직원들 추가  -- 2021.08.06 구매팀 추가

			   ---- 테스트 Mail
			   --,@ToAddress VARCHAR(MAX) = 'kilee@vina.co.kr;'			 
      --        ,@CcAddress VARCHAR(MAX) = 'nicekangil@naver.com;'                                       --'jseom@vina.co.kr;'  --    jhpark@vina.co.kr;yjyu@vina.co.kr;'

    SELECT @IMG_PATH = DefectImage FROM STB_IQcDefectReport WHERE DefectReportNo = @DefectReportNo     -- 테이블명 확인 : 수입검사는 STB_IQcDefectReport

	IF @IMG_PATH IS NOT NULL BEGIN 
			SET @TIMESTAMP = 'C:\MES\WebSite\images\qcRpt2\' + replace(replace(replace(replace(convert(varchar,getdate(),121),'-',''),':',''),'.',''),' ','') + '.jpg'      -- qcRpt2 중요!

			EXEC sp_OACreate 'ADODB.Stream', @ObjectToken OUTPUT
			EXEC sp_OASetProperty @ObjectToken, 'Type', 1
			EXEC sp_OAMethod @ObjectToken, 'Open'
			EXEC sp_OAMethod @ObjectToken, 'Write', NULL, @IMG_PATH
			EXEC sp_OAMethod @ObjectToken, 'SaveToFile', NULL, @TIMESTAMP, 2
			EXEC sp_OAMethod @ObjectToken, 'Close'
			EXEC sp_OADestroy @ObjectToken
	END 
	
	ELSE 
	
			BEGIN
				SET @TIMESTAMP = NULL
			END



	SELECT 
	    @DefectDivisionName =  BC1.Description           --원부자재		  
		  , @PublishDeptName = BC2.Description              --품질부문  (발행부서)
		  --, @ReceiveDeptName = BC2.Description           --품질부문
		  ,@OccurProcessName = BC4.Description
		  , @ReceiveDeptName = C.CustomerName           --수신처 : 하남전자		    
		  , @OccurProcessName = SNR.OccurProcessCode  -- 공정검사		  
		  , @MaterialCode = MQI.MaterialCode                 --품번
		  , @MaterialName = MM.MaterialName
		  , @ProductGroupName = PG.ProductGroupName
		  , @DefectiveRate = Case when  MQI.ActualSampleQty = 0 then 0 when MQI.DefectSampleQty = 0   then 0 else CONVERT(BIGINT, ( CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100)) End  -- 불량율(%) (2020.12.08 수정)
		              
		  -- (Lot조치사항)
		  -- (품질부서의견)
		  -- (부적합현상)
		  --, BC4.Description
		  --,QDR.PublishEmpID
		  --,@PublishName = EI1.EmployeeName     -- 발행자
		  , @PublishName = isnull(EI1.EmployeeName, isnull((select top 1 WorkerName from [SmartFactoryV2].[dbo].[STB_ProdWorkerInfo] where WorkerCode=QDR.PublishEmpID),QDR.PublishEmpID) )           --발행자, 2020.12.07 추가 (박진호님 요청)
		  --,BC4.Description AS OccurProcessName		  
		  , @LotNo = Case When isnull(QDR.LotNo, '') = '' Then SNR.LotNo Else QDR.LotNo End 
		  , @IQCSampleLotList = MQI.IQCSampleLotList                    -- 검사 LotNo
		  , @CorrectiveActionCode = QDR.CorrectiveActionCode         -- 시정조치여부코드
		  , @CorrectiveActionName = BC6.Description                      -- 시정조치여부명
		  --, @DefectImage = QDR.DefectImage
		  --, @DefectImage2=  QDR.DefectImage2  
		  , @DefectLotSize = QDR.DefectLotSize		
		  , @ProdProcessResultCode = QDR.ProdProcessResultCode     -- 생산부분 처리코드 (재작업, 특채 등)
		  , @ProdProcessResultName = BC5.Description                     -- 생산부분 처리명 (코드테이블)		
		  , @IsProdHeadConfirm = CONVERT(BIT, 0) 
		  , @IsQcHeadConfirm = CONVERT(BIT, 0) 
		  , @CreateDateTime = GETDATE() 
		  , @CreateUserID = QDR.CreateUserID
		  , @ChangeDateTime = QDR.ChangeDateTime
		  , @ChangeUserID = QDR.ChangeUserID
		  , @IsReInspectionResult  = CONVERT(BIT, 0) 
		  , @ProdProcessResultFile = QDR.ProdProcessResultFile
		  --, @AFM.[FileName]
		  --, @AFM.FileSize
		  , @FileData = ISNULL(AFM.FileContents, CONVERT(VARBINARY(MAX),NULL)) 
		  , @ImmediateAction = QDR.ImmediateAction     --즉시조치
		  , @CauseInvestigation = QDR.CauseInvestigation    --원인조사
		  , @PreventionRecurrence = QDR.PreventionRecurrence     --재발방지조치
		  , @DetectionCounterMeasures = QDR.DetectionCounterMeasures    --검출대책수립		  
		  , @CheckingCorrectiveAction = QDR.CheckingCorrectiveAction   --시정조치확인
		  , @Validation = QDR.Validation                       --제품유효성확인
		  , @ActionCode = QDR.IsActionCode           -- 시정조치여부
		  , @QcOpinionContent = QDR.QcOpinionContent  -- 품질부서의견
          , @IsQcHeadConfirm = QDR.IsQcHeadConfirm  -- 품질부문장결재
		  , @Payment  = Case When QDR.IsQcHeadConfirm = 0 Then  '결재취소'  When QDR.IsQcHeadConfirm  = 1 Then  '결재완료'  Else '미완료' End  
		      		  
		  -- 원본백업 (2020.12.08 이전)
		  -- , @DefectLotSize = QDR.DefectLotSize
		  --, @DefectSampleCnt = MQI.MIIExtText04
		  --, @DefectLotSize = SNR.Qty                    -- LOT크기
		  --, @DefectErrorCnt = SNR.BadLotQty          -- 불량수
		  --, @DefectSampleCnt =  SNR.InQty            -- 시료수

		  -- 수정사항 (2020.12.08 부터)
		 , @DefectLotSize = MQI.QcQty                    -- 2020.12.08 "Lot크기" 수정사항
		 , @DefectErrorCnt = MQI.DefectSampleQty    -- 2020.12.08 "불량수" 수정사항
	     , @DefectSampleCnt = MQI.ActualSampleQty -- 2020.12.08 "시료수" 수정사항

		-- , @DefectRate = Case When MQI.MIIExtText04 = 0 Then 0 When MDD.LotNo_Qty = 0 Then 0 Else Convert(BIGINT, ( Convert(NUMERIC(20,5), MQI.MIIExtText04) / Convert(NUMERIC(20,5), MDD.LotNo_Qty) * 100)) End   -- 2020.12.08 "불량률" 수정사항
		 ,  @DefectRate =  Case when  MQI.DefectSampleQty = 0 then 0 when MQI.ActualSampleQty = 0   then 0 else CONVERT(NUMERIC(20,5), ( CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))  End 
		  , @JobDate = CONVERT(VARCHAR(10), QDR.CreateDateTime, 121)
		  , @DefectName = QDR.Nonconformity             -- 부적합명 : ex)이물세척
		  , @IQCSampleLotList =  MQI.IQCSampleLotList    -- 검사 Lot No 		
		   ,@ActionContent = QDR.ActionContent --add by Mr.Tung on 2022-07-25
		    		
 FROM							 STB_MaterialQcInfo MQI	    	                  
			LEFT OUTER JOIN  STB_NCR_Report SNR                                    ON SNR.LotNo =  MQI.IQCSampleLotList  
			LEFT OUTER JOIN  STB_IQcDefectReport QDR     WITH(NOLOCK)	 ON SNR.NCRNo = QDR.DefectReportNo    
			LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	         ON QDR.DefectDivisionCode = BC1.ItemCode  AND BC1.CodeGroup = 'DefectDivisionCode'
			LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	         ON QDR.PublishDeptCode = BC2.ItemCode	   AND BC2.CodeGroup = 'PublishDeptCode'			 
			LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI1  ON QDR.PublishEmpID = EI1.EmployeeNo		   
			-- LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3			 ON QDR.ReceiveDeptCode = BC3.ItemCode	   AND BC3.CodeGroup = 'ReceiveDeptCode'         
			LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4	         ON QDR.OccurProcessCode = BC4.ItemCode	   AND BC4.CodeGroup = 'OccurProcessCode'		   
			LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5	         ON QDR.ProdProcessResultCode = BC5.ItemCode  AND BC5.CodeGroup = 'ProdProcessResultCode'
			LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC6	         ON QDR.CorrectiveActionCode = BC6.ItemCode	   AND BC6.CodeGroup = 'CorrectiveActionCode'               						
			LEFT OUTER JOIN (
									SELECT DefectReportNo 
										FROM STB_QcDefectReportReInspectionResult 
									GROUP BY DefectReportNo
									) QDRR	                                                             ON QDRR.DefectReportNo = QDR.DefectReportNo
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	 ON AFM.FileID = QDR.ProdProcessResultFile		
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		             ON MQI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN (
										 SELECT DISTINCT MDD.MaterialDocNo,
													MDD.MaterialIqcNo,
													Count(MDLI.LotNo)	AS LotNo_Qty            
											FROM
													STB_MaterialDocDetail MDD WITH(NOLOCK)
													INNER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)		 ON MQI.MaterialQcNo = MDD.MaterialIqcNo
													INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		 ON MDI.MaterialDocNo = MDD.MaterialDocNo
													INNER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK) ON MDLI.MaterialDocNo = MDD.MaterialDocNo   And MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo      -- 2020.09.06 추가
											WHERE	1=1											
											Group by MDD.MaterialDocNo,	MDD.MaterialIqcNo                            
									) MDD				                                    ON MDD.MaterialIqcNo = MQI.MaterialQcNo
			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		ON MDI.MaterialDocNo = MDD.MaterialDocNo
			LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode
 WHERE 1=1 
	   AND QDR.DefectReportNo = @DefectReportNo
	  -- AND QDR.DefectReportNo = 'VNI201022-01'	     -- Test주석

	 -- 수신처에 따라 메일제목 변경
	 --SET @MailSubject = CASE WHEN @ReceiveDeptName IN ('생산부문(베트남법인)', '베트남법인')  THEN '베트남 제품 부적합 발생 보고서_' + CONVERT(CHAR(5), GETDATE(), 101)
		--								  ELSE '본사 제품 부적합 발생 보고서_'    + CONVERT(CHAR(5), GETDATE(), 101) END

	 --#210716
	 SET @MailSubject = CASE WHEN @PublishDeptName = '품질부문(베트남법인)' THEN '베트남 수입검사 부적합 발생 보고서_' + CONVERT(CHAR(5), GETDATE(), 101)
							 ELSE '본사 수입검사 부적합 발생 보고서_'    + CONVERT(CHAR(5), GETDATE(), 101) END
	
	-- 원본백업 (2020.12.07 이전)
	--IF @ReceiveDeptName IN ('베트남법인', '생산부문(베트남법인)') 
	--BEGIN
	--	--SET @ToAddress = @ToAddress + 'v.vietnamlocalstaff@vina.co.kr;'          -- 일반 부적합 보고서
	--	SET @ToAddress = @ToAddress + 'v.vietnamiqcrelative@vina.co.kr;'           -- IQC 부적합보고서 (2020.12.01 추가)	
	--END

    SET @EmailBody =                     N'    <table width="1100" cellspacing="1" cellpadding="1" border="1">'
    SET @EmailBody = @EmailBody + N'      <colgroup>'
    SET @EmailBody = @EmailBody + N'        <col width="15%"><col width="14%"><col width="14%"><col width="14%"><col width="13%"><col width="13%"><col width="17%"> '
    SET @EmailBody = @EmailBody + N'      </colgroup>'
    SET @EmailBody = @EmailBody + N'      <tbody>'

    SET @EmailBody = @EmailBody + N'        <tr>'
    SET @EmailBody = @EmailBody + N'          <td height="20" valign="top" align="left">' + CASE WHEN @DefectDivisionName = '원/부자재' THEN '■' ELSE '□' END + N'원/부자재<br/>Nguyên/Phụ liệu </b></td>'
    SET @EmailBody = @EmailBody + N'          <td height="20" valign="top" align="left">' + CASE WHEN @DefectDivisionName = '공정검사' THEN '■' ELSE '□' END  + N'공정검사<br/>Kiểm tra công đoạn </b></td>'
    SET @EmailBody = @EmailBody + N'          <td rowspan="2" colspan="4" valign="middle" align="center"><font size="+3"><b> 부적합품 보고서<br/><font size="+1">(BÁO CÁO SẢN PHẨM KHÔNG PHÙ HỢP)</b></font></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff">NCR No.</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="20">'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="left">' + CASE WHEN @DefectDivisionName IN ('제품검사', '제품검사(베트남)', '출하검사(베트남)', 'FOQC') THEN '■' ELSE '□' END + N'제품검사<br/>Kiểm tra sản phẩm </b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="left">' + CASE WHEN @DefectDivisionName IN ('고객불만', 'FOQC', '출하검사(베트남)')  THEN '■' ELSE '□' END + N'출하검사<br/>Kiểm tra lô hàng</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + @DefectReportNo + '</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'
    
	SET @EmailBody = @EmailBody + N'        <tr height="20">'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>발행 부서 <br/>(Bộ phận phát hành)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>수신처 <br/>(Nơi tiếp nhận)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>발생 공정<br/>(Công đoạn phát sinh)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>품목코드<br/>(Tên thiết bị)</b></td>'                               -- 변경부분
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>품목명<br/>(Công nhân thao tác)</b></td>'    -- 변경부분
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>발행자<br/>(nhà xuất bản)</b></td>'                          
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>검사일자<br/>(Ngày thao tác)</b></td>'            -- 변경부분
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="20">'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@PublishDeptName, '') + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@ReceiveDeptName, '') + '</td>'
  --  SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@OccurProcessName, '') + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + '수입검사' + '</td>'
   SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@MaterialCode, '') + '</td>'	
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@MaterialName, '') + '</td>'
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@PublishName, '') + '</td>'                       
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(CHAR(10), @JobDate, 121) + '</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="20">'    
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>MODEL </b></td>'              
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>원자재 그룹명 <br/>(Tên nhóm nguyên liệu) </b></td>'                --변경부분
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>Lot No. </b></td>'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="middle" align="center" bgcolor="#ccccff"><b>부적합명 <br/>(Tên lỗi)</b></td>'    
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="20">'
	SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + '-' + '</td>'      
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@ProductGroupName, '') + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + ISNULL(@IQCSampleLotList, '') + '</td>'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="top" align="center">' + ISNULL(@DefectName, '') + '</td>'												  
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr>'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="top" align="center" bgcolor="#ccccff"><b>부적합 세부 내용 <br/>(Nội dung chi tiết lỗi)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="top" align="center" bgcolor="#ccccff"><b>부적합 현상        <br/>(Hiện trạng lỗi)</b></td>'
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>LOT 크기<br/>(Độ lớn LOT)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(VARCHAR(100), ISNULL(@DefectLotSize, 0)) + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>시료수 <br/>(Số lượng mẫu thử)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(VARCHAR(100), ISNULL(@DefectSampleCnt, 0)) + '</td>'    	
	SET @EmailBody = @EmailBody + N'          <td rowspan="4" colspan="4" valign="middle" align="center">' + CASE WHEN @TIMESTAMP IS NULL 
																																							 THEN 'No Image' 
																																				              ELSE '<img src="http://mes.hycap.co.kr:9952/images/qcRpt2/' + RIGHT(@TIMESTAMP, 21) + '" width="300" height="250" />' END + '</td>'	
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>불량수<br/>(Số lượng NG)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(VARCHAR(100), ISNULL(@DefectErrorCnt, 0)) + '</td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center" bgcolor="#ccccff"><b>불량률<br/>(Tỷ lệ NG)</b></td>'
    SET @EmailBody = @EmailBody + N'          <td valign="top" align="center">' + CONVERT(VARCHAR(100), ISNULL(@DefectRate, 0)) + '</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="100">'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="top" align="left"><b>* Lot 조치사항 (Mục xử lý Lot)</b> : ' + ISNULL(@ActionContent, '') + '</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'

    SET @EmailBody = @EmailBody + N'        <tr height="100">'
    SET @EmailBody = @EmailBody + N'          <td rowspan="1" colspan="4" valign="top" align="left"><b>* 품질부서 의견 (Ý kiến của bộ phận Chất lượng)  </b> : ' + ISNULL(@QcOpinionContent, '') + '</td>'
    SET @EmailBody = @EmailBody + N'        </tr>'
    SET @EmailBody = @EmailBody + N'      </tbody>'
    SET @EmailBody = @EmailBody + N'    </table>'

	EXEC usp_DoAddDefectReportMail @pProcessUserID = @pProcessUserID
												,@pProcessLanguage = @pProcessLanguage
												,@pToMailAddress= @ToAddress
												,@pCcMailAddress= @CcAddress
												,@pMailSubject = @MailSubject
												,@pMailContents = @EmailBody

	-- 부적합 보고서 첨부 이미지의 최종경로 저장 (2020.11.03) By Jackaroe
	UPDATE STB_IQcDefectReport
	      SET DefectImageUrl = CASE WHEN @TIMESTAMP IS NULL THEN 'No Image' ELSE 'http://mes.hycap.co.kr:9952/images/qcRpt2/' + RIGHT(@TIMESTAMP, 21) END
	 WHERE DefectReportNo = @DefectReportNo

END																																				 																																				              																																																																																																																																																																				