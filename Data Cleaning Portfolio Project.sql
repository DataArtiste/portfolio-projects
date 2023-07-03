/*
SQL Project
Skills used: 
JOIN, Substring & ParseName, CTE's, Temp Tables, Window Function, Aggregate Function, Views
*/


SELECT *
FROM NashvilleHousing

--------------------------------
/*
Standardize Date Format
*/

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--- confirm that SaleDateConverted is the same as SaleDate converted

SELECT saleDateConverted, CONVERT(Date,SaleDate)
FROM NashvilleHousing


 /*
Populate Property Address data where a ParcelID entry occurs more than once
and has an address associated with at least one ParcelID
*/

--------------------------------

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

--- self JOIN to identify missing PropertyAddress, matching ParcelID, and available PropertyAddress

SELECT tableA.ParcelID, tableA.PropertyAddress, tableB.ParcelID, tableB.PropertyAddress, ISNULL(tableA.PropertyAddress,tableB.PropertyAddress)
FROM NashvilleHousing AS tableA
JOIN NashvilleHousing AS tableB
	ON tableA.ParcelID = tableB.ParcelID
	AND tableA.[UniqueID ] <> tableB.[UniqueID ]
WHERE tableA.PropertyAddress IS NULL

--- UPDATE to use available PropertyAddress to populate missing PropertyAddress

UPDATE tableA
SET PropertyAddress = ISNULL(tableA.PropertyAddress,tableB.PropertyAddress)
FROM NashvilleHousing AS tableA
JOIN NashvilleHousing AS tableB
	ON tableA.ParcelID = tableB.ParcelID
	AND tableA.UniqueID <> tableB.UniqueID
WHERE tableA.PropertyAddress IS NULL

--- Execute SELECT again to confirm no missing PropertyAddress's


--------------------------------

/*
Seperate PropertyAddress into individual columns (Address, City)
Using SUBSTRING
*/

--- add new column for PropertyStreet 

ALTER TABLE NashvilleHousing
ADD PropertyStreet Nvarchar(255);

--- start at first character of PropertyAddress, go right until comma, then back one (removes comma)

UPDATE NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

--- add new column for PropertyCity

ALTER TABLE NashvilleHousing
ADD PropertyCity Nvarchar(255);

--- start one charcater after comma, go right to end of total characters in address

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


/*
Seperate OwnerAddress into individual columns (Address, City, State)
Using PARSENAME
*/

--- add new column for OwnerStreet 

ALTER TABLE NashvilleHousing
ADD OwnerStreet Nvarchar(255);

--- update new column with 3rd object from right using ',' as object demarkation

UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

--- add new column for OwnerCity

ALTER TABLE NashvilleHousing
ADD OwnerCity Nvarchar(255);

--- update new column with 2nd object from right using ',' as object demarkation

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

--- add new column for OwnerState

ALTER TABLE NashvilleHousing
ADD OwnerState Nvarchar(255);

--- update new column with 1st object from right using ',' as object demarkation

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


--------------------------------------------------------------------------------------------------------------------------

/*
Change Y and N to Yes and No in "Sold as Vacant" field
*/

--- Identify variations for SoldAsVacant

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--- Change N to No and Y to Yes

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------
/*
Remove Duplicates
*/

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

FROM NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



SELECT *
FROM NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



SELECT *
FROM NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

