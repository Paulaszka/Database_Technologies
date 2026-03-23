CREATE OR ALTER PROCEDURE proc2(
    @nazwa_departamentu NVARCHAR(100),
    @id_menadzera INT = NULL,
    @id_lokalizacji INT = 2000
) AS
BEGIN
    INSERT INTO departments (department_id, department_name, manager_id, location_id)
	VALUES ((SELECT COALESCE(MAX(department_id), 0) + 10 FROM departments), @nazwa_departamentu, @id_menadzera, @id_lokalizacji)
END;


EXEC proc2 'Kuba'
EXEC proc2 'Maciej', 101;
EXEC proc2 'Julian', @id_lokalizacji = 2500;
EXEC proc2 'Sergiej', 101, 2500;
EXEC proc2 @id_lokalizacja = 2500; -- nie dziala