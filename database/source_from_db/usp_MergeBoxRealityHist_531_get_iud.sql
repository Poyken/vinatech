-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-27
-- =============================================
--exec usp_stb_MergeBoxRealityHist_531_get 'VVOO152R725665'
CREATE PROCEDURE [dbo].[usp_MergeBoxRealityHist_531_get_iud]
    @pProcessUserID VARCHAR(20) = NULL,
    @pProcessLanguage VARCHAR(20) = NULL,
    @pMergeNumber VARCHAR(50) = NULL,
    @pBarcode VARCHAR(50) = NULL,
    @pBoxQty INT = NULL,
	@pDelete bit  = 0
	
AS
BEGIN
	--DECLARE @test VARCHAR(50)=@pDelete;
	--  RAISERROR(@test, 16, 1);
    -- Kiểm tra xem các tham số cần thiết có hợp lệ không
	DECLARE @BoxQty int 
    IF @pBoxQty IS NULL OR @pBoxQty <=0 OR @pBarcode IS NULL
    BEGIN
        RAISERROR('Barcode không được để trống và số lượng phải lớn hơn 0', 16, 1);
        RETURN;
    END

    -- Khai báo các biến để lưu trữ các giá trị cần lấy
    DECLARE @ParentLotNo VARCHAR(50);
    DECLARE @ControlNo VARCHAR(50);
    DECLARE @DayPlanNO VARCHAR(50);
    DECLARE @PoNo VARCHAR(50);

    -- Lấy giá trị từ bảng stb_MergeBoxRealityHist
    SELECT @ParentLotNo = ParentLotNo,
           @ControlNo = ControlNo,
           @DayPlanNO = DayPlanNO,
           @PoNo = PoNo
    FROM stb_MergeBoxRealityHist
    WHERE MergeNumber = @pMergeNumber;

    -- Thực hiện thao tác MERGE
    MERGE INTO stb_MergeBoxRealityHist AS target
    USING (SELECT @pMergeNumber AS MergeNumber, 
                  @pBarcode AS ChildLotNo, 
                  @pBoxQty AS boxQty) AS source
    ON target.MergeNumber = source.MergeNumber 
       AND target.ChildLotNo = source.ChildLotNo
    WHEN MATCHED THEN
        UPDATE SET target.boxQty = source.boxQty
    WHEN NOT MATCHED THEN
        INSERT (ParentLotNo, ControlNo, DayPlanNO, PoNo, MergeNumber, ChildLotNo, boxQty)
        VALUES (@ParentLotNo, @ControlNo, @DayPlanNO, @PoNo, source.MergeNumber, source.ChildLotNo, source.boxQty);
	
	select @BoxQty= sum(BoxQty) from stb_MergeBoxRealityHist where MergeNumber=@pMergeNumber
	update stb_MergeBoxReality set BoxQty=@BoxQty where MergeNumber=@pMergeNumber
END
    
	--select * from stb_MergeBoxRealityHist
	--delete from stb_MergeBoxRealityHist



