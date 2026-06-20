-- =============================================
-- Fix: B540 grid "Thông tin số lượng sản xuất thẻ công đoạn" trống
-- Nguyên nhân: WHERE PFRS.Status='Pass' loại hết nhà máy VVT_F3 
--              vì bảng STB_PassOrFailRouteStatus chỉ có data cho VVT_F4
-- Fix: Chuyển PFRS.Status='Pass' từ WHERE vào ON clause của LEFT JOIN
-- Ngày: 2026-06-19
-- =============================================

ALTER PROCEDURE [dbo].[usp_AssyCardInfoProdQty_get]
				@pProcessUserID [varchar](20),
				@pProcessLanguage [varchar](20),
				@pBarcode [varchar](50) = NULL,
				@pUtcOffset INT
WITH EXECUTE AS CALLER
AS

BEGIN
	SET NOCOUNT ON;

	Declare @Barcode    VARCHAR(50) = @pBarcode, @utc varchar(50)=@pUtcOffset


	        , @TotalCount INT 
			, @UtcOffset INT = @pUtcOffset

	IF @UtcOffset = 420 BEGIN
		SET @UtcOffset = 540
	END 

	
	--RAISERROR(@utc,16,1)
    SELECT @TotalCount = COUNT(*) FROM STB_ProdRouteHist WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)

	-- 실적등록정보
	 SELECT PRH.MaterialCode
	       , 
		   case when @Barcode in  -- đổi tên theo yêu cầu của Mr.Trung
		   (
		    'VVOT143R850601',
			'VVOT153R850606',
			'VVOT213R850602',
			'VVOT223R850601',
			'VVOT203R850601',
			'VVOT223R850607',
			'VVOT193R850610',
			'VVOT213R850606',
			'VVOU033R850601',
			'VVOT223R850604',
			'VVOT253R850607',
			'VVOU043R850601',
			'VVOT253R850604',
			'VVOU043R850602',
			'VVOT223R850608',
			'VVOT193R850604',
			'VVOT213R850601',
			'VVOT203R850606',
			'VVOT203R850604',
			'VVOT223R850602',
			'VVOT223R850605',
			'VVOT213R850607'
		   )  then 'VEL08253R8506G-B050 (0825)'
		   when @Barcode in  -- 2025-07-08 following  Mr.Diep BG 's request
		   (
			'VVPN113R036708',
			'VVPN123R036727',
			'VVPN113R036707',
			'VVPN133R036716',
			'VVPN173R036709',
			'VVPM153R036709',
			'VVPM173R036723',
			'VVPM153R036708',
			'VVPM163R036737',
			'VVPM153R036710',
			'VVPM163R036738',
			'VVP0223R036707'
		   ) then 'HY-CAP VEP3R0367QG (3562)'
			   WHEN MM.MaterialCode='ECVT27-344' THEN 'HY-CAP WEC2R7106QG (1030 Low)'
			else MM.MaterialName end MaterialName
		   , PRH.LineCode
		   , PRH.RouteCode
		   , RI.RouteName
		   , PRH.WorkerCode
		   , PWI.WorkerName AS WorkerName
		   , PRH. MachineCode 
		   , MM2.MachineName
		   , PRH.ProdQty AS InputProdQty
		   , ISNULL(DRI.DefectQty, 0) AS DefectQty
		   , (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty
		 
		 , dbo.fnGetLocalTime(PRH.ProdDateTime, @UtcOffset) AS ProdDate
		   --Mr.Triều Add a condition for the Bac Giang 2 factory: if it's the final stage, make it visible.(2026-06-08)
		   , CONVERT(BIT, CASE 
					WHEN PRH.WorkCenterCode = 'VVT_F4' THEN 
					-- if conftion for BG2 role check route final
						CASE WHEN PRH.CompleteRoute = 1 THEN 1 ELSE 0 END					
					ELSE (CASE WHEN ROW_NUMBER () OVER ( ORDER BY PRH.RouteCode ASC) = @TotalCount THEN 0 ELSE 1 END)
				  END) AS ProdQtyFinishYn,
				  PFRS.Status
	   FROM STB_ProdRouteHist PRH
			   LEFT OUTER JOIN STB_MaterialMaster MM	  ON PRH.MaterialCode = MM.MaterialCode
			   LEFT OUTER JOIN STB_ProdWorkerInfo PWI  ON PRH.WorkerCode = PWI.EmpNo
			   LEFT OUTER JOIN STB_MachineMaster MM2 ON PRH.MachineCode = MM2.MachineCode
			   LEFT OUTER JOIN ( SELECT ControlNo, FindRouteCode, SUM(DefectQty - RepairQty) AS DefectQty 
									  FROM STB_DefectRepairInfo 
									 WHERE RepairType NOT IN ('MISSING', 'FINISH')
									 GROUP BY ControlNo, FindRouteCode
								  ) DRI	     ON PRH.ControlNo = DRI.ControlNo        AND PRH.RouteCode = DRI.FindRouteCode

			   LEFT OUTER JOIN STB_RouteInfo RI	     ON PRH.RouteCode = RI.RouteCode
			   LEFT OUTER JOIN STB_SetInfo SI               ON PRH.ControlNo = SI.ControlNo
			   -- FIX: Chuyển PFRS.Status='Pass' vào ON clause thay vì WHERE
			   -- Để nhà máy VVT_F3 (không dùng bảng này) vẫn hiện data
			   LEFT OUTER JOIN (
			       SELECT Barcode, RouteCode, Status
				   FROM STB_PassOrFailRouteStatus WITH(NOLOCK)
				   WHERE Status = 'Pass'
			   ) PFRS ON SI.Barcode = PFRS.Barcode 
                                            AND PRH.RouteCode = PFRS.RouteCode
     WHERE SI.Barcode = @Barcode
      Order by  Case when PRH.RouteCode = 'E-28' Then 99 Else ROW_NUMBER() OVER (ORDER BY PRH.RouteCode) End ASC     -- 2022.02.14 Kangs 정렬추가 (공정 히스토리 순서로, 포장 예외처리)


END
