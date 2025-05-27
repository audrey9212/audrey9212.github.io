//COMM2822-W18A-GROUP2
//Audrey_Chang z5627566




-- Calculate total revenue for each ad by combining base cost and additional revenue from metrics and placements
SELECT
	a.AD_ID,
	apt.TYPE_NAME,
	apt.PRICE AS BASE_TYPE_COST,
	NVL(SUM(
    	CASE
        	WHEN ap.IS_CLICKED = 1 THEN 0.0075
        	WHEN ap.IS_CLICKED = 0 THEN 0.0025
        	ELSE 0
    	END
	), 0) +
	NVL((SELECT 0.0075 * am.TOTAL_CLICKS + 0.0025 * am.TOTAL_VIEWS FROM AD_METRICS am WHERE am.AD_ID = a.AD_ID), 0) AS ADDITIONAL_REV,
	apt.PRICE +
	NVL(SUM(
    	CASE
        	WHEN ap.IS_CLICKED = 1 THEN 0.0075
        	WHEN ap.IS_CLICKED = 0 THEN 0.0025
        	ELSE 0
    	END
	), 0) +
	NVL((SELECT 0.0075 * am.TOTAL_CLICKS + 0.0025 * am.TOTAL_VIEWS FROM AD_METRICS am WHERE am.AD_ID = a.AD_ID), 0) AS TOTAL_REV
FROM
	ADS a
	JOIN AD_PRICING_TYPES apt ON a.AD_TYPE_ID = apt.TYPE_ID
	LEFT JOIN AD_PLACEMENTS ap ON a.AD_ID = ap.AD_ID
GROUP BY
	a.AD_ID, apt.TYPE_NAME, apt.PRICE
ORDER BY
	a.AD_ID
;

-- Create a table to store total revenue
CREATE TABLE TOTALS (
	TOTAL_REVENUE_SUM NUMBER,
	TOTALY_ROYALTY_PAYMENTS NUMBER,
	TOTAL_PROFIT NUMBER
);

-- Insert the calculated total revenue into the table
INSERT INTO TOTALS (TOTAL_REVENUE_SUM)
SELECT
	SUM(
    	apt.PRICE +
    	NVL((SELECT SUM(
        	CASE
            	WHEN ap.IS_CLICKED = 1 THEN 0.0075
            	WHEN ap.IS_CLICKED = 0 THEN 0.0025
            	ELSE 0
        	END
    	) FROM AD_PLACEMENTS ap WHERE ap.AD_ID = a.AD_ID), 0) +
    	NVL((SELECT 0.0075 * am.TOTAL_CLICKS + 0.0025 * am.TOTAL_VIEWS FROM AD_METRICS am WHERE am.AD_ID = a.AD_ID), 0)
	) AS TOTAL_REVENUE_SUM
