create PROC [dbo].[usp_vvt_history_qcaudit]
AS
BEGIN
	        select 
            convert(varchar(10),ls.createdatetime,120) as 'Thời gian phát sinh', 
            ls.LineCode 'Mã Line', isnull(li.LineName,ls.LineName) 'Tên Line', ls.routename 'Công đoạn NG', 
            replace((select Item from dbo.fnSplitToTable('~~',ls.errorcode) where RowNo=2),'-Comment:','') 'Người phát hiện',
            replace((select Item from dbo.fnSplitToTable('~~',ls.errorcode) where RowNo=3),'-Comment:','') 'Người thao tác',
            ls.errorname 'Vấn đề phát hiện', 
            --replace((select Item from dbo.fnSplitToTable('~~',ls.errorcode) where RowNo=1),'-Comment:','') 'Mô tả chi tiết vấn đề', 
            (select Item from dbo.fnSplitToTable('~~',tbend.errorcode) where RowNo=1) 'Nguyên nhân',
            (select Item from dbo.fnSplitToTable('~~',tbend.errorcode) where RowNo=2) 'Đối sách',
            (select Item from dbo.fnSplitToTable('~~',tbend.errorcode) where RowNo=3) 'Người nhập',
             convert(varchar(19),tbend.createdatetime,120) as 'Thời gian cập nhật đối sách', 
             convert(varchar(10),DATEDIFF(MINUTE, ls.createdatetime, tbend.createdatetime)) as 'Số Phút đưa ra đối sách', 
            case when ls.id is not null and tbend.id is not null then 'FIXED' else 'None' end as 'Trạng thái'
            from stb_linesituation_vvt ls with(nolock)      
            left outer join stb_linesituation_vvt tbend with(nolock)     on ls.id = (tbend.statusApp)  
            left outer join STB_LineInfo li  with(nolock)  on ls.linecode=li.LineCode  
            where  (ls.statusEmail>=1000) 
            and (tbend.id is null or ( ls.createdatetime > convert(varchar(10),dateadd(day,-2,getdate()),120)  + ' 09:00:00')  ) 
            and ls.statusApp>=0 and ls.statusApp<5 
            and ls.status is not null 
            order by ls.id desc 
END