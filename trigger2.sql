CREATE OR ALTER TRIGGER delete_trigger ON locations
AFTER DELETE
AS
BEGIN
	-- Zmienne do przechowywania wyników kursora
	DECLARE @city NVARCHAR(255);
	DECLARE @country_name NVARCHAR(100);

	-- Deklaracja kursora
	DECLARE  location_cursor CURSOR FOR
	SELECT c.country_name, d.city
	FROM DELETED d
	JOIN countries c on c.country_id = d.country_id;

	-- Otwarcie kursora
	OPEN location_cursor;

	-- Pobieranie danych z kursora i wyœwietlanie wyników
	FETCH NEXT FROM location_cursor INTO @country_name, @city;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Usunieto miasto: ' + @city + ' w kraju: ' + @country_name;
		FETCH NEXT FROM location_cursor INTO @country_name, @city;
	END;
-- Zamkniêcie kursora i zwolnienie zasobów
CLOSE location_cursor;
DEALLOCATE location_cursor;
END;



DELETE
FROM locations
WHERE locations.location_id NOT IN (
					SELECT d.location_id FROM departments d
					WHERE d.location_id IS NOT NULL
					);