FROM
	ADS a
	JOIN AD_PRICING_TYPES apt ON a.AD_TYPE_ID = apt.TYPE_ID;

	-- Update ROYALTY_PAYMENTS.AMOUNT with calculated revenue shares

	-- For label payments (ARTIST_ID IS NULL)
	UPDATE ROYALTY_PAYMENTS rp
	SET AMOUNT = (
    	SELECT
        	(
            	-- Calculate total revenue sum
            	(
                	SELECT
                    	SUM(
                        	apt.PRICE +
                        	NVL((SELECT SUM(
                            	CASE
                                	WHEN ap.IS_CLICKED = 1 THEN 0.0075
                                	WHEN ap.IS_CLICKED = 0 THEN 0.0025
                                	ELSE 0
                            	END
                        	) FROM AD_PLACEMENTS ap WHERE ap.AD_ID = a.AD_ID), 0) +
                        	NVL((SELECT 0.0075 * am.TOTAL_CLICKS + 0.0025 * am.TOTAL_VIEWS FROM AD_METRICS am WHERE am.AD_ID = a.AD_ID), 0)
                    	)
                	FROM
                    	ADS a
                    	JOIN AD_PRICING_TYPES apt ON a.AD_TYPE_ID = apt.TYPE_ID
            	)
            	*
            	-- Multiply by label royalty percentage
            	(l.LABEL_ROYALTY / 100)
        	)
    	FROM LABELS l
    	WHERE l.LABEL_ID = rp.LABEL_ID
	)
	WHERE rp.ARTIST_ID IS NULL AND rp.LABEL_ID IS NOT NULL;

	-- For artist payments (LABEL_ID IS NULL)
	UPDATE ROYALTY_PAYMENTS rp
	SET AMOUNT = (
    	SELECT
        	(
            	-- Calculate total revenue sum
            	(
                	SELECT
                    	SUM(
                        	apt.PRICE +
                        	NVL((SELECT SUM(
                            	CASE
                                	WHEN ap.IS_CLICKED = 1 THEN 0.0075
                                	WHEN ap.IS_CLICKED = 0 THEN 0.0025
                                	ELSE 0
                            	END
                        	) FROM AD_PLACEMENTS ap WHERE ap.AD_ID = a.AD_ID), 0) +
                        	NVL((SELECT 0.0075 * am.TOTAL_CLICKS + 0.0025 * am.TOTAL_VIEWS FROM AD_METRICS am WHERE am.AD_ID = a.AD_ID), 0)
                    	)
                	FROM
                    	ADS a
                    	JOIN AD_PRICING_TYPES apt ON a.AD_TYPE_ID = apt.TYPE_ID
            	)
            	*
            	-- Multiply by artist royalty (use average or fixed, here using 0.01 as example)
            	NVL((
                	SELECT AVG(RATE_AMOUNT)
                	FROM ROYALTY_RATES rr
                	WHERE rr.ARTIST_ID = rp.ARTIST_ID
            	), 0.01)
        	)
    	FROM DUAL
	)
	WHERE rp.LABEL_ID IS NULL AND rp.ARTIST_ID IS NOT NULL;

COMMIT;
-- Sum of all royalty payments and update TOTALS table
UPDATE TOTALS
SET TOTALY_ROYALTY_PAYMENTS = (
	SELECT SUM(AMOUNT) FROM ROYALTY_PAYMENTS
)
WHERE TOTALY_ROYALTY_PAYMENTS IS NULL OR TOTALY_ROYALTY_PAYMENTS <> (
	SELECT SUM(AMOUNT) FROM ROYALTY_PAYMENTS
);
-- Calculate and update TOTAL_PROFIT as TOTAL_REVENUE_SUM - TOTALY_ROYALTY_PAYMENTS
UPDATE TOTALS
SET TOTAL_PROFIT = TOTAL_REVENUE_SUM - TOTALY_ROYALTY_PAYMENTS;
COMMIT;


SELECT 
    table_name,
    column_name,
    data_type,
    data_length
FROM 
    user_tab_columns
ORDER BY 
    table_name, column_id;






-- Song, Artist, Ad performance Analysis

--1.
-- Tracks how each song performs in terms of completion rate, interaction, and monetizable ad opportunities
SELECT
    s.SONG_ID,
    s.TITLE,
    COUNT(ph.PLAY_ID) AS TOTAL_PLAYS,
    CONCAT(ROUND(AVG(ph.DURATION_PLAYED * 100.0 / NULLIF(s.DURATION, 0)), 2), '%') AS COMPLETION_RATE_DISPLAY,
    COUNT(DISTINCT c.COMMENT_ID) AS TOTAL_COMMENTS,
    COUNT(DISTINCT ap.PLACEMENT_ID) AS TOTAL_AD_PLACEMENTS
FROM
    SONGS s
LEFT JOIN PLAY_HISTORY ph ON s.SONG_ID = ph.SONG_ID
LEFT JOIN COMMENTS c ON s.SONG_ID = c.SONG_ID
LEFT JOIN AD_PLACEMENTS ap ON s.SONG_ID = ap.SONG_ID
GROUP BY s.SONG_ID, s.TITLE, s.DURATION
ORDER BY TOTAL_PLAYS DESC;

--2.
-- Detects which songs enhance ad interaction via embedded placements
SELECT
    s.SONG_ID,
    s.TITLE,
    COALESCE(COUNT(ap.SONG_ID), 0) AS TOTAL_ADS_PLAYED,
    COALESCE(SUM(CASE WHEN ap.IS_CLICKED = 1 THEN 1 ELSE 0 END), 0) AS TOTAL_CLICKS,
    ROUND(
        COALESCE(SUM(CASE WHEN ap.IS_CLICKED = 1 THEN 1 ELSE 0 END), 0) * 1.0 /
        NULLIF(COUNT(ap.SONG_ID), 0), 3
    ) AS SONG_AD_CTR
