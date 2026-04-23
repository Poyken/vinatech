CREATE PROC [dbo].[usp_View_Approver] -- exec usp_View_Approver '31811044'
@Approver NVARCHAR(50),
@CODE NVARCHAR(30)
AS
BEGIN
			SELECT 
					GROUPID,
					Barcode,
					RouteCode,
					RouteName,
					MaterialCode,
					MaterialName,
					LineCode,
					LineName,
					ProdQty,

					CASE 
							WHEN SECURITYSTATUS_BG = 1 THEN  N'Đã duyệt'
					
					ELSE ''
					
					END AS  'SECURITYSTATUS_BG',

					CASE
							WHEN PERSONSTATUSAPPROVER_BG = 1 THEN N'Đã duyệt'
					ELSE ''

					END AS 'PERSONSTATUSAPPROVER_BG'
			 FROM 
			
					STB_VN_STAGES_TRANSFER WITH(NOLOCK)	
			
			WHERE
					PERSONSTATUSAPPROVER_BG = 1 AND SECURITYSTATUS_BG = 1  AND PERSONAPPROVER_BN = @Approver AND GROUPID IS NOT NULL AND PERSONSTATUSAPPROVER_BN IS NULL AND FACTORYCODE = @CODE

UNION ALL
			
			SELECT 
					GROUPID,
					Barcode,
					RouteCode,
					RouteName,
					MaterialCode,
					MaterialName,
					LineCode,
					LineName,
					ProdQty,

					CASE 
							WHEN SECURITYSTATUS_BN = 1 THEN  N'Đã duyệt'
					
					ELSE ''
					
					END AS  'SECURITYSTATUS_BG',

					CASE
							WHEN PERSONSTATUSAPPROVER_BN = 1 THEN N'Đã duyệt'
					ELSE ''

					END AS 'PERSONSTATUSAPPROVER_BG'
			 FROM 
			
					STB_VN_STAGES_TRANSFER WITH(NOLOCK)	
			
			WHERE
					PERSONSTATUSAPPROVER_BN = 1 AND SECURITYSTATUS_BN = 1  AND PERSONAPPROVER_BG = @Approver AND GROUPID IS NOT NULL AND PERSONSTATUSAPPROVER_BG IS NULL AND FACTORYCODE = @CODE

UNION ALL

	SELECT 
					GROUPID,
					Barcode,
					RouteCode,
					RouteName,
					MaterialCode,
					MaterialName,
					LineCode,
					LineName,
					ProdQty,

					CASE 
							WHEN SECURITYSTATUS_BG IS NULL THEN  N'Chờ bạn duyệt xong'
					
					ELSE ''
					
					END AS  'SECURITYSTATUS_BG',

					CASE
							WHEN PERSONSTATUSAPPROVER_BG IS NULL THEN N'Chờ bạn duyệt xong'
					ELSE ''

					END AS 'PERSONSTATUSAPPROVER_BG'
			 FROM 
			
					STB_VN_STAGES_TRANSFER WITH(NOLOCK)	
			
			WHERE
					   PERSONAPPROVER_BN = @Approver AND GROUPID IS NOT NULL AND PERSONSTATUSAPPROVER_BN IS NULL AND PERSONSTATUSAPPROVER_BG IS NULL AND SECURITYSTATUS_BG IS NULL AND FACTORYCODE = @CODE

					  

UNION ALL

	SELECT 
					GROUPID,
					Barcode,
					RouteCode,
					RouteName,
					MaterialCode,
					MaterialName,
					LineCode,
					LineName,
					ProdQty,

					CASE 
							WHEN SECURITYSTATUS_BN IS NULL THEN  N'Chờ bạn duyệt xong'
					
					ELSE ''
					
					END AS  'SECURITYSTATUS_BG',

					CASE
							WHEN PERSONSTATUSAPPROVER_BN IS NULL THEN N'Chờ bạn duyệt xong'
					ELSE ''

					END AS 'PERSONSTATUSAPPROVER_BG'
			 FROM 
			
					STB_VN_STAGES_TRANSFER WITH(NOLOCK)	
			
			WHERE
					 PERSONAPPROVER_BG = @Approver AND GROUPID IS NOT NULL AND PERSONSTATUSAPPROVER_BG IS NULL AND PERSONSTATUSAPPROVER_BN IS NULL AND SECURITYSTATUS_BN IS NULL  AND FACTORYCODE = @CODE 
	


UNION ALL

	SELECT 
					GROUPID,
					Barcode,
					RouteCode,
					RouteName,
					MaterialCode,
					MaterialName,
					LineCode,
					LineName,
					ProdQty,

					CASE 
							WHEN SECURITYSTATUS_BN IS NULL THEN  N'Chờ bạn duyệt xong'
					
					ELSE ''
					
					END AS  'SECURITYSTATUS_BG',

					CASE
							WHEN PERSONSTATUSAPPROVER_BN IS NULL THEN N'Chờ bạn duyệt xong'
					ELSE ''

					END AS 'PERSONSTATUSAPPROVER_BG'
			 FROM 
			
					STB_VN_STAGES_TRANSFER WITH(NOLOCK)	
			
			WHERE
					SECURITYSTATUS_BN = 1 AND SECURITYSTATUS_BG = 1 AND PERSONSTATUSAPPROVER_BN = 1 AND PERSONAPPROVER_BG = @Approver AND PERSONSTATUSAPPROVER_BG IS NULL 



UNION ALL

	SELECT 
					GROUPID,
					Barcode,
					RouteCode,
					RouteName,
					MaterialCode,
					MaterialName,
					LineCode,
					LineName,
					ProdQty,

					CASE 
							WHEN SECURITYSTATUS_BN IS NULL THEN  N'Chờ bạn duyệt xong'
					
					ELSE ''
					
					END AS  'SECURITYSTATUS_BG',

					CASE
							WHEN PERSONSTATUSAPPROVER_BN IS NULL THEN N'Chờ bạn duyệt xong'
					ELSE ''

					END AS 'PERSONSTATUSAPPROVER_BG'
			 FROM 
			
					STB_VN_STAGES_TRANSFER WITH(NOLOCK)	
			
			WHERE
					SECURITYSTATUS_BN = 1 AND SECURITYSTATUS_BG = 1 AND PERSONSTATUSAPPROVER_BG = 1 AND PERSONAPPROVER_BN = @Approver AND   PERSONSTATUSAPPROVER_BN IS NULL 
	
END
-- END
-- select * from STB_VN_STAGES_TRANSFER where PERSONSTATUSAPPROVER_BG is null AND SECURITYSTATUS_BG IS NULL