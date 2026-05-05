
-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2020-08-12
-- Browsable : true
-- exec usp_savePackingLabelQty_VVT 'nguyentung','','VVKP183R038732', 3000
-- =============================================
CREATE PROCEDURE [dbo].[usp_savePackingLabelQty_VVT]                                  
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProcessViewName VARCHAR(50),
						@pXml NVARCHAR(MAX) = NULL,
						@pLotNo VARCHAR(50)=null,
						@pLotQty int =null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(30) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName

    --DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    --DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'

	DECLARE @ERROR_MSG NVARCHAR(MAX)    

	DECLARE @PackID VARCHAR(30) --= isnull(@pPackingID,'0.1')
	DECLARE @LotQty NUMERIC --= isnull(@pLabelQty,0)
	DECLARE @CurrentQty NUMERIC --= isnull(@CurrentQty,0)
	
	DECLARE @LabelQty NUMERIC

	DECLARE @ccount NUMERIC(20,5)
	DECLARE @iDoc INT


	declare	@PackingID		varchar(30)  
	declare @LotNo			varchar(30)  
	declare @LotNoi			varchar(30)  
	declare @MaterialCode	varchar(30) 
	declare @MaterialName	varchar(30) 
	declare @PackQty		numeric(18, 0) 
	declare @PrintTime		datetime 
	declare @EmpNo			varchar(30)  
	declare @isPrinted		bit
	declare @isModule		bit	
	declare @partNo			varchar(30) 		

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	

	   --declare @testLabelQty varchar(20)= @pLotQty
--RAISERROR(@testLabelQty,16,1)		
	
	
	    
	BEGIN TRY

		DECLARE SourceData CURSOR FOR
            SELECT
						PackingID,
						LotQty,
						LotNo,
						LabelQty,
						CurrentQty
			FROM
					OPENXML(@idoc , @TableName , 2)
					WITH (
								PackingID VARCHAR(30),
								LotQty NUMERIC,
								LotNo VARCHAR(30) ,
								LabelQty NUMERIC,
								CurrentQty NUMERIC
						 )

        OPEN SourceData
		  FETCH NEXT FROM SourceData INTO
								@PackID,
								@LotQty,
								@LotNo,
								@LabelQty,
								@CurrentQty
        WHILE @@FETCH_STATUS=0 BEGIN

	

            FETCH NEXT FROM SourceData INTO
								@PackID,
								@LotQty,
								@LotNo,
								@LabelQty,
								@CurrentQty

				
            IF @@FETCH_STATUS <> 0 BEGIN 
				BREAK 
			END 
			
						
			--end

