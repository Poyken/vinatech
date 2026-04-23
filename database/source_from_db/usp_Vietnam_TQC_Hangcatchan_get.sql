-- =============================================
-- Author:		Mr.Duy
-- Create date: Hàng cắt chân
-- Description:	2024-03-07
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_TQC_Hangcatchan_get]
@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pInspectionItems nvarchar(200)  = NULL,
	@pSampleQty int = NULL,
	@pLSL numeric(20, 5) = NULL,
	@pUSL numeric(20, 5) = NULL,
	@pFirst numeric(20, 5) = NULL,
	@pMiddle numeric(20, 5) = NULL,
	@pLast numeric(20, 5) = NULL,
	@pResult varchar(50) = NULL,
	@pRemark nvarchar(max) = NULL,
	@pCreateDateTime datetime = NULL,
	@pCreateUserId varchar(50) = NULL,
	@pChangeDateTime datetime = NULL,
	@pChangeUserId varchar(50) = NULL,
	@pLotNo varchar(20) = NULL,
	@pFromDate datetime = NULL,
	@pToDate datetime = NULL,
	@pisUID varchar(20)=NULL
AS
BEGIN
	SET NOCOUNT ON;
	declare @count INT =0
	declare @SizeCode varchar(20)=''

	DECLARE @LotNo VARCHAR(20) = ''
	DECLARE @LotNonew1 VARCHAR(20) = ''
	DECLARE @LotNonew2 VARCHAR(20) = ''
	DECLARE @LotNonew3 VARCHAR(20) = ''
	DECLARE @LotNonew4 VARCHAR(20) = ''
	DECLARE @LotNonew5 VARCHAR(20) = ''
	DECLARE @LotNonew6 VARCHAR(20) = ''

	DECLARE @MaterialName VARCHAR(50) = ''	
 --raiserror (@plotno,16,1)	
