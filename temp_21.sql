use master;
set nocount on
 
declare @run_maintenance                       varchar(max)
set          @run_maintenance                       = ''
select    @run_maintenance                       = @run_maintenance +
'dbcc checkdb(''' + upper(name) + ''') with no_infomsgs;' + char(10)
from     
                sys.databases sd join sys.database_mirroring sdm on sd.database_id = sdm.database_id
where
                name not in ('tempdb')
                and        sdm.mirroring_role_desc is null
                or            sdm.mirroring_role_desc != 'mirror'
exec      (@run_maintenance)