FROM SONGS s
LEFT JOIN AD_PLACEMENTS ap ON ap.SONG_ID = s.SONG_ID
GROUP BY s.SONG_ID, s.TITLE
ORDER BY SONG_AD_CTR DESC;

--3.
-- Evaluates artist impact through total song plays and royalty earnings
-- Revised Artist Royalty Query: Includes artist + label payments
WITH artist_direct_payments AS (
    SELECT ARTIST_ID, SUM(AMOUNT) AS DIRECT_AMOUNT
    FROM ROYALTY_PAYMENTS
    WHERE LABEL_ID IS NULL
    GROUP BY ARTIST_ID
),
label_payments AS (
    SELECT ac.ARTIST_ID, SUM(rp.AMOUNT) AS LABEL_AMOUNT
    FROM ROYALTY_PAYMENTS rp
    JOIN ARTIST_CONTRACTS ac ON rp.LABEL_ID = ac.LABEL_ID
    WHERE rp.ARTIST_ID IS NULL
    GROUP BY ac.ARTIST_ID
)

SELECT
    a.ARTIST_ID,
    a.NAME AS ARTIST_NAME,
    COUNT(DISTINCT sa.SONG_ID) AS TOTAL_SONGS,
    COUNT(ph.PLAY_ID) AS TOTAL_PLAYS,
    ROUND((NVL(adp.DIRECT_AMOUNT, 0) + NVL(lp.LABEL_AMOUNT, 0)) / NULLIF(COUNT(DISTINCT sa.SONG_ID), 0), 2) AS ROYALTY_PER_SONG,
    ROUND((NVL(adp.DIRECT_AMOUNT, 0) + NVL(lp.LABEL_AMOUNT, 0)) / NULLIF(COUNT(ph.PLAY_ID), 0), 4) AS CALCULATED_ROYALTY_PER_PLAY
FROM ARTISTS a
JOIN SONG_ARTISTS sa ON a.ARTIST_ID = sa.ARTIST_ID
LEFT JOIN PLAY_HISTORY ph ON sa.SONG_ID = ph.SONG_ID
LEFT JOIN artist_direct_payments adp ON a.ARTIST_ID = adp.ARTIST_ID
LEFT JOIN label_payments lp ON a.ARTIST_ID = lp.ARTIST_ID
GROUP BY a.ARTIST_ID, a.NAME, adp.DIRECT_AMOUNT, lp.LABEL_AMOUNT
ORDER BY CALCULATED_ROYALTY_PER_PLAY DESC;  -- Fixed: Changed ROYALTY_PER_PLAY to CALCULATED_ROYALTY_PER_PLAY

--3
--compare artists by LOCATION
------------------------------------------------------------
-- Artist-level ad revenue performance grouped by LOCATION
-- Supports comparing geographic monetization effectiveness
------------------------------------------------------------
WITH artist_direct_payments AS (
    SELECT ARTIST_ID, SUM(AMOUNT) AS DIRECT_AMOUNT
    FROM ROYALTY_PAYMENTS
    WHERE LABEL_ID IS NULL
    GROUP BY ARTIST_ID
),
label_payments AS (
    SELECT ac.ARTIST_ID, SUM(rp.AMOUNT) AS LABEL_AMOUNT
    FROM ROYALTY_PAYMENTS rp
    JOIN ARTIST_CONTRACTS ac ON rp.LABEL_ID = ac.LABEL_ID
    WHERE rp.ARTIST_ID IS NULL
    GROUP BY ac.ARTIST_ID
)

SELECT 
    ar.LOCATION,
    ar.ARTIST_ID,
    ar.NAME AS ARTIST_NAME,
    COUNT(DISTINCT sa.SONG_ID) AS TOTAL_SONGS,
    COUNT(ph.PLAY_ID) AS TOTAL_PLAYS,
    ROUND((NVL(adp.DIRECT_AMOUNT, 0) + NVL(lp.LABEL_AMOUNT, 0)) / NULLIF(COUNT(DISTINCT sa.SONG_ID), 0), 2) AS ROYALTY_PER_SONG,
    ROUND((NVL(adp.DIRECT_AMOUNT, 0) + NVL(lp.LABEL_AMOUNT, 0)) / NULLIF(COUNT(ph.PLAY_ID), 0), 4) AS CALCULATED_ROYALTY_PER_PLAY
