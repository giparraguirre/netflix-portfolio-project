-- ============================================================
-- Netflix Titles Analysis - SQL Queries
-- Companion to notebooks/01_clean_explore.ipynb, Step 5
-- Queried via SQLite (data/processed/netflix.db), run from Python
-- using pandas.read_sql_query(). Results cross-validated against
-- the equivalent pandas analysis in Step 4 of the notebook.
-- ============================================================


-- ============================================================
-- Q1: Titles added per year, by type (Movie vs TV Show)
-- ============================================================
SELECT 
    strftime('%Y', date_added) AS year_added,
    type,
    COUNT(*) AS title_count
FROM titles
WHERE date_added IS NOT NULL
GROUP BY year_added, type
ORDER BY year_added;


-- ============================================================
-- Q2: Top 10 most common genres
-- ============================================================
SELECT
    genre_list AS genre,
    COUNT(*) AS title_count
FROM titles_by_genre
GROUP BY genre_list
ORDER BY title_count DESC
LIMIT 10;


-- ============================================================
-- Q3a: Average, minimum, and maximum movie length (minutes)
-- ============================================================
SELECT
    AVG(duration_value) AS avg_duration,
    MIN(duration_value) AS min_duration,
    MAX(duration_value) AS max_duration
FROM titles
WHERE type = 'Movie';


-- Q3b: Approximate quartile boundaries for movie length
-- (SQLite has no built-in percentile function, so NTILE() is used
-- inside a CTE to split movies into 4 equal-sized buckets by duration;
-- the min/max of each bucket approximate the 25th/50th/75th percentiles.)
WITH ranked AS (
    SELECT
        duration_value,
        NTILE(4) OVER (ORDER BY duration_value) AS quartile
    FROM titles 
    WHERE type = 'Movie'
)
SELECT 
    quartile,
    MIN(duration_value) AS min_val,
    MAX(duration_value) AS max_val,
    COUNT(*) AS n
FROM ranked
GROUP BY quartile;


-- ============================================================
-- Q4: Top 10 countries contributing content (excluding "Unknown")
-- ============================================================
SELECT 
    country_list AS country,
    COUNT(*) AS title_count
FROM titles_by_country
WHERE country_list != 'Unknown'
GROUP BY country_list
ORDER BY title_count DESC
LIMIT 10;