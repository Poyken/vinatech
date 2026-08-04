-- ==============================================================================
-- SCRIPT DEPLOY DATABASE MES VINATECH - BẢO TOÀN 100% FONT CHỮ UNICODE
-- FIX CHO 3 MÃ KHAY: 153_SACTRAYHL, 153_TRAY0825VPC, 153_SABTRAYHL
--
-- Hướng dẫn:
--   - Mở file này trên SSMS ➔ Chọn DB SmartFactoryV2 ➔ Bấm F5 (Execute).
--   - Hoặc chạy qua PowerShell: .\deploy_tool_standalone.ps1
-- =============================================================================================================================

USE [SmartFactoryV2]
GO

-- Author:		<Mr.Duy>
-- Create date: <22-12-2023>
-- Description:	<Chuyển đổi ngày tháng khi gộp code các nhà cung cấp khác nhau đọc lotno khác nhau>
--    select [dbo].[fn_VVT_getdatebyVendorLot_MergeCode]('GBAXAC-003','150222607110832811','')
--declare @duy varchar(20)=  select [dbo].[fn_VVT_getdatebyVendorLot_MergeCode]('GBNKSP-066','4510N03B','VV040')

--declare @duy varchar(20)=  [dbo].[fn_VVT_getdatebyVendorLot_MergeCode]('153_TRAY1325','20260603','VV026')
--print @duy
-- =============================================
ALTER FUNCTION [dbo].[fn_VVT_getdatebyVendorLot_MergeCode] (
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

	-- ducnv 2026-06-23: Handle '/' separator - take first lot number only (e.g., 010082606010578001/01008... → 010082606010578001)
	if(@vendorlot like '%/%')
		set @vendorlot = LEFT(@vendorlot, CHARINDEX('/', @vendorlot) - 1)
	   	
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
	--vanduc edited by Mrs.Van Oc 20260530
	--START
    /*WHEN @materialcode = 'GBRLAC-005'  THEN 
    '20' + SUBSTRING(@vendorlot, 5, 2) + '-' + -- Lấy '26' -> '2026'
    SUBSTRING(@vendorlot, 7, 2) + '-' +        -- Lấy '03'
    SUBSTRING(@vendorlot, 9, 2)                -- Lấy '27'*/


	-- Mr.Tuân: BG2 Audit 17/06/2026 - Case 1: LotNo 8 số (YYYYMMDD)
	when @materialcode IN ('MMHA00-004',
			'MMHA00-002',
			'MMHA00-003',
			'MMHA00-001',
			'BELAB0-008',
			'DOW01-001',
			'BEINS0-004001')
		and @vendorlot LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
	then
		SUBSTRING(@vendorlot,1,4) + '-' +
		SUBSTRING(@vendorlot,5,2) + '-' +
		SUBSTRING(@vendorlot,7,2)

	-- Mr.Tuân: BG2 Audit 17/06/2026 - Case 2
	WHEN @materialcode IN ('BEASSY-004', 'BEASSY-003','BEMISC-017', 'BEMISC-018')
		AND @vendorlot LIKE 'C________%' 
		AND ISNUMERIC(SUBSTRING(@vendorlot, 10, 4)) = 1 
	THEN
		CONVERT(VARCHAR(10),
			DATEADD(WEEK,
				CAST(RIGHT(SUBSTRING(@vendorlot, 10, 4), 2) AS INT) - 1, 
				DATEADD(DAY,
					-((@@DATEFIRST + DATEPART(WEEKDAY, DATEFROMPARTS(2000 + CAST(LEFT(SUBSTRING(@vendorlot, 10, 4), 2) AS INT), 1, 4)) - 2) % 7),
					DATEFROMPARTS(2000 + CAST(LEFT(SUBSTRING(@vendorlot, 10, 4), 2) AS INT), 1, 4) 
				)
			),
		120)

	-- Mr.Tuân: BG2 Audit 17/06/2026 - Case 3: LotNo dạng H-xxx-WWYY-x
	when @materialcode = 'BEASSY-002'
		and @vendorlot LIKE 'H-%-%-%'
		and ISNUMERIC(SUBSTRING(@vendorlot,
				CHARINDEX('-', @vendorlot, CHARINDEX('-', @vendorlot) + 1) + 1, 4)) = 1
	then
		CONVERT(VARCHAR(10),
			DATEADD(WEEK,
				CAST(LEFT(SUBSTRING(@vendorlot,
					CHARINDEX('-', @vendorlot, CHARINDEX('-', @vendorlot) + 1) + 1, 4), 2) AS INT) - 1,
				DATEADD(DAY,
					-((@@DATEFIRST + DATEPART(WEEKDAY, DATEFROMPARTS(
						2000 + CAST(RIGHT(SUBSTRING(@vendorlot,
							CHARINDEX('-', @vendorlot, CHARINDEX('-', @vendorlot) + 1) + 1, 4), 2) AS INT),
						1, 4)) - 2) % 7),
					DATEFROMPARTS(
						2000 + CAST(RIGHT(SUBSTRING(@vendorlot,
							CHARINDEX('-', @vendorlot, CHARINDEX('-', @vendorlot) + 1) + 1, 4), 2) AS INT),
						1, 4)
				)
			),
		120)
		WHEN @materialcode = 'PBBL00-002'
			AND ISNUMERIC(SUBSTRING(@vendorlot, 10, 4)) = 1
		THEN
			CONVERT(VARCHAR(10),
				DATEADD(WEEK,
					CAST(RIGHT(SUBSTRING(@vendorlot, 10, 4), 2) AS INT) - 1, 
					DATEADD(DAY,
						-((@@DATEFIRST + DATEPART(WEEKDAY, DATEFROMPARTS(2000 + CAST(LEFT(SUBSTRING(@vendorlot, 10, 4), 2) AS INT), 1, 4)) - 2) % 7),
						DATEFROMPARTS(2000 + CAST(LEFT(SUBSTRING(@vendorlot, 10, 4), 2) AS INT), 1, 4) 
					)
				),
			120)
		 WHEN @materialcode = 'PBBL00-003'
			AND ISNUMERIC(SUBSTRING(@vendorlot, 10, 4)) = 1
		THEN
			CONVERT(VARCHAR(10),
				DATEADD(WEEK,
					CAST(RIGHT(SUBSTRING(@vendorlot, 10, 4), 2) AS INT) - 1, 
					DATEADD(DAY,
						-((@@DATEFIRST + DATEPART(WEEKDAY, DATEFROMPARTS(2000 + CAST(LEFT(SUBSTRING(@vendorlot, 10, 4), 2) AS INT), 1, 4)) - 2) % 7),
						DATEFROMPARTS(2000 + CAST(LEFT(SUBSTRING(@vendorlot, 10, 4), 2) AS INT), 1, 4) 
					)
				),
			120)
	--END
    
	 -- 2026-03-02 following Ms.Phuong's request
	 when @materialcode LIKE 'GCMDPT%' and @productGroupCode = 'SLEEVE' then '20'+ substring(@vendorlot,1,2)+'-'+ substring(@vendorlot,3,2)+'-'+ substring(@vendorlot,5,2)
	 when @materialcode in ('GBAXAC-008')  then '2026-07-11'
	 when @materialcode in ('GBAXAC-003') then '2026-07-13'
	  when @materialcode in ('WRHI00-005') and @vendorlot in ('20260727') then '2026-07-27'
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
   --when @materialcode in ('GBNN00-001') and @vendorlot='5292601233036'  then '2026-01-23'
   --when @materialcode in ('GBNN00-002') and @vendorlot='5292601221039' then '2026-01-22'
	--when @materialcode in ('CRNCM85-001') then '2025-05-12'
	--when @materialcode in ('CRPSC95-001') then '2025-05-13'
	when @materialcode in ('GBEC00-S01') then '2025-05-22' -- DinhManh update 2025-06-23 following Ms.Van (warehouse) request
	when @materialcode in ('GCSAAT-002') then '2025-06-23' -- DinhManh update 2025-06-23 following Ms.Van (warehouse) request
	when @materialcode in ('GSJHSC-001') and @vendorlot = 'TO1019-533' then '2025-10-04' -- DinhManh update 2025-11-05 following Ms.Van (warehouse) request
	when @materialcode in ('GBDYAC-001') and @vendorlot IS NOT NULL then '20' +  substring(@vendorlot,2,2) + '-' + substring(@vendorlot,4,2) + '-' +substring(@vendorlot,6,2)-- DinhManh update 2025-11-05 following Ms.Van (warehouse) request
	when @materialcode in ('GBDYAC-004', 'GBDYAC-006') and @vendorlot IS NOT NULL then '20' +  substring(@vendorlot,2,2) + '-' + substring(@vendorlot,4,2) + '-0' +substring(@vendorlot,6,1) -- DinhManh update 2025-11-05 following Ms.Van (warehouse) request

	when @materialcode in ('GBNN00-001', 'GBNN00-002') then '20' + substring(@vendorlot,4,2)+'-'+ substring(@vendorlot,6,2)+'-'+ substring(@vendorlot,8,2)

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


	-- DinhManh update 2025-12-19			example:	3262511300387205|3262511300387206 cÃ¡ch Ä‘á»c 30/11/2025
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

	-- 2026-05-26 Mr.Manh update following Ms.Van request
	when @materialcode IN (	'GBRLAC-007', 'GBRLAC-012')
			and @sourceCustomerCode IN ('VV040') then '20'+ substring(@vendorlot,4,2)
																	+'-'+	substring(@vendorlot,6,2)
																	+'-'+	substring(@vendorlot,8,2)
	when @materialcode IN (	
							'GBRLAC-006', 'GBRLAC-011')
			and @sourceCustomerCode IN ('VV040') then '20'+ substring(@vendorlot,6,2)
																	+'-'+	substring(@vendorlot,8,2)
																	+'-'+	substring(@vendorlot,10,2)

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
							--Kiá»ƒm tra xem NCC nÃ o Ä‘á»ƒ Ä‘á»c lotno tá»«ng nhÃ  cung cáº¥p riÃªng
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
		

									--ÄÃ¢y cá»§a nhÃ  AOXING cung cáº¥p nhÃ´m
								when @sourceCustomerCode in ('VV040')
									then
										case 
										-- ducnv 2026-06-23: VV040 lot 18 số thuần số (vd: 042812605080970005 → 2026-05-08)
										when LEN(@vendorlot) >= 18 AND ISNUMERIC(@vendorlot) = 1
											then '20'+ substring(@vendorlot,6,2)+'-'+ substring(@vendorlot,8,2)+'-'+ substring(@vendorlot,10,2)
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
									
								-- vanduc edited by Mrs.Van Oc 2026-06-23: NCC P000849 format lotno 18 số, vị trí 6,8,10
								when @sourceCustomerCode in ('P000849')
									then
										'20'+ substring(@vendorlot,6,2)
														+'-'
														+ substring(@vendorlot,8,2)
														+'-'
														+ substring(@vendorlot,10,2)
									
							-- Náº¿u khÃ´ng thuá»™c nhÃ  cung cáº¥p riÃªng thÃ¬ sáº½ tá»± phÃ¢n tÃ­ch chung
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
							--Kiá»ƒm tra xem NCC nÃ o Ä‘á»ƒ Ä‘á»c lotno tá»«ng nhÃ  cung cáº¥p riÃªng
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
	when @materialcode in ('153_TRAY1030VPC')  then '2026-07-28'
	when @materialcode in ('GAKCCA-003','GAKCCA-002') then '20'+ substring(@vendorlot,2,2)+'-'+ substring(@vendorlot,4,2)+'-'+ substring(@vendorlot,6,2)
	-- vanduc edited by Mrs.Van Oc 2026-06-23: GBLYAC-002 NCC P000849/VV040 format lotno 18 số, vị trí 6,8,10
	when @materialcode in ('GBLYAC-002') and (
		@sourceCustomerCode in ('P000849')
		OR (@sourceCustomerCode in ('VV040') AND LEN(@vendorlot) >= 18 AND ISNUMERIC(@vendorlot) = 1)
	)
		then '20'+ substring(@vendorlot,6,2)+'-'+ substring(@vendorlot,8,2)+'-'+ substring(@vendorlot,10,2)

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
							'GCTN00-003', 'GBCP00-004','GBCP00-005')   
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
							,'GBNKSP-072',
							 'GBNKSP-042', 
							 'GBNKSP-074',
							 'GBNKSP-069',
							 'GBNKSP-086',
							 'GBNKSP-078'
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
						'REELTAPE06T', 
						'REEL-TAPEM11416'
						)
		
		) and LEFT(@vendorlot, 1) = '2'  then substring(@vendorlot,1,4)+'-'+ substring(@vendorlot,5,2)+'-'+ substring(@vendorlot,7,2)


	when (@materialcode IN (
						'WRHI00-001', 
						'WRHI00-007',--vanduc edited by Mrs.Van Oc 20260623
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
						'153_TRAY1325',
						'BEPCBA-004',
						--vanduc edited by Mr.Cuong 20260602 START
						'128649',
						--END
						-- vanduc edited by Mrs.Van Oc 2026-06-23: Thêm 16 mã nguyên phụ liệu đóng gói - không có vendor lot
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
						'OTCTN5',
						'LABEL010101',
						'LABEL010102',
						'LABEL010103',
						'031889',
						--vanduc edited by VanOc 20260630 11 mã chip nhà cung cấp mới AT06583V không có lotno, nhập Đặc tính 10 bằng tay START
						'VRE-003',
						'VRE-009',
						'VRE-010',
						'VRE-012',
						'VRE-013',
						'VRE-014',
						'VRE-015',
						'VRE-024',
						'VRE-025',
						'VFET-001',
						'VERAN16-010',
						-- vanduc edited by Mrs.Van Oc 20260804: Thêm 3 mã khay không có vendor lot, nhập Đặc tính 10 bằng tay START
						'153_SACTRAYHL',
						'153_TRAY0825VPC',
						'153_SABTRAYHL'
						-- END
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
		OR @materialcode like 'BEHSS0-%'
		OR @materialcode like 'MDBAR-%'
		OR @materialcode like 'MDFLUX-%'
		OR @materialcode LIKE 'CONN-%'
		OR @materialcode LIKE 'SILDOW-%'
		OR @materialcode LIKE 'LABEL010%'
		OR @materialcode LIKE 'MCIS00-%'
		OR @materialcode LIKE 'MCYH00-%'
		OR @materialcode LIKE 'MMBM00-%'
		OR @materialcode LIKE 'MPBT00-%'
		OR @materialcode LIKE 'MCMR00-%'

		OR @materialcode LIKE 'MWLA00-%'
		) 
		-- vanduc edited by Mrs.Van Oc 20260613 START
		-- and LEFT(@vendorlot, 1) = '2'  then substring(@vendorlot,1,4)+'-'+ substring(@vendorlot,5,2)+'-'+ substring(@vendorlot,7,2)		-- update 2026-02-03 because this material dont have vendor lot BG2
		then
			case 
				when LEFT(@vendorlot, 1) = '2' and len(@vendorlot) >= 8 and ISDATE(substring(@vendorlot,1,4)+'-'+ substring(@vendorlot,5,2)+'-'+ substring(@vendorlot,7,2)) = 1
					then substring(@vendorlot,1,4)+'-'+ substring(@vendorlot,5,2)+'-'+ substring(@vendorlot,7,2)
				else CONVERT(VARCHAR(10), GETDATE(), 120)
			end
		-- END

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
						 --,'153_SATRAY2245' -- vanduc edit 20260724: 153_SATRAY2245 khong co vendor lot, nhap Dac tinh 10 bang tay 
						 ,'153_TRAY0825VPC' 
						 ,'153_TRAY_0612-IL'
						 ,'153_TRAY0825VPC(B)'
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


	when @materialcode in('GAJCFO-002' ,'GAJCFO-010') then '20'+ substring(@vendorlot,1,2)+'-'+ substring(@vendorlot,3,2)+'-'+ (case when substring(@vendorlot,5,2)='1' then '07' when substring(@vendorlot,5,2)='2' then '14' when substring(@vendorlot,5,2)='3' then '21' when substring(@vendorlot,5,2)='4' then '28' else '01' end)
	
	when @materialcode in ('GBRBPL-001' ,'GBRBPL-002','GBRBPL-003')  then  '20'+ substring(@vendorlot,9,2)+'-'+ substring(@vendorlot,11,2)+'-'+ substring(@vendorlot,13,2)

	when @materialcode='GAHSCB-001' then '20'+ substring(@vendorlot,4,2)+'-'+ substring(@vendorlot,6,2)+'-'+ substring(@vendorlot,8,2)
	
	when @materialcode='WRHI00-002' then convert(varchar(10),convert(date,@vendorlot, 103),120)

	when @materialcode = 'TRAY1030-DC050' AND @vendorlot = '20260507' then '2026-05-07' --vanduc edit by req C.Van Oc 20260511
	
	

	else '' end	

	--declare @tung varchar(20)= [dbo].[fn_VVT_getdatebyVendorLot]('GAKA00-002','23-04-11-1')
	--print @tung
	return @date

end
GO

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
									when @LotNo like @materialcode+'%'  then replace(@LotNo, left(@LotNo,len(@materialcode)),'')
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
						'OTCTN5',
						'LABEL010101',
						'LABEL010102',
						'LABEL010103',
						--vanduc edited by VanOc 20260630 11 mã chip nhà cung cấp mới AT06583V không có lotno, nhập Đặc tính 10 bằng tay START
						'VRE-003',
						'VRE-009',
						'VRE-010',
						'VRE-012',
						'VRE-013',
						'VRE-014',
						'VRE-015',
						'VRE-024',
						'VRE-025',
						'VFET-001',
						'VERAN16-010',
						'153_SATRAY1325',
						'153_SATRAY2245',
						-- vanduc edited by Mrs.Van Oc 20260804: Thêm 3 mã khay không có vendor lot, nhập Đặc tính 10 bằng tay START
						'153_SACTRAYHL',
						'153_TRAY0825VPC',
						'153_SABTRAYHL'
						-- END

						--END
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
					-- SET LotAttr10 =  Case When Lotno = '' Then ''
						--						 Else  '20' + SubString(Lotno, 20, 2) + '-' + SubString(Lotno, 22, 2) + '-' + SubString(Lotno, 24, 2) End
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
GO
