-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-03-14
-- Description:	Thêm giá của thành phẩm các công đoạn hoặc giá nguyên vật liệu
-- =============================================
CREATE PROCEDURE usp_UpPriceProductAndPriceMaterial
	@MaterialCode varchar(50),
	@TypeInput varchar(50), --Loại dữ liệu đầu vào của nvl hay của product
	@PriceVE01 varchar(50)=NULL,
	@PriceVE02 varchar(50)=NULL,
	@PriceVE03 varchar(50)=NULL,
	@PriceVE04 varchar(50)=NULL,
	@PriceVE05 varchar(50)=NULL,
	@PriceVE06 varchar(50)=NULL,
	@PriceVE07 varchar(50)=NULL,
	@PriceVE08 varchar(50)=NULL,
	@PriceVE09 varchar(50)=NULL,
	@PriceVE10 varchar(50)=NULL,
	@PRICES varchar(50)=NULL,
	@TypeWasteID varchar(50)=NULL,
	@ProcessUserID VARCHAR(20)

AS
BEGIN
	SET NOCOUNT ON;
	Declare @check int = 0;
	IF(@TypeInput='Product')
		BEGIN
		-- Kiểm tra xem đã có mã này trên hệ thống hay chưa nếu có rồi sẽ chuyển sang update
			select @check = COUNT(model) from STB_VVT_StagePrices where model=@MaterialCode
					IF(isnull(@check,0)=0)
					BEGIN
						INSERT INTO STB_VVT_StagePrices
								(
								model,
								RouteVE01,
								RouteVE02,
								RouteVE03,
								RouteVE04,
								RouteVE05,
								RouteVE06,
								RouteVE07,
								RouteVE08,
								RouteVE09,
								RouteVE10,
								PriceVE01,
								PriceVE02,
								PriceVE03,
								PriceVE04,
								PriceVE05,
								PriceVE06,
								PriceVE07,
								PriceVE08,
								PriceVE09,
								PriceVE10,
								WorkCenterCode,
								CreateDate,
								CreateUserID
								)
								VALUES
								(
								@MaterialCode,	
								'VE01',
								'VE02',
								'VE03',
								'VE04',
								'VE05',
								'VE06',
								'VE07',
								'VE08',
								'VE09',
								'VE10',
								@PriceVE01,
								@PriceVE02,
								@PriceVE03,
								@PriceVE04,
								@PriceVE05,
								@PriceVE06,
								@PriceVE07,
								@PriceVE08,
								@PriceVE09,
								@PriceVE10,
								'VVT_F3',
								GETDATE(),
								@ProcessUserID
								)
						END
						ELSE
						BEGIN
							 UPDATE STB_VVT_StagePrices
								SET
									PriceVE01 =   CASE
												WHEN @PriceVE01 IS NOT NULL THEN @PriceVE01
												ELSE PriceVE01
												END,
									PriceVE02 =   CASE
												WHEN @PriceVE02 IS NOT NULL THEN @PriceVE02
												ELSE PriceVE02
												END,
									PriceVE03 =   CASE
												WHEN @PriceVE03 IS NOT NULL THEN @PriceVE03
												ELSE PriceVE03
												END,
									PriceVE04 =   CASE
												WHEN @PriceVE04 IS NOT NULL THEN @PriceVE04
												ELSE PriceVE04
												END,
									PriceVE05 =   CASE
												WHEN @PriceVE05 IS NOT NULL THEN @PriceVE05
												ELSE PriceVE05
												END,
									PriceVE06 =   CASE
												WHEN @PriceVE06 IS NOT NULL THEN @PriceVE06
												ELSE PriceVE06
												END,
									PriceVE07 =   CASE
												WHEN @PriceVE07 IS NOT NULL THEN @PriceVE07
												ELSE PriceVE07
												END,
									PriceVE08 =   CASE
												WHEN @PriceVE08 IS NOT NULL THEN @PriceVE08
												ELSE PriceVE08
												END,
									PriceVE09 =   CASE
												WHEN @PriceVE09 IS NOT NULL THEN @PriceVE09
												ELSE PriceVE09
												END,
								  PriceVE10 =   CASE
												WHEN @PriceVE10 IS NOT NULL THEN @PriceVE10
												ELSE PriceVE10
												END,
									ChangeDateTime = getdate(),
									ChangeUserID=@ProcessUserID
									WHERE
									model = @MaterialCode
						END
		END
		ELSE IF(@TypeInput='RawMaterial')
		BEGIN
		select @check = COUNT(MaterialCode) from STB_MaterialCodeAndPriceWWaste where MaterialCode=@MaterialCode
			IF(isnull(@check,0)=0)
				BEGIN
						 INSERT INTO STB_MaterialCodeAndPriceWWaste
									(
										MaterialCode,
										PRICES,
										TypeWasteID,
										CreateDateTime,
										CreateUserID
									)
									VALUES
									(
										@MaterialCode,
										@PRICES,
										@TypeWasteID,
										GETDATE(),
										@ProcessUserID
									)
				END
				ELSE
				BEGIN
						UPDATE STB_MaterialCodeAndPriceWWaste
						SET
							--MaterialCode = ISNULL(@MaterialCode, MaterialCode),
							PRICES = ISNULL(@PRICES, PRICES),
							TypeWasteID = ISNULL(@TypeWasteID, TypeWasteID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @ProcessUserID

						WHERE
							MaterialCode = @MaterialCode
				END
			-- Lưu lại lịch sử đơn giá
			INSERT INTO STB_HistoryChangePriceMaterialWaste
						(
							MaterialCode,
							PRICES,
							CreateDateTime,
							CreateUserID
						)
						VALUES
						(
							@MaterialCode,
							@PRICES,
							GETDATE(),
							@ProcessUserID
						)
		END
	
END
