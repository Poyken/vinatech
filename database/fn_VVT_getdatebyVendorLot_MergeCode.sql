??-- =============================================

-- Author:		<Mr.Duy>

-- Create date: <22-12-2023>

-- Description:	<Chuy?n d?i ng�y th�ng khi g?p code c�c nh� cung c?p kh�c nhau d?c lotno kh�c nhau>

--    select [dbo].[fn_VVT_getdatebyVendorLot_MergeCode]('GAHSCB-001','140-231122-014','12471')

--declare @duy varchar(20)=  select [dbo].[fn_VVT_getdatebyVendorLot_MergeCode]('GBNKSP-066','4510N03B','VV040')

--declare @duy varchar(20)=  [dbo].[fn_VVT_getdatebyVendorLot_MergeCode]('GCMDPT-301','25032988P','10001')

--print @duy

-- =============================================

CREATE FUNCTION [dbo].[fn_VVT_getdatebyVendorLot_MergeCode] (

		@materialcode varchar(20) = null,

		@vendorlot    nvarchar(1000) = null,

		@sourceCustomerCode nvarchar(100) = null

	)

RETURNS varchar(20) AS

BEGIN

declare @date varchar(20)=''

declare @test varchar(200)=@materialcode +'--'+@vendorlot+'--'+@sourceCustomerCode

	set @materialcode=rtrim(ltrim(@materialcode))

	set @vendorlot=rtrim(ltrim(@vendorlot))

	if(@vendorlot like '%#%' and CHARINDEX('#',@vendorlot,1)<12) 

		set @vendorlot = stuff(@vendorlot,1,CHARINDEX('#',@vendorlot,1),'')

	declare @datetest varchar(10)= getdate() ;

	declare @YEARstrElectrode varchar(100)=  'PQRSTUVWXYZABCDEFGHJKLMNO';

	--select SUBSTRING(@YEARstr,(DATEPART(year,'2023-01-01' ))%25+1,1)

	--select (DATEPART(year,@datetest )-2000)/25*25

	--select '2'+right('00'+convert(varchar(3), (DATEPART(year,@datetest )-2000)/25*25 +charindex('q',@YEARstr)-1),3)

	declare @YEARofTerminal varchar(100)=  'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

	declare @dayStrPBDM00 varchar(100)=  '123456789ABCDEFGHJKLMNRSTUVWXYZ';

	declare @productGroupCode VARCHAR(20) = NULL

	select @productGroupCode = ProductGroupCode FROM STB_MaterialMaster where MaterialCode = @materialcode

	set @date = 

	 case 

    WHEN @materialcode = 'GBRLAC-005'  THEN 
    '20' + SUBSTRING(@vendorlot, 5, 2) + '-' + -- L?y '26' -> '2026'
    SUBSTRING(@vendorlot, 7, 2) + '-' +        -- L?y '03'
    SUBSTRING(@vendorlot, 9, 2)                -- L?y '27'

	 -- 2026-03-02 following Ms.Phuong's request

	 when @materialcode LIKE 'GCMDPT%' and @productGroupCode = 'SLEEVE' then '20'+ substring(@vendorlot,1,2)+'-'+ substring(@vendorlot,3,2)+'-'+ substring(@vendorlot,5,2)

	--when @materialcode in ('GCSAAT-001') then 

	--						 '2'+right('00'+convert(varchar(3), (DATEPART(year,@datetest )-2000)/26*26 +charindex(substring(@vendorlot,2,1),@YEARstrElectrode)-1),3)

	--						 +'-'+ substring(@vendorlot,3,2)

	--						 +'-'+ substring(@vendorlot,5,2)

   	--when @materialcode in('GBEC00-011')  and @vendorlot in('EP2512081A') then '2025-12-05'

	--when @materialcode in('GBEC00-011') and @vendorlot in('EP2512051C') then '2025-12-08'

	when @materialcode in('GBEC00-011') and @vendorlot LIKE 'EP%' then '20'+ substring(@vendorlot,3,2) 

																				+'-'

																				+ +substring(@vendorlot,5,2) 

																				+'-'

																		+substring(@vendorlot,7,2)

   when @materialcode in ('GBNN00-001') and @vendorlot='5292601233036'  then '2026-01-23'

   when @materialcode in ('GBNN00-002') and @vendorlot='5292601221039' then '2026-01-22'

	--when @materialcode in ('CRNCM85-001') then '2025-05-12'

	--when @materialcode in ('CRPSC95-001') then '2025-05-13'

	when @materialcode in ('GBEC00-S01') then '2025-05-22' -- DinhManh update 2025-06-23 following Ms.Van (warehouse) request

	when @materialcode in ('GCSAAT-002') then '2025-06-23' -- DinhManh update 2025-06-23 following Ms.Van (warehouse) request

	when @materialcode in ('GSJHSC-001') and @vendorlot = 'TO1019-533' then '2025-10-04' -- DinhManh update 2025-11-05 following Ms.Van (warehouse) request

	when @materialcode in ('GBDYAC-001') and @vendorlot IS NOT NULL then '20' +  substring(@vendorlot,2,2) + '-' + substring(@vendorlot,4,2) + '-' +substring(@vendorlot,6,2)-- DinhManh update 2025-11-05 following Ms.Van (warehouse) request

	when @materialcode in ('GBDYAC-004', 'GBDYAC-006') and @vendorlot IS NOT NULL then '20' +  substring(@vendorlot,2,2) + '-' + substring(@vendorlot,4,2) + '-0' +substring(@vendorlot,6,1) -- DinhManh update 2025-11-05 following Ms.Van (warehouse) request

	when @materialcode in ('GSJHSC-001') and @vendorlot IN (

		'TO1020-554M',

		'TO1020-554L', 

		'TO1020-533L',

		'TO1020-533K',

		'TO1020-533M',

		'TO1020-547L',

		'TO1020-523M',

		'TO1020-547M',

		'TO1020-541L',

		'TO1020-245L',

		'TO1021-554K',

		'TO1021-554M',

		'TO1021-533L',

		'TO1021-554L',

		'TO1020-245L',

		'TO1020-541M',

		'TO1021-547L',

		'TO1020-245L',

		'TO1020-541M'

			) then '2025-10-08' -- DinhManh update 2025-11-10 following Ms.Van (warehouse) request

	when @materialcode in ('GBNKSP-083') and @vendorlot IN (

		'5Y13N36F'

			) then '2025-11-13' -- DinhManh update 2026-02-26 following Ms.Van (warehouse) request

	when @materialcode in ('GBSN00-001') and @vendorlot IN (

		'12SR07-5N21'

			) then '2025-11-21' -- DinhManh update 2026-02-26 following Ms.Van (warehouse) request

	when @materialcode in ('GSJHSC-001') and @vendorlot IN (

		'TO1019-554K',

		'TO1019-554J',

		'TO1019-533J',

		'TO1019-533L',

		'TO1019-547L',

		'TO1019-547K',

		'TO1019-547M',

		'TO1019-547J',

		'TO1019-533K',

		'TO1019-533M'

			) then '2025-10-12' -- DinhManh update 2025-11-12 following Ms.Van (warehouse) request

	when @materialcode in ('GCTN00-002') and @vendorlot IN (

		'WL60153510-415'

			) then '2026-01-05' -- DinhManh update 2026-01-27 following Ms.Van (warehouse) request

	when @materialcode in ('GBRLAC-005') and @vendorlot LIKE 'C260135%' then '2026-01-03' -- DinhManh update 2026-01-27 following Ms.Van (warehouse) request

	when @materialcode in ('GBRLAC-004', 'GBAKAC-060') and @vendorlot LIKE 'C2%' then '20'+ substring(@vendorlot,2,2)

																						+'-'+	substring(@vendorlot,4,2)

																						+'-'+	substring(@vendorlot,6,2) -- DinhManh update 2026-01-27 following Ms.Van (warehouse) request

	-- DinhManh update 2025-12-19			example:	3262511300387205|3262511300387206 cách đọc 30/11/2025

	when @materialcode IN ('GBAKAC-060') and @vendorlot LIKE '326%' then '20'+ substring(@vendorlot,4,2) 

																				+'-'

																				+ +substring(@vendorlot,6,2) 

																				+'-'

																				+substring(@vendorlot,8,2)

	when @materialcode in ('GBSN00-008', 'GBSN00-009') then '2025-09-12' -- DinhManh update 2025-09-22 following Ms.Van (warehouse) request

	-- Mr.Manh add 2025-12-30

	when @materialcode in ('GBLYAC-003', 'GBRLAC-005') and @vendorlot LIKE 'F-%' then substring(@vendorlot,4,2)+'-'+ substring(@vendorlot,7,2)

	when @materialcode in ('GBAKAC-037') and @vendorlot LIKE 'F%' then substring(@vendorlot,3,2)+'-'+ substring(@vendorlot,6,2)

	-- end add

	when @materialcode in ('GAKA00-002') then '20'+ substring(@vendorlot,1,8)

	when @materialcode in ('GBRLAC-005') then

											'20' + substring(@vendorlot,4,2)

											+ '-'

											+ substring(@vendorlot,6,2)

											+ '-'

											+ substring(@vendorlot,8,2)

	when @materialcode in ('GBRLAC-004',

							'GBRLAC-002',

							'GBRLAC-006',

							'GBRLAC-007', 

							'GBRLAC-008',

							'GBRLAC-010',

							'GBRLAC-011',

							'GBLYAC-008',

							'GBRLAC-009',

							'GBRLAC-012') then '20'+ substring(@vendorlot,5,2)

																	+'-'+	substring(@vendorlot,7,2)

																	+'-'+	substring(@vendorlot,9,2)

	when @materialcode in ('GBTPPL-002') then '20'+ substring(@vendorlot,1,2)

	+'-'+	substring(@vendorlot,3,2)

	+'-'+	substring(@vendorlot,5,2)

	when @materialcode IN ('ECVT30-358') then CONVERT(DATE, dbo.fnPharseLotNo(@vendorlot, 'D'),112)

	/*when @materialcode in ('GBAKAC-S06'

						) then '202'+ substring(@vendorlot,2,1) 

											+'-'

											+ right('0' + case 

											when substring(@vendorlot,3,1)='A' then '10'

											when substring(@vendorlot,3,1)='B' then '11'

											when substring(@vendorlot,3,1)='C' then '12'

											else substring(@vendorlot,3,1) end,2)

											+'-'

											+substring(@vendorlot,4,2) */

	--140-231122-014

	--    declare @duy varchar(20)= [dbo].[fn_VVT_getdatebyVendorLot_MergeCode]('GBAKAC-059','B3B09533J10030','12')

	--    print @duy 

	when @materialcode in (

						 'GBAKAC-004'

						,'GBAKAC-005'

						,'GBAKAC-013'

						,'GBAKAC-029'

						,'GBAKAC-032'

						,'GBAKAC-033'

						,'GBAKAC-036'

						,'GBAKAC-037'	

						,'GBAKAC-039'

						,'GBAKAC-048'

						,'GBAKAC-051'

						,'GBAKAC-052'

						,'GBAKAC-053'

						,'GBAKAC-054'

						,'GBAKAC-059'

						,'GBAKAC-060'

						,'GBAKAC-062'

						,'GBAKAC-063'

						,'GBAKAC-064'

						,'GBAKAC-065'

						,'GBAKAC-066'

						,'GBAKAC-068'

						,'GBAKAC-071'

						,'GBAKAC-608'

						,'GBAKAC-615'

						,'GBAKAC-S03'

						,'GBAKAC-S13'

						,'GBAKAC-S06'

						,'GBAKAC-S09'

						,'GBAKAC-V03'

						,'GBAKAC-050'

						,'GBAKAC-092'

						) then 

							case 

							--Kiểm tra xem NCC nào để đọc lotno từng nhà cung cấp riêng

								when @sourceCustomerCode in ('VV033')

									then

										case 

											when @vendorlot like '%-%' and @materialcode in (

											 'GBAKAC-004'

											,'GBAKAC-005'

											,'GBAKAC-013'

											,'GBAKAC-029'

											,'GBAKAC-032'

											,'GBAKAC-033'

											,'GBAKAC-036'

											,'GBAKAC-037'	

											,'GBAKAC-039'

											,'GBAKAC-048'

											,'GBAKAC-051'

											,'GBAKAC-052'

											,'GBAKAC-053'

											,'GBAKAC-054'

											,'GBAKAC-059'

											,'GBAKAC-060'

											,'GBAKAC-062'

											,'GBAKAC-063'

											,'GBAKAC-064'

											,'GBAKAC-065'

											,'GBAKAC-066'

											,'GBAKAC-068'

											,'GBAKAC-071'

											,'GBAKAC-608'

											,'GBAKAC-615'

											,'GBAKAC-S03'

											,'GBAKAC-S13'

											,'GBAKAC-S06'

											,'GBAKAC-S09'

											,'GBAKAC-V03'

											,'GBAKAC-050' -- add 2025-08-29

											,'GBAKAC-092'

											)

												then

												'20'+ substring(@vendorlot,5,2) 

																+'-'

																+ +substring(@vendorlot,7,2) 

																+'-'

																+substring(@vendorlot,9,2)

											else

											'20'+ substring(@vendorlot,3,2) 

															+'-'

															+ +substring(@vendorlot,5,2) 

															+'-'

															+substring(@vendorlot,7,2)

											end		

									--Đây của nhà AOXING cung cấp nhôm

								when @sourceCustomerCode in ('VV040')

									then

										case 

										when  @materialcode in (

										'GBAKAC-005'

										,'GBAKAC-060'

										,'GBAKAC-068'

										)

											then

											   case

											     when substring(@vendorlot,4,1) ='A'then '2025'

												 when substring(@vendorlot,4,1) ='B'then '2026'

												 when substring(@vendorlot,4,1) ='C'then '2027'

												 when substring(@vendorlot,4,1) ='D'then '2028'

												 when substring(@vendorlot,4,1) ='E'then '2029'

												 when substring(@vendorlot,4,1) ='F'then '2030'

												 when substring(@vendorlot,4,1) ='G'then '2031'

												 when substring(@vendorlot,4,1) ='H'then '2024'

												  else '' end

															+'-'

													+   case

											     when substring(@vendorlot,5,1) ='A'then '01'

												 when substring(@vendorlot,5,1) ='B'then '02'

												 when substring(@vendorlot,5,1) ='C'then '03'

												 when substring(@vendorlot,5,1) ='D'then '04'

												 when substring(@vendorlot,5,1) ='E'then '05'

												 when substring(@vendorlot,5,1) ='F'then '06'

												 when substring(@vendorlot,5,1) ='G'then '07'

												 when substring(@vendorlot,5,1) ='H'then '08'

												 when substring(@vendorlot,5,1) ='K'then '09'

												 when substring(@vendorlot,5,1) ='X'then '10'

												 when substring(@vendorlot,5,1) ='T'then '11'

												 when substring(@vendorlot,5,1) ='R'then '12'

												  else '' end

															+'-'

															+substring(@vendorlot,6,2)

										else

										'20'+ substring(@vendorlot,3,2) 

														+'-'

														+ +substring(@vendorlot,5,2) 

														+'-'

														+substring(@vendorlot,7,2)

										end

							-- End 

							-- Nếu không thuộc nhà cung cấp riêng thì sẽ tự phân tích chung

									else

									'20'+ substring(@vendorlot,5,2) 

															+'-'

															+ +substring(@vendorlot,7,2) 

															+'-'

															+substring(@vendorlot,9,2)

							end 

	-- 2025-11-14 Mr.Manh update following Ms.Van request

	when @materialcode IN ('SRECEK0', 'SREHBO0', 'SREHCO0', 'CRPSC95-001', 'CRNCM85-001') then 

		case	when substring(@vendorlot,3,1) ='P'then '2025'

				when substring(@vendorlot,3,1) ='Q'then '2026'

				when substring(@vendorlot,3,1) ='R'then '2027'

				when substring(@vendorlot,3,1) ='S'then '2028'

				when substring(@vendorlot,3,1) ='T'then '2029'

				when substring(@vendorlot,3,1) ='U'then '2030'

				when substring(@vendorlot,3,1) ='V'then '2031'

				when substring(@vendorlot,3,1) ='W'then '2032'

			else '' end

					+'-'+

		case	when substring(@vendorlot,4,1) ='J'then '01'

				when substring(@vendorlot,4,1) ='K'then '02'

				when substring(@vendorlot,4,1) ='L'then '03'

				when substring(@vendorlot,4,1) ='M'then '04'

				when substring(@vendorlot,4,1) ='N'then '05'

				when substring(@vendorlot,4,1) ='O'then '06'

				when substring(@vendorlot,4,1) ='P'then '07'

				when substring(@vendorlot,4,1) ='Q'then '08'

				when substring(@vendorlot,4,1) ='R'then '09'

				when substring(@vendorlot,4,1) ='S'then '10'

				when substring(@vendorlot,4,1) ='T'then '11'

				when substring(@vendorlot,4,1) ='U'then '12'

			else '' end

					+'-' + substring(@vendorlot,5,2)

	-- 2025-11-14 END UPDATE			

