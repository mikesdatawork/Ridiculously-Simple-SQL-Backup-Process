use master;
set nocount on
 
declare @shrink_logs     varchar(max)
set          @shrink_logs     = ''
select    @shrink_logs     = @shrink_logs +
'use [' + sd.name + '];' + char(10) +
'dbcc shrinkfile (' + cast(smf.file_id as varchar(3)) + ');' + char(10) + char(10)
from
                sys.databases sd join sys.master_files smf on sd.database_id = smf.database_id
                join sys.database_mirroring sdm on sd.database_id = sdm.database_id
where
                smf.type_desc = 'log'
                and sd.recovery_model_desc = 'full'
                and sd.name not in ('tempdb')
                and        sdm.mirroring_role_desc is null
                or            sdm.mirroring_role_desc != 'mirror'
order by
                sd.name
,               smf.file_id asc
 
exec      (@shrink_logs)
