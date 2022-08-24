Select *
From PortfolioProject..NashvilleHousing

--Standardizing date formats
Select SaleDate, CONVERT(date, SaleDate)
From PortfolioProject..NashvilleHousing

--Update NashvilleHousing						--Update didnt work so used alter table instead
--SET SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDate1 Date
Go
Update NashvilleHousing
SET SaleDate1 = Convert(Date, SaleDate)

--Populate Property Address
Select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelId
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a   --the abbreviated table name is to be used here
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual columns
Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) As Address
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

Select
ParseName(Replace(OwnerAddress,',','.'),3),
ParseName(Replace(OwnerAddress,',','.'),2),			--Replace is used to replace all the commas with dots since parsename can only recognize dots.
ParseName(Replace(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = ParseName(Replace(OwnerAddress,',','.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = ParseName(Replace(OwnerAddress,',','.'),2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = ParseName(Replace(OwnerAddress,',','.'),1)


--Sold as vacant (changing it to yes and no for y and n)

Select Distinct(SoldAsVacant)
From PortfolioProject..NashvilleHousing

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END


--remove duplicates
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY  ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by UniqueID) row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
--Select *
--From RowNumCTE
--where row_num > 1
--order by PropertyAddress
Delete
From RowNumCTE
where row_num > 1



Select *
From PortfolioProject..NashvilleHousing

--Deleting unused columns

Select *
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousing
DROP COLUMN SaleDate