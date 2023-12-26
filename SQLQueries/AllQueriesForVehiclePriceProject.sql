--				Cleaning the Data in SQL Queries

select * from dbo.AustralianVehiclePrices

--				Breaking out Address into Individual Columns (Suburb, State)

SELECT
PARSENAME(Replace(Location,',','.'),1)
,PARSENAME(Replace(Location,',','.'),2)
from dbo.AustralianVehiclePrices

ALTER TABLE AustralianVehiclePrices
Add State nvarchar(255);

Update AustralianVehiclePrices
Set State = PARSENAME(Replace(Location,',','.'),1)

ALTER TABLE AustralianVehiclePrices
Add Suburb nvarchar(255);

Update AustralianVehiclePrices
Set Suburb = PARSENAME(Replace(Location,',','.'),2)

ALTER TABLE AustralianVehiclePrices
Drop Column ExteriorColor

--				Breaking out ColourExtInt into Individual Columns (ExteriorColor, InteriorColor)

SELECT
PARSENAME(Replace(ColourExtInt,'/','.'),2)
,PARSENAME(Replace(ColourExtInt,'/','.'),1)
from dbo.AustralianVehiclePrices

ALTER TABLE AustralianVehiclePrices
Add ExteriorColor nvarchar(255);

Update AustralianVehiclePrices
Set ExteriorColor = PARSENAME(Replace(ColourExtInt,'/','.'),2)

ALTER TABLE AustralianVehiclePrices
Add InteriorColor nvarchar(255);

Update AustralianVehiclePrices
Set InteriorColor = PARSENAME(Replace(ColourExtInt,'/','.'),1)

--				Changing the FuelConsumption column to the FuelConsumption_100km(L)
--				That means all the data now will show as numbers under FuelConsumption_100km column for example (8.7) liter.


-- First we change all the dots with commas

ALTER TABLE AustralianVehiclePrices
Add pointandcommachanged nvarchar(255);

UPDATE AustralianVehiclePrices
SET pointandcommachanged = REPLACE(FuelConsumption, '.', ',');

-- And then Creating new column and adding the data without (/100km)

ALTER TABLE AustralianVehiclePrices
Add FuelConsumption_100km_L nvarchar(255);

Update AustralianVehiclePrices
Set FuelConsumption_100km_L = PARSENAME(Replace(pointandcommachanged,'/','.'),2)

-- And then deleting the letter 'L'

UPDATE AustralianVehiclePrices
SET FuelConsumption_100km_L = REPLACE(FuelConsumption_100km_L, ' L', '');

-- Removing the unusual column

ALTER TABLE AustralianVehiclePrices
Drop Column pointandcommachanged



--				Checking out if there are any duplicates

WITH RowNumCTE AS 
(
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Title,
			   Kilometres,
			   Price,
			   Transmission,
			   Price,
			   Suburb,
			   State,
			   Car_Suv
               ORDER BY Title
           ) AS row_num
    FROM dbo.AustralianVehiclePrices
)
Select * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY Title;

-- There aren't any duplicates




--				Delete Unusual Columns

ALTER TABLE AustralianVehiclePrices
Drop Column ColourExtInt,Location


--					Lets Write Queries to Order the Data

--				Brand Based Sales Statistics

--			Total sales number of each brand

SELECT Brand,
		SUM(Price) as TotalPrice
FROM AustralianVehiclePrices
Where Price is not null
Group By Brand

--			Identifying the most popular brands and examine which models of these brands are generally preferred

SELECT Brand,
		Model,
		Count(*) as NumberOfSales
FROM AustralianVehiclePrices
Group By Brand, Model
Order By NumberOfSales Desc

--			Making comparisons based on fuel types used, gear types and other features on a brand basis

SELECT Brand,
		FuelType,
		Transmission,
		DriveType,
		COUNT(*) as NumberOfSales
FROM AustralianVehiclePrices
WHERE FuelType IS NOT NULL AND Transmission IS NOT NULL AND DriveType IS NOT NULL
Group By Brand, FuelType, Transmission, DriveType
Order By Brand, NumberOfSales DESC

--				Year Based Trend Analysis
--			Observing how the total number of sales and average price change on a yearly basis

SELECT Year,
		COUNT(*) as TotalNumberOfSales,
		AVG(Price) as AveragePrice
FROM AustralianVehiclePrices
Where Year is not null
Group By Year
Order By Year


--			Evaluating year-by-year trends in fuel types and gear types used.

SELECT Year,
	COUNT(FuelType) as FuelTypeCount,
	FuelType,
	COUNT(Transmission) as TransmissionTypeCount,
	Transmission
FROM AustralianVehiclePrices
WHERE Year is not null and FuelType is not null and Transmission is not null
GROUP BY Year,FuelType,Transmission
ORDER BY Year,FuelType,Transmission

--				Fuel Consumption and Kilometer Analysis

--			Analyzing average fuel consumption by fuel types

SELECT
    FuelType,
    AVG(TRY_CAST(FuelConsumption_100km_L AS FLOAT)) AS AverageFuelConsumption
FROM
    AustralianVehiclePrices
WHERE
    FuelType IS NOT NULL AND
    FuelConsumption_100km_L IS NOT NULL AND
	FuelType <> 'Other'
GROUP BY
    FuelType
ORDER BY
    AverageFuelConsumption;


--			Evaluating the relationship between the prices of low-mileage vehicles 
--			and the prices of high-mileage vehicles by examining prices per kilometer.

WITH VehiclePricesWithKilometers AS (
    SELECT
        *,
        CASE
            WHEN Kilometres > 0 THEN Price / Kilometres
            ELSE NULL
        END AS PricePerKilometer
    FROM
        AustralianVehiclePrices
    WHERE
        Kilometres IS NOT NULL AND
        Price IS NOT NULL
)
SELECT
    PricePerKilometer,
    AVG(Price) AS AveragePrice
FROM
    VehiclePricesWithKilometers
GROUP BY
    PricePerKilometer
ORDER BY
    PricePerKilometer;

--			Evaluating the correlation between fuel types and price per kilometer.

SELECT
    FuelType,
    AVG(PricePerKilometer) AS AveragePricePerKilometer
FROM (
    SELECT
        FuelType,
        CASE
            WHEN Kilometres > 0 THEN Price / Kilometres
            ELSE NULL
        END AS PricePerKilometer
    FROM
        AustralianVehiclePrices
    WHERE
		FuelType IS NOT NULL AND
        Kilometres IS NOT NULL AND
        Price IS NOT NULL
) AS VehiclesWithPricePerKilometer
GROUP BY
    FuelType
ORDER BY
    AveragePricePerKilometer DESC; 


