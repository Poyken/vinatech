-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-12-16
-- Description:	<Description,,>
-- =============================================

--	exec usp_ModifyPackingQtyByLevel_VVT 'DinhManh', '', '1568866', 'VVPU133R060636' ,'1' ,'2' ,'3' ,'4'

CREATE PROCEDURE [dbo].[usp_ModifyPackingQtyByLevel_VVT]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pIDSPT VARCHAR(10) NULL,
		@pLotNo VARCHAR(50) NULL,
		@pSClass NUMERIC(15,0) NULL,
		@pAClass NUMERIC(15,0) NULL,
		@pBClass NUMERIC(15,0) NULL,
		@pCClass NUMERIC(15,0) NULL,
		@pDClass NUMERIC(15,0) NULL	


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @MaterialCode VARCHAR(30),
			@MaterialName NVARCHAR(200),
			@BoxQty NUMERIC(15, 0)


	DECLARE	@SClass NUMERIC(15, 0) = ISNULL(@pSClass, 0),
			@AClass NUMERIC(15, 0) = ISNULL(@pAClass, 0),
			@BClass NUMERIC(15, 0) = ISNULL(@pBClass, 0),
			@CClass NUMERIC(15, 0) = ISNULL(@pCClass, 0),
			@DClass NUMERIC(15, 0) = ISNULL(@pDClass, 0),
			@SumClass NUMERIC(15, 0) = 0

	SET @SumClass = @SClass + @AClass + @BClass + @CClass + @DClass

	-- Kiểm tra xem có phải là hàng 35105 hay không, nếu không phải thì sẽ trả về lỗi
	SELECT @MaterialCode = MaterialCode,
			@MaterialName = MaterialName,
			@BoxQty = PackQty
	FROM STB_SavePackingTime_VVT WHERE ID = @pIDSPT AND LotNo = @pLotNo





	IF @MaterialCode NOT IN ('ECVT30-357', 'ECVT30-076', 'ECVT30-117') 
		BEGIN
			RAISERROR(N'Lot no "%s - %s" không phải là hàng "ECVT30-076 / ECVT30-117 (3582) hay ECVT30-357 (35105)". Vui lòng kiểm tra lại .!.', 16, 1, @pLotNo, @MaterialName)
			RETURN
		END
	
	ELSE IF @SumClass <> @BoxQty
		BEGIN
			RAISERROR(N'Tổng số lượng các cấp đã nhập %s <> số lượng đóng gói %s. Vui lòng kiểm tra lại ..!', 16, 1, @SumClass, @BoxQty)
			RETURN
		END

	ELSE 
		BEGIN
			IF EXISTS (SELECT 1 FROM STB_SavePackingQtyByLevel_VVT where IDSPT = @pIDSPT AND LotNo = @pLotNo)
				BEGIN
					UPDATE STB_SavePackingQtyByLevel_VVT
					SET SClass = @SClass,
						AClass = @AClass,
						BClass = @BClass,
						CClass = @CClass,
						DClass = @DClass,
						ChangeDateTime = GETDATE(),
						ChangeUserID = @pProcessUserID
					WHERE IDSPT = @pIDSPT 
						AND LotNo = @pLotNo

				END

			ELSE
				BEGIN
					INSERT INTO STB_SavePackingQtyByLevel_VVT (IDSPT, LotNo, SClass, AClass, BClass, CClass, DClass, CreateDateTime, CreateUserID) 
					values		(@pIDSPT, @pLotNo, @SClass, @AClass, @BClass, @CClass, @DClass, GETDATE(), @pProcessUserID)

				END
		END


	



END
