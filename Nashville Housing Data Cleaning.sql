SELECT *
FROM [Nashville Housing Data for Data Cleaning]


--Standardized Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [Nashville Housing Data for Data Cleaning]

UPDATE [Nashville Housing Data for Data Cleaning]
SET SaleDate = CONVERT(Date, SaleDate)



--Populating Property Address data

SELECT *
FROM [Nashville Housing Data for Data Cleaning]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing Data for Data Cleaning] a
JOIN [Nashville Housing Data for Data Cleaning] b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing Data for Data Cleaning] a
JOIN [Nashville Housing Data for Data Cleaning] b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL




--Breaking out Property Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM [Nashville Housing Data for Data Cleaning]


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address,
CHARINDEX(',', PropertyAddress)
FROM [Nashville Housing Data for Data Cleaning]


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
CHARINDEX(',', PropertyAddress)
FROM [Nashville Housing Data for Data Cleaning]


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) AS City
FROM [Nashville Housing Data for Data Cleaning]

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD PropertySplitAddress NVARCHAR(255)

UPDATE [Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD PropertySplitCITY NVARCHAR(255)

UPDATE [Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))

SELECT *
FROM [Nashville Housing Data for Data Cleaning]




--Breaking out Owner Address into Individual Columns (Address, City, State)

SELECT OwnerAddress
FROM [Nashville Housing Data for Data Cleaning]

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Nashville Housing Data for Data Cleaning]


ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD [Owner Split Address] NVARCHAR(255)

UPDATE [Nashville Housing Data for Data Cleaning]
SET [Owner Split Address] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD [Owner Split City] NVARCHAR(255)

UPDATE [Nashville Housing Data for Data Cleaning]
SET [Owner Split City] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD [Owner Split State] NVARCHAR(255)

UPDATE [Nashville Housing Data for Data Cleaning]
SET [Owner Split State] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM [Nashville Housing Data for Data Cleaning]



--Changing Y to Yes and N to No in "Sold as Vacant" column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville Housing Data for Data Cleaning]
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM [Nashville Housing Data for Data Cleaning]


UPDATE [Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END




--Removing Duplicates

WITH RowNumCTE AS(
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

FROM [Nashville Housing Data for Data Cleaning]
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1

SELECT *
FROM [Nashville Housing Data for Data Cleaning]





--Deleting Unused Columns like OwnerAddress, TaxDistrict

SELECT *
FROM [Nashville Housing Data for Data Cleaning]

ALTER TABLE [Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress