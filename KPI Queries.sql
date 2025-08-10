--KPI Use Cases
-- How many times has each video been watched?
SELECT 
	dv.VideoName,
	COUNT(*)AS TotalViews 
FROM 
	FactVideoViewing fv
JOIN 
	DimVideo dv ON fv.VideoKey=dv.VideoKey
WHERE 
	VideoWatched=1
GROUP BY 
	VideoName
--What are the top 10 most-watched videos?
SELECT	
	Top(10) dv.VideoName,
	COUNT(*)AS TotalViews 
FROM 
	FactVideoViewing fv
JOIN 
	DimVideo dv ON fv.VideoKey=dv.VideoKey
WHERE 
	VideoWatched=1
GROUP BY 
	VideoName
ORDER BY 
	TotalViews DESC
-- what is the average rating for each video that was watched?
SELECT 
	dv.VideoName,
	AVG(dr.RatingValue) AS AverageRatingValue 
FROM 
	FactVideoViewing fv
JOIN 
	DimVideo dv ON fv.VideoKey=dv.VideoKey 
JOIN 
	DimRating dr ON fv.RatingKey=dr.RatingKey
WHERE 
	VideoWatched=1
GROUP BY 
	VideoName
ORDER BY 
	VideoName
-- Which videos had the trailer being watched without the full video being watched?
SELECT 
	dv.VideoName,
	dv.VideoID 
FROM 
	FactVideoViewing fv
JOIN 
	DimVideo dv ON fv.VideoKey=dv.VideoKey
WHERE 
	VideoWatched=0 AND TrailerWatched=1
GROUP BY 
	VideoName,VideoID
-- How many times has each video featuring Dwayne John been watched?
SELECT 
	dv.VideoName,
	dv.VideoID,
	COUNT(fv.VideoKey) AS TotalViews 
FROM 
	FactVideoViewing fv
JOIN 
	DimVideo dv ON fv.VideoKey=dv.VideoKey
JOIN 
	BridgevideoCast bv ON dv.VideoKey=bv.VideoKey
JOIN 
	DimCast dc ON bv.CastKey=dc.CastKey
WHERE 
	CastName='Dwayne John'
GROUP BY 
	VideoName, VideoID


--SELECT *FROM BridgevideoCast
-------- Trend of Video viewing since release date
SELECT 
	dv.VideoName,
	dv.VideoID,
	dd.ViewingDate,
	dv.ReleaseYear,
	DATEDIFF(DAY,dv.ReleaseYear,dd.ViewingDate) AS DaysSinceRelease,
	COUNT(fv.VideoKey) AS TotalViewsForDay
FROM 
	FactVideoViewing fv 
JOIN 
	DimVideo dv ON fv.VideoKey=dv.VideoKey 
JOIN 
	DimDate dd ON fv.DateKey=dd.DateKey
WHERE 
	VideoWatched=1 -----Count actual views only
AND 
	ReleaseYear IS NOT NULL-----Ensures release date exist
GROUP BY
	dv.VideoName,
	dv.VideoID,
	dd.ViewingDate,
	dv.ReleaseYear,
	DATEDIFF(DAY,dd.ViewingDate,dv.ReleaseYear)
----Grouping (Binning/Categories) users by age for video recommendation
SELECT 
	CASE
		WHEN DATEDIFF(YEAR,dc.DateOfBirth,GETDATE()) BETWEEN 0 AND 24 THEN '0-24'
		WHEN DATEDIFF(YEAR,dc.DateOfBirth,GETDATE()) BETWEEN 25 AND 34 THEN '25-34'
		WHEN DATEDIFF(YEAR,dc.DateOfBirth,GETDATE()) BETWEEN 35 AND 44 THEN '35-44'
		WHEN DATEDIFF(YEAR,dc.DateOfBirth,GETDATE()) BETWEEN 45 AND 54 THEN '45-54'
		ELSE '55+'
	END AS AgeGroup,
	COUNT(dc.CustomerKey) AS NumberOfCustomers

FROM
	DimCustomer dc
WHERE 
	DateOfBirth IS NOT NULL----Ensures that the date of birth exists.
GROUP BY 
	CASE
		WHEN DATEDIFF(YEAR,dc.DateOfBirth,GETDATE()) BETWEEN 0 AND 24 THEN '0-24' -----GetDATE() fetch the current date
		WHEN DATEDIFF(YEAR,dc.DateOfBirth,GETDATE()) BETWEEN 25 AND 34 THEN '25-34'
		WHEN DATEDIFF(YEAR,dc.DateOfBirth,GETDATE()) BETWEEN 35 AND 44 THEN '35-44'
		WHEN DATEDIFF(YEAR,dc.DateOfBirth,GETDATE()) BETWEEN 45 AND 54 THEN '45-54'
		ELSE '55+'
	END	
ORDER BY
	AgeGroup;
-----Use Common Table Expressions (CTEs) to avoid aliases syntax error and to separate transformations and aggregation
WITH c AS(
	SELECT 
		dc.CustomerKey,------------Keep the key for later join
		CASE
			WHEN DATEDIFF(YEAR,dc.DateOfBirth,GETDATE()) BETWEEN 0 AND 24 THEN '0-24'
			WHEN DATEDIFF(YEAR,dc.DateOfBirth,GETDATE()) BETWEEN 25 AND 34 THEN '25-34'
			WHEN DATEDIFF(YEAR,dc.DateOfBirth,GETDATE()) BETWEEN 35 AND 44 THEN '35-44'
			WHEN DATEDIFF(YEAR,dc.DateOfBirth,GETDATE()) BETWEEN 45 AND 54 THEN '45-54'
			ELSE '55+'
	END AS AgeGroup
	FROM
		DimCustomer dc
	WHERE dc.DateOfBirth IS NOT NULL)
----Transformation and aggregation
SELECT 
	AgeGroup,
	dv.VideoName,
	COUNT(fv.ViewingKey) AS TotalViewing,
	COUNT(*) AS NumberOfCustomers
FROM 
	c
JOIN
	FactVideoViewing fv ON fv.CustomerKey=c.CustomerKey

JOIN
	DimVideo dv ON fv.VideoKey=dv.VideoKey
WHERE fv.VideoWatched=1
GROUP BY
	c.AgeGroup,dv.VideoName
ORDER BY
	AgeGroup,dv.VideoName


		

