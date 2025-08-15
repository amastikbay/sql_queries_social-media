# Stack Overflow SQL Analysis

This repository contains a collection of SQL queries analyzing the **Stack Overflow** public dataset.  

The queries explore user activity, post performance, badges, votes, and other platform metrics,  
demonstrating advanced SQL skills such as window functions, CTEs, subqueries, and aggregation.

---

## 📂 Dataset

The analysis is based on the **Stack Overflow** schema, which contains tables such as:

- `users` – Information about registered users, including profile views, location, and registration date.
- `posts` – Questions and answers with creation dates, scores, views, and more.
- `votes` – Vote history for posts.
- `vote_types` – Types of votes (e.g., upvote, close, downvote).
- `badges` – User badges earned over time.
- `post_types` – Types of posts (questions or answers).

- ![Stack Overflow Analysis](stack_overflow.png)

---

## 📌 Skills Demonstrated

- Complex **JOIN** operations across multiple tables
- **Aggregation & Grouping** (`COUNT`, `SUM`, `AVG`, `HAVING`)
- **Window functions** (`ROW_NUMBER`, `DENSE_RANK`, `LAG`, `SUM OVER`)
- **Date and time functions** (`DATE_TRUNC`, `EXTRACT`, `INTERVAL`)
- **Conditional logic** with `CASE`
- **Subqueries** and **CTEs** for modular and readable SQL

---

## 📝 Query Highlights

1. **High-Impact Questions** – Identify questions with exceptional scores or favorites.  
2. **Daily Question Averages** – Calculate average posting rates for given time periods.  
3. **User Milestones** – Detect users who earned a badge on the day they joined.  
4. **Author Analysis** – Find posts and voting patterns for specific users.  
5. **Top Voters** – Rank users by "Close" votes cast.  
6. **Badge Leaders** – Rank top badge earners within a specific date range.  
7. **User Segmentation** – Categorize users by profile views and location.  
8. **Engagement Trends** – Measure monthly growth rates of posts and users.  
9. **Activity Tracking** – Identify the last post date per week for top users.

Each query is fully **commented** to explain its purpose and logic.

---

## 📁 File Structure

