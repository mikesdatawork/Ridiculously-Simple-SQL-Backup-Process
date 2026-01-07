
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

