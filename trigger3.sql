-- Wyzwalacz sprawdzający, czy nowa pensja pracownika nie przekracza pensji jego przełożonego.
-- Zgodnie ze specyfikacją SQL Server, użyto typu AFTER UPDATE z walidacją i ewentualnym wycofaniem transakcji.

CREATE OR ALTER TRIGGER check_employee_salary_update
ON employees
AFTER INSERT, UPDATE
AS
BEGIN
    BEGIN TRY
        -- 1. Sprawdzenie widełek płacowych (min/max salary z tabeli jobs)
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN jobs j ON i.job_id = j.job_id
            WHERE i.salary < j.min_salary OR i.salary > j.max_salary
        )
        BEGIN
            ;THROW 50001, 'Error: The employee’s salary exceeds the defined pay scale for this role!', 1;
        END

        -- 2. Sprawdzenie relacji z pensją przełożonego
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN employees m ON i.manager_id = m.employee_id
            WHERE i.salary > m.salary
        )
        BEGIN
            ;THROW 50002, 'Error: Employee salary cannot exceed manager salary.', 1;
        END
    END TRY
    BEGIN CATCH
        -- W wyzwalaczu, jeśli wystąpi błąd, transakcja musi zostać wycofana
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Przekazujemy błąd dalej do aplikacji/użytkownika
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

-- Przypadki testowe

-- Wywołanie z właściwym parametrem
UPDATE employees
SET salary = 7000
WHERE employee_id = 104;

-- Wywołanie z niewłaściwym parametrem (za duzo kasy)
UPDATE employees
SET salary = 10000
WHERE employee_id = 104;

-- Dodajemy pracownika IT (pensja 5000 mieści się w 4k-10k)
INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id, department_id)
VALUES (304, 'Marek', 'Poprawny', 'MPOPR', '500.600.700', GETDATE(), 'IT_PROG', 5000, 103, 60);

-- Próba przyznania 20 000 programiście, limit to 10 000 :(
INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id, department_id)
VALUES (303, 'Jan', 'Kowalski', 'JKOWALL', '555.123.456', GETDATE(), 'IT_PROG', 20000, 103, 60);



