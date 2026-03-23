CREATE or ALTER TRIGGER [dbo].[wyzw1]
ON [dbo].[employees]
INSTEAD OF INSERT
AS
BEGIN
    IF (SELECT hire_date FROM inserted) > GETDATE()
    BEGIN
        PRINT('Niedozwolona operacja!');
    END
    ELSE
    BEGIN
        INSERT INTO employees SELECT * FROM inserted
    END
END;

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id)
VALUES (2, 'Jan', 'Kowalski', 'jan.kowalski@example.com', GETDATE(), 'IT_PROG');

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id)
VALUES (1, 'Jan', 'Kowalski', 'jan.kowalski2@example.com', DATEADD(DAY, 1, GETDATE()), 'IT_PROG');