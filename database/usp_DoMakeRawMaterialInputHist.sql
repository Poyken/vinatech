Text
----
CREATE PROC [dbo].[usp_DoMakeRawMaterialInputHist] 

	@pBarcode VARCHAR(20)

   ,@pSizeCode VARCHAR(20)

AS

BEGIN

	Declare @Barcode VARCHAR(20) = @pBarcode

	       ,@SizeCode VARCHAR(20) = @pSizeCode

		   ,@ProductGroupCode VARCHAR(20)

		   ,@MaterialCode VARCHAR(50)

		   ,@UsedQty numeric(20,10)

		   ,@RawMaterialInputHistNo VARCHAR(20)

		   , @WorkCenterCode VARCHAR(20) -- 2025.01.07 --l?y ra nhà máy d?  thêm d? li?u theo BOM c?a hà nam



	SELECT  @WorkCenterCode=WorkCenterCode

	  FROM STB_DayProdPlan DPP

	 WHERE DayPlanNo = (SELECT DayPlanNo FROM STB_SetInfo WHERE Barcode = @pBarcode)



	if(@WorkCenterCode<>'VVT_F3' 

		AND @WorkCenterCode<>'VNT_F4'

		AND @WorkCenterCode<>'VVT_F4') --2025.10.31 ??2?? BOM???? ??

		BEGIN

			DECLARE cur CURSOR FOR



			SELECT ProductGroupCode

			  FROM STB_RawMaterialBaiscInfo

			 WHERE SizeCode = @SizeCode





			OPEN cur



			FETCH NEXT FROM cur INTO @ProductGroupCode



			WHILE @@FETCH_STATUS = 0

			BEGIN

			

				EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_RawMaterialInputHist',@RawMaterialInputHistNo OUTPUT



				INSERT INTO STB_RawMaterialInputHist (RawMaterialInputHistNo, Barcode, ProductGroupCode, RawMaterialBarcode)

					SELECT @RawMaterialInputHistNo, @Barcode, @ProductGroupCode, NULL

		

				FETCH NEXT FROM cur INTO @ProductGroupCode

			END



			CLOSE cur

			DEALLOCATE cur

		END

	ELSE

		BEGIN

		/* Ðã OK khóa l?i d? th? nghi?m cách bên du?i

		--T?o b?ng ?o d? luu l?i groupcode và s? không trùng

		CREATE TABLE #TempTable (

			ProductGroupCode NVARCHAR(50),

			ProductGroupCodeA bigint,

			UsedQty numeric(20,10)

		);

		INSERT INTO #TempTable

		select mm.ProductGroupCode, ROW_NUMBER() OVER (PARTITION BY mm.ProductGroupCode, bd.MaterialCode ORDER BY bd.createdatetime) as ProductGroupCodeA  , bd.UsedQty

				from STB_SetInfo si with(nolock) 

				join  STB_BomDetail bd with(nolock)  on si.MaterialCode=bd.MaterialCode

				join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode

				join STB_MaterialMaster mm on mm.MaterialCode = bd.ChildMaterialCode

				LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)	ON RI.RouteCode = BD.RouteCode

				where si.Barcode=@Barcode  and bd.BomVersion='99' and RI.IsUsed=1



				

			DECLARE cur CURSOR FOR



		-- n?i groupcode và s? không b? trùng vào d?ng sau. s? d?ng cho nhà máy hà nam do các nguyên li?u gi?ng nhau và mu?n hi?n th? tên sao cho dúng nên làm ki?u này m?i phân bi?t du?c.

		-- ch? y?u do l?y d? li?u t? BOM ra khác v?i d? li?u fix c?ng nhu tru?c nên s? liên k?t hoi khó

				select ProductGroupCode + '-' + CAST(ProductGroupCodeA AS NVARCHAR) AS ProductGroupCode,UsedQty from #TempTable

			OPEN cur



			FETCH NEXT FROM cur INTO @ProductGroupCode



			WHILE @@FETCH_STATUS = 0

			BEGIN

			

				EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_RawMaterialInputHist',@RawMaterialInputHistNo OUTPUT



				INSERT INTO STB_RawMaterialInputHist (RawMaterialInputHistNo, Barcode, ProductGroupCode, RawMaterialBarcode)

					SELECT @RawMaterialInputHistNo, @Barcode, @ProductGroupCode, NULL

		

				FETCH NEXT FROM cur INTO @ProductGroupCode

			END



			CLOSE cur

			DEALLOCATE cur

			DROP TABLE #TempTable;

			*/



			

		--T?o b?ng ?o d? luu l?i groupcode và s? không trùng

		CREATE TABLE #TempTable (

			ProductGroupCode NVARCHAR(50),

			ProductGroupCodeA bigint,

			MaterialCode varchar(50),

			UsedQty numeric(20,10)

		);



		IF @WorkCenterCode <> 'VVT_F4' BEGIN

			INSERT INTO #TempTable

			select mm.ProductGroupCode, ROW_NUMBER() OVER (PARTITION BY mm.ProductGroupCode, bd.MaterialCode ORDER BY BD.ChildMaterialCode) as ProductGroupCodeA  , bd.ChildMaterialCode,bd.UsedQty

					from STB_SetInfo si with(nolock) 

					join  STB_BomDetail bd with(nolock)  on si.MaterialCode=bd.MaterialCode

					join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode

					join STB_MaterialMaster mm on mm.MaterialCode = bd.ChildMaterialCode

					LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)	ON RI.RouteCode = BD.RouteCode

					left join STB_DayProdPlan dp on si.DayPlanNo = dp.DayPlanNo

					where si.Barcode=@Barcode

					and bd.BomVersion=dp.BomVersion  -- L?y ra bomversion tuong ?ng v?i k? ho?ch ngày d? l?y nvl co b?n

					--and RI.IsUsed=1 

					order by BD.ChildMaterialCode

		END ELSE BEGIN

			INSERT INTO #TempTable

			select mm.MaterialSpec, ROW_NUMBER() OVER (PARTITION BY mm.ProductGroupCode, bd.MaterialCode ORDER BY BD.ChildMaterialCode) as ProductGroupCodeA  , bd.ChildMaterialCode,bd.UsedQty

					from STB_SetInfo si with(nolock) 

					join  STB_BomDetail bd with(nolock)  on si.MaterialCode=bd.MaterialCode

					join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode

					join STB_MaterialMaster mm on mm.MaterialCode = bd.ChildMaterialCode

					LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)	ON RI.RouteCode = BD.RouteCode

					left join STB_DayProdPlan dp on si.DayPlanNo = dp.DayPlanNo

					where si.Barcode=@Barcode

					and bd.BomVersion=dp.BomVersion  -- L?y ra bomversion tuong ?ng v?i k? ho?ch ngày d? l?y nvl co b?n

					--and RI.IsUsed=1 

					order by BD.ChildMaterialCode

		END

				

			DECLARE cur CURSOR FOR



		-- n?i groupcode và s? không b? trùng vào d?ng sau. s? d?ng cho nhà máy hà nam do các nguyên li?u gi?ng nhau và mu?n hi?n th? tên sao cho dúng nên làm ki?u này m?i phân bi?t du?c.

		-- ch? y?u do l?y d? li?u t? BOM ra khác v?i d? li?u fix c?ng nhu tru?c nên s? liên k?t hoi khó

				select

					(CASE

						WHEN @WorkCenterCode = 'VNT_F4' -- 2025.10.31 ??? ?? ??? ??? ???.

						THEN ProductGroupCode

						ELSE ProductGroupCode + '-' + CAST(ProductGroupCodeA AS NVARCHAR)

					END) AS ProductGroupCode

					,MaterialCode,UsedQty 

				from #TempTable

			OPEN cur



			FETCH NEXT FROM cur INTO @ProductGroupCode,@MaterialCode,@UsedQty



			WHILE @@FETCH_STATUS = 0

			BEGIN

			

				EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_RawMaterialInputHist',@RawMaterialInputHistNo OUTPUT



				INSERT INTO STB_RawMaterialInputHist (RawMaterialInputHistNo, Barcode, ProductGroupCode, RawMaterialBarcode,MaterialCode,ActualRate)

					SELECT @RawMaterialInputHistNo, @Barcode, @ProductGroupCode, NULL,@MaterialCode,@UsedQty

		

				FETCH NEXT FROM cur INTO @ProductGroupCode,@MaterialCode,@UsedQty

			END



			CLOSE cur

			DEALLOCATE cur

			DROP TABLE #TempTable;

		END

END

--select * from STB_RawMaterialBaiscInfo where sizecode='CHIP_HN'

--select * from  STB_RawMaterialInputHist where barcode='VE241231-001'

/*

select * from stb_setinfo  si

left join STB_DayProdPlan dp on si.DayPlanNo = dp.DayPlanNo

where barcode='VE250227-001'

*/







