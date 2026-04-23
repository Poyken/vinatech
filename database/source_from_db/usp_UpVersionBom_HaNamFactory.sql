-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-03-04
-- Description:	thêm version bom lên hệ thống
-- ============================-================
CREATE PROCEDURE usp_UpVersionBom_HaNamFactory
		@Materialcode varchar(50),
		@ChildMaterialCode  varchar(50),
		@BomVersion varchar(20),
		@UsedQty varchar(20),
		@BomDetailDesc varchar(200),
		@RouteCode varchar(20),
		@BomUnit varchar(10)
AS
BEGIN

	SET NOCOUNT ON;
	 declare @IsOptionItem bit = 0,
	  @ChildBomVersion varchar(50) = '1'
	  set @UsedQty =  TRY_CAST(@UsedQty as NUMERIC(20,10));

	  BEGIN TRY
	  	IF EXISTS (SELECT 1 FROM STB_BomDetail WHERE Materialcode = @Materialcode and ChildMaterialCode=@ChildMaterialCode and  BomVersion=@BomVersion and ChildMaterialCode=@ChildMaterialCode)
        BEGIN
		declare @err nvarchar(200)=N'Mã này của tháng đã tồn tại trong hệ thống! '+@Materialcode
            RAISERROR(@err,16, 1);
        END

		INSERT INTO [dbo].[STB_BomDetail]
           ([MaterialCode]
           ,[BomVersion]
           ,[ChildMaterialCode]
           ,[ChildBomVersion]
           ,[BomUnit]
           ,[UsedQty]
           ,[RouteCode]
           ,[IsOptionItem]
           ,[BomDetailDesc]
           ,[CreateDateTime]
           ,[CreateUserID])
     VALUES
           (
		   @Materialcode
           ,@BomVersion
           ,@ChildMaterialCode
           ,@ChildBomVersion
           ,@BomUnit
           ,@UsedQty
           ,@RouteCode
           ,@IsOptionItem
           ,@BomDetailDesc
           ,getdate()
		   ,'doannam')
	END TRY
	BEGIN CATCH

		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50002, @ErrorMessage, 1;
	END CATCH




END
