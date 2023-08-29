/*

Data Cleaning With SQL Queries
Commands used in this project: (Update, Alter Table, ISNULL, Join, Case, ParseName, Parition By, CTE, Row_Number)

*/

Select *
From [Portfolio Project]..housing

----------------------------------------------

--Date Standarization Formating

Select SaleDate, CONVERT(date,SaleDate)
from [Portfolio Project]..Housing

Update Housing
SET SaleDate = CONVERT(Date,SaleDate)



--Original Update for Sale date did update. Altered Table to add new "SaleDateConverted" column and updated again to bypass problem.



ALTER TABLE Housing
Add SaleDateConverted Date;

Update Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, CONVERT(date,SaleDate)
from [Portfolio Project]..Housing

---------------------------------------------------------



--Populating NULL Property Address Data with Self-Join and ISNULL 

Select *
from [Portfolio Project]..Housing
order by parcelID


Select a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress)
from [Portfolio Project]..Housing a
Join [Portfolio Project]..Housing b
	on a.parcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.propertyaddress is NULL


UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
from [Portfolio Project]..Housing a
Join [Portfolio Project]..Housing b
	on a.parcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.propertyaddress is null





------------------------------------------------------


--Breaking Address into individual columns for Address, City using Substrings


Select PropertyAddress
from [Portfolio Project]..Housing

SELECT
SUBSTRING(Propertyaddress, 1, CHARINDEX(',',propertyaddress)-1 ) as Address, 
SUBSTRING(Propertyaddress, CHARINDEX(',', propertyaddress) + 1 , LEN(propertyaddress)) as Address
from [Portfolio Project]..Housing


ALTER TABLE Housing
Add PropertySplitAddress Nvarchar(255); 

Update Housing
SET PropertySplitAddress = SUBSTRING(Propertyaddress, 1, CHARINDEX(',',propertyaddress)-1 )

ALTER TABLE Housing
Add PropertyCity Nvarchar(255);

Update Housing
SET PropertyCity = SUBSTRING(Propertyaddress, CHARINDEX(',', propertyaddress) + 1 , LEN(propertyaddress))


---------------------------------------------------------

-- Breaking owner address column into Address, City, State using PARSENAME and Replace



Select owneraddress
from [Portfolio Project]..Housing

Select
PARSENAME(REPLACE(Owneraddress, ',', '.') , 3)
,PARSENAME(REPLACE(Owneraddress, ',', '.') , 2)
,PARSENAME(REPLACE(Owneraddress, ',', '.') , 1)
from [Portfolio Project]..Housing


ALTER TABLE Housing
Add OwnerSplitAddress Nvarchar(255); 

ALTER TABLE Housing
Add OwnerPropertyCity Nvarchar(255);

ALTER TABLE Housing
Add OwnerPropertyState Nvarchar(255);


Update Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(Owneraddress, ',', '.') , 3)

Update Housing
SET OwnerPropertyCity = PARSENAME(REPLACE(Owneraddress, ',', '.') , 2)

Update Housing
SET OwnerPropertyState = PARSENAME(REPLACE(Owneraddress, ',', '.') , 1)



------------------------------------------------

--Changing Sold As Vacant 'Yes,Y, No, N' to only 2 selections: 'Yes/No'. Using Case

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [Portfolio Project]..Housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant	
	END
from [Portfolio Project]..Housing


Update Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant	
	END



---------------------------------------------------------------------

-- Removing Duplicates using Partition By, Row Number and CTE

WITH RowNumCTE AS( 
Select *,
	ROW_NUMBER() OVER (
	Partition by parcelID,
				propertyaddress,
				Saleprice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

from [Portfolio Project]..Housing
)
DELETE
From RowNumCTE
Where row_num > 1




------------------------------

--Deleting Unused Columns


ALTER TABLE [Portfolio Project]..Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
