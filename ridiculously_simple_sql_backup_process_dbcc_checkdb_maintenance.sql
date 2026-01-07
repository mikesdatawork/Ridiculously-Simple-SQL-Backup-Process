use master;
set nocount on
 
declare @delete_old_files          varchar(max)
declare @retention                        datetime
set          @retention                        = (select getdate() - 14) --> 14 Days
set          @delete_old_files          = ''
select    @delete_old_files          = @delete_old_files + 'exec master..xp_cmdshell ''del "' + bmf.physical_device_name + '"'';' + char(10)
from      msdb..backupset bs join msdb..backupmediafamily bmf on bs.media_set_id = bmf.media_set_id
where   bs.type in ('D', 'I', 'L' ) and bs.backup_finish_date < @retention
order by               bs.backup_finish_date desc
exec      (@delete_old_files)
