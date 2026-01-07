![MIKES DATA WORK GIT REPO](https://raw.githubusercontent.com/mikesdatawork/images/master/git_mikes_data_work_banner_01.png "Mikes Data Work")        

# Ridiculously Simple SQL Backup Process
**Post Date: July 29, 2015**        



## Contents    
- [About Process](##About-Process)  
- [SQL Logic](#SQL-Logic)  
- [Author](#Author)  
- [License](#License)       

## About-Process

<p>Here's what I traditionally write up as the backup process for SQL Database Servers. You can use a local drive (as I'm doing in this example F:\SQLBACKUPS), or a universal network backup shared drive (preferred). I'll give you all the SQL logic up front since that's what you're here for. The explanations of what it does is below. I'm not the blogger that forces you to read all my drivel first while peppering in the valuable information throughout. I'm not going for Microsoft MVP, not trying to impress the uber-sql community and I'm NOT one of those detested SQL blogging Microsoft shills. I'm sure this just pissed off most of the hardcore Microsoft Database Jockeys. Down with the Cronyism.
Anyway; lets get on with it.
We'll create 2 Jobs:
1. DATABASE BACKUP FULL – All Databases
2. DATABASE BACKUP LOG – All Databases
Note: I added an extra ridiculously simple Maintenance Job at the bottom if you're interested.
Lets start with the first Full Database Backup Job.
DATABASE BACKUP FULL – All Databases
Step 1: Backup all databases.
~ Paste in the following logic…</p>      


## SQL-Logic
```SQL
use master;
set nocount on
 
declare @backup_all_databases               varchar(max)
declare @get_time                                         varchar(25)
declare @get_day                                           varchar(25)
declare @get_date                                         varchar(25)
declare @get_month                                     varchar(25)
declare @get_year                                         varchar(25)
declare @get_timestamp                            varchar(255)
set          @get_day                                           = (select datename(dw, getdate()))
set          @get_date                                         = (select datename(dd, getdate()))
set          @get_month                                     = (select datename(mm, getdate()))
set          @get_year                                         = (select datename(yy, getdate()))
set          @get_time                                         = (select replace(replace(replace(replace(convert(char(20), getdate(), 22), '/', '-'), 'AM', 'am'), 'PM', 'pm'), ':', '-'))
set          @get_timestamp                            = (select @get_time + ' ' + @get_month + ' ' + @get_day + ' ' + @get_date + ' ' + @get_year + ' Full Database Bu ')
set          @backup_all_databases =           ''
select    @backup_all_databases =           @backup_all_databases +
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
                                                backup database [' + upper(name) + '] to disk = ''F:\SQLBACKUPS\' + @get_timestamp + upper(name) + '.bak'' with format;
' + char(10)
from
                sys.databases sd join sys.database_mirroring sdm on sd.database_id = sdm.database_id
where
                name    not in ('tempdb')
                and        state_desc = 'online'
                and        sdm.mirroring_role_desc is null
                or            sdm.mirroring_role_desc != 'mirror'
order by
                name asc
 
exec      master..sp_configure 'show advanced options', 1             reconfigure;
exec      master..sp_configure 'backup compression default', 1   reconfigure;
exec      master..sp_configure 'xp_cmdshell', 1                                   reconfigure;
exec      (@backup_all_databases)
```

<p>Step 2: Delete old backups (2 weeks old).
~ Paste in the following logic…
</p>      


## SQL-Logic
```SQL
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
exec                      (@delete_old_files)
```

<p>…on to the second Transaction Backup Job.
DATABASE BACKUP LOG – All Databases
Step 1: Backup all database transaction logs.
~ Paste in the following logic…</p>      


## SQL-Logic
```SQL
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
```
<p>Step 2: Shrink transaction logs after backup.
~ Paste in the following logic…</p>      


## SQL-Logic
```SQL
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
```

<p>Step 3: Delete old backup files ( 2 weeks ).
~ Paste in the following logic…</p>      


## SQL-Logic
```SQL
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
```

<p>I'll go ahead and add a 3rd basic DBCC Maintenance Job here.
DATABASE MAINTENANCE – All Databases
Step 1: Run maintenance on all databases.
~ Paste in the following logic…</p>      


## SQL-Logic
```SQL
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
```

About the Full and Transaction log backup jobs. This is what they are doing.
The full database backup job will do the following…
1. Get all database that are Online.
2. Get all databases excluding the 'TempDB'
3. Get all database that are not the secondary 'mirror' partner in a database mirroring configuration. Remember there are 2 types of databases in a mirror. Principal (primary) and the Mirror(secondary). You want to focus on the live database.
4. Get all databases that does not have a Backup or Restore operation currently running against it.



[![WorksEveryTime](https://forthebadge.com/images/badges/60-percent-of-the-time-works-every-time.svg)](https://shitday.de/)

## Author

[![Gist](https://img.shields.io/badge/Gist-MikesDataWork-<COLOR>.svg)](https://gist.github.com/mikesdatawork)
[![Twitter](https://img.shields.io/badge/Twitter-MikesDataWork-<COLOR>.svg)](https://twitter.com/mikesdatawork)
[![Wordpress](https://img.shields.io/badge/Wordpress-MikesDataWork-<COLOR>.svg)](https://mikesdatawork.wordpress.com/)

  
## License
[![LicenseCCSA](https://img.shields.io/badge/License-CreativeCommonsSA-<COLOR>.svg)](https://creativecommons.org/share-your-work/licensing-types-examples/)

![Mikes Data Work](https://raw.githubusercontent.com/mikesdatawork/images/master/git_mikes_data_work_banner_02.png "Mikes Data Work")

