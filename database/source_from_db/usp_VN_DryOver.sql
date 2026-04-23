CREATE proc [dbo].[usp_VN_DryOver]
@pProcessLanguage VARCHAR(20),
@pBarCode NVARCHAR(100) = NULL,
@pDryMachines NVARCHAR(50) = NULL
AS
BEGIN
		DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
		DECLARE @BarCode VARCHAR(100) = CASE WHEN ISNULL(@pBarCode,'') = '' THEN '%' ELSE @pBarCode END
		DECLARE @MaterialCodes NVARCHAR(50)
		DECLARE @MaterialNames NVARCHAR(100)
		DECLARE @BarCodes NVARCHAR(100)
		DECLARE @Bar NVARCHAR(100)
		DECLARE @TotalMinutes INT
		DECLARE @QTY FLOAT
		DECLARE @OvenOutDate DATETIME
		DECLARE @OvenInDate DATETIME
		DECLARE @Dryovers NVARCHAR(50)
		DECLARE @StatusOut NVARCHAR(30)
		DECLARE @StatusIn NVARCHAR(30)
		DECLARE @Stg NVARCHAR(50)
		declare @ccount INT=0;
		declare @OvenInputDate datetime;
			   


					DECLARE @LotNonew1 VARCHAR(20) = ''
					DECLARE @LotNonew2 VARCHAR(20) = ''
					DECLARE @LotNonew3 VARCHAR(20) = ''
					DECLARE @LotNonew4 VARCHAR(20) = ''
					DECLARE @LotNonew5 VARCHAR(20) = ''
					DECLARE @LotNonew6 VARCHAR(20) = ''

					
					select @LotNonew1 = NewBarcode
					from STB_LotChangeMaterialHistory  WITH(NOLOCK)
					where OldBarcode=@BarCode 
	
					select @LotNonew2 = NewBarcode
					from STB_LotChangeMaterialHistory  WITH(NOLOCK)
					where OldBarcode=@LotNonew1 

					select @LotNonew3 = NewBarcode
					from STB_LotChangeMaterialHistory  WITH(NOLOCK)
					where OldBarcode=@LotNonew2 

					select @LotNonew4 = NewBarcode
					from STB_LotChangeMaterialHistory  WITH(NOLOCK)
					where OldBarcode=@LotNonew3 

					select @LotNonew5 = NewBarcode
					from STB_LotChangeMaterialHistory  WITH(NOLOCK)
					where OldBarcode=@LotNonew4 

					select @LotNonew6 = NewBarcode
					from STB_LotChangeMaterialHistory  WITH(NOLOCK)
					where OldBarcode=@LotNonew5 	

					select @BarCode = Barcode from stb_setinfo WITH(NOLOCK) where 
					Barcode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)
	
		


	--------	 --begin mr.tung audit hela 2022-09-28
	--------	 declare @count int=0;
	--------Declare @barcode1 varchar(20)=replace(@Barcode,'VV','VJ')
	--------Declare @barcode2 varchar(20)=replace(@Barcode,'VJ','VV')

	--------select @count=count(*) from STB_VN_DRYOVER
	--------where Barcode in (@Barcode,@barcode1,@barcode2)


	--------if(@count>0)begin
	--------	select top 1 @Barcode=Barcode from STB_VN_DRYOVER
	--------	where Barcode in (@Barcode,@barcode1,@barcode2)
	--------	order by barcode,StatusOut desc 
	--------end
 ----------begin mr.tung audit hela 2022-09-28


		
		/* ------------------Bắt đầu kiểm tra xem công đoạn V-22 đã được nhập chưa-----------------*/

		SELECT
				@Stg = routecode
		FROM 
			    STB_ProdRouteHist WITH(NOLOCK)
		WHERE 1=1 
				AND
				routecode='V-22' OR routecode='V-22_BG'
				AND
				controlno= (select controlno 
							from stb_setinfo WITH(NOLOCK) 
							where barcode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)  
							)



		/* ------------------Kết thúc  kiểm tra xem công đoạn V-22 đã được nhập chưa-----------------*/



		/*------------------------------Kiểm tra công đoạn V-22 nếu là Null thì đưa ra yêu cầu người dùng phải nhập công đoạn V-22-------------------------*/
		IF @Stg IS NULL
		
		BEGIN
				 DECLARE @NotEnoughStockError NVARCHAR(MAX)
					EXEC usp_GetSystemStringResource	@ProcessLanguage,
														N'Bạn vui lòng nhập công đoạn V-22 trước khi ^In tem vào^',
														@NotEnoughStockError OUTPUT

					RAISERROR(@NotEnoughStockError,16,1)
					RETURN		
		END

		/*-------------------------------------------------------------------Kết thúc việc kiểm tra V-22 có Null hay không nếu không Null thì làm tiếp tục kiểm tra cho in------------------------------------------------------------------------------*/
		ELSE
				BEGIN
				SELECT
				@MaterialCodes=T1.MaterialCode,
				@MaterialNames=T2.MaterialName,
				@BarCodes=T1.Barcode,
				@QTY=T1.ProdQty
		FROM
				STB_SetInfo T1 WITH(NOLOCK)
				 LEFT OUTER JOIN STB_MaterialMaster T2	 ON T1.MaterialCode = T2.MaterialCode
		WHERE
				T1.Barcode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)

		SELECT 
				@Dryovers=DryMachines,
				@Bar=BarCode,
				@StatusOut=StatusOut,
				@OvenInputDate=OvenInputDate
				
		FROM 
				STB_VN_DRYOVER WITH(NOLOCK)
		WHERE 
				BarCode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)

		IF @Bar IS NULL AND @StatusOut IS NULL

			BEGIN
					INSERT INTO STB_VN_DRYOVER
					(
						MaterialCode,
						MaterialName,
						BarCode,
						DryMachines,
						QTY,
						StatusIn,
						OvenInputDate,
						CreateDateTime
					)
					VALUES
					(
						@MaterialCodes,
						@MaterialNames,
						@BarCode,
						@pDryMachines,
						@QTY,
						N'Vào',
						DATEADD(HH, -2, GETDATE()),
						DATEADD(HH, -2, GETDATE())
					)

					UPDATE STB_SetInfo

					SET 
								SIExtText06= @pDryMachines,
								SIExtText02= CONVERT(nvarchar,GETDATE(),120)
					WHERE 
							Barcode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)
			END
	
		if(datediff(hour,@OvenInputDate,getdate()) > 9 )  --nếu thời gian sấy hơn 10 tiếng , thì mới tính giờ tem RA
		IF(@Bar IS NOT NULL AND @StatusOut IS NULL)

			BEGIN
							
					UPDATE STB_VN_DRYOVER

					SET
						OvenOutDate = DATEADD(HH, -2, GETDATE()), --lệch 2 giờ, sửa ngày 4.4.2023 yêu cầu của chị Kiều Nguyệt Nga
						StatusOut = N'Ra',
						ChangeDateTime = DATEADD(HH, -2, GETDATE()) --lệch 2 giờ, sửa ngày 4.4.2023 yêu cầu của chị Kiều Nguyệt Nga
						
					WHERE 
						 BarCode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)


						 SELECT
								 @TotalMinutes = DATEDIFF(MINUTE,OvenInputDate,OvenOutDate)
						 FROM
								 STB_VN_DRYOVER
						 WHERE
								 BarCode=@BarCode


							
			UPDATE STB_VN_DRYOVER

			SET
						TotalMinutes=@TotalMinutes,
						TotalHouse= @TotalMinutes / 60

			WHERE 

						 BarCode in  (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)


					UPDATE STB_SetInfo

					SET 
								
								SIExtText03=CONVERT(nvarchar,GETDATE(),120)
					WHERE 
							Barcode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)

			END

		IF(@BarCode IS NULL)
			BEGIN
					PRINT 'Do not show anything'
			END
	    ELSE
			BEGIN

			SELECT
					MaterialCode,
				    MaterialName,
					BarCode ,
				    DryMachines,
				    Qty,
					StatusIn,
					convert(varchar(10),OvenInputDate,120)  AS DateIn,     -- lấy Varchar ngày tháng chống trừ 2 tiếng ở View, Mr.Tung 2023-May-20
					RIGHT(convert(varchar(19),OvenInputDate,120) , 8) AS TimeIn,
					StatusOut,
					convert(varchar(10),OvenOutDate,120) AS DateOut,     -- lấy Varchar ngày tháng chống trừ 2 tiếng ở View, Mr.Tung 2023-May-20
					right(convert(varchar(19),OvenOutDate,120) , 8) AS TimeOuts,
					TotalMinutes,
					case 
						when isnull(StatusOut,'' )='' then 'Report'
						when StatusOut=N'Ra' and ( isnull(Pressure,0)=0 or 
						isnull(DryTemperature,0)=0 or
						isnull(OutTemperature,0)=0) 
						then '' 
						else 'Report' 
					end
					AS CommandType,

					TotalHouse,
					 Pressure, 
					 Unit,
                     DryTemperature, 
					 OutTemperature,
					 
						CASE 

							WHEN   TotalHouse = 12  THEN N'Đảm bảo tiêu chuẩn sấy'
							WHEN   TotalHouse > 12  THEN  N'Thời gian sấy vượt qua tiêu chuẩn'
							WHEN   TotalHouse < 12  THEN N'Thời gian nhỏ hơn tiêu chuẩn sấy'
							
							ELSE N'Chưa dõ tiêu chuẩn'

					END AS Result 
				

		 FROM
					STB_VN_DRYOVER WITH(NOLOCK)

		 WHERE 
				
							(BarCode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6) )
			END
				END
