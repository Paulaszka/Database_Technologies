-- Wyzwalacz AFTER INSERT, UPDATE na tabeli employees.
-- Pilnuje, aby w żadnym departamencie nie było więcej niż 3 osoby na stanowiskach kierowniczych
-- (zawierających w nazwie 'Manager' lub 'President'). 
-- W przypadku przekroczenia limitu transakcja jest wycofywana z komunikatem o błędzie.

CREATE OR ALTER TRIGGER check_manager_count
ON employees
AFTER INSERT, UPDATE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;
    BEGIN TRY
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN jobs j ON i.job_id = j.job_id
            WHERE j.job_title LIKE '%Manager%' OR j.job_title LIKE '%President%'
            GROUP BY i.department_id
            HAVING (
                SELECT COUNT(*)
                FROM employees e
                JOIN jobs j2 ON e.job_id = j2.job_id
                WHERE e.department_id = i.department_id
                AND (j2.job_title LIKE '%Manager%' OR j2.job_title LIKE '%President%')
            ) > 3
        )
        BEGIN
            ;THROW 50003, 'Error: The limit on management positions (max. 3) in this department has been reached!', 1;
        END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @Sev INT = ERROR_SEVERITY();
        DECLARE @St INT = ERROR_STATE();

        RAISERROR(@Msg, @Sev, @St);
    END CATCH
END;


--Przypadki testowe

-- Dodajemy nowego menedżera do departamentu 60 (IT), który obecnie nie ma menedżerów (tylko IT_PROG).
INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary, department_id)
VALUES (300, 'Test', 'Manager', 'TMAN_IT', GETDATE(), 'MK_MAN', 10000, 60);

-- Dodajemy nowego 4-go menedżera do departamentu 90 (Executive), który ma już 3 (Steven, Neena, Lex).
INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary, department_id)
VALUES (301, 'Fail', 'Manager', 'FMAN_EXEC', GETDATE(), 'AD_PRES', 30000, 90);

