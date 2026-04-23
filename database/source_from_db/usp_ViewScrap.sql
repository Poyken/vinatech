CREATE PROC [dbo].[usp_ViewScrap] -- EXEC usp_ViewScrap '2023-01-01','2023-05-01'
@pFrom DATE = NULL,
@pTo DATE = NULL

AS
BEGIN

DECLARE @From NVARCHAR(50) = @pFrom
DECLARE @To NVARCHAR(50) = @pTo


	declare @cccount1 INT=0
	declare @cccount2 INT=0

IF @From IS NOT NULL AND @To IS NOT NULL


	BEGIN try		

			SELECT  distinct
			DEPARTMENTNAME,
			NAMEERROR,
			isnull(CODEPRODUTION,CODENAME) as CODEPRODUTION,
			isnull(PRODUCTIONNAME,INPUT) as PRODUCTIONNAME,
			TYPEINPUT,
			UNIT,
			LOTNO,
			convert(float,replace(replace(SPI.QTY,'kg',''),'pcs','')) as QTY,
			SHITF,
			SPI.CreateDateTime,
			SPI.CreateUserID,
			SPI.ChangeDateTime,
			SPI.ChangeUserID		
		   , weightLast.valweight as WeightUnit 
		   , ISNULL(convert(float,replace(replace(SPI.QTY,'kg',''),'pcs','')), 0) * weightLast.valweight/1000 as WasteWeight
		  
		  ,		 (case  when   (DATEPART(HOUR, SPI.CreateDateTime)>10)     or    (DATEPART(HOUR, SPI.CreateDateTime)=10 and DATEPART(MINUTE, SPI.CreateDateTime)>0)     
				then     convert(varchar(10),SPI.CreateDateTime,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  SPI.CreateDateTime),120)       
				end 
		        )      
		  as  JobDate
		INTO #Temp1
		FROM 
				STB_VN_SCRAP_AFTERPRODUCTIONS SPI WITH(NOLOCK)
		-- LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)
		--		ON AFM.FileID = SPI.FILEID
		left outer join (
		  select    [Modelname], replace([Modelcode],'.','')[Modelcode],CodeBtp,RouteCode 
		  from stb_Vietnam_MapCode
		  unpivot(
		   CodeBtp for RouteCode in ( [V-22], [V-23], [V-24], [V-25], [V-26], [V-27], [V-28] , [V-29], [V-30], [V-33], [V-34], [MV-01], [MV-03], [MV-04], [MV-05])
		  )tb2 
		) vMapCode 
		on   (case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end)=vMapCode.CodeBtp 
		or (case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end)=vMapCode.Modelcode 
		
	 left outer join stb_materialmaster mm2 on vMapCode.Modelcode=mm2.materialcode

		OUTER APPLY (select top 1 * from    [dbo].[fn_VVT_Stage2Weight]('') weight3
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(MM2.MaterialName, CHARINDEX('(', MM2.MaterialName, 0) + 1, 4) = weight3.model  and  weight3.routecode=(case when substring(case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end,1,2)='VW' then 'V-22' 
																																						when substring(case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end,1,2)='VR' then 'V-23'
																																						when substring(case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end,1,2)='VC' then 'V-24'
																																						when substring(case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end,1,2)='VV' then 'V-27'
																																						when substring(case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end,1,2)='VN' then 'V-27'
																																						when substring(case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end,1,2)='MV' then 'MV-01'
																																						else '' end
																																						)  
			   ) weightLast 
			  
		WHERE   CONVERT(DATE,SPI.CreateDateTime) BETWEEN @From AND @To
		and (spi.DEPARTMENTNAME like  N'%Sản xuất%' or spi.DEPARTMENTNAME like '%생산%' )
		
		set @cccount1=1

	END try
	begin catch

		set @cccount2=1	

		SELECT  distinct
			DEPARTMENTNAME,
			NAMEERROR,
			isnull(CODEPRODUTION,CODENAME) as CODEPRODUTION,
			isnull(PRODUCTIONNAME,INPUT) as PRODUCTIONNAME,
			TYPEINPUT,
			UNIT,
			LOTNO,
			QTY,
			SHITF,
			SPI.CreateDateTime,
			SPI.CreateUserID,
			SPI.ChangeDateTime,
			SPI.ChangeUserID			
		   , weightLast.valweight as WeightUnit 
		   ,null WasteWeight
		   --, ISNULL(convert(float,replace(replace(SPI.QTY,'',''),'','')), 0) * weightLast.valweight/1000 as WasteWeight
		   
		   ,		 (case  when   (DATEPART(HOUR, SPI.CreateDateTime)>10)     or    (DATEPART(HOUR, SPI.CreateDateTime)=10 and DATEPART(MINUTE, SPI.CreateDateTime)>0)     
				then     convert(varchar(10),SPI.CreateDateTime,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  SPI.CreateDateTime),120)       
				end 
		        )      
		  as  JobDate
		INTO #Temp2
		FROM 
				STB_VN_SCRAP_AFTERPRODUCTIONS SPI WITH(NOLOCK)
		--  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)
		--		ON AFM.FileID = SPI.FILEID
		left outer join (
		  select    [Modelname], replace([Modelcode],'.','')[Modelcode],CodeBtp,RouteCode 
		  from stb_Vietnam_MapCode
		  unpivot(
		   CodeBtp for RouteCode in ( [V-22], [V-23], [V-24], [V-25], [V-26], [V-27], [V-28] , [V-29], [V-30], [V-33], [V-34], [MV-01], [MV-03], [MV-04], [MV-05])
		  )tb2 
		) vMapCode 
		on   (case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end)=vMapCode.CodeBtp 
		or (case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end)=vMapCode.Modelcode 
		
		left outer join stb_materialmaster mm2 on vMapCode.Modelcode=mm2.materialcode

		OUTER APPLY (select top 1 * from    [dbo].[fn_VVT_Stage2Weight]('') weight3
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(MM2.MaterialName, CHARINDEX('(', MM2.MaterialName, 0) + 1, 4) = weight3.model  and  weight3.routecode=(case when substring(case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end,1,2)='VW' then 'V-22' 
																																						when substring(case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end,1,2)='VR' then 'V-23'
																																						when substring(case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end,1,2)='VC' then 'V-24'
																																						when substring(case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end,1,2)='VV' then 'V-27'
																																						when substring(case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end,1,2)='VN' then 'V-27'
																																						when substring(case when SPI.CODEPRODUTION is not null and SPI.CODEPRODUTION<>''  then SPI.CODEPRODUTION else SPI.CODENAME end,1,2)='MV' then 'MV-01'
																																						else '' end
																																						)  
			   ) weightLast 

		WHERE    CONVERT(DATE,SPI.CreateDateTime) BETWEEN @From AND @To
			and (spi.DEPARTMENTNAME like  N'%Sản xuất%' or spi.DEPARTMENTNAME like '%생산%' )
	end catch
	


	
	  if   OBJECT_ID('tempdb.dbo.#Temp1') IS  NULL and OBJECT_ID('tempdb.dbo.#Temp2') IS  NULL
		begin
			raiserror(N'Không có dữ liệu!',16,1);
			return;
		end


	
		if   OBJECT_ID('tempdb.dbo.#Temp1') IS NOT NULL  begin
			if  @cccount1>0 or @cccount2=0 
				select * from #Temp1

			DROP TABLE #Temp1;
		end


		if  OBJECT_ID('tempdb.dbo.#Temp2') IS NOT NULL begin
			
			if @cccount2>0  or @cccount1=0
				select * from #Temp2
			
			DROP TABLE #Temp2; 
		end	
	
END
