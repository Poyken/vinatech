-- =============================================
-- Patch: Thêm 16 mã nguyên phụ liệu vào bypass list trong usp_DoChangeMaterialDocLotInfo
-- Mục đích: Cho phép nhập Đặc tính 10 bằng tay khi LotNo trống (không có Vendor Lot)
-- Yêu cầu từ: Chị (bộ phận kho) - nhập nguyên phụ liệu đóng gói lên MES
-- Ngày: 2026-06-23
-- Tác giả: ducnv
-- Tiền lệ: Các mã WRHI00-001, 153_CHATPHUBM, BEMP00-005 đã được bypass từ 2026-02-03
-- =============================================
-- BACKUP: usp_DoChangeMaterialDocLotInfo (trước patch)
-- ROLLBACK: Chạy lại ALTER với danh sách IN cũ (chỉ 5 mã gốc)
-- =============================================

ALTER PROCEDURE [dbo].[usp_DoChangeMaterialDocLotInfo]
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

	declare @materialcode varchar(20)=''
	declare @companycode varchar(20)=''
	declare @errr nvarchar(1000)=''

		select @companycode = companycode from stb_userinfo
		where userid=@pProcessUserID

	DECLARE @MaterialDocLotInfo TABLE
	(
		IDX INT IDENTITY,
		MaterialDocDetailNo VARCHAR(20),
		MDLISeqNo INT,
		MaterialDocNo VARCHAR(20),
		LotNo VARCHAR(500),
		PackDate VARCHAR(12),                                               -- 추가
		LotID VARCHAR(100),                                                   -- 외주바코드 추가 (2020.04.04)
		RealPackDate VARCHAR(12) -- 이전 담당자가 제조일자 컬럼을 PackDate(유효일자)로 사용하여 구분
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
				CONVERT(VARCHAR(10), XMLData.LotAttr10, 121),                                            -- 추가  ( 주의 : 화면의 컬럼명 및 대소문자구분 으로 해줘야됨!!!)
				XMLData.LotID,
				XMLData.PackDate
		FROM
				OPENXML(@iDoc, @TableName, 2)
				WITH(
						MaterialDocDetailNo  VARCHAR(20),
						MDLISeqNo             INT,
						MaterialDocNo         VARCHAR(20),
						LotNo                     VARCHAR(500),
						LotAttr10                 VARCHAR(12),                                    -- 추가 ( 주의 : 화면의 컬럼명으로 해줘야됨!!!)
						LotID                     VARCHAR(100),
						PackDate VARCHAR(12)
					   ) XMLData

		-- 엑셀 붙여넣기 내용 추가
		INSERT @MaterialDocLotInfo
		SELECT
				XMLData.MaterialDocDetailNo,
				XMLData.MDLISeqNo,
				XMLData.MaterialDocNo,
				XMLData.LotNo,
				CONVERT(VARCHAR(10), XMLData.Lotattr10, 121),
				XMLData.LotID,
				XMLData.PackDate
		FROM
				OPENXML(@iDoc, @TableName2, 2)
				WITH(
						MaterialDocDetailNo VARCHAR(20),
						MDLISeqNo             INT,
						MaterialDocNo         VARCHAR(20),
						LotNo                     VARCHAR(500),
						LotAttr10                 VARCHAR(12),
						LotID					VARCHAR(100),
						PackDate VARCHAR(12)
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
	DECLARE @SourceCustomerCode            VARCHAR(100)
	DECLARE @LotIdParam            VARCHAR(100)
	DECLARE @RealPackDate VARCHAR(12)

	SELECT  TOP 1 
			 @MaterialDocNo = MaterialDocNo,
			 @LotIdParam = LotID 
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
	
		--Lấy nhà cung cấp
				select @SourceCustomerCode= mdi.SourceCustomerCode from 
			STB_MaterialdocLotInfo mdli with(nolock)
			left outer join STB_MaterialDocInfo mdi  with(nolock) on mdli.MaterialDocNo = mdi.MaterialDocNo
			where mdli.MaterialDocNo=@MaterialDocNo and mdli.LotID=@LotIdParam

		
			--End lấy nhà cung cấp
			

						--- Mr.tung 2023-11-21  cập nhật dữ liệu Ngay Thang SX của Vendor cho những Lót bị trống Ngay Thang SX
						UPDATE STB_MaterialDocLotInfo  
						 SET   LotAttr10 =  [dbo].[fn_VVT_getdatebyVendorLot_MergeCode](materialcode,LotNo,isnull(@SourceCustomerCode,''))
						where  (replace(isnull(LotAttr10,''),' ','')='' or ISDATE(LotAttr10)=0 or LotAttr10 = '1900-01-01') and isnull(LotNo,'')<>''
						and MaterialLocationCode not like 'PROD%'
						--ducnv add % : %VN_WH -> %VN_WH% by Mr.Cuong BG2 20260603
						and (MaterialLocationCode like '%VN_WH' or MaterialLocationCode like '%BG_WH' or MaterialLocationCode like '%HN_WH' or MaterialLocationCode LIKE '%BG2_WH')
						and MaterialDocNo=@MaterialDocNo
						
						UPDATE STB_MaterialLotInfo  
						 SET   LotAttr10 =  [dbo].[fn_VVT_getdatebyVendorLot_MergeCode](materialcode,LotNo,isnull(@SourceCustomerCode,''))  
						where   (replace(isnull(LotAttr10,''),' ','')='' or ISDATE(LotAttr10)=0 or LotAttr10 = '1900-01-01')
						and isnull(LotNo,'')<>''
						and MaterialLocationCode not like 'PROD%'
						--ducnv add % : %VN_WH -> %VN_WH% by Mr.Cuong BG2 20260603
						and (MaterialLocationCode like '%VN_WH' or MaterialLocationCode like '%BG_WH' or MaterialLocationCode like '%HN_WH' or MaterialLocationCode LIKE '%BG2_WH')
						--- Mr.tung 2023-11-21 
					

	SELECT @rowCnt = COUNT(1)
	 FROM @MaterialDocLotInfo
	WHILE @initNum <= @rowCnt
	
	
	 BEGIN
		
		SELECT
				@MaterialDocDetailNo = MDI.MaterialDocDetailNo,
				@MDLISeqNo = MDI.MDLISeqNo,
				@LotNo = MDI.LotNo,
				@PackDate = MDI.PackDate,                                                  -- 추가
				@RealPackDate = MDI.RealPackDate
		FROM
				@MaterialDocLotInfo MDI
		WHERE 1=1
		   AND IDX = @initNum
				
				
	-- 2020.06.20 추가사항                 
	--select CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  6, '20200101'), 121)), 121)
	-- select DATALENGTH(CONVERT(VARCHAR(10), CONVERT(VARCHAR(10),  '20200101'), 121))

	--IF DATALENGTH(@PackDate)  < 16 And DATALENGTH(@PackDate) > 2



	-- 이부분은 자동 제조일자가 들어가면 주석처리할것!
	 --IF DATALENGTH(CONVERT(VARCHAR(10), CONVERT(VARCHAR(10),  @PackDate), 121)) < 8 --Or @PackDate is not null Or DATALENGTH(CONVERT(VARCHAR(10), CONVERT(VARCHAR(10),  @PackDate), 121)) > 12
		--	BEGIN
		--		RAISERROR( '날짜 형태 Ex) 2022-06-16 형태로 입력하시기 바랍니다. %s', 16, 1, @PackDate)
		--		RETURN
		--	END



	-- select DATALENGTH(Lotattr10),  Lotattr10 from STB_MaterialDocLotInfo where MaterialDocNo in ( '200602000163', '200526000117')
	--select Lotattr10, * from STB_MaterialDocLotInfo where MaterialDocNo = '200602000163'
				
		UPDATE STB_MaterialDocLotInfo 
		     SET  LotNo = @LotNo
			     , ChangeDateTime = GETDATE()
			     , ChangeUserID = @pProcessUserID
				 , LotAttr10 =  @PackDate                                                        --- 제조일자 추가		
				 , PackDate = @RealPackDate
		WHERE 1=1
			AND MaterialDocDetailNo = @MaterialDocDetailNo 
			AND	MDLISeqNo = @MDLISeqNo
		

		 --SELECT LotNo, * FROM STB_MaterialDocLotInfo	 WHERE Lotid = 'ML20200403000004'         -- LotNo 변경 [자재입고 및 라벨발행]
   --      SELECT LotNo, * FROM STB_MaterialLotInfo      WHERE Lotid = 'ML20200403000004'         -- LotNo 변경[자재리스트] 

		SELECT @LotId = Lotid,
				 @materialcode = materialcode
		 FROM STB_MaterialDocLotInfo
		WHERE 1=1
			AND MaterialDocDetailNo = @MaterialDocDetailNo 
			AND	MDLISeqNo = @MDLISeqNo 

		
         UPDATE STB_MaterialLotInfo
		      SET LotNo = @LotNo
		        -- vanduc edited by Mrs.Van Oc 20260613 START
		          , LotAttr10 = @PackDate
		        -- END
		 WHERE  1=1
		    AND  Lotid = @LotId
			
			  --GR : 입고, GI : 출고

		SET @initNum = @initNum + 1
				

				
		--RAISERROR(@PackDate,16, 1)   

	if (@companycode = 'VVT')

	begin
				
					-- Mr.Tung add LotID for Vietnam Site  on 2023-sep-21
				declare @tmpLotNo varchar(100) =   case when @LotNo like @materialcode+'#%' then replace(@LotNo, left(@LotNo,len(@materialcode)+1),'')  
								when @LotNo like @materialcode+'%'  then replace(@LotNo, left(@LotNo,len(@materialcode)),''  )
								else @LotNo end

				if (@materialcode IN (
						'WRHI00-001', 
						'153_CHATPHUBM',
						'153_CHATPHUBM-01',
						'153_CHATPHUBM-02',
						'BEMP00-005',	-- Bac Giang 2
						--'BEASSY-002'	-- Bac Giang 2
						-- ducnv 2026-06-23: Thêm 16 mã nguyên phụ liệu đóng gói - không có vendor lot, nhập Đặc tính 10 bằng tay
						'OTCTN2',
						'INCTN1',
						'INCTN2',
						'INCTN4',
						'TTSB',
						'TPE',
						'FOAM2',
						'FOAM1',
						'FOAM3',
						'BDMD',
						'OTCTN3',
						'INCTN5',
						'DESICCANT',
						'OTCTN4',
						'INCTN7',
						'OTCTN5'
						)) set @tmpLotNo = @LotNo  -- update 2026-02-03 this material dont have vendor lot
				--RAISERROR(@SourceCustomerCode,16,1)
			    set @PackDate =  [dbo].[fn_VVT_getdatebyVendorLot_MergeCode](@materialcode,@tmpLotNo,isnull(@SourceCustomerCode,''))
					 --RAISERROR(@PackDate,16, 1)  
					 
				

				if(@PackDate is not null  )
					begin try 

					 if(replace(isnull(@LotNo,''),' ','')<>'')
						select convert(datetime,@PackDate,120)
					

						UPDATE STB_MaterialDocLotInfo 
						 SET   LotAttr10 =  @PackDate 						
						WHERE LotID=@LotId
						and  (replace(isnull(LotAttr10,''),' ','')='' or ISDATE(LotAttr10)=0 or LotAttr10 = '1900-01-01')
					end try
					begin catch
						set @errr=N'Không thể chuyển đổi mã Vendor Lot thành ngày tháng. Vui lòng kiểm tra lại: ' +@MaterialDocNo + '----'+@LotIdParam
						raiserror(@errr,16,1);
						return '';
					end catch

		
				end
				
				
			
					

