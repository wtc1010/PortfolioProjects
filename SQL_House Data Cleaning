-- Housing Data Cleaning
-- Skills used: Converting Data Types, Joins, Locate&Substring function, Adding a column, CASE statement, Windows Functions

USE PORTFOLIO2;

SELECT *
FROM house;

-- standardize date format
SELECT SaleDate
FROM house;

UPDATE house 
SET SaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y');

SELECT SaleDate
FROM house;

-- populate property address data
SELECT *
FROM house
WHERE PropertyAddress = '' OR PropertyAddress IS NULL
ORDER BY parcelid;

SELECT a.parcelid, a.PropertyAddress, b.parcelid, b.PropertyAddress, COALESCE(NULLIF(a.PropertyAddress, ''),b.PropertyAddress) 
FROM house a
JOIN house b ON a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid
WHERE a.PropertyAddress = '';
        
UPDATE house a
JOIN house b ON a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid
SET a.PropertyAddress = COALESCE(NULLIF(a.PropertyAddress, ''), b.PropertyAddress)
WHERE a.PropertyAddress = '';
    
-- break out address into individual columns (address,city,state)
SELECT PropertyAddress
FROM house;

SELECT SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress)+1, LENGTH(PropertyAddress)) AS City
FROM house;

ALTER TABLE house
ADD PropertySplitAddress VARCHAR(255);

UPDATE house
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)-1);

ALTER TABLE house
ADD PropertySplitCity VARCHAR(255);

UPDATE house
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress)+1, LENGTH(PropertyAddress));

SELECT *
FROM house;



SELECT OwnerAddress
FROM house;

SELECT SUBSTRING_INDEX(OwnerAddress,',',1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',',-1),
SUBSTRING_INDEX(OwnerAddress,',',-1)
FROM house;



ALTER TABLE house
ADD OwnerSplitAddress VARCHAR(255);

UPDATE house
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress,',',1);

ALTER TABLE house
ADD OwnerSplitCity VARCHAR(255);

UPDATE house
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',',-1);

ALTER TABLE house
ADD OwnerSplitState VARCHAR(255);

UPDATE house
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress,',',-1);

SELECT *
FROM house;

-- change Y&N to Yes&No in 'SoldAsVacent' field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM house
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM house;

UPDATE house
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;
       

-- remove duplicates
SELECT *
FROM house hse INNER JOIN
(SELECT UniqueID ,ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, 
SalePrice,saledate,LegalReference ORDER BY UniqueID) AS rownum
FROM house) t1 
ON hse.UniqueID = t1.UniqueID 
WHERE t1.rownum>1;

DELETE hse
FROM house hse INNER JOIN
(select UniqueID ,ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, 
SalePrice,saledate,LegalReference ORDER BY UniqueID) AS rownum
FROM house) t1 
ON hse.UniqueID = t1.UniqueID 
WHERE t1.rownum>1;


-- delete unused columns
SELECT * 
FROM house;

ALTER TABLE house
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;







