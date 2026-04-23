CREATE PROC [dbo].[usp_ERPInterface_daemon]
AS
BEGIN
	Declare @InterfaceName VARCHAR(100)
	Declare @IUD_FLAG VARCHAR(400)
	Declare @InterfaceFinYn CHAR(1)
	Declare @EIInfText01 VARCHAR(400)
	Declare @EIInfText02 VARCHAR(400)
	Declare @EIInfText03 VARCHAR(400)
	Declare @EIInfText04 VARCHAR(400)
	Declare @EIInfText05 VARCHAR(400)
	Declare @EIInfText06 VARCHAR(400)
	Declare @EIInfText07 VARCHAR(400)
	Declare @EIInfText08 VARCHAR(400)
	Declare @EIInfText09 VARCHAR(400)
	Declare @EIInfText10 VARCHAR(400)
	Declare @EIInfInt01 BIGINT
	Declare @EIInfInt02 BIGINT
	Declare @EIInfInt03 BIGINT
	Declare @EIInfInt04 BIGINT
	Declare @EIInfInt05 BIGINT
	Declare @EIInfInt06 BIGINT
	Declare @EIInfInt07 BIGINT
	Declare @EIInfInt08 BIGINT
	Declare @EIInfInt09 BIGINT
	Declare @EIInfInt10 BIGINT
	Declare @EIInfReal01 NUMERIC(20, 4)
	Declare @EIInfReal02 NUMERIC(20, 4)
	Declare @EIInfReal03 NUMERIC(20, 4)
	Declare @EIInfReal04 NUMERIC(20, 4)
	Declare @EIInfReal05 NUMERIC(20, 4)
	Declare @EIInfReal06 NUMERIC(20, 4)
	Declare @EIInfReal07 NUMERIC(20, 4)
	Declare @EIInfReal08 NUMERIC(20, 4)
	Declare @EIInfReal09 NUMERIC(20, 4)
	Declare @EIInfReal10 NUMERIC(20, 4)
	Declare @EIInfDate01 DATETIME
	Declare @EIInfDate02 DATETIME
	Declare @EIInfDate03 DATETIME
	Declare @EIInfDate04 DATETIME
	Declare @EIInfDate05 DATETIME
	Declare @EIInfDate06 DATETIME
	Declare @EIInfDate07 DATETIME
	Declare @EIInfDate08 DATETIME
	Declare @EIInfDate09 DATETIME
	Declare @EIInfDate10 DATETIME
	Declare @Idx BIGINT
	Declare @InterfaceDetailCode VARCHAR(20)
	Declare @ErpSeqNum VARCHAR(20)
	Declare @Today VARCHAR(10) = CONVERT(VARCHAR(10), GETDATE(), 121)
	Declare @WarehouseCode VARCHAR(20)

	DECLARE CUR CURSOR FOR
               SELECT InterfaceName, IUD_FLAG, InterfaceFinYn, EIInfText01, EIInfText02
			         ,EIInfText03, EIInfText04, EIInfText05, EIInfText06, EIInfText07
					 ,EIInfText08, EIInfText09, EIInfText10, EIInfInt01, EIInfInt02
					 ,EIInfInt03, EIInfInt04, EIInfInt05, EIInfInt06, EIInfInt07
					 ,EIInfInt08, EIInfInt09, EIInfInt10, EIInfReal01, EIInfReal02
					 ,EIInfReal03, EIInfReal04, EIInfReal05, EIInfReal06, EIInfReal07
					 ,EIInfReal08, EIInfReal09, EIInfReal10, EIInfDate01, EIInfDate02
					 ,EIInfDate03, EIInfDate04, EIInfDate05, EIInfDate06, EIInfDate07
					 ,EIInfDate08, EIInfDate09, EIInfDate10, IDX, InterfaceDetailCode
			     FROM STB_ERP_INTERFACE
				WHERE InterfaceFinYn = 'N'
				ORDER BY InterfaceName, IDX

			OPEN CUR

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM CUR INTO
								  @InterfaceName, @IUD_FLAG, @InterfaceFinYn, @EIInfText01, @EIInfText02
								 ,@EIInfText03, @EIInfText04, @EIInfText05, @EIInfText06, @EIInfText07
								 ,@EIInfText08, @EIInfText09, @EIInfText10, @EIInfInt01, @EIInfInt02
								 ,@EIInfInt03, @EIInfInt04, @EIInfInt05, @EIInfInt06, @EIInfInt07
								 ,@EIInfInt08, @EIInfInt09, @EIInfInt10, @EIInfReal01, @EIInfReal02
								 ,@EIInfReal03, @EIInfReal04, @EIInfReal05, @EIInfReal06, @EIInfReal07
								 ,@EIInfReal08, @EIInfReal09, @EIInfReal10, @EIInfDate01, @EIInfDate02
								 ,@EIInfDate03, @EIInfDate04, @EIInfDate05, @EIInfDate06, @EIInfDate07
								 ,@EIInfDate08, @EIInfDate09, @EIInfDate10, @Idx, @InterfaceDetailCode



                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				IF @InterfaceName = 'MaterialMaster'
				BEGIN
					IF @IUD_FLAG = 'INSERT'
					BEGIN
						INSERT INTO erpsvr.erpdb.dbo.product (PRODCD, PRODNM, ACTGBN, PUNIT, 적용일
						                                             , USEGBN, PNO, 입력일시, 입력자, 수정일시
																	 , 수정자)
								SELECT @EIInfText01, @EIInfText02, @EIInfText03, @EIInfText04, @EIInfDate01
									 , @EIInfText05, @EIInfText06, @EIInfDate02, @EIInfText07, @EIInfDate03
									 , @EIInfText08

					END -- END IF

					IF @IUD_FLAG = 'UPDATE'
					BEGIN 
						UPDATE erpsvr.erpdb.dbo.product 
						   SET PRODNM = @EIInfText02
							  ,ACTGBN = @EIInfText03
							  ,PUNIT = @EIInfText04
							  ,PNO = @EIInfText06
							  ,수정일시 = @EIInfDate03
							  ,수정자 = @EIInfText08
						 WHERE PRODCD = @EIInfText01
					END -- END IF

					IF @IUD_FLAG = 'DELETE'
					BEGIN 
						UPDATE erpsvr.erpdb.dbo.product 
						   SET USEGBN = 'N'
							  ,수정일시 = @EIInfDate03
							  ,수정자 = @EIInfText08
						 WHERE PRODCD = @EIInfText01
					END

					EXEC usp_ERPInterfaceFinish_u @Idx
				END -- END IF

				--자재, 제품 입출고 인터페이스

				IF @EIInfText03 = 'FERT' BEGIN 
					SET @WarehouseCode = '12'
				END ELSE BEGIN
					SET @WarehouseCode = '10'
				END

				IF @InterfaceName = 'GR'
				BEGIN 
					IF @InterfaceDetailCode IN ('GR_RETURN_MATERIAL', 'GR_RETURN_PRODUCT')
					BEGIN 
						--반품입고
						EXEC ERPSVR.ERPDB.DBO.MM0402_NUM_OUT '01', @Today, @ErpSeqNum OUTPUT
						
						INSERT INTO ERPSVR.ERPDB.DBO.제품출고대장 (출고번호, 출고항번, 출고일자, 사업장, 창고
						                                   ,품목코드, 수량)
								VALUES (@ErpSeqNum, 1, @Today, '01', @WarehouseCode
								       ,@EIInfText01, @EIInfReal01)

						EXEC usp_ERPInterfaceFinish_u @Idx
					END
					ELSE
					BEGIN
						--일반입고
						EXEC ERPSVR.ERPDB.DBO.MM0310_NUM_OUT '01', @Today, @ErpSeqNum OUTPUT

						INSERT INTO ERPSVR.ERPDB.DBO.제품입고대장 (입고번호, 입고항번, 입고구분, 입고일자, 사업장
						                                          ,창고, 품목코드, 수량)
								VALUES (@ErpSeqNum, 1, '90', @Today, '01'
								       ,@WarehouseCode, @EIInfText01, @EIInfReal01)

						EXEC usp_ERPInterfaceFinish_u @Idx
					END
				END
				ELSE
				BEGIN
					--일반출고
					EXEC ERPSVR.ERPDB.DBO.FM0306_NUM_OUT '01', @Today, @ErpSeqNum OUTPUT

					INSERT INTO ERPSVR.ERPDB.DBO.자재투입 (투입번호, 투입항번, 투입일자, 투입구분, 사업장
														  ,창고, 품목코드, 수량)
							VALUES (@ErpSeqNum, 1, @Today, '01', '01'
									, @WarehouseCode,@EIInfText01, @EIInfReal01)

					EXEC usp_ERPInterfaceFinish_u @Idx
				END
				--OTHER INTERFACE PROCESS 
				
			END -- END WHILE

			CLOSE CUR;
			DEALLOCATE CUR;
END