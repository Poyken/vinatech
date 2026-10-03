-- ============================================================================
-- Script:        02_CREATE_SP_usp_SanminaPrintQueue_clear.sql
-- Author:        vanduc (IT MES)
-- Create Date:   2026-10-03
-- Purpose:       Xóa hàng đợi in tạm thời của User phục vụ nút Làm mới trên B767
-- Target System: SmartFactoryV2 Production DB
-- ============================================================================

USE [SmartFactoryV2];
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_SanminaPrintQueue_clear]
    @pProcessUserID VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @pProcessUserID IS NOT NULL AND LTRIM(RTRIM(@pProcessUserID)) <> ''
    BEGIN
        DELETE FROM [dbo].[STB_SanminaPrintQueue]
        WHERE [ProcessUserID] = LTRIM(RTRIM(@pProcessUserID));
    END
    ELSE
    BEGIN
        -- KHI NÚT CLEAR TRÊN GIAO DIỆN NAIS GỌI (KHÔNG TRUYỀN THAM SỐ HOẶC PARAMETER NULL):
        -- XÓA TOÀN BỘ HÀNG ĐỢI TẠM ĐỂ RESET TRIỆT ĐỂ
        DELETE FROM [dbo].[STB_SanminaPrintQueue];
    END

    SELECT 'SUCCESS' AS ResultStatus, N'Đã xóa sạch hàng đợi in tạm thời' AS ResultMessage;
END
GO
