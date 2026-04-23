CREATE proc [dbo].[usp_VN_order_materials]
@pProcessUserID VARCHAR(20)
AS
BEGIN

DECLARE @UserID NVARCHAR(50) = @pProcessUserID

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

				CASE

					WHEN STATUS_MATERIALS = N'Chờ duyệt' THEN N'Chờ duyệt'
					WHEN STATUS_MATERIALS <> 'Chờ duyệt' THEN N'Đã duyệt'
					
				ELSE ''

				END AS STATUS_MATERIALS,

				WorkCenterCode,
				WorkCenterName,
				CreateDateTime,
				CreateUserID,
				ChangeDateTime,
				ChangeUserID
		FROM 
				STB_VN_ORDER_MATERIALS WITH(NOLOCK)

		WHERE 
				CreateUserID = @UserID AND STATUS_MATERIALS = N'Chờ duyệt'
END

--SELECT * FROM STB_VN_ORDER_MATERIALS