CREATE PROC [dbo].[usp_view_approver_Raw] -- exec usp_view_approver_Raw 'duonghoa'
@pProcessUserID VARCHAR(20) 
AS
BEGIN

SET NOCOUNT ON;

DECLARE @UserID VARCHAR(20) = @pProcessUserID

IF(@UserID ='nguyenminh' OR @UserID ='nguyenchi' OR @UserID ='nguyennha') 

BEGIN

		SELECT 
				ID,
				MaterialCode,
				MaterialName,
				QTYACTUALLY,
				QTYREQUEST,
				EXPECTED_DATE_NEEDED,
				APPROVEREDBY,
				CREATEDATE_APPROVERBY,
				LineCode,
				LineName,
				STATUS_MATERIALS,
				WorkCenterCode,
				WorkCenterName,
				CreateUserID,
				CreateDateTime,
				ChangeUserID,
				ChangeDateTime


		FROM STB_VN_ORDER_MATERIALS WITH(NOLOCK)

		WHERE STATUS_MATERIALS = N'Chờ duyệt' AND WORKCENTERCODE = 'VVT_F1' -- Bac Ninh factory

END

ELSE IF (@UserID ='duonghoa' OR @UserID ='nguyennha') 

BEGIN

	SELECT 
				ID,
				MaterialCode,
				MaterialName,
				QTYACTUALLY,
				QTYREQUEST,
				EXPECTED_DATE_NEEDED,
				APPROVEREDBY,
				CREATEDATE_APPROVERBY,
				LineCode,
				LineName,
				STATUS_MATERIALS,
				WorkCenterCode,
				WorkCenterName,
				CreateUserID,
				CreateDateTime,
				ChangeUserID,
				ChangeDateTime


		FROM STB_VN_ORDER_MATERIALS WITH(NOLOCK)

		WHERE STATUS_MATERIALS = N'Chờ duyệt' AND WORKCENTERCODE = 'VVT_F2' -- Bac Giang factory


END

ELSE
		BEGIN

			SELECT 
				ID,
				MaterialCode,
				MaterialName,
				QTYACTUALLY,
				QTYREQUEST,
				EXPECTED_DATE_NEEDED,
				APPROVEREDBY,
				CREATEDATE_APPROVERBY,
				LineCode,
				LineName,
				STATUS_MATERIALS,
				WorkCenterCode,
				WorkCenterName,
				CreateUserID,
				CreateDateTime,
				ChangeUserID,
				ChangeDateTime


		FROM STB_VN_ORDER_MATERIALS WITH(NOLOCK)

		WHERE STATUS_MATERIALS = N'Chờ duyệt' 

		END

END