--Cleaning Data in SQL Queries 

SELECT *
FROM Porfolio.dbo.NashvilleHousing

---------------------------------------------------------------------

--Standardize Date Format

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM Porfolio.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


---------------------------------------------------------------------

--Populate Property Address data

SELECT *
FROM Porfolio.dbo.NashvilleHousing
ORDER BY ParcelID


SELECT a.ParcelId, a.PropertyAddress, b.ParcelId, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Porfolio.dbo.NashvilleHousing a
JOIN Porfolio.dbo.NashvilleHousing b
	ON a.ParcelId = b.ParcelId
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Porfolio.dbo.NashvilleHousing a
JOIN Porfolio.dbo.NashvilleHousing b
	ON a.ParcelId = b.ParcelId
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


---------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Porfolio.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID


SELECT (PropertyAddress),
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress )-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress )+1, LEN(PropertyAddress)) as City
FROM Porfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress )-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress )+1, LEN(PropertyAddress))




SELECT OwnerAddress
FROM Porfolio.dbo.NashvilleHousing

SELECT OwnerAddress,
	PARSENAME(REPLACE(Owneraddress, ',', '.'), 3) as OwnerSplitAddress, 
	PARSENAME(REPLACE(Owneraddress, ',', '.'), 2) as OwnerSplitCity,
	PARSENAME(REPLACE(Owneraddress, ',', '.'), 1) as OwnerSplitState
FROM Porfolio.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(Owneraddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)

SELECT *
FROM Porfolio.dbo.NashvilleHousing


---------------------------------------------------------------------

--Change Y and N in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant) 
FROM Porfolio.dbo.NashvilleHousing

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'N'	THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant END
FROM Porfolio.dbo.NashvilleHousing;


UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'N'	THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant END

---------------------------------------------------------------------

--Remove duplicates

WITH Row_NumCTE as( 
SELECT *, 
	ROW_NUMBER()
	OVER(PARTITION BY
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID
		) as Row_Num 
FROM Porfolio.dbo.NashvilleHousing)

DELETE
FROM Row_NumCTE
WHERE Row_num > 1

SELECT *
FROM Porfolio.dbo.NashvilleHousing

---------------------------------------------------------------------

--Delete Unsed Columns

SELECT *
FROM Porfolio.dbo.NashvilleHousing

ALTER TABLE Porfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate

			
---------------------------------------------------------------------