--SET IDENTITY_INSERT STB_SavePackingTime_VVT ON
  END			




  
	 if( (@LotNo is null or @LotNo='') and @pLotNo is not null and isnull(@LotNo,'') <> isnull(@pLotNo,'') ) begin
			set @LotNo	 = @pLotNo
			set @LotQty  = @pLotQty 
	end	 
	else begin
	--RAISERROR(@LotNo,16,1)
	
		if(@LotNo like 'MV%' and @LotQty>0)
		begin
		
		    set @LotQty= -1*@LotQty
		 end
		
		if(@LotNo like 'MV%' and @LotQty>0)
		begin
		 set @LotQty= -1*@LotQty
		 end
		 
		
	end




			DECLARE @LotNonew1 VARCHAR(20) = ''
	DECLARE @LotNonew2 VARCHAR(20) = ''
	DECLARE @LotNonew3 VARCHAR(20) = ''
	DECLARE @LotNonew4 VARCHAR(20) = ''
	DECLARE @LotNonew5 VARCHAR(20) = ''
	DECLARE @LotNonew6 VARCHAR(20) = ''
		select top 1 @LotNonew1 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNo 
	
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


	   select top 1 @LotNo = barcode  
	   FROM STB_SetInfo	    WITH(NOLOCK)
	   WHERE 1=1
	   and Barcode in (@LotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)



	 if( (@LotNo is null or @LotNo='') and @pLotNo is not null and isnull(@LotNo,'') <> isnull(@pLotNo,'') ) begin
			set @LotNo	 = @pLotNo
			set @LotQty  = @pLotQty 
	end	 


	

			if  1=1 or @PackID is not null   and   @PackID <> '' 
			begin

				if( 1=1 or @LabelQty=0) begin
				
					DECLARE SourceData1 CURSOR FOR
					
						--select  top 50 isnull(PackingID,'')PackingID, isnull(LotNo,@LotNo)LotNo, a0.MaterialCode, b.materialname,@LotQty,getdate(),@ProcessUserID,
						--(case when @LabelQty is null or @LabelQty=0 then 0 else 1 end) as isPrinted,0 as isModule,
						-- (RTRIM(LTRIM(SUBSTRING(b.materialname, CHARINDEX(' ', b.materialname), 12))) + 
						--		CASE WHEN CHARINDEX('-L', b.materialname) > 0 THEN '-L' ELSE '' END) AS PartNo,
						--		a.CurrentQty
						
						--from STB_SetInfo a0  with(nolock)
						--	left outer join STB_MaterialLotInfo a with(nolock) on a0.Barcode=a.LotNo 
						--	left outer join STB_MaterialMaster  b with(nolock)  on a0.MaterialCode=b.MaterialCode 
						--where Barcode = @LotNo or Barcode = STUFF(@LotNo,1,2,'VV') or a.PackingID=@PackID
								

						------------ 2026-01-23 Mr.Manh update following Mr.Cuong - Bac Giang 1 request
						select  top 1 isnull(PackingID,'')PackingID, isnull(LotNo,@LotNo)LotNo, a0.MaterialCode, b.materialname,@LotQty,getdate(),@ProcessUserID,
						(case when @LabelQty is null or @LabelQty=0 then 0 else 1 end) as isPrinted,0 as isModule,
						 (RTRIM(LTRIM(SUBSTRING(b.materialname, CHARINDEX(' ', b.materialname), 12))) + 
								CASE WHEN CHARINDEX('-L', b.materialname) > 0 THEN '-L' ELSE '' END) AS PartNo,
								a.CurrentQty
						
						from STB_SetInfo a0  with(nolock)
							left outer join STB_MaterialLotInfo a with(nolock) on a0.Barcode=a.LotNo 
							left outer join STB_MaterialMaster  b with(nolock)  on a0.MaterialCode=b.MaterialCode 
						where Barcode = @LotNo or Barcode = STUFF(@LotNo,1,2,'VV') or a.PackingID=@PackID

						order by 
							case when Barcode = @LotNo then 1
								when Barcode = STUFF(@LotNo,1,2,'VV') then 2
								else 3
							end
						------------ END
								

						 OPEN SourceData1
							WHILE 1=1 BEGIN
								FETCH NEXT FROM SourceData1 INTO
												 @PackingID		, 
												 @LotNoi			,
												 @MaterialCode	,
												 @MaterialName	, 
												 @PackQty		,
												 @PrintTime		,
												 @EmpNo			,
												 @isPrinted		,
												 @isModule		,
												 @partNo		,
												 @CurrentQty

						            IF @@FETCH_STATUS <> 0 BEGIN
									BREAK
									END


									if(@LotNo <> @LotNoi) begin
										select @PackingID = @LotNo +'-'+ @PackingID
									end
							
								--kiểm tra nếu là ở hà nam sẽ kiểm tra cho lưu packingid 1 lần vào hệ thống khi không in tem
								-- lấy thông tin nhà máy
								declare @workcentercode varchar(50)
								declare @checkpackingid int =0;
								select @workcentercode = workcentercode from stb_materiallotinfo where packingid=@PackingID 
								select @checkpackingid= count(*) from STB_SavePackingTime_VVT where packingid=@PackingID and isprinted=0 and PackQty>0 and lotno = @LotNoi
								-- kiểm tra nếu nhà máy hà nam mỗi packing chỉ được lưu 1 lần 
								if(@workcentercode='VVT_F3')
								begin
								/*	declare @fd varchar(20) = @CurrentQty
								RAISERROR(@PackingID,16,1)
								return
								*/
									if(@checkpackingid=0 or @isprinted=1) -- nếu nó chưa được lưu packig hoặc in thì sẽ cho lưu lại không thì không làm gì cả
									begin	
										
										insert into STB_SavePackingTime_VVT 
										(PackingID		, LotNo			, MaterialCode	, MaterialName	, PackQty		, PrintTime		, EmpNo			, isPrinted		, isModule		, partNo,LableQty)
										values (@PackingID		, @LotNoi			, @MaterialCode	, @MaterialName	, @CurrentQty		, @PrintTime		, @EmpNo			, @isPrinted		, @isModule		, @partNo,@LabelQty);
										--RAISERROR('vào',16,1)
									end
									
								end
								else
								begin
									--RAISERROR('vào',16,1)
								--	declare @test1 varchar(20)=@PackingID
								--	RAISERROR(@test1,16,1)
								-- kiểm tra xem đã lưu packing chưa dánh cho hàng module
								declare @checklotno int =0;
								select @checklotno= count(*) from STB_SavePackingTime_VVT where lotno=@LotNo and isprinted=0 and PackQty>0
								if(@isPrinted=0 and @EmpNo  in ('anhduy157','hopnguyen','VVTworker','huyen','32107013','hant-1998','hoaiyen') and @checklotno=0 and @LotNo like 'MV%')
									set @PackQty = @PackQty*(-1)
								

								if(@PackQty>0 and @EmpNo  in ('duonghoa','nthop','nguyentha','transao','32210006','32107013','hoangxuan'))
								--RAISERROR(@pLotNo,16,1)
									if(@EmpNo <> 'nguyentha' or @EmpNo <> 'hoangxuan' ) 
										begin 
											--RAISERROR(@pLotNo,16,1)
											set @PackQty = @PackQty*(-1)
										end

									 insert into STB_SavePackingTime_VVT 
									(PackingID		, LotNo			, MaterialCode	, MaterialName	, PackQty		, PrintTime		, EmpNo			, isPrinted		, isModule		, partNo,LableQty)
									values (@PackingID		, @LotNoi			, @MaterialCode	, @MaterialName	, @PackQty		, @PrintTime		, @EmpNo			, @isPrinted		, @isModule		, @partNo,@LabelQty);



								--if(@PackQty>0 and @EmpNo  in ('hant-1998','hopnguyen','nguyentha','transao','32210006','32107013','anhduy157'))
								--	raiserror('check',16,1)
								--	if(@EmpNo <> 'nguyentha') --nếu dùng tài khoản này số sẽ không âm
								--		begin 
											
								--			set @PackQty = @PackQty*(-1)
								--		end

								--	 insert into STB_SavePackingTime_VVT 
								--	(PackingID		, LotNo			, MaterialCode	, MaterialName	, PackQty		, PrintTime		, EmpNo			, isPrinted		, isModule		, partNo,LableQty)
								--	values (@PackingID		, @LotNoi			, @MaterialCode	, @MaterialName	, @PackQty		, @PrintTime		, @EmpNo			, @isPrinted		, @isModule		, @partNo,@LabelQty);
								end
						END
												
					

						CLOSE SourceData1; 
						DEALLOCATE SourceData1; 
					end				
			end


    END TRY

	BEGIN CATCH

	--SET IDENTITY_INSERT STB_SavePackingTime_VVT OFF

		SET @ERROR_MSG = ERROR_MESSAGE() 
		RAISERROR( @ERROR_MSG ,16, 1) 
	END CATCH
			
	CLOSE SourceData; 
	DEALLOCATE SourceData; 
			
	EXEC sp_xml_removedocument @idoc 
	 ---  select RTRIM(LTRIM(SUBSTRING('HY-CAP WEC3R0105QG (0813)', CHARINDEX(' ', 'HY-CAP WEC3R0105QG (0813)'), 12))) + CASE WHEN CHARINDEX('-L', 'HY-CAP WEC3R0105QG (0813)') > 0 THEN '-L' ELSE '' END
	 -- select * from STB_SavePackingTime_VVT where lotno='VVKQ263R010501'
	
	 --update STB_SavePackingTime_VVT 
	 --set isPrinted = 0
	 ---where lotno='VVKQ263R010501'

END
