
--  EXEC usp_DoChangeMaterialDocLotInfo ' ', ' ' , NULL

-- =============================================
-- Author:	    Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-09-30
-- Browsable : true
-- Group : 자재수불관리 
-- Description:	자재수불 LOT IUD - [F330] 자재입고 및 라벨발행 화면의 세번째 Grid Lot변경 Button

-- 2019-03-11 제조일자 업데이트 수정 (kilee) 
-- 2020-03-25 Fix상태 체크 IF문 주석처리 (kilee)
-- =============================================

-- EXEC usp_DoChangeMaterialDocLotInfo '','',''

CREATE PROCEDURE [dbo].[usp_DoChangeMaterialDocLotInfo_backup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX) = null
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @iDoc           INT
	DECLARE	@TableName  VARCHAR(200)
	DECLARE	@TableName2 VARCHAR(200)
	DECLARE @DocStatus    VARCHAR(20)


	DECLARE @MaterialDocLotInfo TABLE
	(
		IDX INT IDENTITY,
		MaterialDocDetailNo VARCHAR(20),
		MDLISeqNo INT,
		MaterialDocNo VARCHAR(20),
		LotNo VARCHAR(500),
		PackDate VARCHAR(12)                                               -- 추가
		--LotId VARCHAR(100)                                                   -- 외주바코드 추가 (2020.04.04)
	)

	SET @TableName  = '/DataSet/MaterialDocLotInfo_UPDATE'
	SET @TableName2 = '/DataSet/MaterialDocLotInfo_INSERT'

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml 

	BEGIN TRY

		INSERT @MaterialDocLotInfo
		SELECT
				XMLData.MaterialDocDetailNo,
				XMLData.MDLISeqNo,
				XMLData.MaterialDocNo,
				XMLData.LotNo,
				CONVERT(VARCHAR(10), XMLData.LotAttr10, 121)                                            -- 추가  ( 주의 : 화면의 컬럼명 및 대소문자구분 으로 해줘야됨!!!)
		FROM
				OPENXML(@iDoc, @TableName, 2)
				WITH(
						MaterialDocDetailNo  VARCHAR(20),
						MDLISeqNo             INT,
						MaterialDocNo         VARCHAR(20),
						LotNo                     VARCHAR(500),
						LotAttr10                 VARCHAR(12)                                    -- 추가 ( 주의 : 화면의 컬럼명으로 해줘야됨!!!)
					   ) XMLData

		-- 엑셀 붙여넣기 내용 추가
		INSERT @MaterialDocLotInfo
		SELECT
				XMLData.MaterialDocDetailNo,
				XMLData.MDLISeqNo,
				XMLData.MaterialDocNo,
				XMLData.LotNo,
				CONVERT(VARCHAR(10), XMLData.Lotattr10, 121)
		FROM
				OPENXML(@iDoc, @TableName2, 2)
				WITH(
						MaterialDocDetailNo VARCHAR(20),
						MDLISeqNo             INT,
						MaterialDocNo         VARCHAR(20),
						LotNo                     VARCHAR(500),
						LotAttr10                 VARCHAR(12)
					   ) XMLData
	END TRY


	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR(@ERROR_MSG,16,1)
	END CATCH
	
	
	EXEC sp_xml_removedocument @iDoc	

	DECLARE @rowCnt INT 
	DECLARE @initNum INT = 1
	DECLARE @MaterialDocDetailNo VARCHAR(20)
	DECLARE @MDLISeqNo            INT
	DECLARE @MaterialDocNo VARCHAR(20)
	DECLARE @LotNo            VARCHAR(500)
	DECLARE @PackDate           VARCHAR(12)                                 -- 제조일자 Date
	DECLARE @LotId            VARCHAR(100)
	DECLARE @LotAttr03        VARCHAR(100)              -- 바코드업체 추가

	SELECT  TOP 1 
			 @MaterialDocNo = MaterialDocNo 
	FROM  @MaterialDocLotInfo

	SELECT
			@DocStatus = MDI.DocStatus
	FROM		STB_MaterialDocInfo MDI
	WHERE 1=1
	   AND MDI.MaterialDocNo = @MaterialDocNo

	--IF @DocStatus = 'FIX'                          ---  FIX된 경우는 변경할수 없도록 -> 구보겸 요청으로 제외 (2020.03.25 kilee)
	
	--BEGIN
	--	RAISERROR( '입고확정된 수불문서의 Lot번호를 변경할 수 없습니다. %s', 16, 1, @MaterialDocNo)
	--	RETURN
	--END




	SELECT @rowCnt = COUNT(1)
	 FROM @MaterialDocLotInfo
	WHILE @initNum <= @rowCnt
	
	
	 BEGIN
		
		SELECT
				@MaterialDocDetailNo = MDI.MaterialDocDetailNo,
				@MDLISeqNo = MDI.MDLISeqNo,
				@LotNo = MDI.LotNo,
				@PackDate = MDI.PackDate                                                  -- 추가
		FROM
				@MaterialDocLotInfo MDI
		WHERE 1=1
		   AND IDX = @initNum
		   		

	-- 2020.06.20 추가사항                 
	--select CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  6, '20200101'), 121)), 121)
	-- select DATALENGTH(CONVERT(VARCHAR(10), CONVERT(VARCHAR(10),  '20200101'), 121))

	--IF DATALENGTH(@PackDate)  < 16 And DATALENGTH(@PackDate) > 2


	 IF DATALENGTH(CONVERT(VARCHAR(10), CONVERT(VARCHAR(10),  @PackDate), 121)) < 8 --Or @PackDate is not null Or DATALENGTH(CONVERT(VARCHAR(10), CONVERT(VARCHAR(10),  @PackDate), 121)) > 12
	BEGIN
		RAISERROR( '날짜 형태 Ex) 2020-06-16 형태로 입력하시기 바랍니다. %s', 16, 1, @PackDate)
		RETURN
	END



	-- select DATALENGTH(Lotattr10),  Lotattr10 from STB_MaterialDocLotInfo where MaterialDocNo in ( '200602000163', '200526000117')
	--select Lotattr10, * from STB_MaterialDocLotInfo where MaterialDocNo = '200602000163'



				
		UPDATE STB_MaterialDocLotInfo 
		     SET  LotNo = @LotNo
			     , ChangeDateTime = GETDATE()
			     , ChangeUserID = @pProcessUserID
				 , LotAttr10 =  @PackDate                                                        --- 제조일자 추가				
		WHERE 1=1
			AND MaterialDocDetailNo = @MaterialDocDetailNo 
			AND	MDLISeqNo = @MDLISeqNo
		

		 --SELECT LotNo, * FROM STB_MaterialDocLotInfo	 WHERE Lotid = 'ML20200403000004'         -- LotNo 변경 [자재입고 및 라벨발행]
   --      SELECT LotNo, * FROM STB_MaterialLotInfo      WHERE Lotid = 'ML20200403000004'         -- LotNo 변경[자재리스트] 

		SELECT @LotId = Lotid
		 FROM STB_MaterialDocLotInfo
		WHERE 1=1
			AND MaterialDocDetailNo = @MaterialDocDetailNo 
			AND	MDLISeqNo = @MDLISeqNo 

		
         UPDATE STB_MaterialLotInfo
		      SET LotNo = @LotNo
		 WHERE  1=1
		    AND  Lotid = @LotId
			
			  --GR : 입고, GI : 출고

		SET @initNum = @initNum + 1
				


