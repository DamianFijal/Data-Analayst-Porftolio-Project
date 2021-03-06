-- Cleaning Data in SQL Queries

Select *
FROM NashvilleData

-------------------------------------------------------------

-- Standarize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
FROM NashvilleData

Update NashvilleData
SET SaleDate = CONVERT(Date,SaleDate)

-------------------------------------------------------------

-- Correct Date Format

ALTER TABLE NashvilleData
ADD SaleDateConverted DATE;

Update NashvilleData
SET SaleDateConverted = CONVERT(Date,SaleDate)


SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM NashvilleData

-------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM NashvilleData
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT *
FROM NashvilleData AS a
JOIN NashvilleData AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleData AS a
JOIN NashvilleData AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleData AS a
JOIN NashvilleData AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM NashvilleData


ALTER TABLE NashvilleData
ADD PropertySplitAddress NVARCHAR(255)

Update NashvilleData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleData
ADD PropertySplitCity NVARCHAR(255)

Update NashvilleData
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT * 
FROM NashvilleData

------------------------------------------------------------------------------

-- Property Owner Address

SELECT OwnerAddress
FROM NashvilleData


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleData


-- 3- Address
ALTER TABLE NashvilleData
ADD OwnerSplitAddress NVARCHAR(255)

Update NashvilleData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

-- 2 - City
ALTER TABLE NashvilleData
ADD OwnerSplitCity NVARCHAR(255)

Update NashvilleHousing..NashvilleData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-- 1 - State
ALTER TABLE NashvilleData
ADD OwnerSplitState NVARCHAR(255)

Update NashvilleHousing..NashvilleData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM NashvilleHousing..NashvilleData


-----------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" column

SELECT DISTINCT(SOldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing..NashvilleData
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From NashvilleHousing..NashvilleData


UPDATE NashvilleHousing..NashvilleData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


----------------------------------------------------------------------

-- Removing Duplicates

WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM NashvilleHousing..NashvilleData
--ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE NashvilleHousing..NashvilleData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT * 
FROM NashvilleHousing..NashvilleData
