use master;
set nocount on
 
declare                 @backup_all_databases               varchar(max)
declare                 @get_time                                         varchar(25)
declare                 @get_day                                           varchar(25)
declare                 @get_date                                         varchar(25)
declare                 @get_month                                     varchar(25)
declare                 @get_year                                         varchar(25)
declare                 @get_timestamp                            varchar(255)
set                          @get_day                                           = (select datename(dw, getdate()))
set                          @get_date                                         = (select datename(dd, getdate()))
set                          @get_month                                     = (select datename(mm, getdate()))
set                          @get_year                                         = (select datename(yy, getdate()))
set                          @get_time                                         = (select replace(replace(replace(replace(convert(char(20), getdate(), 22), '/', '-'), 'AM', 'am'), 'PM', 'pm'), ':', '-'))
set                          @get_timestamp                            = (select @get_time + ' ' + @get_month + ' ' + @get_day + ' ' + @get_date + ' ' + @get_year + ' Transaction Log Bu ')
set                          @backup_all_databases =           ''
select                    @backup_all_databases =           @backup_all_databases +
'
                if exists 
                (
                select 1 
                command from master.sys.dm_exec_requests where
                command in (''backup database'', ''backup log'', ''restore database'') 
                and db_name(database_id) = ''' + upper(name) + '''
                )
                                begin
                                                print ''Database: [' + upper(name) + '] Has a backup or restore operation currently running.  Backup will be skipped.''
                                end
                                else
                                                backup log [' + upper(name) + '] to disk = ''F:\SQLBACKUPS\' + @get_timestamp + upper(name) + '.trn'' with format;
' + char(10)
from
                sys.databases sd join sys.database_mirroring sdm on sd.database_id = sdm.database_id
where
                name    not in ('tempdb')
                and        recovery_model_desc = 'full'
                and        state_desc = 'online'
                and        sdm.mirroring_role_desc is null
                or            sdm.mirroring_role_desc != 'mirror'
order by
                name asc
 
exec      master..sp_configure 'show advanced options', 1             reconfigure;
exec      master..sp_configure 'backup compression default', 1   reconfigure;
exec      master..sp_configure 'xp_cmdshell', 1                                   reconfigure;
exec      (@backup_all_databases)
