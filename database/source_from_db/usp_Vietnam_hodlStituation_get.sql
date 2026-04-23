-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-27
---        exec  [dbo].[usp_Vietnam_hodlStituation_get] '','','2022-01-01','2022-05-31','unHold','','','',''
--  usp_Vietnam_hodlStituation_get '','','2022-05-01','2022-12-31','Hold','','','','','nguyendung'
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_hodlStituation_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromdate datetime = NULL,
	@pTodate datetime = NULL,
	@pType varchar(20) = NULL,
	@pLotno varchar(20) = NULL,
	@pDeptIC varchar(30) = NULL,
	@pSize   varchar(50) = NULL,
	@pStatus varchar(30) = NULL,
	@pcreate varchar(30) = NULL,
	@plocation varchar(30)= NULL
AS
BEGIN
	SET NOCOUNT ON;

	if (@pLotno is not NULL and @pLotno<>'') 
	begin
				DECLARE @LotNo VARCHAR(20) =  CASE WHEN ISNULL(@pLotNo,'') = '' THEN '%' ELSE @pLotNo END
				DECLARE @LotNonew1 VARCHAR(20) = ''
				DECLARE @LotNonew2 VARCHAR(20) = ''
				DECLARE @LotNonew3 VARCHAR(20) = ''
				DECLARE @LotNonew4 VARCHAR(20) = ''
				DECLARE @LotNonew5 VARCHAR(20) = ''
				DECLARE @LotNonew6 VARCHAR(20) = ''
						
				select @LotNonew1 = NewBarcode
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

				--select @LotNo =  CASE WHEN ISNULL(@LotNo,'') = '' THEN '%' ELSE @LotNo END
				--select @LotNonew1 =  CASE WHEN ISNULL(@LotNonew1,'') = '' THEN '%' ELSE @LotNonew1 END
				--select @LotNonew2 =  CASE WHEN ISNULL(@LotNonew2,'') = '' THEN '%' ELSE @LotNonew2 END
				--select @LotNonew3 =  CASE WHEN ISNULL(@LotNonew3,'') = '' THEN '%' ELSE @LotNonew3 END
				--select @LotNonew4 =  CASE WHEN ISNULL(@LotNonew4,'') = '' THEN '%' ELSE @LotNonew4 END
				--select @LotNonew5 =  CASE WHEN ISNULL(@LotNonew5,'') = '' THEN '%' ELSE @LotNonew5 END
				--select @LotNonew6 =  CASE WHEN ISNULL(@LotNonew6,'') = '' THEN '%' ELSE @LotNonew6 END
		;with newtable as (
			select 		id, 
						[type]			,
						[decisiondate] 	as holding_Date,
						DATEDIFF(DAY,[decisiondate],getdate()) as total_day,
						convert(numeric(10,2),100*(isnull([NgQty],0) )/(convert(numeric(10,2),isnull([quantity],1))) ) as NG_rate,
						shsv.[modelcode]		,
						isnull(mbi.[modelname],shsv.modelname)	modelname	,
						(
						case when shsv.modelname is not null and len(shsv.modelname)<=6 then shsv.modelname 
						else  '' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2) + '' end
						) AS Size,
						[lotno]			,
						isnull(pwi.workername,pic) as [pic]			,
						[reason]		,
						[location]		,
						[wip]			,
						[packingid]		,
						shsv.[createdatetime],
						shsv.[createuserid]	
					   ,shsv.[line]
					   ,shsv.[technical]
					   ,shsv.[quantity]
					   ,shsv.[DeptIC]
					   ,shsv.[Expecteddate]
					   ,shsv.[Realdate]
					   ,shsv.[DeptProcess]
					   ,shsv.[Procedures]
					   ,isnull([quantity],0) - isnull([NgQty],0) as [OkQty]
					   ,shsv.[NgQty]
					   ,shsv.[Other]
					   ,shsv.[Status]
					   ,convert(varchar(7), si.InputDateTime,120) as ProdMonth
					    ,HoldFileID
						,safim.[FileName]
						,safim.FileSize
			from stb_hodl_situationVVT shsv with(nolock)
			left outer join SmartFramework_File.dbo.STB_AttachedFileMaster safim  with(nolock) on safim.FileID = shsv.HoldFileID
			left outer join STB_SetInfo si with(nolock) on substring(ltrim(rtrim(shsv.lotno)),1,14)=si.Barcode
			left outer join STB_ProdWorkerInfo PWI WITH(NOLOCK) on shsv.pic = pwi.WorkerCode
			left outer join  STB_ModelBasicInfo  mbi  with(nolock) on shsv.modelcode = mbi.modelcode
			where lotno in (@LotNo,	@LotNonew1,	@LotNonew2,	@LotNonew3,	@LotNonew4,	@LotNonew5,	@LotNonew6) --and @pType='None'
			and (@pDeptIC is null or @pDeptIC='' or shsv.DeptIC=@pDeptIC or shsv.DeptProcess=@pDeptIC)
			and (@pSize is null or @pSize='' or shsv.modelname like '%'+@pSize+'%' )
			and ( isnull(@pcreate,'')='' or  shsv.createuserid = @pcreate )
			and ( isnull(@plocation,'')='' or shsv.location=@plocation)
			 and lotno not like 'del_%'
		union all

			select
					0 as [id]																								,
					'Hold' as [type]																						,
					-- getdate() 	 as [decisiondate]	,

					getdate() 	as holding_Date																			,
					0 as total_day														,
					convert(numeric(10,2),100*(isnull(si.DefectQty,0) )/(convert(numeric(10,2),isnull(si.ProdQty,1))) ) as NG_rate,
					si.materialCode	 as [modelcode]					,
					mbi.modelname as [modelname] ,
					'' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2) + '' AS Size,
					si.barcode   as [lotno]																					,
					isnull(pwi.workername,si.CreateUserID)    as [pic]														,
					'' as [reason]																							,
					case    when Fmqi.DecisionResult in ('Pass','Reject','None') then 'FOQC' 
							when mqi.DecisionResult in ('Pass','Reject','None')  then 'OQC'
							when Fmqi.DecisionResult='Pass' and mli.PackingID is not null  then 'Warehouse'
							else (select max(Routecode) from STB_ProdRouteHist with(nolock) where ControlNo=si.controlno)
							end 
					as [location]																							,
					'' as [wip]																								,
					mli.[packingid]																							,
					   si.[createdatetime]		,
					   si.[createuserid]	
					   ,si.InputLineCode as [line]
					   ,mbi.MBIExtText04 +'V - ' + mbi.MBIExtText05 +'F' as [technical]
					   ,si.ProdQty as [quantity]
					   ,'' as [DeptIC]
					   ,getdate() as [Expecteddate]
					   ,getdate() as [Realdate]
					   ,'' as [DeptProcess]
					   ,'' as [Procedures]
					   ,isnull(si.ProdQty,0) - isnull(si.DefectQty,0) as [OkQty]
					   ,si.DefectQty as [NgQty]
					   ,'' as [Other]
					   ,'' as [Status]
					   ,convert(varchar(7), si.InputDateTime,120) as ProdMonth
						,CONVERT(INT,NULL) as HoldFileID
						,CONVERT(nvarchar(255),NULL) as [FileName]
						,CONVERT(BIGINT,NULL) as FileSize
			from STB_SetInfo si  with(nolock) 
			left outer join STB_MaterialLotInfo mli with(nolock) on mli.LotNo = si.Barcode 
			left outer join STB_ProdWorkerInfo PWI WITH(NOLOCK) on si.CreateUserID = pwi.WorkerCode
			left outer join STB_MaterialQcInfo  mqi with(nolock) on si.Barcode = mqi.MaterialQcNo  						
			left outer join STB_MaterialQcInfo Fmqi with(nolock) on si.Barcode = STUFF(Fmqi.MaterialQcNo,1,1,'') 
			left outer join  STB_ModelBasicInfo  mbi  with(nolock) on (si.materialcode = mbi.modelcode or mqi.materialcode = mbi.modelcode or Fmqi.materialcode = mbi.modelcode)
			where  (si.Barcode in (@LotNo,	@LotNonew1,	@LotNonew2,	@LotNonew3,	@LotNonew4,	@LotNonew5,	@LotNonew6)
			and @pType='None')
			and (@pSize is null or @pSize='' or mbi.modelname like '%'+@pSize+'%' )
			and ( isnull(@pcreate,'')='' or  si.createuserid = @pcreate )

		) 
		select 
			  holding_Date,
			  line,
			  technical,
			  Size,
			  reason,
			  lotno,
			  lotno as oldlotno,
			  quantity,
			  [location],
			  wip,
			  pic,
			  DeptIC,
			  Expecteddate,
			  Realdate,
			  total_day,
			  DeptProcess,
			  Procedures,
			  OkQty,
			  NgQty,
			  NG_rate,
			  Other,
			  type ,
			  [Status],
			  modelcode,
			  modelname,
			  ProdMonth
					    ,HoldFileID
						,[FileName]
						,FileSize
			  ,CONVERT(VARBINARY(MAX),NULL) as "FileData"			  
			  ,
			case when dateadd(  month,  3 , holding_Date ) <= getdate() then 'Expired' 
			when  dateadd(  month,  1 , holding_Date ) <= getdate()  then 'Warning' 
			else 'Safe' end as Statut
			
		from newtable
	end


	else 
	begin
		;with myid as (
			select max(id) as id, lotno
			from stb_hodl_situationVVT with(nolock)
			where decisiondate between @pFromdate and @pTodate and lotno not like 'del_%'
			group by lotno
		),
		newtable2 as (
			select 		id, 
						[type]			,
						[decisiondate] 	as holding_Date,
						DATEDIFF(DAY,[decisiondate],getdate()) as total_day,
						convert(numeric(10,2),100*(isnull([NgQty],0) )/(convert(numeric(10,2),isnull([quantity],1))) ) as NG_rate,
						shsv.[modelcode]		,
						isnull(mbi.[modelname],shsv.modelname)	modelname		,
						(
							case when shsv.modelname is not null and len(shsv.modelname)<=6 then shsv.modelname 
							else  '' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2) + '' end
						) AS Size,
						[lotno]			,
						isnull(pwi.workername,pic) as [pic]			,
						[reason]		,
						[location]		,
						[wip]			,
						[packingid]		,
						shsv.[createdatetime],
						shsv.[createuserid]	
					   ,shsv.[line]
					   ,shsv.[technical]
					   ,shsv.[quantity]
					   ,shsv.[DeptIC]
					   ,shsv.[Expecteddate]
					   ,shsv.[Realdate]
					   ,shsv.[DeptProcess]
					   ,shsv.[Procedures]
					   ,isnull([quantity],0) - isnull([NgQty],0) as [OkQty]
					   ,shsv.[NgQty]
					   ,shsv.[Other]
					   ,shsv.[Status]
					   ,convert(varchar(7), si.InputDateTime,120) as ProdMonth
					    ,HoldFileID
						,safim.[FileName]
						,safim.FileSize
			from stb_hodl_situationVVT shsv with(nolock)
			left outer join SmartFramework_File.dbo.STB_AttachedFileMaster safim  with(nolock) on safim.FileID = shsv.HoldFileID
			left outer join STB_SetInfo si with(nolock) on substring(ltrim(rtrim(shsv.lotno)),1,14)=si.Barcode
			left outer join STB_ProdWorkerInfo PWI WITH(NOLOCK) on shsv.pic = pwi.WorkerCode
			left outer join  STB_ModelBasicInfo  mbi  with(nolock) on shsv.modelcode = mbi.modelcode
		where id in (select id from myid) and  (@pType='' or @pType is null or type=@pType)
			and (@pDeptIC is null or @pDeptIC='' or shsv.DeptIC=@pDeptIC or shsv.DeptProcess=@pDeptIC)
			and (@pSize is null or @pSize='' or shsv.modelname like '%'+@pSize+'%' )
			and ( isnull(@pcreate,'')='' or  shsv.createuserid = @pcreate )
			and ( isnull(@plocation,'')='' or shsv.location=@plocation)
			 and lotno not like 'del_%'
	union all 

		select 
			0 as [id]																								,
			case    when Fmqi.DecisionResult='Hold' or mqi.DecisionResult='Hold'  or  SIExtInt01=1  then 'Hold' 
					when  @pType='None' then 'None'
					else  'Unhold'  end 
			as [type]																								,
			--isnull(isnull(Fmqi.DecisionDateTime , mqi.DecisionDateTime ) , getdate() )	 as [decisiondate]	,

			isnull(isnull(Fmqi.DecisionDateTime , mqi.DecisionDateTime ) , getdate() ) 	as holding_Date																			,
			0 as total_day														,
			convert(numeric(10,2),100*(isnull(si.DefectQty,0) )/(convert(numeric(10,2),isnull(si.ProdQty,1))) ) as NG_rate,
						isnull(isnull(Fmqi.materialCode , mqi.materialCode ) , si.materialCode)	 as [modelcode]					,
			--(select materialname from STB_MaterialMaster with(nolock) where MaterialCode=si.MaterialCode ) as [modelname] ,
			mbi.modelname as modelname,
			--(
			--	select '' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2) + ''
			--	from STB_ModelBasicInfo  with(nolock) 
			--	where modelcode = isnull(isnull(Fmqi.materialCode , mqi.materialCode ) , si.materialCode)
			--) AS Size,
			'' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2) + '' as Size,
			isnull(isnull( STUFF(Fmqi.MaterialQcNo,1,1,'') , mqi.MaterialQcNo ) , si.barcode)    as [lotno]			,
			--isnull(isnull(Fmqi.DecisionUserID , mqi.DecisionUserID ) , si.CreateUserID)   as [pic]					,
			isnull(pwi.workername,isnull(isnull(Fmqi.DecisionUserID , mqi.DecisionUserID ) , si.CreateUserID)) as [pic],
			'' as [reason]																							,
			case    when Fmqi.DecisionResult='Hold' or Fmqi.VendorLotNo like '%old%' then 'FOQC' 
					when mqi.DecisionResult='Hold'  or mqi.VendorLotNo like '%old%'  then 'OQC'
					when Fmqi.DecisionResult='Pass' and mli.PackingID is not null  then 'Warehouse'
					else (select max(Routecode) from STB_ProdRouteHist with(nolock) where ControlNo=si.controlno)
					end 
			as [location]																							,
			'' as [wip]																								,
			mli.[packingid]																							,
			isnull(isnull(Fmqi.createdatetime , mqi.createdatetime ) , si.createdatetime) as   [createdatetime]		,
			isnull(isnull(Fmqi.createuserid , mqi.createuserid ) , si.createuserid) as   [createuserid]	
			,si.InputLineCode as [line]
			,(
				select MBIExtText04 +'V - ' + MBIExtText05 +'F'
					from STB_ModelBasicInfo  with(nolock) 
					where modelcode = isnull(isnull(Fmqi.materialCode , mqi.materialCode ) , si.materialCode)
			) as [technical]
			,isnull(isnull(Fmqi.QcQty,mqi.QcQty),si.ProdQty) as [quantity]
			,'' as [DeptIC]
			,getdate() as [Expecteddate]
			,getdate() as [Realdate]
			,'' as [DeptProcess]
			,'' as [Procedures]
			,isnull(isnull(isnull(Fmqi.QcQty,mqi.QcQty),si.ProdQty),0) - isnull(si.DefectQty,0) as [OkQty]
			,si.DefectQty as [NgQty]
			,'' as [Other]
			,'' as [Status]
			,convert(varchar(7), si.InputDateTime,120) as ProdMonth
			,CONVERT(INT,NULL) as HoldFileID
			,CONVERT(nvarchar(255),NULL) as [FileName]
			,CONVERT(BIGINT,NULL) as FileSize
		from STB_SetInfo si with(nolock)
		left outer join STB_MaterialLotInfo mli with(nolock) on mli.LotNo = si.Barcode 		
		full outer join STB_MaterialQcInfo  mqi with(nolock) on si.Barcode = mqi.MaterialQcNo  						
		full outer join STB_MaterialQcInfo Fmqi with(nolock) on si.Barcode = STUFF(Fmqi.MaterialQcNo,1,1,'') 
		left outer join  STB_ModelBasicInfo  mbi  with(nolock) on (si.materialcode = mbi.modelcode or mqi.materialcode = mbi.modelcode or Fmqi.materialcode = mbi.modelcode)
		left outer join STB_ProdWorkerInfo PWI WITH(NOLOCK) on isnull(isnull(Fmqi.DecisionUserID , mqi.DecisionUserID ) , si.CreateUserID) = pwi.WorkerCode
			
		where 
		(
		(si.InputDateTime between @pFromdate and @pTodate  
		and (@pType='' or @pType is null or @pType = (case  when @pType='None' then 'None' when Fmqi.DecisionResult='Hold' or mqi.DecisionResult='Hold'  or  SIExtInt01=1  then 'Hold'  else  'Unhold'  end)  )
		and si.Barcode not in (select lotno from myid)  and isnull(SIExtInt01,0)=(case when @pType='None' then 0 else 1 end) and barcode like 'VV%'
		)
		or
		(
		 fmqi.DecisionDateTime between  @pFromdate and @pTodate and STUFF(Fmqi.MaterialQcNo,1,1,'') not in (select lotno from myid) 
		 and (@pType='' or @pType is null or @pType = case when Fmqi.DecisionResult='Hold' or mqi.DecisionResult='Hold'  or  SIExtInt01=1  then 'Hold'  else  'Unhold'  end  )
						and (Fmqi.DecisionResult='Hold' or Fmqi.VendorLotNo like '%old%')  and fmqi.MaterialQcNo like 'FVV%'
		)
		or
		(
		 mqi.DecisionDateTime between  @pFromdate and @pTodate and mqi.MaterialQcNo not in (select lotno from myid) 
		 and (@pType='' or @pType is null or @pType = case when Fmqi.DecisionResult='Hold' or mqi.DecisionResult='Hold'  or  SIExtInt01=1  then 'Hold'  else  'Unhold'  end  )
						and (mqi.DecisionResult='Hold'  or mqi.VendorLotNo like '%old%' ) and mqi.MaterialQcNo like 'VV%'
		)
		)
		and (@pSize is null or @pSize='' or mbi.modelname like '%'+@pSize+'%' )
		and ( isnull(@pcreate,'')='' or  si.createuserid = @pcreate )

	  ) 
	  select 
	  holding_Date,
	  line,
	  technical,
	  Size,
	  reason,
	  lotno,
	  lotno as oldlotno,
	  quantity,
	  wip,
	  pic,
	  DeptIC,
	  Expecteddate,
	  Realdate,
	  total_day,
	  DeptProcess,
	  Procedures,
	  OkQty,
	  NgQty,
	  NG_rate,
	  Other,
	  type ,
	  modelcode,
	  modelname,
	  [location],
	  packingid,
	  [Status],
	  ProdMonth
					    ,HoldFileID
						,[FileName]
						,FileSize,
			  CONVERT(VARBINARY(MAX),NULL) as "FileData",

			case when dateadd(  month,  3 , holding_Date ) <= getdate() and [type] like '%Hold%' then 'Expired' 
			when  dateadd(  month,  1 , holding_Date ) <= getdate() and [type] like '%Hold%'  then 'Warning' 
			else 'Safe' end as Statut 

	  from  newtable2
	end

END
---        exec  [dbo].[usp_Vietnam_hodlStituation_get] '','','2021-01-01','2021-05-31','Hold','','','',''

--select*
--,STUFF(Fmqi.MaterialQcNo,1,1,'')
--from
--STB_MaterialQcInfo fmqi
--where MaterialQcNo='VVLM233R015618'
--and  fmqi.DecisionDateTime between  '2019-04-01' and '2021-05-31'  --and STUFF(Fmqi.MaterialQcNo,1,1,'') not in (select lotno from myid) 
--						and (Fmqi.DecisionResult='Hold' or Fmqi.VendorLotNo like '%Hold%') 



--select*
--from
--STB_SetInfo fmqi
--where Barcode='VLM233R015618'


--select*from
--stb_hodl_situationVVT
--where lotno='VVLP293R015609'


--select*from STB_SlittingLocationConfig_VVT

