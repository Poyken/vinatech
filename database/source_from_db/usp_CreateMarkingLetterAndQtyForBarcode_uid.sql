-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-03-24
-- Description:	Thêm  marking cho nhà máy hà nam
-- =============================================
CREATE PROCEDURE [dbo].[usp_CreateMarkingLetterAndQtyForBarcode_uid]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProcessViewName VARCHAR(50),
						@pXml NVARCHAR(MAX) = null
AS
BEGIN

	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @IsAutoKey BIT=1
    DECLARE @IsLoopIUD BIT=1
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT

    -- Declare Columns Variable
	DECLARE @MarkingCode	VARCHAR(50)
	DECLARE @MarkingName	VARCHAR(50)
	DECLARE @Barcode		VARCHAR(50)
	DECLARE @QtyOfMarking			int        
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID	varchar(50)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID	varchar(50)
	DECLARE @WorkCenterCode varchar(50)

	DECLARE @ProdQtyCheck 	int  --số lượng thực tế 
	DECLARE @TotalProdQtyMarkingInsert 	int -- tổng số lượng đã chia có 2 TH 1 là insert 2 là update. chỉ cho update từng bản ghi 1 để có thể so sánh số lượng
	DECLARE @TotalProdQtyMarkingUpdate 	int 

	DECLARE @iDoc INT


	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
					'INSERT' AS IUD_FLAG,
							MarkingCode,		
							MarkingName	,	
							Barcode,			
							QtyOfMarking	,			
							CreateDateTime,	
							CreateUserID,	
							ChangeDateTime,	
							ChangeUserID,
							WorkCenterCode	

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										MarkingCode		varchar(50),
										MarkingName		varchar(50),
										Barcode			varchar(50),
										QtyOfMarking				int,
										CreateDateTime	datetimeoffset,
										CreateUserID	varchar(50),
										ChangeDateTime	datetimeoffset,
										ChangeUserID	varchar(50),
										WorkCenterCode	varchar(50)
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							MarkingCode,		
							MarkingName	,	
							Barcode,			
							QtyOfMarking	,			
							CreateDateTime,	
							CreateUserID,	
							ChangeDateTime,	
							ChangeUserID,
							WorkCenterCode
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										MarkingCode		varchar(50),
										MarkingName		varchar(50),
										Barcode			varchar(50),
										QtyOfMarking				int,
										CreateDateTime	datetimeoffset,
										CreateUserID	varchar(50),
										ChangeDateTime	datetimeoffset,
										ChangeUserID	varchar(50),
										WorkCenterCode	varchar(50)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							MarkingCode,		
							MarkingName	,	
							Barcode,			
							QtyOfMarking	,			
							CreateDateTime,	
							CreateUserID,	
							ChangeDateTime,	
							ChangeUserID,
							WorkCenterCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										MarkingCode		varchar(50),
										MarkingName		varchar(50),
										Barcode			varchar(50),
										QtyOfMarking				int,
										CreateDateTime	datetimeoffset,
										CreateUserID	varchar(50),
										ChangeDateTime	datetimeoffset,
										ChangeUserID	varchar(50),
										WorkCenterCode	varchar(50)
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@MarkingCode,	
								@MarkingName,	
								@Barcode,		
								@QtyOfMarking,			
								@CreateDateTime,
								@CreateUserID,	
								@ChangeDateTime,
								@ChangeUserID,	
								@WorkCenterCode
				
				-- Lấy ra số lượng thực tế của công đoạn ngoại quan
				SELECT	@ProdQtyCheck= PRH.ProdQty - ISNULL(DRI.DefectQty, 0)
	
						   FROM STB_ProdRouteHist PRH
						   LEFT OUTER JOIN STB_MaterialMaster MM	  ON PRH.MaterialCode = MM.MaterialCode
						   LEFT OUTER JOIN STB_ProdWorkerInfo PWI  ON PRH.WorkerCode = PWI.EmpNo
						   LEFT OUTER JOIN STB_MachineMaster MM2 ON PRH.MachineCode = MM2.MachineCode
						   LEFT OUTER JOIN ( SELECT ControlNo, FindRouteCode, SUM(DefectQty - RepairQty) AS DefectQty 
													  FROM STB_DefectRepairInfo 
													 WHERE RepairType NOT IN ('MISSING', 'FINISH')
													 	 and DefectQty>0.5
													 GROUP BY ControlNo, FindRouteCode
												  ) DRI	     ON PRH.ControlNo = DRI.ControlNo        AND PRH.RouteCode = DRI.FindRouteCode

						   LEFT OUTER JOIN STB_RouteInfo RI	     ON PRH.RouteCode = RI.RouteCode
							 WHERE PRH.ControlNo = ( SELECT ControlNo
													 FROM STB_SetInfo SI
													WHERE Barcode = @Barcode
												   )
								AND PRH.RouteCode='VE09'
						-- Lấy ra số lượng đã lưu trong bảng
			
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)
					/*

					IF EXISTS (SELECT 1 FROM STB_CreateMarkingLetterAndQtyForBarcode WHERE MarkingName = @MarkingName and Barcode= @Barcode)
					BEGIN
						RAISERROR(N'Bạn đã thêm chữ marking cho lot sản phẩm này rồi ! Vui lòng kiểm tra lại ....', 16, 1)
					END
					*/
					
					select @TotalProdQtyMarkingInsert= sum(Qty) from STB_CreateMarkingLetterAndQtyForBarcode where barcode=@Barcode
					if(@QtyOfMarking >1)
					begin
						-- So sánh xem số lượng đã lưu và số lượng chuẩn bị lưu có vượt quá số lượng OK không.
						if((@TotalProdQtyMarkingInsert+@QtyOfMarking)>@ProdQtyCheck)
							begin
							    declare @toal nvarchar(200) = @ProdQtyCheck - @TotalProdQtyMarkingInsert -- số lượng còn lại có thể lưu là 
								declare @r nvarchar(200) = @TotalProdQtyMarkingInsert+@QtyOfMarking -- số lượng tổng của các bản ghi đã lưu và số lượng đang sửa đổi ở bản ghi hiện tại
								declare @currentQty nvarchar(200) = @ProdQtyCheck  -- Số lượng OK của lot hàng

								declare @errorInsert nvarchar(200)=
								N'Số lượng của bạn đã vượt quá số lượng cho phép. Số lượng đã lưu và chuẩn bị lưu là :'+@r 
								+ CHAR(13) + CHAR(10) 
								+N'Số lượng thực tế là : ' + @currentQty
								+ CHAR(13) + CHAR(10) 
								+N'Số lượng thực tế còn lại có thể lưu là : ' + @toal
					

								RAISERROR(@errorInsert, 16, 1)
							end
							
					end
					IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CreateMarkingLetterAndQtyForBarcode',@MarkingCode OUTPUT
                    END
				
					INSERT INTO STB_CreateMarkingLetterAndQtyForBarcode
						(
							MarkingCode,		
							MarkingName	,	
							Barcode,			
							Qty	,			
							CreateDateTime,	
							CreateUserID,
							Workcentercode	
						)
						VALUES
						(
							@MarkingCode,
							@MarkingName,
							@Barcode,
							@QtyOfMarking,
							GETDATE(),
							@pProcessUserID,
							@Workcentercode	
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

					select @TotalProdQtyMarkingInsert= sum(Qty) from STB_CreateMarkingLetterAndQtyForBarcode where barcode=@Barcode -- Lấy ra số lượng đã lưu trong bảng

					select @TotalProdQtyMarkingUpdate= sum(Qty) from STB_CreateMarkingLetterAndQtyForBarcode where barcode=@Barcode and MarkingCode not in (@MarkingCode) -- lấy ra số lượng đã lưu trừ bản ghi đang sửa đổi
					-- So sánh xem số lượng đã lưu và số lượng chuẩn bị lưu có vượt quá số lượng OK không.
							if((@TotalProdQtyMarkingUpdate+@QtyOfMarking)>@ProdQtyCheck)
							begin
								declare @a nvarchar(200) = @TotalProdQtyMarkingUpdate+@QtyOfMarking -- số lượng tổng của các bản ghi đã lưu và số lượng đang sửa đổi ở bản ghi hiện tại
								declare @b nvarchar(200) = @ProdQtyCheck  -- Số lượng OK của lot hàng
								--declare @c nvarchar(200) =  @QtyOfMarking + @ProdQtyCheck -@TotalProdQtyMarkingInsert
				

								declare @errorUpdate nvarchar(200)=
								N'Số lượng của bạn đã vượt quá số lượng cho phép :'+@a 
								+ CHAR(13) + CHAR(10) 
								+N'Số lượng thực tế là : ' + @b
								--+ CHAR(13) + CHAR(10)
								--+N'Số bạn có thể lưu với bản ghi bạn đang sửa là  : ' + @c

								RAISERROR(@errorUpdate, 16, 1)
									
							end
							/*
							-- chặn lấy ra mã marking này đã được nhập kho hay chưa nếu nhập rồi thì chặn k cho phép sửa và cập nhật
							IF EXISTS( select 1  from STB_VN_FINISHGOODS_HN_New FG  where FG.LotNo=@Barcode and StatusImport=1)
							BEGIN
							       RAISERROR(N'Bạn không thể thay đổi mã Marking vì barcode này đã nhập kho, nếu muốn vui lòng liên hệ chị Xuân', 16, 1);
							END
							*/

					UPDATE STB_CreateMarkingLetterAndQtyForBarcode
						SET
							Barcode = ISNULL(@Barcode, Barcode),
							MarkingName = ISNULL(@MarkingName, MarkingName),
							Qty = ISNULL(@QtyOfMarking, Qty),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID

						WHERE
							MarkingCode = @MarkingCode

					
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					-- chặn lấy ra mã marking này đã được nhập kho hay chưa nếu nhập rồi thì chặn k cho phép sửa và cập nhật
							-- chặn lấy ra mã marking này đã được nhập kho hay chưa nếu nhập rồi thì chặn k cho phép sửa và cập nhật
							/*
							IF EXISTS( select 1  from STB_VN_FINISHGOODS_HN_New FG  where FG.LotNo=@Barcode and StatusImport=1)
							BEGIN
							    RAISERROR(N'Bạn không thể thay đổi mã Marking vì barcode này đã nhập kho, nếu muốn vui lòng liên hệ chị Xuân', 16, 1);
							END
							*/
					DELETE FROM STB_CreateMarkingLetterAndQtyForBarcode
						WHERE
							MarkingCode = @MarkingCode

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
    --END


END
