CREATE PROC [dbo].[usp_MasterAgain] --EXEC usp_MasterAgain '','','VVKT163R033506'
@pProcessLanguage VARCHAR(20) = NULL,
@pProcessUserID VARCHAR(20) = NULL,
@pBarCode NVARCHAR(50) = NULL
AS
BEGIN
	
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @BarCode NVARCHAR(50) = @pBarCode
	DECLARE @PRODROUTEHISTNO NVARCHAR(50)
	DECLARE @PONO NVARCHAR(50)
	DECLARE @DAYPLANNO NVARCHAR(50)
	DECLARE @CONTROLNO NVARCHAR(50)
	DECLARE @MATERIALCODE NVARCHAR(50)
	DECLARE @PRODQTY INT
	DECLARE @LINECODE NVARCHAR(20)
	DECLARE @ROUTECODE NVARCHAR(20)
	DECLARE @MACHINECODE NVARCHAR(20)
	DECLARE @USERID NVARCHAR(30)
	DECLARE @DATECREATE DATETIME
	DECLARE @LOTNO NVARCHAR(50)
	DECLARE @CODEID NVARCHAR(30)
	

	-- Kiểm tra xem bảng đã có LOTNO chưa-----

	SELECT
			@CODEID =IDCODE,
			@LOTNO= LOTNO
	FROM 
		 STB_MasterAgaing WITH(NOLOCK)
	WHERE
		 LOTNO = @BarCode

		 --------------------Kết thúc bảng có LOTNO chưa----------------

		 --------------------------------Kiểm tra nếu trong bảng đã tồn tại LOTNO thì hiển thị ra---------------------------------
	    IF @LOTNO IS NOT NULL

		BEGIN
				SELECT 
							ID,
							IDCODE,
							LOTNO,
							PRODROUTEHISTNO,
							PONO,
							DAYPLANNO,
							CONTROLNO,
							MATERIALCODE,
							PRODQTY,
							LINECODE,
							ROUTECODE,
							MACHINECODE,
							USERID,
							DATECREATE,
							CreateDateTime,
							CreateUserID
				FROM 
						STB_MasterAgaing
				WHERE 
						LOTNO = @BarCode
		END

		
		SELECT
				@PRODROUTEHISTNO = ProdRouteHistNo,
				@PONO = PONo,
				@DAYPLANNO = DayPlanNo,
				@CONTROLNO = ControlNo,
				@MATERIALCODE = MaterialCode,
				@PRODQTY = ProdQty,
				@LINECODE = LineCode,
				@ROUTECODE = RouteCode,
				@MACHINECODE = MachineCode,
				@USERID = CreateUserID,
				@DATECREATE = CreateDateTime
				
	    FROM 
			    STB_ProdRouteHist WITH(NOLOCK)
		WHERE 
				--routecode='V-28' 
				--AND 
				controlno= (select controlno from stb_setinfo where barcode = @BarCode)	

		--IF @ROUTECODE IS NULL

		--	BEGIN
		--			 DECLARE @NotEnoughStockError NVARCHAR(MAX)
		--			EXEC usp_GetSystemStringResource	@ProcessLanguage,
		--												N'Mã LotNo này chưa làm qua công đoạn V28, Vui lòng chờ đóng gói xong ^.^',
		--												@NotEnoughStockError OUTPUT

		--			RAISERROR(@NotEnoughStockError,16,1)
		--			RETURN		
		--END	

		/***---------------------------------------------------------------Start automatic ID for add recorder-----------------------------------------------------------------***/


			DECLARE @NewCode NVARCHAR(50)
			DECLARE @Prefix NVARCHAR(30) = 'MAG'
			DECLARE @Id INT

			SELECT @Id = ISNULL(MAX(ID),0) + 1 FROM STB_MasterAgaing 
			SELECT @NewCode = @Prefix + RIGHT('000' + CAST(@Id AS nvarchar(30)),30)


	/***---------------------------------------------------------------End automatic ID for add recorder-------------------------------------------------------------------***/
		
			

			  DECLARE @IDCOES NVARCHAR(50)
			  DECLARE @LOTNOS NVARCHAR(50)

			  SELECT
					  @LOTNOS = LOTNO
			  FROM
					 STB_MasterAgaing
			  WHERE 
					 LOTNO = @BarCode
					
			 IF @LOTNOS IS NULL

				 BEGIN

			   INSERT INTO STB_MasterAgaing (LOTNO,IDCODE,PRODROUTEHISTNO,PONO,DAYPLANNO,CONTROLNO,MATERIALCODE,PRODQTY,LINECODE,ROUTECODE,MACHINECODE,USERID,DATECREATE,CreateDateTime,CreateUserID)
			  VALUES (@BarCode,@NewCode,@PRODROUTEHISTNO,@PONO,@DAYPLANNO,@CONTROLNO,@MATERIALCODE,@PRODQTY,@LINECODE,@ROUTECODE,@MACHINECODE,@USERID,@DATECREATE,DATEADD(HH, -2, GETDATE()),@ProcessUserID)

			  	SELECT 
							TOP(1)
							ID,
							IDCODE,
							LOTNO,
							PRODROUTEHISTNO,
							PONO,
							DAYPLANNO,
							CONTROLNO,
							MATERIALCODE,
							PRODQTY,
							LINECODE,
							ROUTECODE,
							MACHINECODE,
							USERID,
							DATECREATE,
							CreateDateTime,
							CreateUserID 
				FROM 
						STB_MasterAgaing WITH(NOLOCK)
				WHERE 
						LOTNO = @BarCode
						AND
						CreateUserID = @ProcessUserID

				ORDER BY CreateDateTime DESC

			  SELECT
					@IDCOES = IDCODE
			  FROM
					STB_MasterAgaingDetails
			  WHERE 
					IDCODE = @CODEID
				
			IF @IDCOES IS NULL

			BEGIN

				INSERT INTO STB_MasterAgaingDetails (IDCODE,LOTNO,CreateDateTime,CreateUserID) VALUES (@NewCode,@BarCode, DATEADD(HH, -2, GETDATE()),@ProcessUserID)

			END

			 END
	ELSE
		BEGIN
			 
				 --DECLARE @NotEnoughStockErrors NVARCHAR(MAX)
					--EXEC usp_GetSystemStringResource	@ProcessLanguage,
					--									N'Mã LotNo này đã tồn tại ^.^',
					--									@NotEnoughStockErrors OUTPUT

																	SELECT 
																				ID,
																				IDCODE,
																				LOTNO,
																				PRODROUTEHISTNO,
																				PONO,
																				DAYPLANNO,
																				CONTROLNO,
																				MATERIALCODE,
																				PRODQTY,
																				LINECODE,
																				ROUTECODE,
																				MACHINECODE,
																				USERID,
																				DATECREATE,
																				CreateDateTime,
																				CreateUserID
																	FROM 
																			STB_MasterAgaing
																	WHERE 
																			LOTNO = @BarCode

					--RAISERROR(@NotEnoughStockErrors,16,1)
					--RETURN	
					
				
		END
END
