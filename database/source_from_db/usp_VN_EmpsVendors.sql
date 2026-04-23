create PROC usp_VN_EmpsVendors
AS
BEGIN
		CREATE TABLE #T
		(
		  ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY(ID),
		  Names NVARCHAR(50) NULL,
		  LINE NVARCHAR(30) NULL
		)

INSERT INTO #T (Names,LINE) VALUES (N'Hoàng Thị Huệ',N'Cắm Tụ')
INSERT INTO #T (Names,LINE) VALUES (N'Nguyễn Thị Huyền',N'Cắm Tụ')
INSERT INTO #T (Names,LINE) VALUES (N'Lò Thị Quỳnh',N'Cắm Tụ')
INSERT INTO #T (Names,LINE) VALUES (N'Hoàng Thị Khôn',N'Cắm Tụ')
INSERT INTO #T (Names,LINE) VALUES (N'Lô Thị Ánh Tuyết',N'Cắm Tụ')
INSERT INTO #T (Names,LINE) VALUES (N'La ThỊ An',N'Cắm Tụ')
INSERT INTO #T (Names,LINE) VALUES (N'La Ngọc Cảnh',N'Hàn Nhúng')
INSERT INTO #T (Names,LINE) VALUES (N'Trịnh Văn Hoàn',N'Hàn Nhúng')
INSERT INTO #T (Names,LINE) VALUES (N'Bùi Thị Kim',N'Cắt Chân')
INSERT INTO #T (Names,LINE) VALUES (N'Mai Thu Hằng',N'Cắt Chân')
INSERT INTO #T (Names,LINE) VALUES (N'Trần Thị Hà',N'KTTG')
INSERT INTO #T (Names,LINE) VALUES (N'Bùi Thị Hường',N'KTTG')
INSERT INTO #T (Names,LINE) VALUES (N'Hoàng Hải Ngàn',N'Đo Rò Điện ')
INSERT INTO #T (Names,LINE) VALUES (N'Thái Thị Ngân',N'Silicone')
INSERT INTO #T (Names,LINE) VALUES (N'Mai Thị Sinh',N'Silicone')
INSERT INTO #T (Names,LINE) VALUES (N'Trần Thị Nhung',N'Silicone')
INSERT INTO #T (Names,LINE) VALUES (N'Hà Thị Linh',N'Silicone')
INSERT INTO #T (Names,LINE) VALUES (N'Kiều Hoa Khôi',N'Tách PCB')
INSERT INTO #T (Names,LINE) VALUES (N'Bùi Thị Hương Ly',N'Tách PCB')
INSERT INTO #T (Names,LINE) VALUES (N'Thái Thị Ly',N'Bọc Vỏ')
INSERT INTO #T (Names,LINE) VALUES (N'Trần Thị Hòa',N'Bọc Vỏ')
INSERT INTO #T (Names,LINE) VALUES (N'Hà Thị Vinh',N'Bọc Vỏ')
INSERT INTO #T (Names,LINE) VALUES (N'Hoàng Thị Huê',N'Bọc Vỏ')
INSERT INTO #T (Names,LINE) VALUES (N'Trần Thị Quyên',N'Hàn Dây')
INSERT INTO #T (Names,LINE) VALUES (N'Lò Văn Thanh',N'Hàn Dây')
INSERT INTO #T (Names,LINE) VALUES (N'Lương Thị Nhàn',N'ESR')
INSERT INTO #T (Names,LINE) VALUES (N'Hứa Thị Vở',N'ESR')
INSERT INTO #T (Names,LINE) VALUES (N'Trần Thị Diệp',N'ESR')
INSERT INTO #T (Names,LINE) VALUES (N'Lương Thị Vinh',N'ESR')
INSERT INTO #T (Names,LINE) VALUES (N'Nguyễn Văn Thìn',N'Check short')
INSERT INTO #T (Names,LINE) VALUES (N'Lò Văn Hùng',N'Check short')
INSERT INTO #T (Names,LINE) VALUES (N'Ngô Văn Vĩnh',N'Check short')
INSERT INTO #T (Names,LINE) VALUES (N'Chảo Thị Minh Thu',N'Kiểm tra')
INSERT INTO #T (Names,LINE) VALUES (N'Tướng Thị Ninh',N'Kiểm tra')
INSERT INTO #T (Names,LINE) VALUES (N'Trần Thị Diệp',N'Kiểm tra')
INSERT INTO #T (Names,LINE) VALUES (N'Tạ Thị Tiền',N'OQC')
INSERT INTO #T (Names,LINE) VALUES (N'Đặng Thị Chắn',N'OQC')
INSERT INTO #T (Names,LINE) VALUES (N'Trần Thị Dung',N'OQC')
INSERT INTO #T (Names,LINE) VALUES (N'Ma Văn Trường',N'Đóng Gói')

SELECT ID,LINE,Names, COUNT(*)
  FROM #T WITH (NOLOCK)
 GROUP BY ID,LINE,Names
 HAVING COUNT(*) > 0

 --DROP TABLE #T
END