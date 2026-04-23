CREATE PROCEDURE [dbo].[usp_VN_Add_ImportExcel_HN]
@LotNo VARCHAR(50),
@PackingID VARCHAR(50),
@PackQty INT,
@PublicCode VARCHAR(50),
@IDCODE VARCHAR(50),
@CreateUserID varchar(50),
@SoPhieuNhapKho VARCHAR(50),
@INPUTFROM VARCHAR(50),
@LOCATIONS VARCHAR(100)
AS  
BEGIN   
		BEGIN TRY
						exec usp_VVT_checkHOLD_QC @pLotNo=@LotNo
						Declare @CheckPackingID varchar(50),
								@checkCreateTemFake int,   -- kiểm tra xem có tạo tem fake không.
								@checkExis int
						declare @err nvarchar(200)
						select @CheckPackingID=count(PackingID) from STB_MaterialLotInfo where PackingID=@PackingID

						select @checkCreateTemFake = count(PackingID) from STB_CreateTemFakeForHaNam where packingid=@PackingID and LotNo=@LotNo

						select @checkExis=count(PackingID) from STB_VN_FINISHGOODS_HN_New where PackingID=@PackingID and LotNo=@LotNo
						
						if(@CheckPackingID <1 and @checkCreateTemFake <1)
							BEGIN
									set @err = N'Packing này không tồn tại trong hệ thống ! '+@PackingID
									RAISERROR(@err,16, 1);
							END
						if(@checkExis >0)
							BEGIN
									set @err = N'Packing này đã nhập kho rồi ! '+@PackingID
									RAISERROR(@err,16, 1);
							END
						INSERT INTO STB_VN_FINISHGOODS_HN_New
							(
								IDCODE,
								PackingID,
								LotNo,
								PackQty,
								CreateDateTime,
								MethodAction,
								PublicCode,
								SoPhieuNhapKho,
								TypeInput,
								LOCATIONS,
								CreateUserID
							)
							VALUES
							(
								@IDCODE,
								@PackingID,
								@LotNo,
								@PackQty,
								DATEADD(HH, -2, GETDATE()),
								N'Nhập bằng Excel',
								@PublicCode,
								@SoPhieuNhapKho,
								@INPUTFROM,
								@LOCATIONS,
								@CreateUserID
							)
	END TRY
	BEGIN CATCH

		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50002, @ErrorMessage, 1;
	END CATCH	

			
END


