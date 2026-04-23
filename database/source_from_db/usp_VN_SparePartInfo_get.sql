-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-17
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트정보 조회
-- Modified:
--exec usp_VN_SparePartInfo_get '', '','','','','','','VVT_F1',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_SparePartInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pSparePartCode VARCHAR(20) = NULL,
    @pSparePartName NVARCHAR(100) = NULL,
	@pSparePartSpec02 NVARCHAR(20)=NULL,
	@pTypeCode NVARCHAR(100) = NULL,
	@pTypeName NVARCHAR(100) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
	@pNameWorkCenterCode NVARCHAR(50) = NULL
AS
BEGIN
	  SET NOCOUNT ON;
      DECLARE @SparePartCode VARCHAR(20) = CASE WHEN ISNULL(@pSparePartCode,'') = '' THEN '*' ELSE @pSparePartCode END
      DECLARE @SparePartName NVARCHAR(100) = CASE WHEN ISNULL(@pSparePartName,'') = '' THEN '*' ELSE @pSparePartName END
	  DECLARE @TypeCode NVARCHAR(100) = CASE WHEN ISNULL(@pTypeCode,'') = '' THEN '*' ELSE @pTypeCode END
	  DECLARE @SparePartSpec02 NVARCHAR(100) = CASE WHEN ISNULL(@pSparePartSpec02,'') ='' THEN '*' ELSE @pSparePartSpec02 END
	  
	  select A1.*,case when COALESCE(CurrentStockQty,0) < COALESCE(SafeQty,0)
	THEN
	COALESCE ((COALESCE(A1.MaxSafeQty,0) - COALESCE(CurrentStockQty,0)),0) else 0 end as QtyNeedOrder from  (SELECT
	        SPI.SparePartCode AS OldSparePartCode,
	        SPI.SparePartCode,
	        SPI.SparePartName,
	        SPI.SparePartSpec01,
	        SPI.SparePartSpec02,
	        SPI.SparePartSpec03,
	        SPI.SparePartSpec04,
	        SPI.SparePartSpec05,
			SPI.TypeCode,
	        TS.TypeName,
	        SPI.SparePartImage,
	    --    AFM.[FileName],
		--	AFM.FileSize,
		--	CONVERT(VARBINARY(MAX),NULL) AS FileData,
		--	CONVERT(VARBINARY(MAX),AFM.FileContents) AS FileData,
	        SPI.BasicUnitPrice,
	        SPI.BasicDeliveryDay,
	        SPI.BasicUnit,
	        SPI.SafeQty,
			SPI.MaxSafeQty,
	        SPI.LastDeliveryVendor,
	        SPI.CompatibilityGroup,
			SPI.WorkCenterCode,
			SPI.NameWorkCenterCode,
			--(
			--		SELECT
			--				COALESCE(SUM(ISNULL(SPSI.CurrentStockQty,0)),0) AS CurrentStockQty
			--		FROM
			--				STB_VNSparePartStockInfo SPSI WITH (NOLOCK)
			--		WHERE
			--				SPSI.SparePartCode = SPI.SparePartCode and spwarehousecode='Kho1'
			--) AS CurrentStock1Qty,
			--(
			--		SELECT
			--				COALESCE(SUM(ISNULL(SPSI.CurrentStockQty,0)),0) AS CurrentStockQty
			--		FROM
			--				STB_VNSparePartStockInfo SPSI WITH (NOLOCK)
			--		WHERE
			--				SPSI.SparePartCode = SPI.SparePartCode and spwarehousecode='Kho2'
			--) AS CurrentStock2Qty,
			--(
			--		SELECT
			--				SUM(ISNULL(SPSI.CurrentStockQty,0)) AS CurrentStockQty
			--		FROM
			--				STB_VNSparePartStockInfo SPSI WITH (NOLOCK)
			--		WHERE
			--				SPSI.SparePartCode = SPI.SparePartCode
			--) AS CurrentStockQty,




	--------------------------------------------------------- Ha them 07/05/24
		(
					SELECT
							COALESCE(SUM(ISNULL(SPSI.CurrentStockQty,0)),0) AS CurrentStockQty
					FROM
							STB_VNSparePartStockInfo_TEST SPSI WITH (NOLOCK)
					WHERE
							SPSI.SparePartCode = SPI.SparePartCode and spwarehousecode='Kho1'  and  WorkCenterCode ='VVT_F1'
			) AS CurrentStock1QtyBN,
			(
					SELECT
							COALESCE(SUM(ISNULL(SPSI.CurrentStockQty,0)),0) AS CurrentStockQty
					FROM
							STB_VNSparePartStockInfo_TEST SPSI WITH (NOLOCK)
					WHERE
							SPSI.SparePartCode = SPI.SparePartCode and spwarehousecode='Kho2'  and  WorkCenterCode ='VVT_F1'
			) AS CurrentStock2QtyBN,
			(
					SELECT
							SUM(ISNULL(SPSI.CurrentStockQty,0)) AS CurrentStockQty
					FROM
							STB_VNSparePartStockInfo_TEST SPSI WITH (NOLOCK) 
					WHERE
							SPSI.SparePartCode = SPI.SparePartCode   and  WorkCenterCode ='VVT_F1'
			) AS CurrentStockQtyBN,
			(
					SELECT
							COALESCE(SUM(ISNULL(SPSI.CurrentStockQty,0)),0) AS CurrentStockQty
					FROM
							STB_VNSparePartStockInfo_TEST SPSI WITH (NOLOCK)
					WHERE
							SPSI.SparePartCode = SPI.SparePartCode and spwarehousecode='Kho1'  and  WorkCenterCode ='VVT_F2'
			) AS CurrentStock1QtyBG,
			(
					SELECT
							COALESCE(SUM(ISNULL(SPSI.CurrentStockQty,0)),0) AS CurrentStockQty
					FROM
							STB_VNSparePartStockInfo_TEST SPSI WITH (NOLOCK)
					WHERE
							SPSI.SparePartCode = SPI.SparePartCode and spwarehousecode='Kho2'  and  WorkCenterCode ='VVT_F2'
			) AS CurrentStock2QtyBG,
			(
					SELECT
							SUM(ISNULL(SPSI.CurrentStockQty,0)) AS CurrentStockQty
					FROM
							STB_VNSparePartStockInfo_TEST SPSI WITH (NOLOCK) 
					WHERE
							SPSI.SparePartCode = SPI.SparePartCode   and WorkCenterCode ='VVT_F2'
			) AS CurrentStockQtyBG,
				(
					SELECT
							COALESCE(SUM(ISNULL(SPSI.CurrentStockQty,0)),0) AS CurrentStockQty
					FROM
							STB_VNSparePartStockInfo_TEST SPSI WITH (NOLOCK)
					WHERE
							SPSI.SparePartCode = SPI.SparePartCode and spwarehousecode='Kho1'  and  WorkCenterCode ='VVT_F3'
							) as CurrentStock1QtyHN,
							
			(
					SELECT
							SUM(ISNULL(SPSI.CurrentStockQty,0)) AS CurrentStockQty
					FROM
							STB_VNSparePartStockInfo_TEST SPSI WITH (NOLOCK) 
					WHERE
							SPSI.SparePartCode = SPI.SparePartCode   and WorkCenterCode ='VVT_F3' and spwarehousecode='Kho1'
			) AS CurrentStockQtyHN,
			(
					SELECT
							SUM(ISNULL(SPSI.CurrentStockQty,0)) AS CurrentStockQty
					FROM
							STB_VNSparePartStockInfo_TEST SPSI WITH (NOLOCK) 
					WHERE
							SPSI.SparePartCode = SPI.SparePartCode  and WorkCenterCode='VVT_F3' and spwarehousecode='Kho1'
			) AS CurrentStockQty,
	        SPI.IsUsed,
			SPI.IsSpecial,
	        SPI.CreateDateTime,
	        SPI.CreateUserID,
	        SPI.ChangeDateTime,
	        SPI.ChangeUserID,
			SPI.Position,
			SPI.PositionBG,
			SPI.Attribute1,
			SPI.CurrentStock --AS 'SafeInventory' -- Tồn kho an toàn Mr.Trieu
			
	FROM
	        STB_VNSparePartInfo SPI WITH(NOLOCK)
	        LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)
				ON AFM.FileID = SPI.SparePartImage
			left join STB_typesparepart TS ON SPI.TypeCode = TS.TypeCode
		
	

	WHERE
	        ((@SparePartCode = '*') OR (SPI.SparePartCode = @SparePartCode)) AND
			((@pWorkCenterCode = '*') OR (SPI.WorkCenterCode = @pWorkCenterCode)) AND
	        ((@SparePartName = '*') OR (SPI.SparePartName like '%'+@SparePartName+'%')) AND
			((@Typecode = '*') OR (SPI.TypeCode = @TypeCode)) AND
			((@SparePartSpec02 = '*') OR (SPI.SparePartSpec02 like '%'+ @SparePartSpec02+'%'))
			) A1
	order by SparePartCode
END


-- select * from STB_VNSparePartInfo

--alter table STB_VNSparePartInfo
--add
--		 CompanyCode  VARCHAR(20) default 'VVT' NULL,
--		 WorkCenterCode VARCHAR(20) NULL,
--		 NameWorkCenterCode NVARCHAR(50) NULL
--exec usp_VN_SparePartInfo_get '', '','','','','','','VVT_F3',''