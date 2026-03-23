USE msdb;
GO

-- 1. Utworzenie zadania
EXEC dbo.sp_add_job
    @job_name = N'HR_full_backup_daily';
GO

-- 2. Dodanie kroku (backup bazy HR)
-- Upewnij się, że folder D:\ istnieje i SQL Server ma do niego uprawnienia zapisu
EXEC dbo.sp_add_jobstep
    @job_name = N'HR_full_backup_daily',
    @step_name = N'backup_step',
    @subsystem = N'TSQL',
    @command = N'BACKUP DATABASE HR TO DISK = ''D:\HR_full.bak'' WITH INIT;', -- WITH INIT nadpisuje stary plik
    @database_name = N'master';
GO

-- 3. Utworzenie i aktywacja harmonogramu (Codziennie o 3:00)
-- @freq_type = 4 (Daily / Codziennie)
-- @freq_interval = 1 (Co 1 dzień)
EXEC dbo.sp_add_schedule
    @schedule_name = N'Daily_3AM',
    @enabled = 1,              -- 1 oznacza, że jest od razu aktywny
    @freq_type = 4,            -- Codziennie
    @freq_interval = 1,        -- Co 1 dzień
    @active_start_time = 030000;
GO

-- 4. Przypisanie harmonogramu do zadania
EXEC dbo.sp_attach_schedule
    @job_name = N'HR_full_backup_daily',
    @schedule_name = N'Daily_3AM';
GO

-- 5. Przypisanie zadania do lokalnego serwera (niezbędne do uruchomienia)
EXEC dbo.sp_add_jobserver
    @job_name = N'HR_full_backup_daily',
    @server_name = N'(LOCAL)';
GO