CREATE OR ALTER FUNCTION func4 (@input NVARCHAR(100))
RETURNS decimal(5,2)
AS BEGIN
	DECLARE @deparmentCount decimal
	DECLARE @sumEmployes decimal

	SELECT @deparmentCount = count(*) FROM employees
	WHERE employees.department_id = (SELECT departments.department_id FROM departments
									WHERE departments.department_name = @Input)

	SELECT @sumEmployes = count(*) FROM employees

    RETURN ROUND((@deparmentCount / @sumEmployes) * 100, 2)
END

SELECT department_id, department_name, dbo.func4(department_name) AS PERCENTAGE FROM departments