
CREATE PROC [dbo].[usp_vvt_GetProductbyMatName]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
@pMatName NVARCHAR(200)='',
@pcellline nVARCHAR(50)='',
@pProduct INT=1
AS
BEGIN

----            usp_vvt_GetProductbyMatName '','',N'DUNG DỊCH -3.0V','','1'
----            usp_vvt_GetProductbyMatName '','',N'DUNG DỊCH 3.8V (VN-62)','',1

	SET NOCOUNT ON;		
	--RAISERROR(@pMatName, 16, 1, N'Aha');
	--RAISERROR(@pcellline, 16, 1, N'Aha');
		
	set @pMatName=upper(@pMatName);
	set @pcellline=lower(@pcellline);

	declare @line varchar(30) = '';
	declare @code varchar(30) = '';
	--replace(replace(replace(replace(replace(replace(replace(lower(@pcellline),'#',''),'line',''),'cell',''),N'sản xuất điện cực',''),'module',''),'thủ công',''),'xưởng','')

	if(@pcellline like '%line%cell%' or @pcellline like '%cell%line%')begin
		set @line='VVC-'+ RIGHT('0'+ltrim(rtrim(replace(replace(replace(replace(replace(replace(replace(lower(@pcellline),N'#',''),N'line',''),N'cell',''),N'sản xuất điện cực',''),N'module',''),N'thủ công',''),N'xưởng',''))),2)
	end

	if(@pcellline like N'%thủ%công%2%' or @pcellline like N'%công%thủ%2%')begin
		set @line='VV%'
	end	

	if(@pcellline like N'%thủ%công%1%' or @pcellline like N'%công%thủ%1%')begin
		set @line='VVM%'
	end	

	if(@pcellline like N'%điện%cực%sản%xuất%' or @pcellline like N'%sản%xuất%điện%cực%')begin
		set @line='VVC-ELECTRODE-LINE'
	end	

	if(@pcellline like N'%module%' or @pcellline like N'%mô đun%')begin
		set @line='VVMD'
	end	

	select top 1 @code=materialcode from stb_setinfo with(nolock) where InputLineCode like @line

			declare @kind nvarchar(30)='';
			declare @thick nvarchar(30)='';
			declare @ProductGroupCode nvarchar(30)='';
			declare @size nvarchar(30)='';


		if(@pMatName like N'%ĐIỆN%CỰC%') begin

			set @ProductGroupCode='TING-ROLL'

			if (@pMatName like '% CY %') begin
			 set @kind='CY'
				if (@pMatName like '%120%') begin					
					set @thick='120'
				end
				else if (@pMatName like '%200%') begin
					set @thick='200'
				end
			end			

			if (@pMatName like '% MSP %') begin
			 set @kind='MSP'
				if (@pMatName like '%162%') begin					
					set @thick='162'
				end
				else if (@pMatName like '%200%') begin
					set @thick='200'
				end
			end			
			
			if (@pMatName like '% YP %') begin
			 set @kind='YP'
				if (@pMatName like '%116%') begin					
					set @thick='116'
				end
				else if (@pMatName like '%200%') begin
					set @thick='200'
				end
			end			


			if (@pMatName like '% NCM%') begin
			 set @kind='NCM'
				if (@pMatName like '%105%') begin					
					set @thick='105'
				end
			end		
			
			if (@pMatName like '% PSCAM%') begin
			 set @kind='PSCAM'
				if (@pMatName like '%120%') begin					
					set @thick='120'
				end
			end		

		end

		if(@pMatName like N'%GIẤY%NGĂN%') begin

			set @ProductGroupCode='SEPARATOR'						   			

			BEGIN try
				DECLARE DetailCursor CURSOR FOR
							select distinct RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2) as size
							from STB_ModelBasicInfo mbi with(nolock) where MBISizeW is not null and MBISizeH is not null
							order by RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2) 

				OPEN DetailCursor			
				WHILE 1 = 1 
				BEGIN
					FETCH NEXT FROM DetailCursor INTO @size

					if (@pMatName like '%'+@size+'%') begin
						BREAK
					end
				
					IF @@FETCH_STATUS <> 0 BEGIN
						BREAK
					END		
				END

			END TRY
			BEGIN CATCH
			end catch
			
			CLOSE DetailCursor;
			DEALLOCATE DetailCursor;

			if(@pMatName like '%25.7%' and @pMatName like '%L30%' ) begin
				set @size=''
				set @kind='T2B4035'
				set @thick='25.7'
			end
		end
		
		if(@pMatName like N'%DUNG%DỊCH%') begin
				
			set @ProductGroupCode='ELECTROLYTE'

			set @kind=replace(replace(replace(@pMatName,N'DUNG DỊCH',''),'-',''),' ','')
			
			if(@pMatName like '%3.0V%'  ) begin
			set @kind='3.0V'	
			end
			--			if(@pMatName like '%2.5V%'  ) begin
			--	set @kind='2.5V'	
			--end			if(@pMatName like '%2.7V%'  ) begin
			--	set @kind='2.7V'	
			--end			if(@pMatName like '%3.0V%'  ) begin
			--	set @kind='3.0V'	
			--end			
			if(@pMatName like '%3.8V%'  ) begin
				set @kind='3.8V'	
			end
		end

		if(@pMatName like N'%CAO%SU%') begin

			set @ProductGroupCode='RUBBER'
			set @kind=replace(replace(@pMatName,N'CAO SU',''),' ','')
			
		end
		
		if(@pMatName like N'%VỎ%NHÔM%') begin

			set @ProductGroupCode='CASE'						   			

			BEGIN try
				DECLARE DetailCursor CURSOR FOR
							select distinct RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2) as size
							from STB_ModelBasicInfo mbi with(nolock) where MBISizeW is not null and MBISizeH is not null
							order by RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2) 

				OPEN DetailCursor			
				WHILE 1 = 1 
				BEGIN
					FETCH NEXT FROM DetailCursor INTO @size

					if (@pMatName like '%'+@size+'%') begin
						BREAK
					end
				
					IF @@FETCH_STATUS <> 0 BEGIN
						BREAK
					END		
				END

			END TRY
			BEGIN CATCH
			end catch
			
		  if(@pMatName like '%48MM%' and @pMatName like '%2245%' ) begin
				set @size=''
				set @kind='2245'
				set @thick='48'
			end

			if(@pMatName like '%48.8MM%' and @pMatName like '%2245%' ) begin
				set @size=''
				set @kind='2245'
				set @thick='48.8'
			end
			
			CLOSE DetailCursor;
			DEALLOCATE DetailCursor;

		end

		if(@pMatName like N'%VỎ%BỌC%') begin

			set @ProductGroupCode='SLEE'						   			

			BEGIN try
				DECLARE DetailCursor CURSOR FOR
							select distinct RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2) as size
							from STB_ModelBasicInfo mbi with(nolock) where MBISizeW is not null and MBISizeH is not null
							order by RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2) 

				OPEN DetailCursor			
				WHILE 1 = 1 
				BEGIN
					FETCH NEXT FROM DetailCursor INTO @size

					if (@pMatName like '%'+@size+'%') begin
						BREAK
					end
				
					IF @@FETCH_STATUS <> 0 BEGIN
						BREAK
					END		
				END

			END TRY
			BEGIN CATCH
			end catch
			
			CLOSE DetailCursor;
			DEALLOCATE DetailCursor;

		end
		
		if(@pMatName like N'%MODULE%DÂY%') begin

			set @ProductGroupCode='MD-WIRE'
			set @kind=''			
		end

		if(@pMatName like N'%MODULE%PCB%') begin

			set @ProductGroupCode='MD-PCB'
			set @kind=''			
		end
					   
		if( @pMatName like N'%TANCHA%') begin

			set @ProductGroupCode='TERMINA'
						if(@pMatName like '%9.8%'  ) begin
				set @size=''
				set @kind=''
				set @thick='9.8'
			end			
			
			

		
								if(@pMatName like '%16.3%'  ) begin
				set @size=''
				set @kind=''
				set @thick='16.3'
			end									if(@pMatName like '%VPC%'  ) begin
				set @size='0825'
				set @kind=''
				set @thick=''
			end									if(@pMatName like '%20.5%'  ) begin
				set @size=''
				set @kind=''
				set @thick='20.5'
			end							
						
			if(@pMatName like '%Φ22%' or @pMatName like '%PHI%' and @pMatName like '%22%'  ) begin
				set @size=''
				set @kind='Φ22'
				set @thick=''
			end									
			
			if(@pMatName like '%Φ25%'  or @pMatName like '%PHI%' and @pMatName like '%25%' ) begin
				set @size=''
				set @kind='Φ25'
				set @thick=''
			end								
			
			if(@pMatName like '%Φ27%'  or @pMatName like '%PHI%' and @pMatName like '%25%'  ) begin
				set @size=''
				set @kind='Φ27'
				set @thick=''
			end									if(@pMatName like '%Φ30%'  or @pMatName like '%PHI%' and @pMatName like '%30%'  ) begin
				set @size=''
				set @kind='Φ30'
				set @thick=''
			end									if(@pMatName like '%Ø30%'   or @pMatName like '%PHI%' and @pMatName like '%30%' ) begin
				set @size=''
				set @kind='Ø30'
				set @thick=''
			end									if(@pMatName like '%Φ35%'   or @pMatName like '%PHI%' and @pMatName like '%35%' ) begin
				set @size=''
				set @kind='Φ35'
				set @thick=''
			end									if(@pMatName like '%Φ40%'  or @pMatName like '%PHI%' and @pMatName like '%40%' ) begin
				set @size=''
				set @kind='Φ40'
				set @thick=''
			end				
			
		end

		declare @count INT =0

		select @count= count(*)
			from STB_ModelBasicInfo mbi
			cross apply ( 
			select  distinct MaterialCode from stb_setinfo si where MaterialCode = mbi.ModelCode
			and (InputDateTime> dateadd(month,-2,getdate()) or ChangeDateTime> dateadd(month,-2,getdate()))
			--and (InputLineCode like @line or MaterialCode=@code)
			group by MaterialCode
			) si
			left outer join STB_BomHeader  bh  on mbi.ModelCode=bh.MaterialCode
			left outer join STB_BomDetail  bd  on bh.MaterialCode=bd.MaterialCode
			left outer join STB_MaterialMaster  mm  on bd.childMaterialCode=mm.MaterialCode

			where 1=1 
			--and bh.Bomversion='99'
			and (
				 mm.MaterialThickness=@thick and mm.MaterialSource=@kind
				 or mm.MaterialName like '%'+@kind+'%'+@thick+'%'
				 or mm.MaterialName like '%'+@thick+'%'+@kind+'%'
				 or RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2)=@size
				)
			and mm.ProductGroupCode like '%'+@ProductGroupCode+'%'

		if(@count=0) begin
			if (@pProduct=0)
						select 	
						distinct 		
						mm.MaterialCode,
						mm.MaterialName
						from STB_ModelBasicInfo mbi
						cross apply ( 
						select  distinct MaterialCode from stb_setinfo si where MaterialCode = mbi.ModelCode
						and (InputDateTime> dateadd(month,-2,getdate()) or ChangeDateTime> dateadd(month,-2,getdate()))
						--and (InputLineCode like @line or MaterialCode=@code)
						group by MaterialCode
						) si
						left outer join STB_BomHeader  bh  on mbi.ModelCode=bh.MaterialCode
						left outer join STB_BomDetail  bd  on bh.MaterialCode=bd.MaterialCode
						left outer join STB_MaterialMaster  mm  on bd.childMaterialCode=mm.MaterialCode
						where 1=1
						--and bh.Bomversion='99'
						and mm.ProductGroupCode like '%'+@ProductGroupCode+'%'
			else			
						select
						distinct  
						ModelCode,
						replace(replace(replace(replace(ModelName,'HY-CAP ',''),'HY-CAP',''),RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2),''),'()','') +'('+RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2)+')' as ModelName
						from STB_ModelBasicInfo mbi
						cross apply ( 
						select  distinct MaterialCode from stb_setinfo si where MaterialCode = mbi.ModelCode
						and (InputDateTime> dateadd(month,-2,getdate()) or ChangeDateTime> dateadd(month,-2,getdate()))
						and (InputLineCode like @line or MaterialCode=@code)
						group by MaterialCode
						) si
			return;
		end

		if (@pProduct=0)
		select distinct * from (		
			select 			
			--@line LineCode,
			--case when mbi.MaterialTypeCode='MDL' then N'Mô đun' else 'Cell' end  as Product,
			mm.MaterialCode,
			mm.MaterialName,
			 mm.ProductGroupCode
			from STB_ModelBasicInfo mbi
			cross apply ( 
			select  distinct MaterialCode from stb_setinfo si where MaterialCode = mbi.ModelCode
			and (InputDateTime> dateadd(month,-2,getdate()) or ChangeDateTime> dateadd(month,-2,getdate()))
			--and (InputLineCode like @line or MaterialCode=@code)
			group by MaterialCode
			) si
			left outer join STB_BomHeader  bh  on mbi.ModelCode=bh.MaterialCode
			left outer join STB_BomDetail  bd  on bh.MaterialCode=bd.MaterialCode
			left outer join STB_MaterialMaster  mm  on bd.childMaterialCode=mm.MaterialCode

			where 1=1 
			--and bh.Bomversion='99'
			and (
				 mm.MaterialThickness=@thick and mm.MaterialSource=@kind
				 or mm.MaterialName like '%'+@kind+'%'+@thick+'%'
				 or mm.MaterialName like '%'+@thick+'%'+@kind+'%'
				 or RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2)=@size
				)
			and mm.ProductGroupCode like '%'+@ProductGroupCode+'%'
			) newtb 
			where ProductGroupCode like '%'+@ProductGroupCode+'%'
		else

		select 
			distinct  
			ModelCode,
			replace(replace(replace(replace(ModelName,'HY-CAP ',''),'HY-CAP',''),RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2),''),'()','') +'('+RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2)+')' as ModelName,
			--@line LineCode,
			case when mbi.MaterialTypeCode='MDL' then N'Mô đun' else 'Cell' end  as Product

			from STB_ModelBasicInfo mbi
			cross apply ( 
			select  distinct MaterialCode from stb_setinfo si where MaterialCode = mbi.ModelCode
			and (InputDateTime> dateadd(month,-2,getdate()) or ChangeDateTime> dateadd(month,-2,getdate()))
			--and (InputLineCode like @line or MaterialCode=@code)
			group by MaterialCode
			) si
			left outer join STB_BomHeader  bh  on mbi.ModelCode=bh.MaterialCode
			left outer join STB_BomDetail  bd  on bh.MaterialCode=bd.MaterialCode
			left outer join STB_MaterialMaster  mm  on bd.childMaterialCode=mm.MaterialCode

			where 1=1 
			--and bh.Bomversion='99'
			and (
				 mm.MaterialThickness=@thick and mm.MaterialSource=@kind
				 or mm.MaterialName like '%'+@kind+'%'+@thick+'%'
				 or mm.MaterialName like '%'+@thick+'%'+@kind+'%'
				 or RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2)=@size
				)
			and mm.ProductGroupCode like '%'+@ProductGroupCode+'%'
					   

END

