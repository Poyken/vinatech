-- =============================================
-- Author:		<Mr.Duy>
-- Create date: <2024-02-23>
-- Description:	<Tạo dữ liệu V-28,V-28_Bg lấy từ V-27,V_27_Bg khi mà ai đã dùng lệnh xóa V-28 trong bảng "delete from STB_ProdRouteHist where Controlno = '20240217000099'">
-- =============================================
--  exec usp_CreateV28Data_B523 'VVOK063R060607'
CREATE PROCEDURE [dbo].[usp_CreateV28Data_B523]
 @Barcode VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @ProdRouteHistNo VARCHAR(20)
	Declare @Controlno VARCHAR(20)
	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProdRouteHist', @ProdRouteHistNo OUTPUT

	select @Controlno = ControlNo from STB_SetInfo
			where Barcode = @Barcode
			
 
INSERT INTO STB_ProdRouteHist
SELECT @ProdRouteHistNo
      ,CompanyCode
      ,WorkCenterCode
      ,PONo
      ,DayPlanNo
      ,ControlNo
      ,MaterialCode
      ,BomVersion
      ,JobDate
      ,ShiftCode
      ,TimeCode
      ,LineCode
      ,'V-28_BG'
      ,WorkerCode
      ,MachineCode
      ,ProdQty
      ,ProdDateTime
      ,CreateDateTime
      ,CreateUserID
      ,ChangeDateTime
      ,ChangeUserID
      ,DelayCode
  FROM STB_ProdRouteHist
 WHERE ControlNo = @Controlno
   AND RouteCode = 'V-27_BG'
END