when @materialcode in (

						 'GCMDPT-382',

						 'GCMDPT-479',

						 'GCMDPT-S04',

						 'GCMDPT-383',

						 'GCMDPT-379'

						 --'GCMDPT-475'

						) then 

							case 

							--Kiểm tra xem NCC nào để đọc lotno từng nhà cung cấp riêng

								when @sourceCustomerCode in ('VV034')

									then

										case 

										when @materialcode in (

										 'GCMDPT-382',

										 'GCMDPT-479',

										 'GCMDPT-S04',

										 'GCMDPT-383',

										 'GCMDPT-379'

										)

										then

										'20'+ substring(@vendorlot,1,2) 

															+'-'

															+ +substring(@vendorlot,3,2) 

															+'-'

															+substring(@vendorlot,5,2)

										else

										'20'+ substring(@vendorlot,1,2) 

														+'-'

														+ +substring(@vendorlot,3,2) 

														+'-'

														+substring(@vendorlot,5,2)

										end

									else

									'20'+ substring(@vendorlot,1,2) 

														+'-'

														+ +substring(@vendorlot,3,2) 

														+'-'

														+substring(@vendorlot,5,2)

							end 

	when @materialcode in ('GAKCCA-003','GAKCCA-002') then '20'+ substring(@vendorlot,2,2)+'-'+ substring(@vendorlot,4,2)+'-'+ substring(@vendorlot,6,2)

	when @materialcode in ('GBLYAC-002','GBLYAC-003','GBLYAC-004', 'GBLYAC-006') then '20'+ substring(@vendorlot,5,2)+'-'+ substring(@vendorlot,7,2)+'-'+ substring(@vendorlot,9,2)

		when @materialcode in ('GBYCTT-002','GBYCTT-003') then '20'+ substring(@vendorlot,4,2)+'-'+ substring(@vendorlot,6,2)+'-'+ substring(@vendorlot,8,2)

			when @materialcode in ('GBYYPL-001') then '20'+ substring(@vendorlot,1,2)+'-'+ substring(@vendorlot,3,2)+'-'+ substring(@vendorlot,5,2)

	when @materialcode = 'GADACB-001' and len(@vendorlot) >= 5 then 

		'20' + substring(@vendorlot, 1, 2) + '-' + 

		(case substring(@vendorlot, 4, 1) 

			when 'X' then '10' when 'Y' then '11' when 'Z' then '12' 

			when 'A' then '10' when 'B' then '11' when 'C' then '12'

			else '0' + substring(@vendorlot, 4, 1) end) + '-' +

		(case when substring(@vendorlot, 5, 1) between 'A' and 'Z' 

			then right('0' + cast(ascii(substring(@vendorlot, 5, 1)) - 64 as varchar), 2)

			else right('0' + substring(@vendorlot, 5, 1), 2) end)

