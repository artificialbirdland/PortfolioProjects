--				Cleaning Data in SQL Queries

select * from dbo.NashVilleHousing

--				Standardize Date Format

select SaleDate, Convert(date,SaleDate) from dbo.NashVilleHousing

update NashVilleHousing
set SaleDate = Convert(date,SaleDate)


--				Populate Property Address Data

select * from dbo.NashVilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.NashVilleHousing a
join dbo.NashVilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID 
Where a.PropertyAddress is null 

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.NashVilleHousing a
join dbo.NashVilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID 
	Where a.PropertyAddress is null

--				Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress 
from dbo.NashVilleHousing
--where PropertyAddress is null
--order by ParcelID

SELECT
    SUBSTRING(PropertyAddress, 1, ISNULL(NULLIF(CHARINDEX(',', PropertyAddress), 0), LEN(PropertyAddress) + 1) - 1) AS Address,
    SUBSTRING(PropertyAddress, ISNULL(NULLIF(CHARINDEX(',', PropertyAddress), 0), LEN(PropertyAddress)) + 1, LEN(PropertyAddress)) AS Address
FROM dbo.NashVilleHousing;

ALTER TABLE NashVilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashVilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, ISNULL(NULLIF(CHARINDEX(',', PropertyAddress), 0), LEN(PropertyAddress) + 1) - 1)

ALTER TABLE NashVilleHousing
Add PropertySplitCity nvarchar(255);

Update NashVilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, ISNULL(NULLIF(CHARINDEX(',', PropertyAddress), 0), LEN(PropertyAddress)) + 1, LEN(PropertyAddress))



--			Easier Way to do
SELECT
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
from dbo.NashVilleHousing

ALTER TABLE NashVilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashVilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER TABLE NashVilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashVilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE NashVilleHousing
Add OwnerSplitState nvarchar(255);

Update NashVilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

--				Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM dbo.NashVilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
,CASE when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		End
from dbo.NashVilleHousing

Update NashVilleHousing
Set	SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
						when SoldAsVacant = 'N' Then 'No'
						ELSE SoldAsVacant
						End

--				Remove Duplicates


WITH RowNumCTE AS 
(
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM dbo.NashVilleHousing
    -- ORDER BY ParcelID
)
Select * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

--				Delete Unusual Columns


select *
from dbo.NashVilleHousing

ALTER TABLE dbo.NashVilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE dbo.NashVilleHousing
Drop Column SaleDate
