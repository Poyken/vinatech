-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리
-- Description:	전극슬리팅결과정보
-- 2021.11.08  조회항목추가 (밀도값)
-- [usp_ElectrodeSlittingResult_get] '','', 'VVQK2718001E32'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeSlittingResult_get]
	  @pProcessUserID VARCHAR(20),
	  @pProcessLanguage VARCHAR(20),
	  @pElectrodeLotNumber VARCHAR(20) = NULL
--	, @pQcRollingDensityValue Numeric = Null
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	       ,@UserCompanyCode VARCHAR(20)

	SET @ElectrodeLotNumber = @pElectrodeLotNumber

	SELECT @UserCompanyCode = CompanyCode 
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID



	--raiserror ( @ElectrodeLotNumber ,16,1) ;
	IF @UserCompanyCode = 'VNT' BEGIN
		SELECT   ESR.ElectrodeLotNumber
				,ESR.Seq
				,ESR.ElectrodeThick
				,ESR.SlittingWidth
				,ESR.ProductionQty
				,ESR.GoodQtyLength
				,ESR.CreateDateTime
				,ESR.CreateUserID
				,ESR.ChangeDateTime
				,ESR.ChangeUserID
				,'Report' AS CommandType
				,ESR.Barcode
				,ESR.LotUniqueNumber
				,RIGHT(ESR.Barcode, 3) AS CutNo
				,MM.MaterialSource
				--, '' AS QcRollingDensityValue
				, Round(dbo.fnGetElectrodeDensityAvg(@ElectrodeLotNumber), 3) AS QcRollingDensityValue
				,ESR.SlittingMaterialCode
		  FROM STB_ElectrodeSlittingResult ESR
				  LEFT OUTER JOIN STB_SetInfo SI	                ON ESR.ElectrodeLotNumber = SI.Barcode
				  LEFT OUTER JOIN STB_MaterialMaster MM	 ON MM.MaterialCode = SI.MaterialCode
		 WHERE ESR.ElectrodeLotNumber = @ElectrodeLotNumber
		 ORDER BY Seq
	 END ELSE BEGIN
		;with
			getlistElect as (
					SELECT   ESR.ElectrodeLotNumber
					--,ESR.Seq
					,ESR.ElectrodeThick
					,ESR.SlittingWidth
					,MaterialThickness
					,ESR.ProductionQty
					,ESR.GoodQtyLength
					,ESR.CreateDateTime
					,ESR.CreateUserID
					,ESR.ChangeDateTime
					,ESR.ChangeUserID
					,'Report' AS CommandType
					,ESR.Barcode
					,ESR.Seq
					,ESR.LotUniqueNumber
					,RIGHT(ESR.Barcode, 3) AS CutNo
					,MM.MaterialSource
					,MM.MaterialCode
					,MM.MaterialName
					, Round(dbo.fnGetElectrodeDensityAvg(@ElectrodeLotNumber), 3) AS QcRollingDensityValue
					,ESR.SlittingMaterialCode
					,SI.GradeModelCode  --updated
			  FROM STB_ElectrodeSlittingResult ESR
					  LEFT OUTER JOIN STB_SetInfo SI	                ON ESR.ElectrodeLotNumber = SI.Barcode
					  LEFT OUTER JOIN STB_MaterialMaster MM	 ON MM.MaterialCode = SI.MaterialCode
			 WHERE ESR.ElectrodeLotNumber = @ElectrodeLotNumber
			 --ORDER BY Seq
			),
			getconfig as(
			select distinct Partno,SlittingCode,SlittingSize ,Width, min(Farad) as Farad
			from stb_slittinglocationconfig_vvt vvt	with(nolock) 
			join getlistElect cw on (SlittingCode like '%'+cw.MaterialSource+'%' and  (replace(SlittingCode,SlittingSize,'') + SlittingSize) like '%'+cw.MaterialThickness+'%' 
			or MaterialName like '%'+replace(SlittingCode,SlittingSize,'')+'%'+SlittingSize+'%' ) 
			and  Width=cw.SlittingWidth 
			and vvt.WarehouseLocation IN ('VVT_F1') -- hiện tại chỉ có bắc ninh sản xuất điện cực nên so sánh với config điện cực của bắc ninh
			group by Partno,SlittingCode,SlittingSize,Width
			)
			,
			getFrad as (
			select PartNo,SlittingCode,SlittingSize,Farad,Width,cw.Seq,cw.CommandType
			,MaterialCode,MaterialName,MaterialSource,
			MaterialThickness,ElectrodeLotNumber,cw.Barcode,ElectrodeThick,SlittingWidth,
			GoodQtyLength ,cw.CreateDateTime,LotUniqueNumber,cw.CutNo,cw.GradeModelCode
			
			from getconfig	with(nolock) 
			join getlistElect cw on (SlittingCode like '%'+cw.MaterialSource+'%' and  (replace(SlittingCode,SlittingSize,'') + SlittingSize) like '%'+cw.MaterialThickness+'%' 
			or MaterialName like '%'+replace(SlittingCode,SlittingSize,'')+'%'+SlittingSize+'%' ) 
			and  Width=cw.SlittingWidth
			)
			,resultst as (
					select
					-- thay đổi nếu cắt cho hàng 2245 thì sẽ chia làm 2 loai partno được chia theo như bên dưới để tránh nhầm lẫn điện cực cho các hàng theo Mr.Bách 2025-02-17
					case when PartNo in ('2245') and SlittingCode ='YP' then '2245S,C'
					     when PartNo in ('2245') and SlittingCode ='BA21E' then '2245L'
						 when MaterialCode = 'CRFYN85L' and Partno = '1030' then '1030_Low' --Mr Bach request 2026-01-06
						 when MaterialCode = 'CRFYN85' and Partno = '1030' then '1030_VET' --Mr Bach request 2026-01-06
						 when MaterialCode = 'CRFYO85B-02' and Partno = '1030' then '1030_L' --Mr Lân request 2026-01-07
						 when MaterialCode = 'CREBO85L' and PartNo = '1030' then  '1030_Low' --Mr Huy request 2026-01-15
						 when MaterialCode = 'CREYO85B-02' and Partno = '1030' and ElectrodeLotNumber = 'VVQL1720001E19' then '1030_L' --Mr Lân request 2026-01-07
						 when MaterialCode = 'CRFYN85L' and Partno = '1625' then '1625_Low' --Mr Huy request 2026-04-24
						 when MaterialCode = 'CRECO85A' and Partno = '1625' then '1625_Low' --Mr Huy request 2026-04-24
						 when MaterialCode = 'CRECO85-03' and Partno = '1625' then '1625_Low' --Mr Huy request 2026-04-24
						when MaterialCode = 'CREBO85' and Partno = '1030' then '1030_VET(+)' --Mr Huy request 2026-04-24
						when MaterialCode = 'CREYO85B-02' and Partno = '1030' then '1030_L' --Mr Huy request 2026-06-29

					else PartNo end as PartNo
					,case when MaterialCode = 'CRYPK0-018' then 'BH(4:6)' else SlittingCode end as SlittingCode --updated 2025-12-27
					,SlittingSize,
					case when PartNo in ('1840') and SlittingCode in ('YP') and Farad in ('50','60') -- bỏ trắng theo yêu cầu của Mr.Bách 2024-09-18
						then 
							null
						else
							Farad
						end as Farad
					,Width,Seq,CommandType
			,MaterialCode,MaterialName,MaterialSource,
			MaterialThickness,ElectrodeLotNumber,Barcode,ElectrodeThick,
			SlittingWidth,
			GoodQtyLength ,CreateDateTime,LotUniqueNumber,CutNo,GradeModelCode from getFrad
			where (
				PartNo != '3562'  -- Các PartNo khác giữ nguyên
				or (PartNo = '3562' and SlittingCode = 'YP')  -- PartNo 3562 chỉ lấy YP
			)
			)
					select * from resultst 	

		END
END

