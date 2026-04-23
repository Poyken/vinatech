

CREATE PROCEDURE [dbo].[usp_VN_Update_ExportExcel_HN]

@PackingID NVARCHAR(50),
@PackingID_Divide NVARCHAR(50),
@LotNo NVARCHAR(50),
@Qty INT,
@Country  NVARCHAR(50),
@Uid NVARCHAR(50),
@SoPhieuXuatKho NVARCHAR(50),
@SoInVoice NVARCHAR(50),
@SoToKhaiHaiQuan NVARCHAR(50),
@TYPEEXPORT NVARCHAR(50),
@Levleout NVARCHAR(50),
@Vanchuyen NVARCHAR(50),
@Khachhang NVARCHAR(50),
@DateExport datetime,
@IDCODE VARCHAR(50)
AS
BEGIN
			BEGIN TRY

		DECLARE @Barcode NVARCHAR(50)
		DECLARE @Sts NVARCHAR(50)
		DECLARE @Coun NVARCHAR(50) ,
				@checkMaterialLotInfo int,  -- kiểm tra xem đã có lot ở hoàn thành côgn đoạn chưa 
				@checkDividePackaging int,   -- kiểm tra xem có chia lot hay không.
				@checkCreateTemFake int,   -- kiểm tra xem có tạo tem fake không.
				@checkQty numeric(20,5),
				@QtyInWarehouse numeric(20,5),
				@Err nvarchar(500)

				select @checkMaterialLotInfo=count(PackingID) from stb_materiallotinfo where packingid=@PackingID and LotNo=@LotNo

				select @checkDividePackaging=count(PackingID) from STB_DividePackaging where packingid=@PackingID_Divide

				select @checkMaterialLotInfo=packQtyoutput+@Qty,@QtyInWarehouse=packQty from STB_VN_FINISHGOODS_HN_New where packingid=@PackingID  and LotNo=@LotNo

				select @checkCreateTemFake = count(PackingID) from STB_CreateTemFakeForHaNam where packingid=@PackingID and LotNo=@LotNo

		if(@checkDividePackaging >=1)  --check nếu mà mã đã chia cso trong bảng thì phải lấy số lượng đã chia để input vào hệ thống
		   begin
			select @Qty=Qty from STB_DividePackaging  where packingid=@PackingID_Divide
		   end

		if(@checkMaterialLotInfo < 1 and @checkDividePackaging <1 and @checkCreateTemFake < 1) -- kiểm tra xem packing có trong hệ thống hay không
		begin
			set @Err = N'Lot của bạn không có trên hệ thống : '+@PackingID  +N' hoặc :' +isnull(@PackingID_Divide,N'.....')
			raiserror(@Err,16,1)
			return
		end

		if(@QtyInWarehouse < @checkMaterialLotInfo) --kiểm tra số lượng đầu vào có vượt quá số lượng trong kho hay không
		begin
			set @Err = N'Số lượng xuất kho của Packing : '+@PackingID +','+@PackingID_Divide+N' đang vượt quá số lượng trong kho .' 
			raiserror(@Err,16,1)
			return
		end

		INSERT INTO [dbo].[STB_VN_FINISHGOODS_HN_Export]
           ([CodeExport]
           ,[LotNo]
           ,[PackingID]
		   ,[PackingID_Divide]
           ,[Qty]
           ,[Country]
           ,[SoPhieuXuatKho]
           ,[SoInVoice]
           ,[SoToKhaiHaiQuan]
           ,[TypeExport]
           ,[TRANSPORT]
           ,[CustomerName]
           ,[LevelOut]
           ,[DateRequestExport]
           ,[CreateDateTime]
           ,[CreateUserID]
           )
     VALUES
           (@IDCODE
           ,@LotNo
           ,@PackingID
		   ,@PackingID_Divide
           ,@Qty
           ,@Country
           ,@SoPhieuXuatKho
           ,@SoInVoice
           ,@SoToKhaiHaiQuan
           ,@TYPEEXPORT
           ,@Vanchuyen
           ,@Khachhang
           ,@Levleout
           ,@DateExport
           ,getdate()
           ,@Uid
           )

		-- cập nhật số lượng đã xuất kho
		update STB_VN_FINISHGOODS_HN_New
		set packQtyoutput = isnull(packQtyoutput,0)+@Qty
		where PackingID=@PackingID and LotNo=@LotNo


	END TRY
	BEGIN CATCH

		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50002, @ErrorMessage, 1;
	END CATCH
END
-- select * from STB_VN_FINISHGOODS_HN_Export where LotNo ='VVNU083R038733'

