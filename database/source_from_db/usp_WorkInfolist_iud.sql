-- =============================================
-- Author:	    Lee Kang il (kilee@vina.co.kr)
-- Create date: 2018-12-19
-- Browsable : true
-- Group : 공통
-- Description:	사용자정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_WorkInfolist_iud]
AS
BEGIN


			-- Process Insert Table
            MERGE STB_ProdWorkerInfo AS TargetTable
			USING
				(
				   SELECT 'VNT'           AS CompanyCode	
						, 'VNT_F1'        AS WorkCenterCode
						, ER.NO_EMP        AS WorkerCode
						, ER.NM_KOR        AS WorkerName 
						, ER.NO_EMP        AS EmpNo
						, CASE WHEN ER.CD_INCOM = '099' THEN '0' ELSE '1' END               AS IsUsed
						, CASE WHEN ER.TP_EMP IN ('100', '200') THEN '0' ELSE '1' END AS IsProdWorker
					FROM NEOE.NEOE.MA_EMP ER
					WHERE 1=1
					  AND CD_COMPANY = '1000'

				) AS SourceTable

			ON
				(
					TargetTable.WorkerCode = SourceTable.WorkerCode
				)

			WHEN MATCHED THEN

			-- UPDATE문
				UPDATE SET
					WorkerCode      = ISNULL(SourceTable.WorkerCode,TargetTable.WorkerCode),
					WorkerName      =  SourceTable.WorkerName,
					IsUsed          = SourceTable.IsUsed,
					IsProdWorker   = SourceTable.IsProdWorker,
					ChangeDateTime  = GETDATE(),
					ChangeUserID    = 'eai'




			WHEN NOT MATCHED THEN

			-- INSERT문 
				INSERT
					   (  CompanyCode	
						, WorkCenterCode
						, WorkerCode 
						, WorkerName	
						, EmpNo
						, IsUsed
						, IsProdWorker
						, CreateDateTime
						, CreateUserID
				      )
				VALUES
					(
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.WorkerCode,
							SourceTable.WorkerName,
							SourceTable.WorkerCode,
							SourceTable.IsUsed,
							SourceTable.IsProdWorker,
							GETDATE(),
							'eai'
					);

				UPDATE STB_ProdWorkerInfo
				   SET IsProdWorker = CONVERT(BIT, 1)
				 WHERE WorkerCode IN ('14120103', '22090103', '19120104', '24010104', '25101303')
END