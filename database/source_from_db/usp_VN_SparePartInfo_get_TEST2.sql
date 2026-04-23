-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-17
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트정보 조회
-- Modified:

--			exec usp_VN_SparePartInfo_get_TEST2 '', '','CSP000004','','','','','VVT_F1',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_SparePartInfo_get_TEST2]
	--@pProcessUserID VARCHAR(20),
	--@pProcessLanguage VARCHAR(20),
 --   @pSparePartCode VARCHAR(20) = NULL,
 --   @pSparePartName NVARCHAR(100) = NULL,
	--@pSparePartSpec02 NVARCHAR(20)=NULL,
	--@pTypeCode NVARCHAR(100) = NULL,
	--@pTypeName NVARCHAR(100) = NULL,
 --   @pWorkCenterCode VARCHAR(20) = NULL,
	--@pNameWorkCenterCode NVARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
   --   DECLARE @SparePartCode VARCHAR(20) = CASE WHEN ISNULL(@pSparePartCode,'') = '' THEN '*' ELSE @pSparePartCode END
   --   DECLARE @SparePartName NVARCHAR(100) = CASE WHEN ISNULL(@pSparePartName,'') = '' THEN '*' ELSE @pSparePartName END
	  --DECLARE @TypeCode NVARCHAR(100) = CASE WHEN ISNULL(@pTypeCode,'') = '' THEN '*' ELSE @pTypeCode END
	  --DECLARE @SparePartSpec02 NVARCHAR(100) = CASE WHEN ISNULL(@pSparePartSpec02,'') ='' THEN '*' ELSE @pSparePartSpec02 END
	  print '1'

	  
END