END


-- select * from STB_VN_DRYOVER
-- select top(1000) * from STB_SetInfo where Barcode= 'VJJT013R015609'
-- VJHR113R033509
-- exec usp_VN_DryOver 'VJJT013R015609','Dryoven_02'
-- delete STB_VN_DRYOVER

-- 
-- SELECT DATEDIFF(minute,OvenOutDate,OvenInputDate)
--FROM STB_VN_DRYOVER
--where Barcode= 'VJJT013R015609'

--		SELECT DATEDIFF(OvenOutDate,OvenInputDate) FROM STB_VN_DRYOVER

		--- select * from STB_VN_DRYOVER
		--2020-07-10 23:00:23.527
		--2020-07-10 22:58:00.207
		--2020-07-10 22:58:00.207
		--UPDATE STB_VN_DRYOVER
		--SET 
		--OvenInputDate='2020-07-13 20:40:07.780'
		--WHERE BarCode='VJJT013R015609'


		--	UPDATE STB_VN_DRYOVER
		--SET 
		--TotalHouse=11
		--WHERE BarCode='VJJL182R715518'

--DECLARE @startdate datetime2
--SET @startdate = '2007-05-05 12:10:09.3312722';
--DECLARE @enddate datetime2 = '2007-05-04 12:10:09.3312722'; 
--SELECT DATEDIFF(MINUTE, @enddate, @startdate);


--SELECT sum((datediff(minute,OvenOutDate,OvenInputDate)) AS TotalInstruct
--FROM STB_VN_DRYOVER

--select * from STB_VN_DRYOVER
--where BarCode='VVKP243R010512'

--delete STB_VN_DRYOVER
--where BarCode='VVKP243R010512'
 --select top(1000) * from STB_SetInfo order by CreateDateTime desc

 --select  DATEADD(HH, -2, GETDATE())

 --SELECT * FROM STB_ProdRouteHist WHERE WorkCenterCode  ='VVT_f2'