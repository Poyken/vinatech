CREATE PROC [dbo].[usp_DoAutoRemoveSystemGrant]
AS
BEGIN
	Declare @RetireUserCount INT

	-- 삭제대상 백업 (ERP)
	INSERT INTO MA_GRANT_AUTOREMOVE_LOG (
		 CD_GROUP
		,CD_COMPANY
		,ID_USER
		,USR_GBN
		,NM_USER
		,NO_EMP
		,ID_INSERT
		,ID_UPDATE
		,DTS_UPDATE
		,DTS_INSERT
		,YN_USERMENU
		,NM_USER_L1
		,NM_USER_L2
		,NM_USER_L3
		,NM_USER_L4
		,NM_USER_L5
	)
	SELECT CD_GROUP
		  ,CD_COMPANY
		  ,ID_USER
		  ,USR_GBN
		  ,NM_USER
		  ,NO_EMP
		  ,ID_INSERT
		  ,ID_UPDATE
		  ,DTS_UPDATE
		  ,DTS_INSERT
		  ,YN_USERMENU
		  ,NM_USER_L1
		  ,NM_USER_L2
		  ,NM_USER_L3
		  ,NM_USER_L4
		  ,NM_USER_L5
	  FROM NEOE.NEOE.MA_GRANT
	 WHERE CD_COMPANY = '1000'
	   AND NO_EMP IN (SELECT NO_EMP 
						FROM NEOE.NEOE.MA_EMP 
					   WHERE CD_COMPANY = '1000' 
						 AND CD_INCOM = '099')

	-- 삭제 (ERP)
	DELETE
	  FROM NEOE.NEOE.MA_GRANT
	 WHERE CD_COMPANY = '1000'
	   AND NO_EMP IN (SELECT NO_EMP 
						FROM NEOE.NEOE.MA_EMP 
					   WHERE CD_COMPANY = '1000' 
						 AND CD_INCOM = '099')

	--	-- 삭제대상 백업 (MES:권한)
	--INSERT INTO STB_UserPermissionGroupHist (
	--	UserID
	--   ,UserType
	--   ,HasPermission
	--   ,CreateDateTime
	--   ,CreateUserID
	--   ,ChangeDateTime
	--   ,ChangeUserID
	--)
	--SELECT UserID
	--	  ,UserType
	--	  ,HasPermission
	--	  ,CreateDateTime
	--	  ,CreateUserID
	--	  ,ChangeDateTime
	--	  ,ChangeUserID
	--  FROM SmartFramework.dbo.STB_UserPermissionGroup
	-- WHERE UserID IN (
	--		SELECT UserID
	--		  FROM SmartFramework.dbo.STB_UserInfo
	--		 WHERE Appendix8 IN (SELECT NO_EMP 
	--									   FROM NEOE.NEOE.MA_EMP
	--									  WHERE CD_COMPANY = '1000' AND CD_INCOM = '099')
	--			   AND UserID IN (SELECT UserID 
	--								FROM SmartFactoryV2.dbo.STB_UserInfo 
	--							   WHERE CompanyCode = 'VNT')
	-- )

	 -- 삭제(MES:권한)
	 -- 삭제로직에서 업데이트 로직으로 변경
	 -- 권한 회수 이력을 쌓기 위함.
	UPDATE SmartFramework.dbo.STB_UserPermissionGroup
	   SET HasPermission = 0
	 WHERE UserID IN (
			SELECT UserID
			  FROM SmartFramework.dbo.STB_UserInfo
			 WHERE Appendix8 IN (SELECT NO_EMP 
										   FROM NEOE.NEOE.MA_EMP
										  WHERE CD_COMPANY = '1000' AND CD_INCOM = '099')
				   AND UserID IN (SELECT UserID 
									FROM SmartFactoryV2.dbo.STB_UserInfo 
								   WHERE CompanyCode = 'VNT')
	 )

	-- 삭제대상 백업 (MES:계정)
	INSERT INTO STB_UserInfoAutoRemoveHist (
			UserID
		   ,UserName
		   ,Password
		   ,Phone
		   ,Mobile
		   ,Email
		   ,AllowFlag
		   ,UserImg
		   ,SystemCode
		   ,CanMakeReport
		   ,IsDeveloper
		   ,IsLogin
		   ,IPAddress
		   ,LastLoginDateTime
		   ,Appendix1
		   ,Appendix2
		   ,Appendix3
		   ,Appendix4
		   ,Appendix5
		   ,Appendix6
		   ,Appendix7
		   ,Appendix8
		   ,Appendix9
		   ,Appendix10
		   ,CreateDateTime
		   ,ChangeDateTime
	)
	SELECT UserID
		   ,UserName
		   ,Password
		   ,Phone
		   ,Mobile
		   ,Email
		   ,AllowFlag
		   ,UserImg
		   ,SystemCode
		   ,CanMakeReport
		   ,IsDeveloper
		   ,IsLogin
		   ,IPAddress
		   ,LastLoginDateTime
		   ,Appendix1
		   ,Appendix2
		   ,Appendix3
		   ,Appendix4
		   ,Appendix5
		   ,Appendix6
		   ,Appendix7
		   ,Appendix8
		   ,Appendix9
		   ,Appendix10
		   ,CreateDateTime
		   ,ChangeDateTime
	  FROM SmartFramework.dbo.STB_UserInfo
	 WHERE Appendix8 IN (SELECT NO_EMP 
						   FROM NEOE.NEOE.MA_EMP
						   WHERE CD_COMPANY = '1000' AND CD_INCOM = '099')
		   AND UserID IN (SELECT UserID 
							FROM SmartFactoryV2.dbo.STB_UserInfo 
						   WHERE CompanyCode = 'VNT')

	-- 삭제 (MES:계정)
	DELETE
	  FROM SmartFramework.dbo.STB_UserInfo
	 WHERE Appendix8 IN (SELECT NO_EMP 
						   FROM NEOE.NEOE.MA_EMP
						   WHERE CD_COMPANY = '1000' AND CD_INCOM = '099')
		   AND UserID IN (SELECT UserID 
							FROM SmartFactoryV2.dbo.STB_UserInfo 
						   WHERE CompanyCode = 'VNT')


	-- 시스템별 퇴사자 합계
	SELECT @RetireUserCount = SUM(UserCnt)
	  FROM (
		SELECT COUNT(*) AS UserCnt
		  FROM MA_GRANT_AUTOREMOVE_LOG
		 WHERE CONVERT(CHAR(10), DTS_LOG, 121) = CONVERT(CHAR(10), GETDATE(), 121)
		UNION ALL
		SELECT COUNT(*)
		  FROM STB_UserInfoAutoRemoveHist
		 WHERE CONVERT(CHAR(10), LogDateTime, 121) = CONVERT(CHAR(10), GETDATE(), 121)
	  ) A

	IF @RetireUserCount > 0 BEGIN
		exec usp_DoAddSystemMail '', '', 'yjyu@vina.co.kr;hjkim@vina.co.kr', '퇴직자 정보가 발생하였습니다.', '퇴직자 정보가 발생하였습니다.<br/><br/>각 시스템 삭제 로그를 확인하시기 바랍니다.'
	END
END