-- 1. Count number of posts that are questions (post_type_id=1) 
--    and are either highly scored (>300) or highly favorited (>=100).
SELECT COUNT(id)
FROM stackoverflow.posts
WHERE post_type_id = 1 
  AND (score > 300 OR favorites_count >= 100)
GROUP BY post_type_id;


-- 2. Calculate the average number of questions per day 
--    between 2008-11-01 and 2008-11-18, rounded to nearest integer.
SELECT ROUND(AVG(t.count),0)
FROM (
      SELECT COUNT(id),
             creation_date::date
      FROM stackoverflow.posts
      WHERE post_type_id = 1
      GROUP BY creation_date::date
      HAVING creation_date::date BETWEEN '2008-11-01' AND '2008-11-18'
) AS t;


-- 3. Count users who received their first badge on the same date they registered.
SELECT COUNT(DISTINCT u.id)
FROM stackoverflow.badges AS b
JOIN stackoverflow.users AS u ON b.user_id = u.id
WHERE b.creation_date::date = u.creation_date::date;


-- 4. Count posts made by "Joel Coehoorn" that have at least one vote.
SELECT COUNT(t.id)
FROM (
     SELECT p.id
     FROM stackoverflow.posts AS p
     JOIN stackoverflow.votes AS v ON p.id = v.post_id
     JOIN stackoverflow.users AS u ON p.user_id = u.id
     WHERE u.display_name LIKE 'Joel Coehoorn'
     GROUP BY p.id
     HAVING COUNT(v.id) >= 1
) AS t;


-- 5. Show all vote types with a sequential row number assigned by ID (descending).
SELECT *,
       ROW_NUMBER() OVER(ORDER BY id DESC) AS rank
FROM stackoverflow.vote_types
ORDER BY id;


-- 6. Find top 10 users who cast the most "Close" votes.
SELECT *
FROM (
      SELECT v.user_id,
             COUNT(vt.id) AS cnt
      FROM stackoverflow.votes AS v
      JOIN stackoverflow.vote_types AS vt ON vt.id = v.vote_type_id
      WHERE vt.name LIKE 'Close'
      GROUP BY v.user_id
      ORDER BY cnt DESC LIMIT 10
) AS t
ORDER BY t.cnt DESC, t.user_id DESC;


-- 7. Find top 10 users by number of badges earned between 2008-11-15 and 2008-12-15.
--    Assign a dense rank to handle ties.
SELECT *,
       DENSE_RANK() OVER (ORDER BY t.cnt DESC) AS n
FROM (
      SELECT COUNT(id) AS cnt,
             user_id
      FROM stackoverflow.badges
      WHERE creation_date::date BETWEEN '2008-11-15' AND '2008-12-15' 
      GROUP BY user_id
      ORDER BY cnt DESC, user_id
      LIMIT 10
) AS t;


-- 8. For each user, calculate their average post score (excluding 0 scores), 
--    then display each post along with the user's average score.
WITH t AS (
SELECT ROUND(AVG(score)) AS avg_score,
       user_id
FROM stackoverflow.posts
WHERE title IS NOT NULL 
  AND score <> 0
GROUP BY user_id
)
SELECT p.title,
       t.user_id,
       p.score,
       t.avg_score
FROM t 
JOIN stackoverflow.posts AS p ON t.user_id = p.user_id
WHERE p.title IS NOT NULL 
  AND p.score <> 0;   


-- 9. Select all post titles from users with more than 1000 badges.
SELECT title
FROM stackoverflow.posts
WHERE user_id IN (
                  SELECT user_id
                  FROM stackoverflow.badges
                  GROUP BY user_id
                  HAVING COUNT(id) > 1000
)
  AND title IS NOT NULL;


-- 10. Categorize U.S. users into 3 groups based on profile views.
SELECT id,
       views,
       CASE
          WHEN views >= 350 THEN 1
          WHEN views < 100 THEN 3
          ELSE 2
       END AS group
FROM stackoverflow.users
WHERE location LIKE '%United States%'
  AND views > 0;


-- 11. For U.S. users, find the user(s) with the maximum views in each group.
WITH tab AS (
     SELECT t.id,
            t.views,
            t.group,
            MAX(t.views) OVER (PARTITION BY t.group) AS max	
     FROM (
           SELECT id,
                  views,
                  CASE
                     WHEN views >= 350 THEN 1
                     WHEN views < 100 THEN 3
                     ELSE 2
                  END AS group
           FROM stackoverflow.users
           WHERE location LIKE '%United States%'
             AND views > 0
     ) AS t
)
SELECT tab.id, 
       tab.views,  
       tab.group
FROM tab
WHERE tab.views = tab.max
ORDER BY tab.views DESC, tab.id;


