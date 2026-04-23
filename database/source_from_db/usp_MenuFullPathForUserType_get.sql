-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 시스템관리
-- Browsable : true
-- Create date : 
-- Description : 
-- Modified :
-- =============================================

CREATE PROCEDURE usp_MenuFullPathForUserType_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS

BEGIN
	WITH tree_query
	AS (
		 SELECT A.Name
			   ,A.ParentName
			   ,A.Caption
			   , convert(varchar(255), A.Name) sort
			   , convert(varchar(255), B.Value) depth_fullname
		   FROM SmartFramework.dbo.STB_VendorScreenInfo A
		   INNER JOIN SmartFramework.dbo.STB_StringResources B
		     ON B.Language = @pProcessLanguage
			AND B.Name = A.Caption
		  WHERE ParentName IS NULL
			AND IsDelete = CONVERT(BIT, 0)
			AND ShowInMenu = CONVERT(BIT, 1)
		  UNION ALL
		SELECT  B.Name
			  , B.ParentName
			  , B.Caption
			  , convert(varchar(255)
			  , convert(nvarchar,C.sort) + ' > ' + convert(varchar(255), B.Name)) sort
			  , convert(varchar(255)
			  , convert(nvarchar,C.depth_fullname) + ' > ' + convert(varchar(255), D.Value)) depth_fullname
		   FROM SmartFramework.dbo.STB_VendorScreenInfo B
			INNER JOIN tree_query C
			  ON B.ParentName = C.Name
			INNER JOIN SmartFramework.dbo.STB_StringResources D
			  ON D.Language = @pProcessLanguage
			 AND D.Name = B.Caption
			 WHERE IsDelete = CONVERT(BIT, 0)
			 AND ShowInMenu = CONVERT(BIT, 1)
	)
	SELECT Name
		  , ParentName
		  , Caption
		  , REPLACE(depth_fullname, '^', '') AS MenuFullPath
	   FROM tree_query
	  ORDER BY SORT
END