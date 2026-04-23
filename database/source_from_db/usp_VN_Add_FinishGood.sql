CREATE proc [dbo].[usp_VN_Add_FinishGood] --exec usp_VN_Add_FinishGood 'nguyennha', 'VVKQ123R010519','Hàng cell'
@PackingID NVARCHAR(50), 
@LotNo NVARCHAR(50),
@MaterialCode NVARCHAR(50),
@MaterialName NVARCHAR(50),
@PackQty INT,
@EmpNo NVARCHAR(50),
@CreatePacked NVARCHAR(50),
@PartNo NVARCHAR(50),
@UserID NVARCHAR(50)
AS
BEGIN

exec usp_VVT_checkHOLD_QC @pLotNo=@LotNo

	DECLARE @VNCODE NVARCHAR(50)
		--IF @TypeProduction = N'Hàng cell'

		--	BEGIN
		--				DECLARE @PackingID NVARCHAR(50)
		--				DECLARE @LotNos NVARCHAR(50)
		--				DECLARE @CreatePacked DATETIME
		--				DECLARE @MaterialCode NVARCHAR(50)
		--				DECLARE @MaterialName NVARCHAR(100)
		--				DECLARE @EmpNo NVARCHAR(50)
		--				DECLARE @PartNo NVARCHAR(50)
						
		--				SELECT 
		--						@PackingID = PackingID,
		--						@LotNos = LotNo,
		--						@MaterialCode = MaterialCode,
		--						@MaterialName = MaterialName,
		--						@CreatePacked = PrintTime,
		--						@EmpNo = EmpNo,
		--						@PartNo = PartNo

		--				FROM 
		--						STB_SavePackingTime_VVT WITH(NOLOCK)
		--				WHERE
		--						LotNo = @LotNo


								IF (@LotNo IS NOT NULL)

									BEGIN
											INSERT INTO STB_VN_FINISHGOODS
											(
												PackingID,
												LotNo,
												MaterialCode,
												MaterialName,
												PackQty,
												EmpNo,
												CreatDatePacked,
												PartNo,
												StatusSystem,
												ProductionSize,
												CreateDate,
												USERID
											)
											VALUES
											(
												@PackingID,
												@LotNo,
												@MaterialCode,
												@MaterialName,
												@PackQty,
												@EmpNo,
												@CreatePacked,
												@PartNo,
												N'Nhập',
												SUBSTRING(@MaterialName,19,14),
												DATEADD(HH, -2, GETDATE()),
												@UserID
											)
									END

							SELECT 
									@VNCODE = CODEACC
							FROM
									STB_VN_CODEGOODFINISED WITH (NOLOCK)
							WHERE 
									CODEKR = @PartNo
									
									
							UPDATE 
										STB_VN_FINISHGOODS

							SET 
										PublicCode = @VNCODE

							WHERE 
									PartNo = @PartNo	
		--	END
		
		--IF @TypeProduction = N'Hàng module'

		--	BEGIN
		--			DECLARE @BarcodeS NVARCHAR(50)
		--			DECLARE @MaterialNameS NVARCHAR(50)
		--			DECLARE @MaterialCodeS NVARCHAR(50)
		--			DECLARE @LotQty INT
		--			DECLARE @PackedCreate DATETIME
		--			DECLARE @PartNos NVARCHAR(50)
		--			DECLARE @CreateUserID NVARCHAR(50)
		--			DECLARE @IDPack NVARCHAR(50)

		--			SELECT
		--					@BarcodeS = Barcode,
		--					@MaterialNameS = MaterialName,
		--					@MaterialCodeS = MaterialCode,
		--					@PackedCreate = CreateDateTime,
		--					@PartNos = PartNo,
		--					@CreateUserID = CreateUserID,
		--					@IDPack = PackingID
		--			FROM
		--					STB_VN_NEW_PRINTER WITH(NOLOCK)
		--			WHERE 
		--					Barcode = @LotNo
							
		--			IF (@BarcodeS IS NOT NULL)
		--					BEGIN
		--							INSERT INTO STB_VN_FINISHGOODS
		--									(
												
		--										LotNo,
		--										MaterialCode,
		--										MaterialName,
		--										PackQty,
		--										EmpNo,
		--										CreatDatePacked,
		--										PartNo,
		--										TypeProduction,
		--										StatusSystem,
		--										CreateDate,
		--										USERID,
		--										PackingID
												
		--									)
		--									VALUES
		--									(
												
		--										@BarcodeS,
		--										@MaterialCodeS,
		--										@MaterialNameS,
		--										@PackQty,
		--										@CreateUserID,
		--										@PackedCreate,
		--										@PartNos,
		--										N'Hàng module',
		--										N'Nhập',
		--										DATEADD(HH, -2, GETDATE()),
		--										@UserID,
		--										@IDPack
		--									)
		--					END
		--	END
END