--- 2021.06.11 추가 [Start]  -------------------------------------------------------------------------------------------------------->>

		select  @LotAttr03 = LotAttr03             --- 바코드업체
		 from  STB_MaterialDocLotInfo
		where 1=1
		  And ( Lotno = @LotNo  Or LotID = @LotID )

	 -- 1. 
          IF @LotAttr03 = '성남전기공업(주)'    

			BEGIN

				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 =   Case When Lotno = '' Then ''
												 When Len(LotNo) < 10 Then ''
												 When Substring(Lotno, 8, 1) in ('8','9')  And Substring(Lotno, 9, 1) = 'O' Then '201' + Substring(Lotno, 8, 1) + '-' + '0' + '10' + '-' + Substring(Lotno, 10, 2)
												 When Substring(Lotno, 8, 1) in ('8','9')  And Substring(Lotno, 9, 1) = 'N' Then '201' + Substring(Lotno, 8, 1) + '-' + '0' + '11' + '-' + Substring(Lotno, 10, 2)
												 When Substring(Lotno, 8, 1) in ('8','9')  And Substring(Lotno, 9, 1) = 'D' Then '201' + Substring(Lotno, 8, 1) + '-' + '0' + '12' + '-' + Substring(Lotno, 10, 2)
												 When Substring(Lotno, 8, 1) in ('8','9')  And Substring(Lotno, 9, 1) NOT IN ( 'O', 'N', 'D') Then '201' + Substring(Lotno, 8, 1) + '-' + '0' + Substring(Lotno, 9, 1) + '-' + Substring(Lotno, 10, 2)

												 When Substring(Lotno, 8, 1) Not in ('8','9')  And Substring(Lotno, 9, 1) = 'O' Then '202' + Substring(Lotno, 8, 1) + '-' + '0' + '10' + '-' + Substring(Lotno, 10, 2)
												 When Substring(Lotno, 8, 1) Not in ('8','9')  And Substring(Lotno, 9, 1) = 'N' Then '202' + Substring(Lotno, 8, 1) + '-' + '0' + '11' + '-' + Substring(Lotno, 10, 2)
												 When Substring(Lotno, 8, 1) Not in ('8','9')  And Substring(Lotno, 9, 1) = 'D' Then '202' + Substring(Lotno, 8, 1) + '-' + '0' + '12' + '-' + Substring(Lotno, 10, 2)
												 When Substring(Lotno, 8, 1) Not in ('8','9')  And Substring(Lotno, 9, 1) NOT IN ( 'O', 'N', 'D') Then '201' + Substring(Lotno, 8, 1) + '-' + '0' + Substring(Lotno, 9, 1) + '-' + Substring(Lotno, 10, 2)
												   Else  '202' + Substring(Lotno, 8, 1) + '-' + '0' +  Substring(Lotno, 9, 1) + '-' + Substring(Lotno, 10, 2)  End  			
				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )

			END

		 -- 2. 
           IF @LotAttr03 = '제신'     

			BEGIN

				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 =  Case When Lotno = '' Then ''
												When Len(LotNo) < 7 Then ''
											       Else  '20' + LEFT(Lotno, 2) + '-' + Substring(Lotno, 3, 2) + '-' + Substring(Lotno, 5, 2) End 
				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )

			END

		-- 3.
		 IF @LotAttr03 = '무등'     

			BEGIN

				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 = Case When Lotno = '' Then ''
												 When Len(LotNo) = 29 Then '20' + SubString(Lotno, 20, 2) + '-' + SubString(Lotno, 22, 2) + '-' + SubString(Lotno, 24, 2)
												Else  '' End
				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )

			END

		-- 4.	
		 IF @LotAttr03 = '리더스월드'     

			BEGIN

				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 =  Case When Lotno = '' Then ''
												 Else  '20' + SubString(Lotno, 20, 2) + '-' + SubString(Lotno, 22, 2) + '-' + SubString(Lotno, 24, 2) End
				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )

			END

		--5. 인터컴
			 IF @LotAttr03 = 'INTERCOMM. COMPANY CO, LTD.'   

			BEGIN

				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 =  Case When Lotno = '' Then '' Else '20' + Left(Lotno, 2) + '-' + Substring(Lotno, 3, 2) + '-' + Substring(Lotno, 5, 2) End
				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )

			END


		--6. 호북전자
			IF @LotAttr03 = 'SUZHOU KOHOKU OPTO-ELECTRONICS'     

			BEGIN

				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 =  Case When Lotno = '' Then '' Else '20' + Left(Lotno, 2) + '-' + Substring(Lotno, 3, 2) + '-' + Substring(Lotno, 5, 2) End
				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )

			END

	   -- 7. 한국JCC
		 IF @LotAttr03 = '한국제이씨씨(주)'     

			BEGIN
				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 =  Case When Lotno = '' Then '' Else dbo.fnGetMondayByWeekNo ( ('20' + Left(Lotno, 2))  , Substring(Lotno, 3, 2), Substring(Lotno, 4, 1) )   End
				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )
			END

         -- 8. 테이팩스
		 IF @LotAttr03 = '(주)테이팩스화성공장'

			BEGIN
				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 =  Case When Lotno = '' Then '' Else dbo.fnGetMondayByWeekNo ( ('20' + Left(Lotno, 2))  , Substring(Lotno, 3, 2), Substring(Lotno, 4, 1) )   End
				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )
			END

			 -- 9 테이팩스
		 IF @LotAttr03 = '(주)테이팩스화성공장'

			BEGIN
				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 =  Case When Lotno = '' Then '' Else dbo.fnGetMondayByWeekNo ( ('20' + Left(Lotno, 2))  , Substring(Lotno, 3, 2), Substring(Lotno, 4, 1) )   End
				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )
			END

			 -- 10. 리더스월드- 전해액 (xxx)
		 IF @LotAttr03 = '리더스월드'

			BEGIN
				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 =  Case When Lotno = '' Then '' Else '20' + SubString(Lotno, 3, 2) + '-' + Substring(Lotno, 5, 2) + '-' +Substring(Lotno, 7, 2)  End 
				where 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )
			END

			 -- 11. 쿠라레이
		 IF @LotAttr03 = 'Kuraray Co.,Ltd.'

			BEGIN
				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 =  Case When Lotno = '' Then '' Else '20' + SubString(Lotno, 2, 2) + '-' + Substring(Lotno, 4, 2) + '-' +Substring(Lotno, 6, 2)  End
				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )
			END

			 -- 12. 파워카본테크놀로지 
		 IF @LotAttr03 = '파워카본테크놀로'

			BEGIN
				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 =  Case When Lotno = '' Then '' 
												 When SubString(Lotno, 7, 1)  = 'K'  Then'20' + SubString(Lotno, 5, 2) + '-' +   Convert(Varchar(10), dbo.fnGetMonthNo(Substring(Lotno, 7, 1))) + '-' +Substring(Lotno, 8, 2)
												 When SubString(Lotno, 7, 1)  = 'L'  Then'20' + SubString(Lotno, 5, 2) + '-' +   Convert(Varchar(10), dbo.fnGetMonthNo(Substring(Lotno, 7, 1))) + '-' +Substring(Lotno, 8, 2)
												 When SubString(Lotno, 7, 1)  = 'M'  Then'20' + SubString(Lotno, 5, 2) + '-' +   Convert(Varchar(10), dbo.fnGetMonthNo(Substring(Lotno, 7, 1))) + '-' +Substring(Lotno, 8, 2)
													Else '20' + SubString(Lotno, 5, 2) + '-' + '0' + Convert(Varchar(10), dbo.fnGetMonthNo(Substring(Lotno, 7, 1))) + '-' +Substring(Lotno, 8, 2)                                         End
				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )
			END

			 -- 13. 하남전자
		 IF @LotAttr03 = '(주)하남전자'

			BEGIN
				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 = Case When Lotno = '' Then '' Else '20' + SubString(Lotno, 10, 2) + '-' + Substring(Lotno, 12, 2) + '-' +Substring(Lotno, 14, 2)  End 
				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )
			END
--- 2021.06.11 추가 [End]  -------------------------------------------------------------------------------------------------------->>



	END

END