--- 2021.06.11 추가 [Start]  -------------------------------------------------------------------------------------------------------->>
	IF (@PackDate IS NULL OR @PackDate = '')		--제조일자 입력하지 않은 경우만 자동 계산 처리, 제조일자 수기 입력하면 처리 안함
		BEGIN

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
										 When Substring(Lotno, 8, 1) in ('8','9')  And Substring(Lotno, 9, 1) = 'O' Then '201' + Substring(Lotno, 8, 1) + '-' + '10' + '-' + Substring(Lotno, 10, 2)
										 When Substring(Lotno, 8, 1) in ('8','9')  And Substring(Lotno, 9, 1) = 'N' Then '201' + Substring(Lotno, 8, 1) + '-' +  '11' + '-' + Substring(Lotno, 10, 2)
										 When Substring(Lotno, 8, 1) in ('8','9')  And Substring(Lotno, 9, 1) = 'D' Then '201' + Substring(Lotno, 8, 1) + '-' +  '12' + '-' + Substring(Lotno, 10, 2)
										 When Substring(Lotno, 8, 1) in ('8','9')  And Substring(Lotno, 9, 1) NOT IN ( 'O', 'N', 'D') Then '201' + Substring(Lotno, 8, 1) + '-' + '0' + Substring(Lotno, 9, 1) + '-' + Substring(Lotno, 10, 2)

										 When Substring(Lotno, 8, 1) Not in ('8','9')  And Substring(Lotno, 9, 1) = 'O' Then '202' + Substring(Lotno, 8, 1) + '-' + '10' + '-' + Substring(Lotno, 10, 2)
										 When Substring(Lotno, 8, 1) Not in ('8','9')  And Substring(Lotno, 9, 1) = 'N' Then '202' + Substring(Lotno, 8, 1) + '-' + '11' + '-' + Substring(Lotno, 10, 2)
										 When Substring(Lotno, 8, 1) Not in ('8','9')  And Substring(Lotno, 9, 1) = 'D' Then '202' + Substring(Lotno, 8, 1) + '-' + '12' + '-' + Substring(Lotno, 10, 2)
										 --When Substring(Lotno, 8, 1) Not in ('8','9')  And Substring(Lotno, 9, 1) NOT IN ( 'O', 'N', 'D') Then '201' + Substring(Lotno, 8, 1) + '-' + '0' + Substring(Lotno, 9, 1) + '-' + Substring(Lotno, 10, 2)
										 
										 -- Modified by Mr.Tung    on 27-Oct-2021    because  last WHEN wrong is 201 , changed to  202
										 When Substring(Lotno, 8, 1) Not in ('8','9')  And Substring(Lotno, 9, 1) NOT IN ( 'O', 'N', 'D') Then '202' + Substring(Lotno, 8, 1) + '-' + '0' + Substring(Lotno, 9, 1) + '-' + Substring(Lotno, 10, 2)
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
		 IF @LotAttr03 = '(주)무등'     

			BEGIN

				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 = Case When Lotno = '' Then ''
										when LotNo like 'P%' and LotNo like '%-%' then '20'+ SubString(Lotno, 12, 2) + '-' + Substring(Lotno, 14, 2) + '-' +Substring(Lotno, 16, 2) --add by Mr.Tung on 11-Sep-2021 
										When Len(LotNo) >= 29 Then '20' + SubString(Lotno, 20, 2) + 
										 '-' + SubString(Lotno, 22, 2) + '-' + SubString(Lotno, 24, 2)
										 When Len(LotNo) < 14 Then '20' + SubString(Lotno, 1, 2) + 
										 '-' + SubString(Lotno, 3, 2) + '-' + SubString(Lotno, 5, 2)
										Else  '' End
				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )

			END

		-- 4.	
		 IF @LotAttr03 = '리더스월드'     

			BEGIN

				UPDATE STB_MaterialDocLotInfo 
					-- SET LotAttr10 =  Case When Lotno = '' Then '' Else '20' + SubString(Lotno, 20, 2) + '-' + SubString(Lotno, 22, 2) + '-' + SubString(Lotno, 24, 2) End
					SET	LotAttr10 =  Case When Lotno = '' or len(lotno) < 14 Then ''
                    Else 
                     '202' + case when left(lotno,1) in ('A','B') then SUBSTRING(lotno,2,1) end  -- YEAR
                     + '-' + case when SubString(Lotno, 3, 1) < 'A' then '0'+ SubString(Lotno, 3, 1) --MONTH
                                 else replace(replace(replace(SubString(Lotno, 3, 1),'A','10'),'B','11'),'C','12') end --MONTH
                     + '-' + SubString(Lotno, 4, 2)  --DAY                                     
                     End 


				WHERE 1=1
				  And ( Lotno = @LotNo  Or LotID = @LotID )
				  And LotNo NOT LIKE 'H2%'


			END

		--5. 인터컴
			 IF @LotAttr03 = 'INTERCOMM. COMPANY CO, LTD.'   

			BEGIN

				UPDATE STB_MaterialDocLotInfo 
					-- SET LotAttr10 =  Case When Lotno = '' Then '' Else '20' + Left(Lotno, 2) + '-' + Substring(Lotno, 3, 2) + '-' + Substring(Lotno, 5, 2) End
					  SET LotAttr10 = Case When Lotno = '' or len(lotno)<8 or len(lotno)>20 or (lotno not like '%H%' and lotno not like '%N%' and lotno not like '%U%' ) Then ''  
											Else 
											 case when left(lotno,1) = '9' then  '2019' else '202' + left(lotno,1) end  -- YEAR
											 + '-' + case when SubString(Lotno, 2, 1) < 'A' then '0'+ SubString(Lotno, 2, 1) --MONTH
													 else replace(replace(replace(SubString(Lotno, 2, 1),'X','10'),'Y','11'),'Z','12') end --MONTH
											 + '-' + SubString(Lotno, 3, 2)  --DAY                                     
											 End 
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
					 SET LotAttr10 =  Case When Lotno = '' Then '' Else dbo.fnGetMondayByWeekNo ( ('20' + Left(Lotno, 2))  , Substring(Lotno, 3, 2), Substring(Lotno, 5, 1) )   End     -- 4가 아니라 5
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


		-- 9. 리더스월드- 전해액 (xxx)
		-- 4와 상충됨. 수정함. 2021.09.10 by Jackaroe

		--IF @LotAttr03 = '리더스월드'

		--BEGIN
		--	--UPDATE STB_MaterialDocLotInfo 
		--	--	 SET LotAttr10 =  Case When Lotno = '' Then '' Else '20' + SubString(Lotno, 3, 2) + '-' + Substring(Lotno, 5, 2) + '-' +Substring(Lotno, 7, 2)  End 
		--	--where 1=1
		--	--   And ( Lotno = @LotNo  Or LotID = @LotID )
		--
		--
		--		UPDATE STB_MaterialDocLotInfo 
		--		-- SET LotAttr10 =  Case When Lotno = '' Then '' Else '20' + SubString(Lotno, 2, 2) + '-' + Substring(Lotno, 4, 2) + '-' +Substring(Lotno, 6, 2)  End
		--		SET LotAttr10 = Case When Lotno = '' or LotNo not like 'H2%' or len(LotNo)<8 Then '' 
        --        Else 
        --            '20' + SUBSTRING(Lotno,3,2)  -- YEAR
        --            + '-' + SUBSTRING(Lotno,5,2) --MONTH
        --            + '-' + SubString(Lotno, 7, 2)  --DAY                                     
        --            End 
		--		WHERE 1=1
		--		And ( Lotno = @LotNo  Or LotID = @LotID )
		--END

		IF @LotAttr03 = '리더스월드'
		BEGIN
				UPDATE STB_MaterialDocLotInfo 
				SET LotAttr10 = Case When Lotno = '' or len(LotNo) < 8 Then '' 
								 Else 
									'20' + SUBSTRING(LotNo,3,2)  -- YEAR
									+ '-' + SUBSTRING(LotNo,5,2) --MONTH
									+ '-' + SubString(LotNo, 7, 2)  --DAY                                     
							End 
				WHERE 1=1
				And ( Lotno = @LotNo  Or LotID = @LotID )
				And LotNo LIKE 'H2%'
		END

			 -- 10. 쿠라레이
		 IF @LotAttr03 = 'Kuraray Co.,Ltd.'

			BEGIN
				UPDATE STB_MaterialDocLotInfo 
					-- SET LotAttr10 =  Case When Lotno = '' Then '' Else '20' + SubString(Lotno, 2, 2) + '-' + Substring(Lotno, 4, 2) + '-' +Substring(Lotno, 6, 2)  End
				SET LotAttr10 = Case When Lotno = '' or LotNo not like 'K%' or len(LotNo)<7 Then '' 
						Else 
						'20' + SUBSTRING(Lotno,2,2)  -- YEAR
						+ '-' + SUBSTRING(Lotno,4,2) --MONTH
						+ '-' + SubString(Lotno, 6, 2)  --DAY								 
						End 
				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )
			END

			 -- 11. 파워카본테크놀로지 
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

			 -- 12. 하남전자
		 IF @LotAttr03 = '(주)하남전자'

			BEGIN
				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 = Case When Lotno = '' Then '' 
									when LotNo like 'P%' and LotNo like '%-%' then SubString(Lotno, 5, 4) + '-' + Substring(Lotno, 9, 2) + '-' +Substring(Lotno, 11, 2) --add by Mr.Tung on 10-Sep-2021
									Else '20' + SubString(Lotno, 10, 2) + '-' + Substring(Lotno, 12, 2) + '-' +Substring(Lotno, 14, 2)  End 
				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )
			END

				 -- 13. 엔켐
		 IF @LotAttr03 = '주식회사 엔켐'

			BEGIN
				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 =  Case When Lotno = '' or SUBSTRING(lotno,2,1)='-' or SUBSTRING(lotno,3,1)='-' Then '' 
											Else 
											 '20' + SUBSTRING(Lotno,3,2)  -- YEAR
											 + '-' + SUBSTRING(Lotno,5,2) --MONTH
											 + '-' + SubString(Lotno, 7, 2)  --DAY                                     
											 End

				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )
			END

				
				-- 14. Mr.Tung add on 2021-12-30
		 IF @LotAttr03 = '주식회사 라투스'

			BEGIN
				UPDATE STB_MaterialDocLotInfo 
					 SET LotAttr10 =  Case When Lotno = '' or len(Lotno)<11 Then '' 
											Else 
											 SUBSTRING(Lotno,4,4)  -- YEAR
											 + '-' + SUBSTRING(Lotno,8,2) --MONTH
											 + '-' + SubString(Lotno, 10, 2)  --DAY                                     
											 End

				WHERE 1=1
				   And ( Lotno = @LotNo  Or LotID = @LotID )
			END
			
			
			
		END

--- 2021.06.11 추가 [End]  -------------------------------------------------------------------------------------------------------->>



	END

END
