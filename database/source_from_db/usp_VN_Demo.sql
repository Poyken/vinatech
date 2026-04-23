-- =============================================
-- Author:	Kevin Nguyen(nguyennha@vina.co.kr)
-- Create date: 2020.06.23
-- Browsable : true
-- Group : EA VN TEAM
-- Description:	The scrap function.
-- =============================================
CREATE PROC usp_VN_Demo
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@IDIF INT,
	    @CLASSIFY NVARCHAR(50) ,
	    @STAGE NVARCHAR(50),
	    @STAGENAME NVARCHAR(50),
	    @MODEL NVARCHAR(50),
	    @PRODUCTIONNAME NVARCHAR(50),
	    @UNIT NVARCHAR(20),
	    @STATUSS NVARCHAR(50),
	    @LOCATIONS NVARCHAR(50),
	    @QTYONPAGER NVARCHAR(50),
	    @ACTUALLYQTY NVARCHAR(50),
	    @DESCRIPTIONS NVARCHAR(500),
	    @DateInput DATETIME,
        @CreateUserID NVARCHAR(20)
	AS
	BEGIN
		    SET NOCOUNT ON;

		DECLARE @GetID INT
		DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
		DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	    --DECLARE @Line VARCHAR(100) = CASE WHEN ISNULL(@pLine,'') = '' THEN '%' ELSE @pLine END,
				
			IF @IDIF IS NOT NULL

			BEGIN
						UPDATE STB_VN_InventoryFirst
							   SET
									  CLASSIFY = @CLASSIFY,
									  STAGE = @STAGE,
									  STAGENAME = @STAGENAME,
									  MODEL = @MODEL,
									  PRODUCTIONNAME = @PRODUCTIONNAME,
									  UNIT = @UNIT,
									  STATUSS = @STATUSS,
									  LOCATIONS = @LOCATIONS,
							          QTYONPAGER = @QTYONPAGER,
								      ACTUALLYQTY = @ACTUALLYQTY,
									  DESCRIPTIONS = @DESCRIPTIONS,
								      DateInput = @DateInput,
						              CreateDateTime = GETDATE(),
								      CreateUserID = @ProcessUserID
						WHERE
									  IDIF = @IDIF
				END

		ELSE IF @IDIF IS NULL

				BEGIN

						INSERT INTO STB_VN_InventoryFirst
									(
						    CLASSIFY,
						    STAGE,
							STAGENAME,
						    MODEL,
						    PRODUCTIONNAME,
						    UNIT,
						    STATUSS,
						    LOCATIONS,
						    QTYONPAGER,
						    ACTUALLYQTY,
							DESCRIPTIONS,
							DateInput,
						    CreateDateTime,
						    CreateUserID
						   
						)
						VALUES
						(
						    @CLASSIFY,
						    @STAGE,
							@STAGENAME,
							@MODEL,
							@PRODUCTIONNAME,
							@UNIT,
							@STATUSS,
						    @LOCATIONS,
							@QTYONPAGER,
						    @ACTUALLYQTY,
						    @DESCRIPTIONS,
							@DateInput,
						    GETDATE(),
						    @ProcessUserID
						)

				END
			
		--ELSE IF   @GetID = @IDIF
		--		BEGIN
		--				UPDATE STB_VN_InventoryFirst
		--					   SET
		--							  CLASSIFY = @CLASSIFY,
		--							  STAGE = @STAGE,
		--							  STAGENAME = @STAGENAME,
		--							  MODEL = @MODEL,
		--							  PRODUCTIONNAME = @PRODUCTIONNAME,
		--							  UNIT = @UNIT,
		--							  STATUSS = @STATUSS,
		--							  LOCATIONS = @LOCATIONS,
		--					          QTYONPAGER = @QTYONPAGER,
		--						      ACTUALLYQTY = @ACTUALLYQTY,
		--							  DESCRIPTIONS = @DESCRIPTIONS,
		--						      DateInput = @DateInput,
		--				              CreateDateTime = GETDATE(),
		--						      CreateUserID = @ProcessUserID
		--				WHERE
		--							  IDIF = @IDIF
		--		END
		--ELSE
		--		BEGIN
		--				DELETE 
		--						STB_VN_InventoryFirst
		--				WHERE
		--						 IDIF = @IDIF
		--		END
			
	END