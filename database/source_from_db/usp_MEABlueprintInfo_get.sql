-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-08-11
-- Browsable : true
-- Group : MEA > 도면관리 > MEA도면정보
-- Description:
-- =============================================
CREATE PROCEDURE usp_MEABlueprintInfo_get
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pMEAClassCode VARCHAR(20) = NULL,
						@pIsFinalVersion BIT
AS
BEGIN
	Declare @MEAClassCode VARCHAR(20) = CASE WHEN ISNULL(@pMEAClassCode, '') = '' THEN '*' ELSE @pMEAClassCode END
	       ,@IsFinalVersion BIT = @pIsFinalVersion

	IF @IsFinalVersion = CONVERT(BIT, 1) BEGIN
		SELECT MBI.MEABlueprintNo
			  ,MBI.MEABlueprintModelNo
			  ,MBI.MEABlueprintSerNo
			  ,MBI.MEAClassCode
			  ,MCI.MEAClassName
			  ,MBI.CathodeCatalystCode
			  ,MRMIC.MEARawMaterialName AS CathodeCatalystName
			  ,MBI.AnodeCatalystCode
			  ,MRMIA.MEARawMaterialName AS AnodeCatalystName
			  ,MBI.ElectrolyteMembraneCode
			  ,MRMIM.MEARawMaterialName AS ElectrolyteMembraneName
			  ,MBI.AreaValue
			  ,MBI.GDLValue
			  ,MBI.BlueprintFileID
			  ,AFM.[FileName]
			  ,AFM.FileSize
			  ,ISNULL(AFM.FileContents ,CONVERT(VARBINARY(MAX), NULL)) AS FileData
			  ,MBI.CreateDateTime
			  ,MBI.CreateUserID
			  ,MBI.ChangeDateTime
			  ,MBI.ChangeUserID
		  FROM STB_MEABlueprintInfo MBI
		  LEFT OUTER JOIN STB_MEAClassInfo MCI
			ON MCI.MEAClassCode = MBI.MEAClassCode
		  LEFT OUTER JOIN STB_MEARawMaterialInfo MRMIC
			ON MRMIC.MEAClassCode = MBI.MEAClassCode
		   AND MRMIC.MEARawMaterialClassCode = 'C'
		   AND MRMIC.MEARawMaterialCode = MBI.CathodeCatalystCode
		  LEFT OUTER JOIN STB_MEARawMaterialInfo MRMIA
			ON MRMIA.MEAClassCode = MBI.MEAClassCode
		   AND MRMIA.MEARawMaterialClassCode = 'A'
		   AND MRMIA.MEARawMaterialCode = MBI.AnodeCatalystCode
		  LEFT OUTER JOIN STB_MEARawMaterialInfo MRMIM
			ON MRMIM.MEAClassCode = MBI.MEAClassCode
		   AND MRMIM.MEARawMaterialClassCode = 'M'
		   AND MRMIM.MEARawMaterialCode = MBI.ElectrolyteMembraneCode
		  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM
			ON AFM.FileID = MBI.BlueprintFileID
		  INNER JOIN (
			SELECT MEABlueprintModelNo, MAX(MEABlueprintSerNo) AS MEABlueprintSerNo
			  FROM STB_MEABlueprintInfo
			 GROUP BY MEABlueprintModelNo
		  ) F
		    ON MBI.MEABlueprintModelNo = F.MEABlueprintModelNo
		   AND MBI.MEABlueprintSerNo = F.MEABlueprintSerNo
		 WHERE (@MEAClassCode = '*' OR MBI.MEAClassCode = @MEAClassCode)
		 ORDER BY MBI.MEABlueprintModelNo
	END ELSE BEGIN
		SELECT MBI.MEABlueprintNo
			  ,MBI.MEABlueprintModelNo
			  ,MBI.MEABlueprintSerNo
			  ,MBI.MEAClassCode
			  ,MCI.MEAClassName
			  ,MBI.CathodeCatalystCode
			  ,MRMIC.MEARawMaterialName AS CathodeCatalystName
			  ,MBI.AnodeCatalystCode
			  ,MRMIA.MEARawMaterialName AS AnodeCatalystName
			  ,MBI.ElectrolyteMembraneCode
			  ,MRMIM.MEARawMaterialName AS ElectrolyteMembraneName
			  ,MBI.AreaValue
			  ,MBI.GDLValue
			  ,MBI.BlueprintFileID
			  ,AFM.[FileName]
			  ,AFM.FileSize
			  ,ISNULL(AFM.FileContents ,CONVERT(VARBINARY(MAX), NULL)) AS FileData
			  ,MBI.CreateDateTime
			  ,MBI.CreateUserID
			  ,MBI.ChangeDateTime
			  ,MBI.ChangeUserID
		  FROM STB_MEABlueprintInfo MBI
		  LEFT OUTER JOIN STB_MEAClassInfo MCI
			ON MCI.MEAClassCode = MBI.MEAClassCode
		  LEFT OUTER JOIN STB_MEARawMaterialInfo MRMIC
			ON MRMIC.MEAClassCode = MBI.MEAClassCode
		   AND MRMIC.MEARawMaterialClassCode = 'C'
		   AND MRMIC.MEARawMaterialCode = MBI.CathodeCatalystCode
		  LEFT OUTER JOIN STB_MEARawMaterialInfo MRMIA
			ON MRMIA.MEAClassCode = MBI.MEAClassCode
		   AND MRMIA.MEARawMaterialClassCode = 'A'
		   AND MRMIA.MEARawMaterialCode = MBI.AnodeCatalystCode
		  LEFT OUTER JOIN STB_MEARawMaterialInfo MRMIM
			ON MRMIM.MEAClassCode = MBI.MEAClassCode
		   AND MRMIM.MEARawMaterialClassCode = 'M'
		   AND MRMIM.MEARawMaterialCode = MBI.ElectrolyteMembraneCode
		  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM
			ON AFM.FileID = MBI.BlueprintFileID
		 WHERE (@MEAClassCode = '*' OR MBI.MEAClassCode = @MEAClassCode)
		 ORDER BY MBI.MEABlueprintModelNo
	END
END
