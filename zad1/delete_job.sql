USE msdb;
GO

EXEC msdb.dbo.sp_detach_schedule
    @job_name = N'HR_full_backup_daily',
    @schedule_name = N'Daily_3AM';
GO

EXEC msdb.dbo.sp_delete_schedule
    @schedule_name = N'Daily_3AM',
    @force_delete = 1; -- Parametr wymuszający usunięcie, jeśli byłby jeszcze gdzieś użyty
GO

EXEC msdb.dbo.sp_delete_job
    @job_name = N'HR_full_backup_daily';
GO