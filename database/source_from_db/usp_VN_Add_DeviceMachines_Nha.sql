-- =============================================
-- Author:	    Kevin, Loan, Tung()
-- Create date: 2016-02-15
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_Add_DeviceMachines_Nha]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
	DECLARE @OldID INT
	DECLARE @ID INT
	DECLARE @BARCODESYSTEM NVARCHAR(100)
	DECLARE @CODEDEVICEMACHINES NVARCHAR(100)
	DECLARE @CODEEXPENSE NVARCHAR(100)
	DECLARE @CODESTOREMACHINES NVARCHAR(100)
	DECLARE @CODESTATUSMACHINES NVARCHAR(100)
	DECLARE @CODELOCATIONMACHINES NVARCHAR(100)
	DECLARE @Classifications NVARCHAR(50)
	DECLARE @BPSDPM  NVARCHAR(50)
	DECLARE @BPDETAIL NVARCHAR(50)
	DECLARE @Seller NVARCHAR(50)
	DECLARE @English  NVARCHAR(50)
	DECLARE @Vietnamese NVARCHAR(500)
	DECLARE @Model NVARCHAR(50)
	DECLARE @Specifications NVARCHAR(50)
	DECLARE @Korean NVARCHAR(50)
	DECLARE @DocumentNo NVARCHAR(100)
	DECLARE @Quantiy INT
	DECLARE @PurchaseDate DATETIME
	DECLARE @CODE NVARCHAR(50)
	DECLARE @IsUsed BIT
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID NVARCHAR(50)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID NVARCHAR(50)
	DECLARE				@BasePriceVND float
	DECLARE				@BasePriceUSD float
	DECLARE				@CodeB250	  varchar(50)


	DECLARE @iDoc INT


	if(@ProcessUserID<>'MrHuy' or @pProcessUserID<>'MrHuy') begin
		raiserror(N'Chỉ có Mr.Huy được phép sửa dữ liệu này!',16,1)
		return;
	end


    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
		DECLARE SourceData CURSOR FOR
            SELECT
                    'INSERT' AS IUD_FLAG,
								XMLData.OldID,
								XMLData.ID,
								XMLData.BARCODESYSTEM,
								XMLData.CODEDEVICEMACHINES,
								XMLData.CODEEXPENSE,
								XMLData.CODESTOREMACHINES,
								XMLData.CODESTATUSMACHINES,
								XMLData.CODELOCATIONMACHINES,
								XMLData.Classifications,
								XMLData.BPSDPM,
								XMLData.BPDETAIL,
								XMLData.Seller,
								XMLData.English,
								XMLData.Vietnamese,
								XMLData.Korean,
								XMLData.Model,
								XMLData.Specifications,
								XMLData.DocumentNo,
								XMLData.Quantiy,
								XMLData.PurchaseDate,
								XMLData.CODE,
								XMLData.IsUsed,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID,
								XMLData.BasePriceVND,
								XMLData.BasePriceUSD,
								XMLData.CodeB250
						FROM
								OPENXML(@idoc , @InsertTableName , 2)
							    WITH  (
										OldID int,
										ID int,
										BARCODESYSTEM NVARCHAR(100),
										CODEDEVICEMACHINES NVARCHAR(100),
										CODEEXPENSE NVARCHAR(100),
										CODESTOREMACHINES NVARCHAR(100),
										CODESTATUSMACHINES NVARCHAR(100),
										CODELOCATIONMACHINES NVARCHAR(100),
										Classifications NVARCHAR(50),
										BPSDPM  NVARCHAR(50),
										BPDETAIL NVARCHAR(50),
										Seller NVARCHAR(50),
										English  NVARCHAR(50), 
										Vietnamese NVARCHAR(500),  
										Korean NVARCHAR(50),  
										Model NVARCHAR(50),
										Specifications NVARCHAR(50),
										DocumentNo NVARCHAR(100),   
										Quantiy INT,
										PurchaseDate DATETIME,
										CODE NVARCHAR(50),
										IsUsed BIT,
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20),
										BasePriceVND float,
										BasePriceUSD float,
										CodeB250	  varchar(50)
										) XMLData
						UNION ALL
						SELECT
								'UPDATE' AS IUD_FLAG,
								CASE 
									WHEN XMLData.OldID IS NULL THEN XMLData.ID
									ELSE XMLData.OldID
								END AS OldID,
								XMLData.ID,
								XMLData.BARCODESYSTEM,
								XMLData.CODEDEVICEMACHINES,
								XMLData.CODEEXPENSE,
								XMLData.CODESTOREMACHINES,
								XMLData.CODESTATUSMACHINES,
								XMLData.CODELOCATIONMACHINES,
								XMLData.Classifications,
								XMLData.BPSDPM,
								XMLData.BPDETAIL,
								XMLData.Seller,
								XMLData.English,
								XMLData.Vietnamese,
								XMLData.Korean,
								XMLData.Model,
								XMLData.Specifications,
								XMLData.DocumentNo,
								XMLData.Quantiy,
								XMLData.PurchaseDate,
								XMLData.CODE,
								XMLData.IsUsed,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID,
								XMLData.BasePriceVND,
								XMLData.BasePriceUSD,
								XMLData.CodeB250	 
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
							    WITH  (
											OldID int,
											ID int,
											BARCODESYSTEM NVARCHAR(100),
											CODEDEVICEMACHINES NVARCHAR(100),
											CODEEXPENSE NVARCHAR(100),
											CODESTOREMACHINES NVARCHAR(100),
											CODESTATUSMACHINES NVARCHAR(100),
											CODELOCATIONMACHINES NVARCHAR(100),
											Classifications NVARCHAR(50),
											BPSDPM  NVARCHAR(50),
											BPDETAIL NVARCHAR(50),
											Seller NVARCHAR(50),
											English  NVARCHAR(50), 
											Vietnamese NVARCHAR(500),  
											Korean NVARCHAR(50),  
											Model NVARCHAR(50),
											Specifications NVARCHAR(50),
											DocumentNo NVARCHAR(100),   
											Quantiy INT,
											PurchaseDate DATETIME,
											CODE NVARCHAR(50),
											IsUsed BIT,
											CreateDateTime DATETIME,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIME,
											ChangeUserID VARCHAR(20),
										BasePriceVND float,
										BasePriceUSD float,
										CodeB250	  varchar(50)
										) XMLData
						UNION ALL
						SELECT
								'DELETE' AS IUD_FLAG,
								CASE 
									WHEN XMLData.OldID IS NULL THEN XMLData.ID
									ELSE XMLData.OldID
								END AS OldID,
								XMLData.ID,
								XMLData.BARCODESYSTEM,
								XMLData.CODEDEVICEMACHINES,
								XMLData.CODEEXPENSE,
								XMLData.CODESTOREMACHINES,
								XMLData.CODESTATUSMACHINES,
								XMLData.CODELOCATIONMACHINES,
								XMLData.Classifications,
								XMLData.BPSDPM,
								XMLData.BPDETAIL,
								XMLData.Seller,
								XMLData.English,
								XMLData.Vietnamese,
								XMLData.Korean,
								XMLData.Model,
								XMLData.Specifications,
								XMLData.DocumentNo,
								XMLData.Quantiy,
								XMLData.PurchaseDate,
								XMLData.CODE,
								XMLData.IsUsed,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID,
								XMLData.BasePriceVND,
								XMLData.BasePriceUSD,
								XMLData.CodeB250
						FROM
								OPENXML(@idoc , @DeleteTableName , 2)
							    WITH  (
										OldID int,
											ID int,
											BARCODESYSTEM NVARCHAR(100),
											CODEDEVICEMACHINES NVARCHAR(100),
											CODEEXPENSE NVARCHAR(100),
											CODESTOREMACHINES NVARCHAR(100),
											CODESTATUSMACHINES NVARCHAR(100),
											CODELOCATIONMACHINES NVARCHAR(100),
											Classifications NVARCHAR(50),
											BPSDPM  NVARCHAR(50),
											BPDETAIL NVARCHAR(50),
											Seller NVARCHAR(50),
											English  NVARCHAR(50), 
											Vietnamese NVARCHAR(500),  
											Korean NVARCHAR(50),  
											Model NVARCHAR(50),
											Specifications NVARCHAR(50),
											DocumentNo NVARCHAR(100),   
											Quantiy INT,
											PurchaseDate DATETIME,
											CODE NVARCHAR(50),
											IsUsed BIT,
											CreateDateTime DATETIME,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIME,
											ChangeUserID VARCHAR(20),
										BasePriceVND float,
										BasePriceUSD float,
										CodeB250	  varchar(50)
										) XMLData


        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@OldID,
								@ID,
								@BARCODESYSTEM,
								 @CODEDEVICEMACHINES,
								 @CODEEXPENSE,
								 @CODESTOREMACHINES,
								 @CODESTATUSMACHINES,
								 @CODELOCATIONMACHINES,
								 @Classifications,
								 @BPSDPM,
								 @BPDETAIL,
								 @Seller,
								 @English, 
								 @Vietnamese,  
								 @Korean,  
								 @Model,
								 @Specifications,
							 	 @DocumentNo,   
								 @Quantiy,
								 @PurchaseDate,
								 @CODE,
								 @IsUsed,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID,
								@BasePriceVND,
								@BasePriceUSD,
								@CodeB250	 


            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END
            IF @IUD_FLAG = 'INSERT' BEGIN
				PRINT 'INSERT'
				 --Get Max No and Create Next No
				Declare @MaxNo INT
				       ,@NextNo VARCHAR(50)

				SELECT @MaxNo = max(cast(substring(BARCODESYSTEM,5,12) as int )) +1
				  FROM STB_VN_DEVICEMACHINES
				
				SET @NextNo = ISNULL('VINA','') + RIGHT(REPLICATE('0',8) + CONVERT(VARCHAR,@MaxNo),8)

				PRINT @NextNo

				-- IF @IsAutoKey = 1 BEGIN
				--		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_DEVICEMACHINES', @BARCODESYSTEM OUTPUT		
				--END

                INSERT INTO STB_VN_DEVICEMACHINES
					(
							BARCODESYSTEM,
							CODEDEVICEMACHINES,
							CODEEXPENSE,
							CODESTOREMACHINES,
							CODESTATUSMACHINES,
							CODELOCATIONMACHINES,
							Classifications,
							BPSDPM,
							BPDETAIL,
							Seller,
							English, 
							Vietnamese,  
							Korean,  
							Model,
							Specifications,
							DocumentNo,   
							Quantiy,
							PurchaseDate,
							CODE,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID,
					BasePriceVND,
					BasePriceUSD,
					CodeB250
					)
					VALUES
					(
						@NextNo,
						--@BARCODESYSTEM,
						@CODEDEVICEMACHINES,
						@CODEEXPENSE,
						@CODESTOREMACHINES,
						@CODESTATUSMACHINES,
						@CODELOCATIONMACHINES,
						@Classifications,
						@BPSDPM,
						@BPDETAIL,
						@Seller,
						@English, 
						@Vietnamese,  
						@Korean,  
						@Model,
						@Specifications,
						@DocumentNo,   
						@Quantiy,
						@PurchaseDate,
						@CODE,
						'1',
						GETDATE(),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID,
								@BasePriceVND,
								@BasePriceUSD,
								@CodeB250	 
					)

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
				
				
                UPDATE STB_VN_DEVICEMACHINES
					SET
							BARCODESYSTEM =   CASE
						                WHEN @BARCODESYSTEM IS NOT NULL THEN @BARCODESYSTEM
						                ELSE BARCODESYSTEM
						            END,
						CODEDEVICEMACHINES =   CASE
						                WHEN @CODEDEVICEMACHINES IS NOT NULL THEN @CODEDEVICEMACHINES
						                ELSE CODEDEVICEMACHINES
						            END,

							 CODEEXPENSE =   CASE
						                WHEN @CODEEXPENSE IS NOT NULL THEN @CODEEXPENSE
						                ELSE CODEEXPENSE
						            END,

							 CODESTOREMACHINES =   CASE
						                WHEN @CODESTOREMACHINES IS NOT NULL THEN @CODESTOREMACHINES
						                ELSE CODESTOREMACHINES
						            END,
							 CODELOCATIONMACHINES =   CASE
						                WHEN @CODELOCATIONMACHINES IS NOT NULL THEN @CODELOCATIONMACHINES
						                ELSE CODELOCATIONMACHINES
						            END,
						 CODESTATUSMACHINES =   CASE
						                WHEN @CODESTATUSMACHINES IS NOT NULL THEN @CODESTATUSMACHINES
						                ELSE CODESTATUSMACHINES
						            END,

						 Classifications =   CASE
						                WHEN @Classifications IS NOT NULL THEN @Classifications
						                ELSE Classifications
						            END,

						 BPSDPM =   CASE
						                WHEN @BPSDPM IS NOT NULL THEN @BPSDPM
						                ELSE BPSDPM
						            END,

						 BPDETAIL =   CASE
						                WHEN @BPDETAIL IS NOT NULL THEN @BPDETAIL
						                ELSE BPDETAIL
						            END,

										 Seller =   CASE
						                WHEN @Seller IS NOT NULL THEN @Seller
						                ELSE Seller
						            END,

										 Vietnamese =   CASE
						                WHEN @Vietnamese IS NOT NULL THEN @Vietnamese
						                ELSE Vietnamese
						            END,

										 English =   CASE
						                WHEN @English IS NOT NULL THEN @English
						                ELSE English
						            END,

										 Korean =   CASE
						                WHEN @Korean IS NOT NULL THEN @Korean
						                ELSE Korean
						            END,

										Model = CASE
										WHEN @Model IS NOT NULL THEN @Model
										ELSE Model
									END,
									
									 Specifications =   CASE
						                WHEN @Specifications IS NOT NULL THEN @Specifications
						                ELSE Specifications
						            END,

									 DocumentNo =   CASE
						                WHEN @DocumentNo IS NOT NULL THEN @DocumentNo
						                ELSE DocumentNo
						            END,


									 Quantiy =   CASE
						                WHEN @Quantiy IS NOT NULL THEN @Quantiy
						                ELSE Quantiy
						            END,

									 PurchaseDate =   CASE
						                WHEN @PurchaseDate IS NOT NULL THEN @PurchaseDate
						                ELSE PurchaseDate
						            END,

									CODE =   CASE
						                WHEN @CODE IS NOT NULL THEN @CODE
						                ELSE CODE
						            END,

										IsUsed =   CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
						            END,

						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID,
							
								BasePriceVND=@BasePriceVND,
								BasePriceUSD=@BasePriceUSD,
								CodeB250=@CodeB250	 
					WHERE
						ID = @OldID
            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                DELETE FROM STB_VN_DEVICEMACHINES
					WHERE
						ID = @ID
              END
        END

    END TRY

	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
			
	CLOSE SourceData;
	
	DEALLOCATE SourceData;
			
	EXEC sp_xml_removedocument @idoc	

END

