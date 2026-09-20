-- ==============================================================================
-- HOTFIX TEMPLATE: CHUYỂN FIFO SANG THEO THÁNG (yyyy-MM)
-- Target SP: [dbo].[usp_DoValidateFIFO] (Database: SmartFactoryV2)
-- ==============================================================================

USE [SmartFactoryV2]
GO

-- Đoạn code này thay thế yyyy-MM-dd thành yyyy-MM tại 4 vị trí trong usp_DoValidateFIFO
-- Xem chi tiết tại: KB_02_01_WMS_CORE.md (§4.9.1) & HOTFIX_LOG.md (ID_24)
