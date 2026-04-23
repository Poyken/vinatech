CREATE PROC [dbo].[usp_VN_NgoaiQuan] 
@pProcessLanguage VARCHAR(20) = NULL,
@pProcessUserID VARCHAR(20) = NULL ,
@pLOTNO NVARCHAR(50) = NULL
AS
BEGIN
		DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID 
		DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
		DECLARE @BARCODE NVARCHAR(50) = @pLOTNO
		DECLARE @IDCODE NVARCHAR(50)
		DECLARE @MODEL NVARCHAR(50)
		DECLARE @NAMEERROR NVARCHAR(50)
		DECLARE @QTYINPUT INT
		DECLARE @QTYOK INT
		DECLARE @LOTNO NVARCHAR(50)
		DECLARE @BR NVARCHAR(50)


		DECLARE @IDC NVARCHAR(50)
		DECLARE @MODE NVARCHAR(50)
		DECLARE @Qtyi INT
		DECLARE @Qok INT

		SELECT
				@IDC = IDCODE,
				@MODE = MODEL,
				@Qtyi = QTYINPUT,
				@Qok = QTYOK
		FROM	
				STB_MasterAgaingDetails

		WHERE
				LOTNO = @BARCODE

		IF @IDC IS  NULL AND @MODE IS  NULL  AND @Qtyi IS  NULL AND @Qok IS  NULL

			BEGIN
				 DECLARE @NotEnoughStockError NVARCHAR(MAX)
					EXEC usp_GetSystemStringResource	@ProcessLanguage,
														N'Vui lòng nhập đầy đủ thông tin của againg, bạn mới có thể nhập được Ngoại Quan ^.^',
														@NotEnoughStockError OUTPUT

					RAISERROR(@NotEnoughStockError,16,1)
					RETURN		
				END



		SELECT
				@BR = LOTNO
		FROM 
				STB_NgoaiQuan WITH(NOLOCK)
		WHERE
				LOTNO = @BARCODE

	IF @BR IS NOT NULL

		BEGIN
				SELECT
						ID,
						MODEL,
						LOTNO,
						VITRILO,
						VITRICURLING,
						NAMEERROR,
						QTYERROR,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
				FROM 
						STB_NgoaiQuan WITH(NOLOCK)
				WHERE
						LOTNO = @BARCODE
		END

	IF @BR IS NULL

		BEGIN
				SELECT
						@IDCODE = T1.IDCODE,
						@LOTNO = T1.LOTNO,
						@MODEL = T2.MODEL,
						@NAMEERROR = T2.NAMEERROR,
						@QTYINPUT = T2.QTYINPUT,
						@QTYOK = T2.QTYOK
				FROM 
						STB_MasterAgaing T1

				FULL JOIN

						STB_MasterAgaingDetails T2 

				ON T1.IDCODE = T2.IDCODE

				WHERE
						T1.LOTNO = @BARCODE


		
	/***---------------------------------------------------------------Start automatic ID for add recorder-----------------------------------------------------------------***/

			DECLARE @NewCode NVARCHAR(50)
			DECLARE @Prefix NVARCHAR(30) = 'NQ'
			DECLARE @Id INT

			SELECT @Id = ISNULL(MAX(ID),0) + 1 FROM STB_NgoaiQuan 
			SELECT @NewCode = @Prefix + RIGHT('000' + CAST(@Id AS nvarchar(30)),30)


  /***---------------------------------------------------------------End automatic ID for add recorder-------------------------------------------------------------------***/
	
				INSERT INTO STB_NgoaiQuan (LOTNO,IDCODE,IDNQ,MODEL,INPUTQTY,OK,CreateDateTime,CreateUserID) VALUES (@LOTNO,@IDCODE,@NewCode,@MODEL,@QTYINPUT,@QTYOK,DATEADD(HH, -2, GETDATE()),@ProcessUserID)

				SELECT
						TOP(1)
						ID,
						MODEL,
						LOTNO,
						--INPUTQTY,
						--OK,
						VITRILO,
						VITRICURLING,
						NAMEERROR,
						QTYERROR,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
				FROM 
						STB_NgoaiQuan WITH(NOLOCK)
				WHERE
						LOTNO = @BARCODE 

--		IF @IDCODE IS NOT NULL AND @MODEL IS NOT NULL  AND @QTYINPUT IS NOT NULL AND @QTYOK IS NOT NULL
--		--AND @NAMEERROR IS NOT NULL
		
--		BEGIN

--	/***---------------------------------------------------------------Start automatic ID for add recorder-----------------------------------------------------------------***/

--			DECLARE @NewCode NVARCHAR(50)
--			DECLARE @Prefix NVARCHAR(30) = 'NQ'
--			DECLARE @Id INT

--			SELECT @Id = ISNULL(MAX(ID),0) + 1 FROM STB_NgoaiQuan 
--			SELECT @NewCode = @Prefix + RIGHT('000' + CAST(@Id AS nvarchar(30)),30)


--  /***---------------------------------------------------------------End automatic ID for add recorder-------------------------------------------------------------------***/
		
			--SELECT * FROM STB_NgoaiQuan
--			IF @BR IS NULL

--		BEGIN

--				INSERT INTO STB_NgoaiQuan (LOTNO,IDCODE,IDNQ,MODEL,INPUTQTY,OK,CreateDateTime,CreateUserID) VALUES (@LOTNO,@IDCODE,@NewCode,@MODEL,@QTYINPUT,@QTYOK,DATEADD(HH, -2, GETDATE()),@ProcessUserID)


--				SELECT
--						TOP(1)
--						--ID,
--						--IDNQ,
--						--IDCODE,
--						MODEL,
--						LOTNO,
--						INPUTQTY,
--						OK,
--						--NGUOC,
--						--HUHONG,
--						--XUOC,
--						--BIENSAC,
--						--THUYCHAN,
--						--LOICHAN,
--						--BEPTHAN,
--						--BEPDAY,
--						--NHIEMBAN,
--						--BOCNGUOC,
--						--NHANBOCNG,
--						VITRILO,
--						VITRICURLING,
--						NAMEERROR,
--						QTYERROR,
--						--DIVAT,
--						--TOTALNG,
--						CreateDateTime,
--						CreateUserID,
--						ChangeDateTime,
--						ChangeUserID
--				FROM 
--						STB_NgoaiQuan WITH(NOLOCK)
--				WHERE
--						LOTNO = @BARCODE 
--		END
--END
	--ELSE
	--	BEGIN
	--			 DECLARE @NotEnoughStockError NVARCHAR(MAX)
	--				EXEC usp_GetSystemStringResource	@ProcessLanguage,
	--													N'Vui lòng nhập đầy đủ thông tin của againg, bạn mới có thể nhập được Ngoại Quan ^.^',
	--													@NotEnoughStockError OUTPUT

	--				RAISERROR(@NotEnoughStockError,16,1)
	--				RETURN		
	--	END
				
END
END
-- SELECT * FROM STB_MasterAgaingDetails
-- SELECT * FROM STB_MasterAgaing
-- SELECT * FROM STB_NgoaiQuan
-- delete STB_MasterAgaing
-- delete STB_MasterAgaingDetails
-- delete STB_NgoaiQuan