FROM 
    ARTISTS ar
JOIN SONG_ARTISTS sa ON ar.ARTIST_ID = sa.ARTIST_ID
LEFT JOIN PLAY_HISTORY ph ON sa.SONG_ID = ph.SONG_ID
LEFT JOIN artist_direct_payments adp ON ar.ARTIST_ID = adp.ARTIST_ID
LEFT JOIN label_payments lp ON ar.ARTIST_ID = lp.ARTIST_ID
GROUP BY ar.LOCATION, ar.ARTIST_ID, ar.NAME, adp.DIRECT_AMOUNT, lp.LABEL_AMOUNT
ORDER BY CALCULATED_ROYALTY_PER_PLAY DESC;  -- Fixed: Changed to CALCULATED_ROYALTY_PER_PLAY

--4.
------------------------------------------------------------
-- Calculates engagement and profitability by ad type
-- Includes base price, click/view-based revenue, and CTR
------------------------------------------------------------

WITH ad_revenue_per_ad AS (
    SELECT
        a.AD_ID,
        a.AD_TYPE_ID,
        apt.TYPE_NAME,
        apt.PRICE AS BASE_PRICE,
        NVL(am.TOTAL_CLICKS, 0) AS METRIC_CLICKS,
        NVL(am.TOTAL_VIEWS, 0) AS METRIC_VIEWS,
        -- Revenue from metrics
        (0.0075 * NVL(am.TOTAL_CLICKS, 0) + 0.0025 * NVL(am.TOTAL_VIEWS, 0)) AS METRIC_REVENUE,
        -- Revenue from placements (click/impression-based payout)
        NVL((
            SELECT SUM(
                CASE 
                    WHEN ap.IS_CLICKED = 1 THEN 0.0075
                    WHEN ap.IS_CLICKED = 0 THEN 0.0025
                    ELSE 0
                END)
            FROM AD_PLACEMENTS ap
            WHERE ap.AD_ID = a.AD_ID
        ), 0) AS PLACEMENT_REVENUE,
        -- Total revenue
        (
            apt.PRICE +
            0.0075 * NVL(am.TOTAL_CLICKS, 0) +
            0.0025 * NVL(am.TOTAL_VIEWS, 0) +
            NVL((
                SELECT SUM(
                    CASE 
                        WHEN ap.IS_CLICKED = 1 THEN 0.0075
                        WHEN ap.IS_CLICKED = 0 THEN 0.0025
                        ELSE 0
                    END)
                FROM AD_PLACEMENTS ap
                WHERE ap.AD_ID = a.AD_ID
            ), 0)
        ) AS TOTAL_REVENUE
    FROM ADS a
    JOIN AD_PRICING_TYPES apt ON a.AD_TYPE_ID = apt.TYPE_ID
    LEFT JOIN AD_METRICS am ON a.AD_ID = am.AD_ID
)

-- Final aggregation by ad type
SELECT 
    TYPE_NAME,
    COUNT(AD_ID) AS NUM_ADS,
    SUM(METRIC_CLICKS) AS TOTAL_CLICKS,
    SUM(METRIC_VIEWS) AS TOTAL_VIEWS,
    ROUND(SUM(METRIC_CLICKS * 1.0) / NULLIF(SUM(METRIC_VIEWS), 0), 4) AS AVG_CTR,
    ROUND(SUM(BASE_PRICE), 2) AS TOTAL_BASE_COST,
    ROUND(SUM(METRIC_REVENUE), 2) AS TOTAL_METRIC_REVENUE,
    ROUND(SUM(PLACEMENT_REVENUE), 2) AS TOTAL_PLACEMENT_REVENUE,
    ROUND(SUM(TOTAL_REVENUE), 2) AS TOTAL_REVENUE_TYPE
FROM ad_revenue_per_ad
GROUP BY TYPE_NAME
ORDER BY TOTAL_REVENUE_TYPE DESC;