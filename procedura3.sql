-- Procedura zwiększająca wynagrodzenie pracownika o określoną kwotę,
-- z zachowaniem limitu max_salary dla danego stanowiska.

CREATE OR ALTER PROCEDURE update_salary
    @p_employee_id NUMERIC(6),
    @p_raise NUMERIC(8,2)
AS
BEGIN
    DECLARE @v_current_salary NUMERIC(8,2);
    DECLARE @v_max_salary NUMERIC(8,2);
    DECLARE @v_action_word VARCHAR(20);

    IF @p_raise = 0
    BEGIN
        PRINT 'Raise cannot be zero'
        RETURN;
    END

    SELECT @v_current_salary = e.salary,
           @v_max_salary = CAST(j.max_salary AS NUMERIC(8,2))
    FROM employees e
    JOIN jobs j ON e.job_id = j.job_id
    WHERE e.employee_id = @p_employee_id;

    IF @v_current_salary IS NULL
    BEGIN
        PRINT 'Error: Employee with ID ' + CAST(@p_employee_id AS VARCHAR) + ' not found.';
        RETURN;
    END


    IF @v_current_salary >= @v_max_salary
    BEGIN
        PRINT 'The employee already earns the maximum amount for their position.';
    END
    ELSE
    BEGIN
        DECLARE @new_salary NUMERIC(8,2);
        SET @new_salary = @v_current_salary + @p_raise;

        IF @new_salary > @v_max_salary
        BEGIN
            SET @new_salary = @v_max_salary;
        END

        UPDATE employees
        SET salary = @new_salary
        WHERE employee_id = @p_employee_id;

        SET @v_action_word = CASE
                                WHEN @p_raise > 0 THEN 'increased'
                                ELSE 'decreased'
                             END;

        PRINT 'Salary for employee ' + CAST(@p_employee_id AS VARCHAR) +
              ' has been ' + @v_action_word + ' from ' + CAST(@v_current_salary AS VARCHAR) +
              ' to ' + CAST(@new_salary AS VARCHAR) + '.';
    END
END;


-- Wywołanie z dodatnią podwyżką
EXEC update_salary @p_employee_id = 100, @p_raise = 500.0;

-- Wywołanie z zerową podwyżką
EXEC update_salary @p_employee_id = 100, @p_raise = 0.0;

-- Wywołanie z ujemną wartością
EXEC update_salary @p_employee_id = 100, @p_raise = -500.0;

-- Wywołanie dla osoby z maksymalnymi zarobkami
EXEC update_salary @p_employee_id = 109, @p_raise = 500.0;

-- Wywołanie dla nieistniejącego pracownika
EXEC update_salary @p_employee_id = 99, @p_raise = 500.0;


