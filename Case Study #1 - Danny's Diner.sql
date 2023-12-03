/* Create Database */
CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
/* 
Case Study Questions
Each of the following case study questions can be answered using a single SQL statement:

1.What is the total amount each customer spent at the restaurant?
2.How many days has each customer visited the restaurant?
3.What was the first item from the menu purchased by each customer?
4.What is the most purchased item on the menu and how many times was it purchased by all customers?
5.Which item was the most popular for each customer?
6.Which item was purchased first by the customer after they became a member?
7.Which item was purchased just before the customer became a member?
8.What is the total items and amount spent for each member before they became a member?
9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
*/


/* 1. What is the total amount each customer spent at the restaurant? */
SELECT S.customer_id, SUM(M.price) AS Total_Pay
FROM dannys_diner.sales S
LEFT JOIN dannys_diner.menu M ON S.product_id = M.product_id
GROUP BY S.customer_id
ORDER BY Total_Pay DESC;

/* 2.How many days has each customer visited the restaurant? */
SELECT S.customer_id, COUNT(DISTINCT S.order_date)
FROM dannys_diner.Sales S
GROUP BY S.customer_id;

/* 3.What was the first item from the menu purchased by each customer? */
SELECT S.customer_id, MIN(S.order_date) AS first_purchase_date, M.product_name AS first_purchase_item
FROM dannys_diner.sales S
JOIN dannys_diner.menu M ON S.product_id = M.product_id
GROUP BY S.customer_id, M.product_name
ORDER BY first_purchase_date;

/* 4.What is the most purchased item on the menu and how many times was it purchased by all customers? */
SELECT m.product_name AS most_purchased_item, COUNT(*) AS purchase_count
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY purchase_count DESC
LIMIT 1;

/* 5.Which item was the most popular for each customer? */
SELECT S.customer_id, M.product_name AS most_popular_item, COUNT(*) AS purchase_count
FROM dannys_diner.sales S
JOIN dannys_diner.menu M ON S.product_id = M.product_id
GROUP BY S.customer_id, M.product_name
HAVING COUNT(*) = (
  SELECT MAX(purchase_count)
  FROM (
    SELECT customer_id, COUNT(*) AS purchase_count
    FROM dannys_diner.sales
    GROUP BY customer_id, product_id
  ) AS subquery
  WHERE subquery.customer_id = S.customer_id
)
ORDER BY S.customer_id;

/* 6. Which item was purchased first by the customer after they became a member? */
SELECT S.customer_id, M.product_name AS first_purchase_item, MIN(S.order_date) AS first_purchase_date
FROM dannys_diner.sales S
JOIN dannys_diner.menu M ON S.product_id = M.product_id
JOIN dannys_diner.members MB ON S.customer_id = MB.customer_id
WHERE S.order_date > MB.join_date
GROUP BY S.customer_id, M.product_name
ORDER BY S.customer_id;

/* 7.Which item was purchased just before the customer became a member? */
SELECT S.customer_id, M.product_name AS last_purchase_item, MAX(S.order_date) AS last_purchase_date
FROM dannys_diner.sales S
JOIN dannys_diner.menu M ON S.product_id = M.product_id
JOIN dannys_diner.members MB ON S.customer_id = MB.customer_id
WHERE S.order_date < MB.join_date
GROUP BY S.customer_id, M.product_name
ORDER BY S.customer_id;

/* 8.What is the total items and amount spent for each member before they became a member? */
SELECT S.customer_id, COUNT(*) AS total_items, SUM(M.price) AS total_amount_spent
FROM dannys_diner.sales S
JOIN dannys_diner.menu M ON S.product_id = M.product_id
JOIN dannys_diner.members MB ON S.customer_id = MB.customer_id
WHERE S.order_date < MB.join_date
GROUP BY S.customer_id
ORDER BY S.customer_id;

/* 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? */
SELECT
  S.customer_id,
  SUM(
    CASE
      WHEN M.product_name = 'sushi' THEN (M.price * 2) * 10
      ELSE M.price * 10
    END
  ) AS total_points
FROM dannys_diner.sales S
JOIN dannys_diner.menu M ON S.product_id = M.product_id
GROUP BY S.customer_id
ORDER BY S.customer_id;

/* 10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January? */
SELECT
  S.customer_id,
  SUM(
    CASE
      WHEN S.order_date <= DATE_TRUNC('week', MB.join_date + INTERVAL '1 week') THEN (M.price * 2) * 10
      ELSE M.price * 10
    END
  ) AS total_points
FROM dannys_diner.sales S
JOIN dannys_diner.menu M ON S.product_id = M.product_id
JOIN dannys_diner.members MB ON S.customer_id = MB.customer_id
WHERE S.order_date <= '2023-01-31'
  AND (S.order_date <= DATE_TRUNC('week', MB.join_date + INTERVAL '1 week') OR S.order_date > DATE_TRUNC('month', MB.join_date))
  AND S.customer_id IN ('A', 'B')
GROUP BY S.customer_id
ORDER BY S.customer_id;

/* Bonus Questions */

/* Join All The Things */
CREATE VIEW sales_summary AS
SELECT s.customer_id, s.order_date, m.product_name, m.price,
       CASE WHEN mbr.customer_id IS NOT NULL THEN 'Y' ELSE 'N' END AS member
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
LEFT JOIN dannys_diner.members mbr ON s.customer_id = mbr.customer_id
ORDER BY s.customer_id, s.order_date;

SELECT * FROM sales_summary;

/* Rank All The Things */
SELECT s.customer_id, s.order_date, m.product_name, m.price,
       CASE WHEN mbr.customer_id IS NOT NULL THEN 'Y' ELSE 'N' END AS member,
       CASE WHEN mbr.customer_id IS NULL THEN NULL
            ELSE RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date)
       END AS ranking
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
LEFT JOIN dannys_diner.members mbr ON s.customer_id = mbr.customer_id
ORDER BY s.customer_id, s.order_date;



