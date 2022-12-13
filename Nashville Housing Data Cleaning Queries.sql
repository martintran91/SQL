# Cleaning Data in SQL Queries

SELECT * 
FROM nashville.nashvillehousing;

---------------------------------------------------------------------------------------

#Standardize Date Format

SELECT
	SaleDate, 
    CONVERT(SaleDate, Date)
FROM
	nashville.nashvillehousing;

ALTER TABLE nashvillehousing
MODIFY SaleDate Date;

ALTER TABLE nashvillehousing
MODIFY SaleDate Date;

---------------------------------------------------------------------------------------

#Populate Property Address Data

SELECT *
FROM nashvillehousing
# WHERE PropertyAddress = '';
ORDER BY ParcelID;

UPDATE nashvillehousing 
SET PropertyAddress = NULL WHERE PropertyAddress = '';

SELECT a.parcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress, b.PropertyAddress)
FROM nashvillehousing a
JOIN nashvillehousing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE nashvillehousing
JOIN nashvillehousing b
	ON nashvillehousing.ParcelID = b.ParcelID
    AND nashvillehousing.UniqueID <> b.UniqueID
SET nashvillehousing.PropertyAddress = ifnull(nashvillehousing.PropertyAddress, b.PropertyAddress)
WHERE nashvillehousing.PropertyAddress IS NULL;

---------------------------------------------------------------------------------------

#Breaking out Address into Individual Columns

SELECT PropertyAddress
FROM nashvillehousing;

SELECT
	SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress)) AS City
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

ALTER TABLE nashvillehousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress));


SELECT *
FROM nashvillehousing;


SELECT OwnerAddress
FROM nashvillehousing;


#Creating a functing to split address using delimiter (similar to PARSENAME function in MSSQL)

SET GLOBAL log_bin_trust_function_creators = 1;

CREATE FUNCTION SPLIT_STR(
  x VARCHAR(255),
  delim VARCHAR(12),
  pos INT
)
RETURNS VARCHAR(255)
RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),
       CHAR_LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),
       delim, '');

SET GLOBAL log_bin_trust_function_creators = 0;


#Now split the address

SELECT 
	SPLIT_STR(OwnerAddress, ",", 1) AS Address,
    SPLIT_STR(OwnerAddress, ",", 2) AS City,
    SPLIT_STR(OwnerAddress, ",", 3) AS State
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = SPLIT_STR(OwnerAddress, ",", 1);

ALTER TABLE nashvillehousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitCity = SPLIT_STR(OwnerAddress, ",", 2);

ALTER TABLE nashvillehousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitState = SPLIT_STR(OwnerAddress, ",", 3);

SELECT *
FROM nashvillehousing;


---------------------------------------------------------------------------------------

#Change Y and N to Yes and No in "Sold as Vacant" field

SELECT 
	DISTINCT(SoldAsVacant), 
    COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant
ORDER BY Count(SoldAsVacant);

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM nashvillehousing;

UPDATE nashvillehousing
SET SoldAsVacant = 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END;


---------------------------------------------------------------------------------------


#Remove Duplicates (Not typically done to raw data)

WITH RowNumCTE AS 
(
SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress,SalePrice,SaleDate, LegalReference
		ORDER BY UniqueID) row_num
FROM nashvillehousing
ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) row_num
FROM nashvillehousing;

SELECT *
FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) row_num
FROM nashvillehousing) AS t
WHERE row_num > 1;

DELETE FROM nashvillehousing
WHERE UniqueID IN
(
SELECT UniqueID
FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM nashvillehousing) AS t
WHERE row_num > 1
);

#SELECT * FROM nashvillehousing;


---------------------------------------------------------------------------------------


#Delete Unused Columns (Not typically done to raw data)

SELECT * FROM nashvillehousing;

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress;