/*	when (@materialcode IN (

			'GADACB-001'

			)

		) and LEFT(@vendorlot, 1) = '2'  then substring(@vendorlot,1,4)+'-'+ substring(@vendorlot,5,2)+'-'+ substring(@vendorlot,7,2)	

	when @materialcode='GADACB-001' then 

									'20'+ case when substring(@vendorlot,1,1)=1 then '24' else '25' end

									+'-0'+ substring(@vendorlot,4,1) +'-0'+ substring(@vendorlot,6,1)

*/

	when @materialcode = 'GBEC00-008' then '20' + SUBSTRING(@vendorlot,3,2) +'-'+ SUBSTRING(@vendorlot,5,2)+'-'+ SUBSTRING(@vendorlot,7,2)   -- DinhManh update 2025-06-23 following Ms.Van (warehouse) request

	when @materialcode in ('GBEC00-005') then '20' + SUBSTRING(@vendorlot,4,2) +'-'+ SUBSTRING(@vendorlot,6,2)+'-'+ SUBSTRING(@vendorlot,8,2)

	--when @materialcode in ('GBEC00-005','GBEC00-008') then '20' + SUBSTRING(@vendorlot,4,2) +'-'+ SUBSTRING(@vendorlot,6,2)+'-'+ SUBSTRING(@vendorlot,8,2)

	when @materialcode='GADPCB-002' then '20'+ substring(@vendorlot,1,2)+'-'+ substring(@vendorlot,3,2) + '-15'

	--when @materialcode='PBDM00-187' then 

	--										'20'+ substring(@vendorlot,1,2)

	--										+'-'

	--										+ right('0'+case 

	--										when substring(@vendorlot,3,1)='A' then '10'

	--										when substring(@vendorlot,3,1)='B' then '11'

	--										when substring(@vendorlot,3,1)='C' then '12'

	--										else substring(@vendorlot,3,1) end,2)

	--										+'-'

	--										+ right('0'+convert(varchar(3),CHARINDEX('z',@dayStrPBDM00)),2)

	when @materialcode in  ('GCTN00-S01',

							'GCTN00-002',

							--'GCTN00-003',

							'GCTN00-S03',

							'GCTN00-004',						

							'GCTN00-005')   then 

											(case when (substring(@vendorlot,3,1)<'7') then '202' else '201' end )

											+ substring(@vendorlot,3,1) 

											+ '-' 

											+ substring(@vendorlot,4,2) 

											+ '-' 

											+ substring(@vendorlot,6,2)

	when @materialcode IN ('GAHCCA-001') --6250118

							then   '202' 	+ substring(@vendorlot,1,1) 

											+ '-0' 

											+ substring(@vendorlot,2,1) 

											+ '-0' 

											+ substring(@vendorlot,3,1)

	when @materialcode in  (

							'GAHKCB-002')   

							then 

											'20'

											+ substring(@vendorlot,5,2) 

											+ '-' 

											+ substring(@vendorlot,7,2) 

											+ '-' 

											+ substring(@vendorlot,9,2)

	when @materialcode in  (

							'GCTN00-003', 'GBCP00-004')   

							then 

											'20'

											+ substring(@vendorlot,3,2) 

											+ '-' 

											+ substring(@vendorlot,5,2) 

											+ '-' 

											+ substring(@vendorlot,7,2)

	when @materialcode in  ('GBCP00-S06')   then 

											'20'+ substring(@vendorlot,4,2) 

											+ '-' 

											+'0'+substring(@vendorlot,6,1) 

											+ '-' 

											+'0'+ substring(@vendorlot,7,1)

	when @materialcode in  ('GCMTTT-013','GCMTTT-023','GCMTTT-024')   then 

											'20'+ substring(@vendorlot,1,2) 

											+ '-' 

											+substring(@vendorlot,3,2) 

											+ '-' 

											+ substring(@vendorlot,5,2)

	when @materialcode in  ('GBNKSP-060'

							,'GBNKSP-066'

							,'GBNKSP-067'

							,'GBNKSP-068'

							,'GBNKSP-080'

							,'GBNKSP-081'

							,'GBNKSP-083'

							,'GBNKSP-059'

							,'GBNKSP-057'

							,'GBNKSP-054'

							,'GBNKSP-061'

							,'GBNKSP-068'

							,'GBNKSP-080'

							,'GBNKSP-077'

							,'GBNKSP-079'

							,'GBNKSP-063'

							,'GBNKSP-061'

							,'GBNKSP-072'

								)   then 

											'202'+ substring(@vendorlot,1,1) 

											+ '-' 

											+ 

											case 

											when substring(@vendorlot,2,1)='X' then '10'

											when substring(@vendorlot,2,1)='Y' then '11'

											when substring(@vendorlot,2,1)='Z' then '12' else '0'+	substring(@vendorlot,2,1)  end

											+ '-' 

											+ substring(@vendorlot,3,2)

	when @materialcode IN (	'GBSN00-007',

							'GBSN00-005',

							'GBSN00-001','GBSN00-002') THEN '202'+ substring(@vendorlot,8,1) 

											+ '-' 

											+ 

											case 

											when substring(@vendorlot,9,1)='O' then '10'

											when substring(@vendorlot,9,1)='N' then '11'

											when substring(@vendorlot,9,1)='D' then '12' 

											else '0'+	substring(@vendorlot,9,1)  end

											+ '-' 

											+ substring(@vendorlot,10,2)		-- 2026-04-02

	when @materialcode in  ('GBSN00-003')   

											then 

											'202'+ substring(@vendorlot,8,1) 

											+ '-' 

											+

											(case 

											when substring(@vendorlot,9,1)='D' then '12'

											when substring(@vendorlot,9,1)='N' then '11'

											when substring(@vendorlot,9,1)='O' then '10'

											when substring(@vendorlot,9,1)='D' then '09'

											when substring(@vendorlot,9,1)='E' then '08'

											when substring(@vendorlot,9,1)='F' then '07'

											when substring(@vendorlot,9,1)='G' then '06'

											when substring(@vendorlot,9,1)='H' then '05'

											when substring(@vendorlot,9,1)='J' then '04'

											when substring(@vendorlot,9,1)='K' then '03'

											when substring(@vendorlot,9,1)='L' then '02'

											when substring(@vendorlot,9,1)='M' then '01' end )

											+ '-' 

											+ substring(@vendorlot,10,2)

	when @materialcode in  (

							'GCMTTT-002',

							'GCMTTT-012'

							--'GCMTTT-013'

							)   then 

											'20' + substring(@vendorlot,1,2) 

											+ '-' 

											+ (case 

											when substring(@vendorlot,3,1)='A' then '12'

											when substring(@vendorlot,3,1)='B' then '11'

											when substring(@vendorlot,3,1)='C' then '10'

											when substring(@vendorlot,3,1)='D' then '09'

											when substring(@vendorlot,3,1)='E' then '08'

											when substring(@vendorlot,3,1)='F' then '07'

											when substring(@vendorlot,3,1)='G' then '06'

											when substring(@vendorlot,3,1)='H' then '05'

											when substring(@vendorlot,3,1)='J' then '04'

											when substring(@vendorlot,3,1)='K' then '03'

											when substring(@vendorlot,3,1)='L' then '02'

											when substring(@vendorlot,3,1)='M' then '01' else

											substring(@vendorlot,3,2) 

											 end )

											+ '-' 

											+ substring(@vendorlot,5,2)

	when @materialcode in ('GAPOCA-006','GAPOCA-009') then 

											'20' + substring(@vendorlot,5,2) 

											+ '-' 

											+(case 

											when substring(@vendorlot,7,1)='A' then '01'

											when substring(@vendorlot,7,1)='B' then '02'

											when substring(@vendorlot,7,1)='C' then '03'

											when substring(@vendorlot,7,1)='D' then '04'

											when substring(@vendorlot,7,1)='E' then '05'

											when substring(@vendorlot,7,1)='F' then '06'

											when substring(@vendorlot,7,1)='G' then '07'

											when substring(@vendorlot,7,1)='H' then '08'

											when substring(@vendorlot,7,1)='J' then '09'

											when substring(@vendorlot,7,1)='K' then '10'

											when substring(@vendorlot,7,1)='L' then '11'

											when substring(@vendorlot,7,1)='M' then '12' end)

											+'-'+substring(@vendorlot,8,2)											

	when (@materialcode IN (

						'WRHI00-001', 

						'BEMP00-005', 

						'BEMC00-113',

						'PBDM00-187',

						'153_CHATPHUBM',

						'153_CHATPHUBM-01',

						'153_CHATPHUBM-02',

						'153_SATRAY1030' ,

						'TRAY1320-B015',

						'LABEL-001',

						'BEMC00-00',

						'BEMISC-010',

						'BEMISC-009',

						'BEINS0-009',

						'BEBB00-001',

						'BESM00-001',

						'BESM00-002',

						'BESM00-003',

						'BESM00-004',

						'BESM00-005',

						'BESM00-006',

						'BESM00-007',

						'BEMC00-117',

						'BEMC00-118',

						'PBDM00-187',

						'BEMC00-065',

						'VSBMD16-001',

						'VMDDW00-001',

						'MDCLEAN-001',

						'MDFLUX-001',

						'MDIPA-001',

						'GCSAAT-001',

						'BEPCBA-004'

						)

		OR @materialcode like 'BELAB0-%'

		OR @materialcode like 'BEWH00-%'

		OR @materialcode like 'BEPCBA-%'

		OR @materialcode like 'BEMP00-%'

		OR @materialcode like 'BEMC00-%'

		OR @materialcode like 'BEASSY-%'

		OR @materialcode like 'PBBL00-%'

		OR @materialcode like 'PBDM00-%'

		OR @materialcode like 'MCYH00-%'

		OR @materialcode like 'BEFN00-%'

		OR @materialcode like 'BEMISC-%'

		OR @materialcode like 'MDBAR-%'

		OR @materialcode like 'MDFLUX-%'

		OR @materialcode LIKE 'CONN-%'

		OR @materialcode LIKE 'SILDOW-%'

		) and LEFT(@vendorlot, 1) = '2'  then substring(@vendorlot,1,4)+'-'+ substring(@vendorlot,5,2)+'-'+ substring(@vendorlot,7,2)		-- update 2026-02-03 because this material dont have vendor lot BG2

	when @materialcode IN ( '16485-A', '164855-B', '164855-C', '164855-S')

	 then case	when substring(@vendorlot,3,1) ='P'then '2025'

				when substring(@vendorlot,3,1) ='Q'then '2026'

				when substring(@vendorlot,3,1) ='R'then '2027'

				when substring(@vendorlot,3,1) ='S'then '2028'

				when substring(@vendorlot,3,1) ='T'then '2029'

				when substring(@vendorlot,3,1) ='U'then '2030'

				when substring(@vendorlot,3,1) ='V'then '2031'

				when substring(@vendorlot,3,1) ='W'then '2032'

			else '' end

					+'-'+

		case	when substring(@vendorlot,4,1) ='J'then '01'

				when substring(@vendorlot,4,1) ='K'then '02'

				when substring(@vendorlot,4,1) ='L'then '03'

				when substring(@vendorlot,4,1) ='M'then '04'

				when substring(@vendorlot,4,1) ='N'then '05'

				when substring(@vendorlot,4,1) ='O'then '06'

				when substring(@vendorlot,4,1) ='P'then '07'

				when substring(@vendorlot,4,1) ='Q'then '08'

				when substring(@vendorlot,4,1) ='R'then '09'

				when substring(@vendorlot,4,1) ='S'then '10'

				when substring(@vendorlot,4,1) ='T'then '11'

				when substring(@vendorlot,4,1) ='U'then '12'

			else '' end

					+'-' + substring(@vendorlot,5,2)		-- 2026-04-08 add for 35105 BG2

	when @materialcode IN (

							'BEASSY-002',

							'BEFN00-021',

							'BEMISC-007',

							'BEMISC-008',

							'BEFN00-027',

							'BEFN00-022',

							'BEFN00-023',

							'BEFN00-019',

							'BEFN00-024',

							'BEFN00-025',

							'BEFN00-020',

							'BEFN00-026',

							'BEFN00-028',

							'BEFN00-029')  then substring(@vendorlot,3,4)+'-'+ substring(@vendorlot,7,2)+'-'+ substring(@vendorlot,9,2) -- 2026-02-11 - BG2

    when @materialcode in ('GAZOCB-001' 

						 ,'GCMDPT-309' 

						 ,'GCMDPT-392'

						 ,'GCMDPT-442' 

						 ,'GCMDPT-471' 

						 ,'GCMDPT-308' 

						 ,'GCMDPT-475'  --update 2025-08-06

						 ,'GCMDPT-419'  --update 2025-08-06

						 ,'GCMDPT-406'  --update 2025-08-06

						 ,'GCMDPT-507'  --update 2026-02-05

						 ,'GCMDPT-469'  --update 2026-02-05

						 ,'GCMDPT-200'	--update 2026-03-02

						 ,'GCMDPT-468'	--update 2026-03-02

						 ,'GCMDPT-202'	--update 2026-03-02

						 --,'GCMDPT-409'	--update 2026-03-02

						 --,'GCMDPT-301'	--update 2026-03-02

						 --,'GCMDPT-450'	--update 2026-03-02

						 --,'GCMDPT-432'

						 ,'GBHB00-042',

						 'GBHB00-031',

						 'GBHB00-032',

						 'GBHB00-033',

						 'GBHB00-034',

						 'GBHB00-036',

						 'GBHB00-035',

						 'GBHB00-050',

						 'GBHB00-049',

						 'GBHB00-S05'

						 ,'GCSN00-001'

						 ,'GCSN00-002'

						 ,'GCSN00-003'

						 ,'VSBMD16-001' 

						 ,'VMDDW00-001' 

						 ,'153_BTRAYMD' 

						 ,'153_CTRAYMD' 

						 ,'153_SABTRAYHL' 

						 ,'153_SACTRAYHL' 

						 ,'153_SATRAY_VNF' 

						 ,'153_SATRAY0820-OL' 

						 --,'153_SATRAY1030' 

						 ,'153_SATRAY1320' 

						 ,'TRAY1320-B015'

						 ,'153_SATRAY1325' 

						 ,'153_SATRAY2245' 

						 ,'153_TRAY0825VPC' 

						 ,'153_TRAY_0612-IL'

						 ,'153_TRAY0825VPC(B)'

						 ,'153_TRAY1030VPC'

						 ,'PBDM00-186'

						 ,'PBDM00-184'

						 ,'PBDM00-171'

						 ,'WRHI00-001')  then '20'+ substring(@vendorlot,1,2)+'-'+ substring(@vendorlot,3,2)+'-'+ substring(@vendorlot,5,2)

	when @materialcode in ('CRNCA5-002','CRPSC0-002','SREYPK0','SRFYPK0')  or substring(@vendorlot,1,2) in ('VV','VJ') and left(right(@vendorlot,3),1)='E'

													                   then 

																			'2'+right('00'+convert(varchar(3), (DATEPART(year,@datetest )-2000)/25*25 +charindex(substring(@vendorlot,3,1),@YEARstrElectrode)-1),3)

																			+ '-' 

																			+(case 

																			when substring(@vendorlot,4,1)='J' then '01'

																			when substring(@vendorlot,4,1)='K' then '02'

																			when substring(@vendorlot,4,1)='L' then '03'

																			when substring(@vendorlot,4,1)='M' then '04'

																			when substring(@vendorlot,4,1)='N' then '05'

																			when substring(@vendorlot,4,1)='O' then '06'

																			when substring(@vendorlot,4,1)='P' then '07'

																			when substring(@vendorlot,4,1)='Q' then '08'

																			when substring(@vendorlot,4,1)='R' then '09'

																			when substring(@vendorlot,4,1)='S' then '10'

																			when substring(@vendorlot,4,1)='T' then '11'

																			when substring(@vendorlot,4,1)='U' then '12' end)

																			+'-'

																			+ substring(@vendorlot,5,2)

	when @materialcode in('GAJCFO-002' ,'GAJCFO-010') then '20'+ substring(@vendorlot,1,2)+'-'+ substring(@vendorlot,3,2)+'-'+ (case when substring(@vendorlot,5,2)='1' then '07' when substring(@vendorlot,5,2)='2' then '14' when substring(@vendorlot,5,2)='3' 
then '21' when substring(@vendorlot,5,2)='4' then '28' else '01' end)

	when @materialcode in ('GBRBPL-001' ,'GBRBPL-002','GBRBPL-003')  then  '20'+ substring(@vendorlot,9,2)+'-'+ substring(@vendorlot,11,2)+'-'+ substring(@vendorlot,13,2)

	when @materialcode='GAHSCB-001' then '20'+ substring(@vendorlot,4,2)+'-'+ substring(@vendorlot,6,2)+'-'+ substring(@vendorlot,8,2)

	when @materialcode='WRHI00-002' then convert(varchar(10),convert(date,@vendorlot, 103),120)

	else '' end	

	--declare @tung varchar(20)= [dbo].[fn_VVT_getdatebyVendorLot]('GAKA00-002','23-04-11-1')

	--print @tung

	return @date

end