-- 12. Show the cumulative sum of users registered each day in November 2008.
SELECT *,
       SUM(t.cnt_id) OVER (ORDER BY t.days) AS nn
FROM (
      SELECT EXTRACT(DAY FROM creation_date::date) AS days,
             COUNT(id) AS cnt_id
      FROM stackoverflow.users
      WHERE creation_date::date BETWEEN '2008-11-01' AND '2008-11-30'
      GROUP BY EXTRACT(DAY FROM creation_date::date)
) AS t;


-- 13. Calculate the difference in days between user's registration 
--     and their first post.
WITH p AS (
SELECT DISTINCT user_id,
       MIN(creation_date) OVER (PARTITION BY user_id) AS min_dt					
FROM stackoverflow.posts
)
SELECT p.user_id,
       (p.min_dt - u.creation_date) AS diff
FROM stackoverflow.users AS u 
JOIN p ON u.id = p.user_id;


-- 14. Find total post views per month, sorted by highest to lowest.
SELECT SUM(views_count),
       DATE_TRUNC('month', creation_date)::date AS mnth
FROM stackoverflow.posts
GROUP BY DATE_TRUNC('month', creation_date)::date
ORDER BY SUM(views_count) DESC;


-- 15. Find users who posted more than 100 answers in their first month on the site.
SELECT u.display_name,
       COUNT(DISTINCT p.user_id)
FROM stackoverflow.posts AS p
JOIN stackoverflow.users AS u ON p.user_id = u.id
JOIN stackoverflow.post_types AS pt ON pt.id = p.post_type_id
WHERE p.creation_date::date BETWEEN u.creation_date::date 
      AND (u.creation_date::date + INTERVAL '1 month')
  AND pt.type LIKE '%Answer%'
GROUP BY u.display_name
HAVING COUNT(p.id) > 100
ORDER BY u.display_name;


-- 16. For users registered in Sep 2008 who posted in Dec 2008, 
--     count their posts by month in 2008.
WITH t AS (
     SELECT u.id
     FROM stackoverflow.posts AS p
     JOIN stackoverflow.users AS u ON p.user_id = u.id
     WHERE DATE_TRUNC('month', u.creation_date)::date = '2008-09-01'
       AND DATE_TRUNC('month', p.creation_date)::date = '2008-12-01'
     GROUP BY u.id
     HAVING COUNT(p.id) > 0
)
SELECT COUNT(p.id),
       DATE_TRUNC('month', p.creation_date)::date      
FROM stackoverflow.posts AS p
WHERE p.user_id IN (SELECT * FROM t)
  AND DATE_TRUNC('year', p.creation_date)::date = '2008-01-01'
GROUP BY DATE_TRUNC('month', p.creation_date)::date
ORDER BY DATE_TRUNC('month', p.creation_date)::date DESC;


-- 17. For each user, calculate the cumulative sum of views on their posts over time.
SELECT user_id,
       creation_date,
       views_count,
       SUM(views_count) OVER (PARTITION BY user_id ORDER BY creation_date)						
FROM stackoverflow.posts;


-- 18. Find the average number of unique active posting days per user 
--     during the first week of December 2008.
SELECT ROUND(AVG(t.cnt))
FROM (
      SELECT user_id,
             COUNT(DISTINCT creation_date::date) AS cnt
      FROM stackoverflow.posts
      WHERE creation_date::date BETWEEN '2008-12-01' AND '2008-12-07' 
      GROUP BY user_id
) AS t;


-- 19. Monthly user growth rate (Sep–Dec 2008) based on number of posts.
WITH t AS (
     SELECT EXTRACT(MONTH FROM creation_date::date) AS month,
            COUNT(DISTINCT id)    
     FROM stackoverflow.posts
     WHERE creation_date::date BETWEEN '2008-09-01' AND '2008-12-31'
     GROUP BY month
)
SELECT *,
       ROUND(((count::numeric / LAG(count) OVER (ORDER BY month)) - 1) * 100, 2) AS user_growth
FROM t;


-- 20. For the most active user in the dataset, find the last post date for each week in Oct 2008.
WITH t AS (
     SELECT user_id,
            COUNT(DISTINCT id) AS cnt
     FROM stackoverflow.posts
     GROUP BY user_id
     ORDER BY cnt DESC
     LIMIT 1
),
t1 AS (
     SELECT p.user_id,
            p.creation_date,
            EXTRACT('week' FROM p.creation_date) AS week_number
     FROM stackoverflow.posts AS p
     JOIN t ON t.user_id = p.user_id
     WHERE DATE_TRUNC('month', p.creation_date)::date = '2008-10-01'
)
SELECT DISTINCT week_number::numeric,
       MAX(creation_date) OVER (PARTITION BY week_number)
FROM t1
ORDER BY week_number;
