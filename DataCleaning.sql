/*

Cleaning Data in SQL Queries

*/

select  *
from PortfolioProject..NashvilleHousingData


--Populate property address
select *
from PortfolioProject..NashvilleHousingData
where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousingData a
join PortfolioProject..NashvilleHousingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousingData a
join PortfolioProject..NashvilleHousingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


--Breaking out PropertyAddress Into Individual Columns (Address, City) Using Substring

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

From PortfolioProject..NashvilleHousingData 


ALTER TABLE PortfolioProject..NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE PortfolioProject..NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

select *
from PortfolioProject..NashvilleHousingData 


--Breaking out OwnerAddress Into Individual Columns (Address, City, State) Using Parsename

select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3 )
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from PortfolioProject..NashvilleHousingData 


ALTER TABLE PortfolioProject..NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3 )


ALTER TABLE PortfolioProject..NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE PortfolioProject..NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


--Change 1 and 0 to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousingData
group by SoldAsVacant
order by 2

--

select SoldAsVacant
, CASE when SoldAsVacant = '1' then 'Yes'
	   when SoldAsVacant = '0' then 'No'
	   END
from PortfolioProject..NashvilleHousingData


Update PortfolioProject..NashvilleHousingData
SET SoldAsVacant = CASE when SoldAsVacant = '1' then 'Yes'
	   when SoldAsVacant = '0' then 'No'
	   END


--Remove Duplicates

WITH RowNumCTE AS(
select *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
				UniqueID
				) row_num 

from PortfolioProject..NashvilleHousingData
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
order by PropertyAddress


--Delete Unused Columns

ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate