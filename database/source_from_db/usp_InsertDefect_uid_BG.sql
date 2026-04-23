-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-21
-- Description:	Thêm lôi cho OP nhập
-- =============================================
CREATE PROCEDURE [dbo].[usp_InsertDefect_uid_BG]
	-- Add the parameters for the stored procedure here
	@pUserId varchar(20),
    @pRouterName nvarchar(100),
    @pDefectName nvarchar(100),
    @pDesc NVARCHAR(100),
    @pNguoiPhatHien NVARCHAR(100),
    @pNguoiThaoTax NVARCHAR(100),
    @pNguyenNhanDungMay NVARCHAR(100),
	@pMachineName NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

    -- Insert statements for procedure here
	 DECLARE @groupid NVARCHAR(100);

    SELECT @groupid = groupid
    FROM stb_vvt_userwarning
    WHERE username = @pUserId;

    -- Ensure all columns are matched with correct values
    INSERT INTO DefectReportsAndon_BG (
        LineCode,
        RouteName,
        ErrorName,
        ErrorDescription,
        DetectedBy,
        Operator,
        Status,
        MachineRootCause,
		MachineName
    )
    VALUES (
        @groupid,
        @pRouterName,
        @pDefectName,
        @pDesc,
        @pNguoiPhatHien,
        @pNguoiThaoTax,
        0,
        @pNguyenNhanDungMay,
		@pMachineName
    );
END
