--					Select the data that we are going to be using

--				Price Trends

--			Analyzing price changes over time

SELECT yearOfRegistration, ROUND(AVG(CAST(price AS FLOAT)), 2) AS averagePrice
FROM vehicles
GROUP BY yearOfRegistration
ORDER BY yearOfRegistration;


--			Identifying market trends by average prices over the years or specific brand/model combination

SELECT yearOfRegistration,
		brand,
		model,
		AVG(CAST(price AS FLOAT)) AS averagePrice
FROM vehicles
GROUP BY yearOfRegistration,brand,model
ORDER BY yearOfRegistration,brand,model


--				Car Condition and Price Relation

--			Examining the prices of damaged vehicles and determining the differences between the prices of damaged and undamaged vehicles

SELECT
    notRepairedDamage,
    AVG(CAST(price AS FLOAT)) AS averagePrice
FROM
    vehicles
GROUP BY
    notRepairedDamage;


--				Kilometers and Age Relation

--			Return the average mileage values of vehicles according to their registration years

SELECT
    yearOfRegistration,
    AVG(CAST(kilometer as float)) AS averageKilometer
FROM
    vehicles
GROUP BY
    yearOfRegistration
ORDER BY
    yearOfRegistration;


--				Vehicle Distribution and Market Size

--			Grouping according to the cities where the vehicles are located and counted the number of vehicles in each city

SELECT
    Location,
    COUNT(*) AS VehicleCount
FROM
    vehicles
GROUP BY
    Location
ORDER BY
    VehicleCount DESC

--				Relationship between Power and Fuel Consumption

--			Bring average prices of vehicles grouped by power and fuel types

SELECT
    powerPS,
    fuelType,
    AVG(CAST(price AS FLOAT)) AS averagePrice
FROM
    vehicles
GROUP BY
    powerPS, fuelType
ORDER BY
    powerPS, fuelType;


--				Relationship between Date, Advertisement was Published and the Demand

--			Group the dates when ads were published and determine that there is more demand on certain days or months

SELECT
    CONVERT(date, dateCreated_f) AS PublicationDate,
    COUNT(*) AS AdCount
FROM
    vehicles
GROUP BY
    CONVERT(date, dateCreated_f)
ORDER BY
    PublicationDate


--				Comparing prices of vehicles with manual and automatic transmission

--			Bring the average prices of vehicles grouped according to their transmission types

SELECT
    gearbox,
    AVG(CAST(price AS FLOAT)) AS averagePrice
FROM
    vehicles
GROUP BY
    gearbox;

--				Seasonal Price Changes

--			Return average prices grouped by the months the vehicles were registered

SELECT
    monthOfRegistration,
    AVG(CAST(price AS FLOAT)) AS averagePrice
FROM
    vehicles
GROUP BY
    monthOfRegistration
ORDER BY
    monthOfRegistration


--				Damage Status and Sales Prices

--			Average sales prices of vehicles grouped according to their damage status

SELECT
    notRepairedDamage,
    AVG(CAST(price AS FLOAT)) AS averagePrice
FROM
    vehicles
GROUP BY
    notRepairedDamage
