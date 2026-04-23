
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-04
-- Browsable : true
-- Group : 자재관리
-- Description:	자재발주전표 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DayMaterialOrder_iud]
	@pProcessUserID VARCHAR(20) = null,
	@pProcessLanguage VARCHAR(20) = null,
    @pProcessViewName VARCHAR(50) = null,
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName  
    --DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    --DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)



	DECLARE @DayPlanNo VARCHAR(20)
	DECLARE @MaterialOrderNo VARCHAR(20)
	DECLARE @iDoc INT

 EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DayMaterialOrder', @MaterialOrderNo OUTPUT
-- Đọc XML và tạo bảng tạm để trích xuất dữ liệu
--raiserror(@pXml,16,1)
 
EXEC sp_xml_preparedocument @idoc OUTPUT, @pXml;

SELECT   @DayPlanNo=DayPlanNo 
				FROM OPENXML(@idoc, @InsertTableName, 2)
				WITH (
					DayPlanNo VARCHAR(20)
				);

IF  EXISTS (SELECT * FROM STB_DayProdPlan where DayPlanNo = @DayPlanNo and  IsOrderMaterial=1)
BEGIN
			RAISERROR('Kế hoạch ngày này đã order nguyên vật liệu rồi, không thể order tiếp ....',16,1)
			RETURN;
END


INSERT INTO STB_DayMaterialOrder 
(MaterialOrderNo,PONo, DayPlanNo, ChildMaterialCode, MaterialName, LineCode, SoLuongKehoachNgay, UsedQtyDay, NVLngay,PlanShiftCode, Plandate,CreateDateTime,CreateUserID,IsAdditional,WorkCenterCode,QtyByPO,OrderDesc,StatusWarehouseConfirm)
SELECT 
	@MaterialOrderNo,
    PONo,
    DayPlanNo,
    ChildMaterialCode,
    MaterialName,
    LineCode,
    SoLuongKehoachNgay,
    UsedQtyDay,
    NVLngay,
	PlanShiftCode,
    Plandate,
	GETDATE(),
	@pProcessUserID,
	IsAdditional,
	WorkCenterCode,
	QtyByPO,
	OrderDesc,
	0

FROM OPENXML(@idoc, @InsertTableName, 2)
WITH (
    PONo VARCHAR(20),
    DayPlanNo VARCHAR(20),
    ChildMaterialCode NVARCHAR(50),
    MaterialName NVARCHAR(50),
    LineCode NVARCHAR(20),
    SoLuongKehoachNgay DECIMAL(18, 4),
    UsedQtyDay DECIMAL(18, 4),
    NVLngay DECIMAL(18, 4),
	PlanShiftCode varchar(1),
    Plandate DATETIME,
	IsAdditional BIT,
	WorkCenterCode VARCHAR(20),
	QtyByPO DECIMAL(18, 4),
	OrderDesc NVARCHAR(100)
	
);


update  STB_DayProdPlan set IsOrderMaterial  =  1  where DayPlanNo =@DayPlanNo 


EXEC sp_xml_removedocument @idoc;

  
END





--- select * from STB_DayMaterialOrder order by createdatetime DESC
--- delete  from STB_DayMaterialOrder








