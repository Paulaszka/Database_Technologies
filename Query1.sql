-- DATEPART, DATENAME, LIMIT 1 - TOP(1)

-- 1. Wyświetl imiona i nazwiska pracowników zatrudnionych w departamencie o nazwie IT. Wyniki posortuj malejąco
-- według wynagrodzenia oraz alfabetycznie według nazwiska.

SELECT e.first_name, e.last_name FROM employees e
JOIN departments d ON d.department_id = e.department_id
WHERE d.department_name LIKE 'IT'
ORDER BY e.salary DESC, e.last_name;

-- 2. Wyświetl nazwy departamentów, których pierwsza litera jest taka sama jak ostatnia litera nazwy kraju, w
-- którym mieści się ich siedziba.

SELECT d.department_name FROM departments d
JOIN locations l ON l.location_id = d.location_id
JOIN countries c ON c.country_id = l.country_id
WHERE LEFT(d.department_name, 1) = RIGHT(c.country_name, 1);

-- 3. Wyświetl imiona i nazwiska pracowników oraz nazwę dnia tygodnia, w którym zostali zatrudnieni na obecnym
-- stanowisku (nazwij tę kolumnę hired_weekday). Uwzględnij tylko tych pracowników, którzy zostali zatrudnieni
--w poniedziałek albo piątek.

SELECT e.first_name, e.last_name, DATENAME(WEEKDAY , e.hire_date) AS hired_weekday
FROM employees e
WHERE DATENAME(WEEKDAY , e.hire_date) IN ('Monday', 'Friday');

-- 4. Wyświetl nazwy stanowisk, na których nie jest zatrudniony żaden pracownik.

SELECT j.job_title FROM jobs j
LEFT JOIN employees e ON e.job_id = j.job_id
WHERE e.job_id IS NULL;

-- 5. Dla każdego pracownika wyświetl jego imię i nazwisko oraz liczbę bezpośrednio podległych mu współpracowników.
-- Uwzględnij również tych pracowników, którzy nie mają podwładnych.

SELECT e1.first_name, e1.last_name, count(e2.employee_id) AS liczba_podwladnych FROM employees e1
LEFT JOIN employees e2 ON e2.employee_id = e1.manager_id
GROUP BY e1.first_name, e1.last_name;

-- 6. Wyświetl nazwy miast, w których swoją siedzibę ma więcej niż jeden departament.

SELECT l.city FROM locations l
JOIN departments d ON d.location_id = l.location_id
GROUP BY l.city
HAVING COUNT(d.location_id) > 1;

-- 7. Wyświetl imiona i nazwiska pracowników, którzy zarabiają więcej niż średnie wynagrodzenie pracowników
-- zatrudnionych rocznikowo co najmniej 20 lat temu.

SELECT e.first_name, e.last_name FROM employees e
WHERE e.salary > (	SELECT AVG(salary) FROM employees
					WHERE DATEADD(YEAR, 20, hire_date) < CURRENT_TIMESTAMP
				);

-- 8. Wyświetl nazwy departamentów, w których zatrudnionych jest najwięcej pracowników.

SELECT d.department_name FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
HAVING COUNT(e.department_id) = (
								SELECT TOP(1) COUNT(e.department_id) FROM employees e
								GROUP BY e.department_id
								ORDER BY COUNT(e.department_id) DESC
								);

-- 9. Dla każdego stanowiska wyświetl jego nazwę oraz imiona i nazwiska obecnych pracowników, którzy są na nim
-- najkrócej zatrudnieni. Uwzględnij również te stanowiska, na których nie jest zatrudniony żaden pracownik.

SELECT j.job_title, e.first_name, e.last_name FROM jobs j
LEFT JOIN employees e ON e.job_id = j.job_id
WHERE e.hire_date = (
					SELECT MAX(hire_date) FROM employees
					WHERE job_id = j.job_id
					)