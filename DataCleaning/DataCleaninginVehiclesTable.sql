--				Cleaning Data in SQL Queries
SELECT *
FROM vehicles

--				Standardizing the Date columns 

-- Removing the unusued 0 part from rows and updating the informational data to new columns
ALTER TABLE vehicles
Add dateCrawled_f nvarchar(255);

Update vehicles
Set dateCrawled_f = LEFT(dateCrawled, 10)


ALTER TABLE vehicles
Add dateCreated_f nvarchar(255);

Update vehicles
Set dateCreated_f = LEFT(dateCreated, 10)

-- Seperating the lastSeen column to two columns to be able to analyse both date and time.

ALTER TABLE vehicles
Add lastSeen_Date nvarchar(255);

Update vehicles
Set lastSeen_Date = LEFT(lastSeen, 10)

ALTER TABLE vehicles
Add lastSeen_Time nvarchar(255);

Update vehicles
Set lastSeen_Time = SUBSTRING(CONVERT(VARCHAR(24), lastSeen, 121), 12, 8)

--		Removing the unusual columns
--	There is no different value then 0 in nrOfPictures column so we will delete it.

ALTER TABLE vehicles
DROP COLUMN DateCrawled,dateCreated,lastSeen,nrOfPictures


--				Change ja and nein to Yes and No in "notRepairedDamage" field

UPDATE vehicles
SET notRepairedDamage = CASE
    WHEN notRepairedDamage = 'ja' THEN 'Yes'
    WHEN notRepairedDamage = 'nein' THEN 'No'
    ELSE notRepairedDamage
END;

--				Change privat and gewerblich to Private and Dealer in "seller" field


UPDATE vehicles
SET seller = CASE
    WHEN seller = 'privat' THEN 'Private'
    WHEN seller = 'gewerblich' THEN 'Dealer'
    ELSE seller
END;


--				Change Angebot and Gesuch to Offer and Request in "offerType"

UPDATE vehicles
SET offerType = CASE
    WHEN offerType = 'Angebot' THEN 'Offer'
    WHEN offerType = 'Gesuch' THEN 'Request'
    ELSE offerType
END;

--				Remove Duplicates

--			Checking out if there are any duplicates

WITH RowNumCTE AS 
(
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY name,
							seller,
							offerType,
							price,
							abtest,
							vehicleType,
							yearOfRegistration,
							gearbox,
							powerPS,
							model,
							kilometer,
							monthOfRegistration,
							fuelType,
							brand,
							notRepairedDamage,
							nrOfPictures,
							PostalCode,
							dateCrawled_f,
							dateCreated_f,
							lastSeen_Date,
                            lastSeen_Time
               ORDER BY name
           ) AS row_num
    FROM dbo.vehicles
)
Select * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY name;

--			Deleting all the duplicates

WITH RowNumCTE AS 
(
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY name,
                            seller,
                            offerType,
                            price,
                            abtest,
                            vehicleType,
                            yearOfRegistration,
                            gearbox,
                            powerPS,
                            model,
                            kilometer,
                            monthOfRegistration,
                            fuelType,
                            brand,
                            notRepairedDamage,
                            nrOfPictures,
                            PostalCode,
                            dateCrawled_f,
                            dateCreated_f,
                            lastSeen_Date,
                            lastSeen_Time
               ORDER BY name
           ) AS row_num
    FROM dbo.vehicles
)
DELETE FROM RowNumCTE
WHERE row_num > 1;

--				Doing an Inner Join To show the locations with postal codes


SELECT v.*, g.Location
FROM vehicles v
INNER JOIN germanyzipcodes g 
ON v.postalCode = g.postalCode;

--			Copying the Location column from 'germanyzipcodes' table and pasting it to Location column in 'vehicles' table which we just created

ALTER TABLE vehicles
Add Location nvarchar(255);

UPDATE vehicles
SET Location = g.Location
FROM vehicles v
INNER JOIN germanyzipcodes g ON v.postalCode = g.postalCode;


--				Changing the value '0' with 'null' value because there is no 0'th month of a year

UPDATE vehicles
SET monthOfRegistration = NULL
WHERE monthOfRegistration = '0';


select * from vehicles