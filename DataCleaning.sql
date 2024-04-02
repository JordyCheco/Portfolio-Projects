Select * from PortfolioProject..NashvilleHousing

-- Standardize Data Format

Select SaleDateConverted, convert(Date,SaleDate) 
from PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SaleDate =CONVERT(Date, SaleDate)

Alter Table  PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted =CONVERT(Date, SaleDate)


--Populate Property Address Data

Select *
from PortfolioProject..NashvilleHousing
--Where PropertyAddress is Null
order by ParcelID


Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
from PortfolioProject..NashvilleHousing as A
JOIN PortfolioProject..NashvilleHousing as B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ]<> B.[UniqueID ]
Where a.PropertyAddress is Null

-- This matches A's Property Address with B.Property Address where there is  a NULL Value
Update A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
from PortfolioProject..NashvilleHousing as A
JOIN PortfolioProject..NashvilleHousing as B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ]<> B.[UniqueID ]

--Breaking out Address Into Individual Colums (Address, City, State) 
Select PropertyAddress
from PortfolioProject..NashvilleHousing

Select 
SUBSTRING (PropertyAddress, 1, CHARINDEX( ',', PropertyAddress)-1) as Address ,
SUBSTRING (PropertyAddress, CHARINDEX( ',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing


Alter Table  PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX( ',', PropertyAddress)-1)

Alter Table  PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity =SUBSTRING (PropertyAddress, CHARINDEX( ',', PropertyAddress)+1, LEN(PropertyAddress))

-- Adding two new colums to the table making it easier to see the address and city
Select *
from PortfolioProject..NashvilleHousing

--Owner Address splitting the (Address, City, State) with ParsName
Select OwnerAddress
from PortfolioProject..NashvilleHousing

Select
PARSENAME(Replace( OwnerAddress,',','.'),3) as Address,
PARSENAME(Replace( OwnerAddress,',','.'),2) as City,
PARSENAME(Replace( OwnerAddress,',','.'),1) as State
from PortfolioProject..NashvilleHousing

Alter Table  PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace( OwnerAddress,',','.'),3)

Alter Table  PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace( OwnerAddress,',','.'),2)

Alter Table  PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace( OwnerAddress,',','.'),1)

-- Adding two new colums to the table making it easier to see the address and city
Select *
from PortfolioProject..NashvilleHousing

-- Changing Y and N to Yes and No in 'Sold as Vacant' field
Select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
Case When SoldAsVacant ='Y' then 'Yes'
	 When SoldAsVacant ='N' then 'No'
Else SoldAsVacant 
END
from PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
 SET SoldAsVacant =
 Case When SoldAsVacant ='Y' then 'Yes'
	 When SoldAsVacant ='N' then 'No'
Else SoldAsVacant 
END

-- Removing Duplicates

With RowNumberCTE as(
Select *,
	ROW_NUMBER() Over (
	Partition by	ParcelID,
					PropertyAddress,
					SalePrice,SaleDate,
					LegalReference
	Order by UniqueID ) as Row_num
from PortfolioProject..NashvilleHousing
)
 Select *
 from RowNumberCTE
 where Row_num >1


 -- Delete unused Colums
 Select *
 from PortfolioProject..NashvilleHousing

 Alter Table PortfolioProject..NashvilleHousing
 Drop Column OwnerAddress, TaxDistrict, PropertyAddress

 Alter Table PortfolioProject..NashvilleHousing
 Drop Column SaleDate