--return


	if (@pLotNo is null or @pLotNo='')
		 begin

			declare @FromDate varchar(19) = convert(varchar(10),@pFromDate,120) + ' 10:30:00'
			declare @Todate varchar(19) = convert(varchar(10),dateadd(DAY,1,@pTodate),120) + ' 10:30:00'
		
				--SELECT ttv.*, 
				--replace(replace(replace(vbt.MachineName,'Taping 3','Taping ￡3'),'Taping 2','Taping ￡2'),'Taping 1','Taping ￡1') as MachineName
			 -- FROM SmartFactoryV2.dbo.Stb_TQC_Tapping_VVT ttv with(nolock)
			 -- left outer join STB_VN_BENDING_TAPPING  vbt with(nolock) on ttv.LotNo = vbt.LOTNO
			 -- where ttv.CreateDateTime between @FromDate and @ToDate
	
			 select distinct ttv.LotNo,
			 
			 --max(ttv.Result) as Result,
			 sum(case when ttv.Result='OK' then 1 else 0 end) as  Result,
			 max(case  when   (datepart(hour, ttv.CreateDateTime)>10)     or    (datepart(hour, ttv.CreateDateTime)=10 and datepart(minute, ttv.CreateDateTime)>30)     
				then     convert(varchar(10),ttv.CreateDateTime,120)    
				else    convert(varchar(10),dateadd(day, -1,  ttv.CreateDateTime),120)       
				end )    as  CreateDateTime ,

			 replace(replace(replace(max(vbt.MachineName),'Taping 3','Taping ￡3'),'Taping 2','Taping ￡2'),'Taping 1','Taping ￡1') as MachineName
			  FROM SmartFactoryV2.dbo.Stb_TQC_Tapping_VVT ttv with(nolock)
			   	left join STB_VN_BENDING_TAPPING vbt on ttv.LotNo = vbt.LOTNO
			  where vbt.TYPESS='Cutting' and ttv.CreateDateTime between @FromDate and @ToDate  
			  			  /* outer apply (
			   select top 1 * from STB_VN_BENDING_TAPPING   with(nolock) 
			   where LotNo = ttv.lotno
			   and LotNo in (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6) 
			   and TYPESS='Cutting'
					  ) vbt 
			  where ttv.CreateDateTime between @FromDate and @ToDate 
			*/
			  group by ttv.LotNo--,vbt.MachineName
			  order by max(case  when   (datepart(hour, ttv.CreateDateTime)>10)     or    (datepart(hour, ttv.CreateDateTime)=10 and datepart(minute, ttv.CreateDateTime)>30)     
					then     convert(varchar(10),ttv.CreateDateTime,120)    
					else    convert(varchar(10),dateadd(day, -1,  ttv.CreateDateTime),120)       
					end )  
					--raiserror ('123123',16,1)	
			  return
		 end
	


	select @LotNonew1 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@pLotNo 
	
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



	  SELECT @count = count(*)
	  FROM SmartFactoryV2.dbo.Stb_TQC_Tapping_VVT with(nolock)
	  where lotno  in (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)


	 --raiserror (@pisUID,16,1)	
	if (@count>0 and @pisUID is not null and  @pisUID <>'' )
		--raiserror (@pisUID,16,1)	
		begin
			UPDATE [dbo].[Stb_TQC_Tapping_VVT]
			   SET 
				[InspectionItems] = isnull(@pInspectionItems,InspectionItems), -- remove comment following Mr.Bach's request
				  [SampleQty] = isnull(@pSampleQty,SampleQty)
				  ,[LSL] = isnull(@pLSL,LSL)
				  ,[USL] = isnull(@pUSL,USL)
				  ,[First] = isnull(@pFirst,[First])
				  ,[Middle] = isnull(@pMiddle,Middle)
				  ,[Last] = isnull(@pLast,[Last])
				  ,[Result] = isnull(@pResult,Result)
				  ,[Remark] = isnull(@pRemark,Remark)
				  ,[ChangeDateTime] = getdate()
				  ,[ChangeUserId] = isnull(@pProcessUserID,ChangeUserId)
			 WHERE lotno  in (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)
			 and [InspectionItems]=@pInspectionItems
			 
			 return
		end




	  if (@count=0 AND @pSampleQty is not null and @pSampleQty>0 )
	  begin

	  	SELECT @SizeCode = CASE WHEN MBISizeW <13 THEN 'Small'
										WHEN MBISizeW >= 13 and MBISizeW <=18 THEN 'Middle'
										WHEN MBISizeW >= 22 THEN 'Large'
										ELSE NULL END
		FROM STB_ModelBasicInfo with(nolock) 
		WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo with(nolock)  
							WHERE Barcode  in (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6))
		
		select @LotNo = Barcode from STB_SetInfo with(nolock)   where Barcode  in (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)
		
		if (@LotNo is null or @LotNo='')
		begin
			select @LotNo = @pLotNo
		end

		--Mr.Duy lấy tên model để chia các trường hợp có giá trị khác nhau
		/*select @MaterialName = materialname 
		from STB_MaterialMaster with(nolock) 
		where materialcode = (select materialcode from STB_SetInfo  with(nolock) where barcode=@LotNo)
		*/
		select  @MaterialName = CODEPRODUCTION from STB_VN_BENDING_TAPPING where lotno=@LotNo
		

		---end 

		select @count=6
		while @count>0
			begin
				SET IDENTITY_INSERT dbo.Stb_TQC_Tapping_VVT OFF;  
				INSERT INTO dbo.Stb_TQC_Tapping_VVT
					   (InspectionItems
					   ,SampleQty
					   ,LSL
					   ,USL
					   ,First
					   ,Middle
					   ,Last
					   ,Result
					   ,Remark
					   ,CreateDateTime
					   ,CreateUserId
					   ,ChangeDateTime
					   ,ChangeUserId
					   ,LotNo
					   ,ModelName)
				 VALUES
						(case  when  @count=6 then N'Kiểm tra ngoại quan' 
						 when  @count=5 then N'Kiểm tra kích thước D' 
						 when  @count=4 then N'Kiểm tra kích thước d.' 
						 when  @count=3 then N'Kiểm tra kích thước P' 
						 when  @count=2 then N'Kiểm tra kích thước M(+)' 
						 when  @count=1 then N'Kiểm tra kích thước M(-)' 
						else NULL end
						,case 
						 when  @count=6 then 20 
						 when  @count=5 then 3 
						 when  @count=4 then 3 
						 when  @count=3 then 3 
						 when  @count=2 then 3 
						 when  @count=1 then 3 
						else NULL end

						,case
						when  @count=6 then NULL  
						when  @count=5 then
							case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0335QG-C035')
								then 8.0
								when @MaterialName in ('WEC3R0106QD-C040','WEC3R0156QG–C035')
								then 12.5
								when @MaterialName in ('WEC3R0606QG-C050')
								then 18.0
								when @MaterialName in ('WEC3R0256QG–C035')
								then 16.0
								when @MaterialName in ('WEC3R0126HC–C035')
								then 10.0
						    else
							 Null
							end
						 when  @count=4 then 
						 	case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0335QG-C035','WEC3R0106QD-C040','WEC3R0256QG–C035','WEC3R0126HC–C035')
								then 0.5
								when @MaterialName in ('WEC3R0606QG-C050','WEC3R0256QG–C035')
								then 0.7
						    else
							 Null
							end
						 when  @count=3 then 
							 case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0335QG-C035')
								then 3.0
								when @MaterialName in ('WEC3R0106QD-C040','WEC3R0126HC–C035','WEC3R0156QG–C035')
								then 4.5
								when @MaterialName in ('WEC3R0606QG-C050','WEC3R0256QG–C035')
								then 7.0
							 else
								 Null
							 end
						 when  @count=2 then 
							case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0126HC–C035','WEC3R0256QG–C035','WEC3R0156QG–C035')
								then 3.0
								when @MaterialName in ('WEC3R0335QG-C035')
								then 3.2
								when @MaterialName in ('WEC3R0106QD-C040')
								then 3.5
								when @MaterialName in ('WEC3R0606QG-C050')
								then 4.5
							else
								 Null
							end
						 when  @count=1 then 
							case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0126HC–C035','WEC3R0256QG–C035','WEC3R0156QG–C035')
								then 3.0
								when @MaterialName in ('WEC3R0335QG-C035')
								then 3.2
								when @MaterialName in ('WEC3R0106QD-C040')
								then 3.5
								when @MaterialName in ('WEC3R0606QG-C050')
								then 4.5
							else
								 Null
							end
						else NULL end

						,case
						when  @count=6 then NULL
						 when @count=5 then 
							case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0335QG-C035')
								then 8.0
								when @MaterialName in ('WEC3R0106QD-C040','WEC3R0156QG–C035')
								then 13.5
								when @MaterialName in ('WEC3R0606QG-C050')
								then 19.0
								when @MaterialName in ('WEC3R0256QG–C035')
								then 17.0
								when @MaterialName in ('WEC3R0126HC–C035')
								then 11.0
						    else
							 Null
							end
						 when  @count=4 then 
							case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0335QG-C035','WEC3R0106QD-C040','WEC3R0256QG–C035','WEC3R0126HC–C035')
								then 0.7
								when @MaterialName in ('WEC3R0606QG-C050','WEC3R0256QG–C035')
								then 0.9
						    else
							 Null
							end
						 when  @count=3 then 
							case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0335QG-C035')
								then 4.0
								when @MaterialName in ('WEC3R0106QD-C040','WEC3R0126HC–C035','WEC3R0156QG–C035')
								then 5.5
								when @MaterialName in ('WEC3R0606QG-C050','WEC3R0256QG–C035')
								then 8.0
							else
								 Null
							end
						 when  @count=2 then 
						   case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0126HC–C035','WEC3R0256QG–C035','WEC3R0156QG–C035')
								then 4.0
								when @MaterialName in ('WEC3R0335QG-C035')
								then 3.8
								when @MaterialName in ('WEC3R0106QD-C040')
								then 4.5
								when @MaterialName in ('WEC3R0606QG-C050')
								then 5.5
							else
								 Null
							end 
						 when  @count=1 then 
						   case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0126HC–C035','WEC3R0256QG–C035','WEC3R0156QG–C035')
								then 4.0
								when @MaterialName in ('WEC3R0335QG-C035')
								then 3.8
								when @MaterialName in ('WEC3R0106QD-C040')
								then 4.5
								when @MaterialName in ('WEC3R0606QG-C050')
								then 5.5
							else
								 Null
								end 
						else NULL end

					   ,NULL
					   ,NULL
					   ,NULL
					   ,'None'
					   ,NULL
					   ,getdate()
					   ,@pProcessUserID
					   ,NULL
					   ,NULL
					   ,@LotNo
					   ,	(	select materialname 
								from STB_MaterialMaster with(nolock) 
								where materialcode = (select materialcode from STB_SetInfo  with(nolock) where barcode=@LotNo) 
							)
						)

					SET IDENTITY_INSERT dbo.Stb_TQC_Tapping_VVT ON;  
				
				SELECT @count = @count - 1
			end
		end


		update Stb_TQC_Tapping_VVT
		set LSL =	case when InspectionItems=N'Kiểm tra ngoại quan' then NULL
						 when  InspectionItems=N'Kiểm tra kích thước D'  and @Sizecode='Small' and @count=5 then 
							case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0335QG-C035')
								then 8.0
								when @MaterialName in ('WEC3R0106QD-C040','WEC3R0156QG–C035')
								then 12.5
								when @MaterialName in ('WEC3R0606QG-C050')
								then 18.0
								when @MaterialName in ('WEC3R0256QG–C035')
								then 16.0
								when @MaterialName in ('WEC3R0126HC–C035')
								then 10.0
								else
								 Null
								end
						 when  InspectionItems=N'Kiểm tra kích thước d.' and @Sizecode='Small' and @count=4 then 
							case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0335QG-C035','WEC3R0106QD-C040','WEC3R0256QG–C035','WEC3R0126HC–C035')
								then 0.5
								when @MaterialName in ('WEC3R0606QG-C050','WEC3R0256QG–C035')
								then 0.7
								else
								 Null
								end 
						 when  InspectionItems=N'Kiểm tra kích thước P' and @Sizecode='Small' and @count=3 then 
							case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0335QG-C035')
								then 3.0
								when @MaterialName in ('WEC3R0106QD-C040','WEC3R0126HC–C035','WEC3R0156QG–C035')
								then 4.5
								when @MaterialName in ('WEC3R0606QG-C050','WEC3R0256QG–C035')
								then 7.0
								else
								 Null
								end
						 when  InspectionItems=N'Kiểm tra kích thước M(+)' and @Sizecode<>'Small' and @count=2 then   
							case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0126HC–C035','WEC3R0256QG–C035','WEC3R0156QG–C035')
								then 3.0
								when @MaterialName in ('WEC3R0335QG-C035')
								then 3.2
								when @MaterialName in ('WEC3R0106QD-C040')
								then 3.5
								when @MaterialName in ('WEC3R0606QG-C050')
								then 4.5
								else
								 Null
								end 
						 when  InspectionItems=N'Kiểm tra kích thước M(-)' and @Sizecode<>'Small' and @count=1 then  
						  case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0126HC–C035','WEC3R0256QG–C035','WEC3R0156QG–C035')
								then 3.0
								when @MaterialName in ('WEC3R0335QG-C035')
								then 3.2
								when @MaterialName in ('WEC3R0106QD-C040')
								then 3.5
								when @MaterialName in ('WEC3R0606QG-C050')
								then 4.5
								else
								 Null
								end
						else NULL end
						
			,USL =case when InspectionItems=N'Kiểm tra ngoại quan' then NULL
						 when  InspectionItems=N'Kiểm tra kích thước D'  and @Sizecode='Small' and @count=5 then 
						 	case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0335QG-C035')
								then 8.0
								when @MaterialName in ('WEC3R0106QD-C040','WEC3R0156QG–C035')
								then 13.5
								when @MaterialName in ('WEC3R0606QG-C050')
								then 19.0
								when @MaterialName in ('WEC3R0256QG–C035')
								then 17.0
								when @MaterialName in ('WEC3R0126HC–C035')
								then 11.0
								else
								 Null
								end 
						 when  InspectionItems=N'Kiểm tra kích thước d.' and @Sizecode='Small' and @count=4 then
							 case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0335QG-C035','WEC3R0106QD-C040','WEC3R0256QG–C035','WEC3R0126HC–C035')
								then 0.7
								when @MaterialName in ('WEC3R0606QG-C050','WEC3R0256QG–C035')
								then 0.9
								else
								 Null
								end
						 when  InspectionItems=N'Kiểm tra kích thước P' and @Sizecode='Small' and @count=3 then 
							case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0335QG-C035')
								then 4.0
								when @MaterialName in ('WEC3R0106QD-C040','WEC3R0126HC–C035','WEC3R0156QG–C035')
								then 5.5
								when @MaterialName in ('WEC3R0606QG-C050','WEC3R0256QG–C035')
								then 8.0
								else
								 Null
								end
						 when  InspectionItems=N'Kiểm tra kích thước M(+)' and @Sizecode<>'Small' and @count=2 then   
							case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0126HC–C035','WEC3R0256QG–C035','WEC3R0156QG–C035')
								then 4.0
								when @MaterialName in ('WEC3R0335QG-C035')
								then 3.8
								when @MaterialName in ('WEC3R0106QD-C040')
								then 4.5
								when @MaterialName in ('WEC3R0606QG-C050')
								then 5.5
								else
								 Null
								end 
						 when  InspectionItems=N'Kiểm tra kích thước M(-)' and @Sizecode<>'Small' and @count=1 then   
							 case
								when @MaterialName in ('VEC3R0105QG-C035','WEC3R0126HC–C035','WEC3R0256QG–C035','WEC3R0156QG–C035')
								then 4.0
								when @MaterialName in ('WEC3R0335QG-C035')
								then 3.8
								when @MaterialName in ('WEC3R0106QD-C040')
								then 4.5
								when @MaterialName in ('WEC3R0606QG-C050')
								then 5.5
							else
								 Null
								end 
						else NULL end
		where LotNo in  (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)
		and (LSL is null or USL is null)


		SELECT distinct ttv.*,
		replace(replace(replace(vbt.MachineName,'Taping 3','Taping ￡3'),'Taping 2','Taping ￡2'),'Taping 1','Taping ￡1') as MachineName
			  FROM SmartFactoryV2.dbo.Stb_TQC_Tapping_VVT ttv with(nolock)
			   outer apply (
			   select top 1 * from STB_VN_BENDING_TAPPING   with(nolock) 
			   where LotNo = ttv.lotno
			   and LotNo in (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)
					  ) vbt 
		where (vbt.LOTNO = ttv.LotNo or ttv.LotNo in (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6) )
	
					
END
