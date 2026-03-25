USE msdb;
GO

/* Procedura tworząca nowe zadanie (Job) w usłudze SQL Server Agent */
EXEC msdb.dbo.sp_add_job
    @job_name = N'HR_full_backup_daily'; -- Nazwa identyfikująca zadanie w systemie
GO

/* Procedura dodająca konkretny krok wykonawczy do istniejącego zadania */
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'HR_full_backup_daily', -- Nazwa zadania, do którego przypisujemy krok
    @step_name = N'backup_step',         -- Unikalna nazwa dla tego kroku w ramach zadania
    @subsystem = N'TSQL',                -- Określa silnik wykonawczy (w tym przypadku Transact-SQL)
    @command = N'BACKUP DATABASE HR TO DISK = ''~/db_backups/HR_full.bak'' WITH INIT;', -- Rzeczywiste polecenie SQL do wykonania
    @database_name = N'master';          -- Baza danych, w kontekście której zostanie wykonane polecenie
GO

/* Procedura tworząca harmonogram czasowy określający kiedy zadania mają być uruchamiane */
EXEC msdb.dbo.sp_add_schedule
    @schedule_name = N'Daily_3AM',   -- Nazwa identyfikująca dany harmonogram
    @enabled = 1,                    -- Flaga określająca, czy harmonogram jest aktywny (1) czy wyłączony (0)
    @freq_type = 4,                  -- Określa typ częstotliwości (wartość 4 oznacza codziennie)
    @freq_interval = 1,              -- Określa interwał (w połączeniu z trybem dziennym oznacza uruchamianie co 1 dzień)
    @active_start_time = 175400;     -- Dokładna godzina rozpoczęcia zadania w formacie HHMMSS (03:00:00)
GO

/* Procedura wiążąca zdefiniowany harmonogram czasowy z konkretnym zadaniem */
EXEC msdb.dbo.sp_attach_schedule
    @job_name = N'HR_full_backup_daily', -- Nazwa zadania, które ma zostać powiązane
    @schedule_name = N'Daily_3AM';       -- Nazwa harmonogramu, który ma zostać przypisany do zadania
GO

/* Procedura przypisująca zadanie do konkretnego serwera docelowego, co umożliwia jego start */
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'HR_full_backup_daily', -- Nazwa zadania, które przypisujemy do serwera
    @server_name = N'(LOCAL)';           -- Nazwa instancji serwera SQL, na której zadanie ma być uruchamiane
GO
