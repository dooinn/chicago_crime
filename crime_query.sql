use chicago_crime;


SELECT * FROM crime;


-- Q. What is the most prevalent type of crime in Chicago?

SELECT primary_type, COUNT(primary_type) as count FROM crime
GROUP BY primary_type
ORDER BY count desc
LIMIT 10;


-- Q. Which month tends to have higher crime rates?
-- July, August, and June – the summer months – tend to have a higher crime rate compared to other seasons.
WITH t1 AS (
	SELECT 
	  YEAR(date) as year, 
	  MONTH(date) as month, 
	  COUNT(*) as count 
	FROM crime
	GROUP BY year, month
	ORDER BY year, month ASC
)
SELECT month, ROUND(AVG(count),2) as avg_count FROM t1
GROUP BY month
ORDER BY avg_count DESC;


-- Q. What time during the day tends to have a higher crime rate than other times?
-- Midnight (0h) records the highest crime rate, followed closely by midday (12h).
WITH t1 AS (
	SELECT
		DAYNAME(date) as day,
		HOUR(date) as hour,
		COUNT(*) as count
	FROM crime
	GROUP BY day, hour
	ORDER BY day, hour ASC
)
SELECT hour, ROUND(AVG(count),2) as avg_count from t1
GROUP BY hour
ORDER BY avg_count DESC;


-- Q. Which hour is considered the most dangerous for each community?

WITH t1 AS (
	SELECT 
		community,
		HOUR(date) as hour,
		ROW_NUMBER() OVER (PARTITION BY community ORDER BY COUNT(*) DESC) as rnk
	FROM crime
	GROUP BY community, HOUR(date)
) SELECT community, hour FROM t1 
WHERE rnk = 1;

-- Q. Which season (or month) is considered the most dangerous for each community?


WITH t1 AS (
	SELECT 
		community,
		MONTH(date) as month,
		ROW_NUMBER() OVER (PARTITION BY community ORDER BY COUNT(*) DESC) as rnk
	FROM crime
	GROUP BY community, MONTH(date)
) SELECT community, month FROM t1 
WHERE rnk = 1;



-- Q. Do certain crimes tend to occur at specific times or seasons?



WITH t1 AS (
	SELECT primary_type, DAYNAME(date) as day, HOUR(date) as hour, COUNT(*) as count
	FROM crime
	GROUP BY primary_type, day, hour
),

t2 AS (
	SELECT primary_type, hour, AVG(count) as avg_count
	FROM t1
	GROUP BY primary_type, hour
),

t3 AS (
	SELECT primary_type, hour, RANK() OVER (PARTITION BY primary_type ORDER BY avg_count DESC) as rnk
	FROM t2
)
SELECT primary_type, hour
FROM t3
WHERE rnk = 1;





-- Q. Do certain locations see a higher incidence of crime at specific times or seasons?


WITH t1 AS (
	SELECT location_description, DAYNAME(date) as day, HOUR(date) as hour, COUNT(*) as count
	FROM crime
	GROUP BY location_description, day, hour
),
t2 AS (
	SELECT location_description, hour, AVG(count) as avg_count
	FROM t1
	GROUP BY location_description, hour
),
t3 AS (
	SELECT location_description, hour, RANK() OVER (PARTITION BY location_description ORDER BY avg_count DESC) as rnk
	FROM t2
)
SELECT location_description, hour
FROM t3
WHERE rnk = 1;

SELECT * FROM crime;

-- Q. What is the most frequently committed crime in each community?


WITH RankedCrimes AS (
	SELECT 
		community, 
		primary_type, 
		RANK() OVER (PARTITION BY community ORDER BY count DESC) as rnk
	FROM (
		SELECT
			community,
			primary_type,
			COUNT(primary_type) as count
		FROM crime
		GROUP BY community, primary_type
	) t1
)
SELECT community, primary_type
FROM RankedCrimes
WHERE rnk = 1
ORDER BY community DESC;


-- Q. At what time does crime occur the most in each community?

WITH t1 AS (
	SELECT 
		community, 
        DAYNAME(date) as day, 
        hour(date) as hour, 
        COUNT(*) as count 
	FROM crime
	GROUP BY community, day, hour
),
t2 AS (
	SELECT
		community, 
        hour, 
        AVG(count) as avg_count
	FROM t1
	GROUP BY community, hour
),
t3 AS (
	SELECT community, hour, RANK() OVER (PARTITION BY community ORDER BY avg_count DESC) as rnk
	FROM t2
)
SELECT community, hour
FROM t3
WHERE rnk = 1;


-- Q. What is the arrest rate for each community, and which one has the highest?

SELECT 
	community,
	ROUND(AVG(CASE WHEN arrest = 'True' THEN 1 ELSE 0 END) * 100, 2) AS ArrestRate
FROM crime
GROUP BY community
ORDER BY ArrestRate DESC




-- Q. For each specific crime type, what is the most common description or detail associated with it?
WITH RankedCrimesSpecific AS (
	SELECT 
		primary_type, 
        description,
		RANK() OVER (PARTITION BY primary_type ORDER BY count DESC) as rnk
	FROM (
		SELECT
			primary_type,
			description,
			COUNT(primary_type) as count
		FROM crime
		GROUP BY primary_type, description
	) t1
)
SELECT primary_type, description
FROM RankedCrimesSpecific
WHERE rnk = 1
ORDER BY primary_type DESC;


-- Q. Domestic Crime rate per Community

SELECT 
	community,
	ROUND(AVG(CASE WHEN domestic = 'True' THEN 1 ELSE 0 END) * 100, 2) AS DomesticCrimeRate
FROM crime
GROUP BY community;



-- Q. number of crime by location
SELECT location_description, COUNT(*) AS count FROM crime
GROUP BY location_description
ORDER BY count DESC;


-- Q. Location and the top crime type

WITH t1 AS (
	SELECT 
		location_description, 
		primary_type, 
		COUNT(*) as count 
    FROM crime
	GROUP BY location_description, primary_type
), 
t2 AS (
	SELECT 
		location_description, 
        primary_type,
        count,
        RANK() OVER (PARTITION BY location_description ORDER BY count DESC) as rnk 
	FROM t1
) 
SELECT
	location_description,
	primary_type,
    count
FROM t2 
WHERE rnk =1;

-- Q. Most common type of crime per Community

WITH t1 AS (
	SELECT 
		community,
		primary_type,
		ROW_NUMBER() OVER (PARTITION BY community ORDER BY COUNT(*) DESC) as rnk
	FROM crime
	GROUP BY community, primary_type
)
SELECT community, primary_type FROM t1
WHERE rnk = 1;


-- Q. Most Dangerous Location per Community

WITH t1 AS (
	SELECT 
		community,
		location_description,
		ROW_NUMBER() OVER (PARTITION BY community ORDER BY COUNT(*) DESC) as rnk
	FROM crime
	GROUP BY community, location_description
) SELECT community, location_description FROM t1
WHERE rnk = 1 ;







SELECT * FROM crime;







