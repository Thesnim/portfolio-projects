/* 
Cleaning Data in Sql Queries

*/
select * from [Portfolio project].dbo.NashvilleHousing;

/* Standardize Data Format*/

select SaleDate from [Portfolio project].dbo.NashvilleHousing;
--Step 1 /*convert date into date, adding a new column */
select saleDate,CONVERT(Date,SaleDate)from [Portfolio project].dbo.NashvilleHousing;

-- step 2 /* update the column saleDate 
update [Portfolio project].dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- step 3 /* step 2 is not working properly
-- alter the table by adding new column saledateconverted
Alter Table NashvilleHousing
Add SaleDateConverted Date;


--step 4 /* update the column saledateconverted
update [Portfolio project].dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- step 5 /* formatting date and selecting datecolumn SaleDateConverted
select saleDateConverted,CONVERT(Date,SaleDate)from [Portfolio project].dbo.NashvilleHousing;


/* Populate Property Address Data */

select * from [Portfolio project].dbo.NashvilleHousing
where PropertyAddress is null;

--step1
select * from [Portfolio project].dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID;

--step2

--join /* in opertaion  self join  the table joining the same parcel ids but different unique ids
select * from [Portfolio project].dbo.NashvilleHousing a
join
[Portfolio project].dbo.NashvilleHousing b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null;


 --step3
 -- for the null property address taken the value of b.property address with the same parcel ids
 select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
 from [Portfolio project].dbo.NashvilleHousing a
join
[Portfolio project].dbo.NashvilleHousing b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
-- where a.PropertyAddress is null;

	--final query
 -- update the table where property address is null
 update a
 set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
 from [Portfolio project].dbo.NashvilleHousing a
join
[Portfolio project].dbo.NashvilleHousing b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null;



 /* Breaking out Address into Individual Columns (Address,City,State)*/

 select PropertyAddress from [Portfolio project].dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID;

	--step1
	--breaking property address into two columns
SELECT
    LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    LTRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))) AS Address
FROM [Portfolio project].dbo.NashvilleHousing;

	--step2
-- addg new two columns propertysplitaddress,propertysplitcity
ALTER TABLE [Portfolio project].dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255), -- Adjust size as needed
    PropertySplitCity NVARCHAR(255);         -- Adjust size as needed

		--step3
	--update the columns by splitting property address
UPDATE [Portfolio project].dbo.NashvilleHousing
SET 
    PropertySplitAddress = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1),
    PropertySplitCity = LTRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)));

	--step4
	select * from [Portfolio project].dbo.NashvilleHousing;

	/*                                                                    

	--BREAKING  OUT OWNER ADDRESS INTO INDIVIDUAL COLUMNS
	*/
	
select ownerAddress from [Portfolio project].dbo.NashvilleHousing;


SELECT 
     PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
     PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
     PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
	 from [Portfolio project].dbo.NashvilleHousing;


--step1:add three new column


ALTER TABLE [Portfolio project].dbo.NashvilleHousing 
ADD OwnersplitAddress NVARCHAR(255),
    OwnersplitCity NVARCHAR(255),
    OwnersplitState NVARCHAR(50);


	--step 2:update the columns by using parsename function
	UPDATE [Portfolio project].dbo.NashvilleHousing
	SET 
    OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
   OwnersplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnersplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

	select * from [Portfolio project].dbo.NashvilleHousing;

--change Y and N as YES or NO
SELECT SoldAsVacant from [Portfolio project].dbo.NashvilleHousing;

	
select distinct SoldAsVacant, count(SoldAsVacant)
from [Portfolio project].dbo.NashvilleHousing
group by SoldAsVacant
order by 2;

 SELECT SoldAsVacant,
 case  WHEN SoldAsVacant ='Y'  THEN 'YES'
 WHEN SoldAsVacant  = 'N' THEN 'NO'
 else SoldAsVacant
 end
 from [Portfolio project].dbo.NashvilleHousing;  
 
   -- final query
   UPDATE [Portfolio project].dbo.NashvilleHousing
	set SoldAsVacant = case  WHEN SoldAsVacant ='Y'  THEN 'YES'
 WHEN SoldAsVacant  = 'N' THEN 'NO'
 else SoldAsVacant
 end
 from [Portfolio project].dbo.NashvilleHousing;  
     
	 --Remove Duplicates
	 -- find duplicates order by unique id 
	

	-- delete duplicate rows
		 WITH RowNumCTE AS(
	select *, 
	ROW_NUMBER() over (partition BY ParcelID,
									PropertyAddress,
										SalePrice,
										SaleDate,
										LegalReference
										ORDER BY 
										UniqueID
										)row_num
	from [Portfolio project].dbo.NashvilleHousing
	--order by ParcelID
	)

	delete  FROM RowNumCTE
	where row_num > 1
	--order by PropertyAddress;


	--chechk any duplicate rows
	WITH RowNumCTE AS(
	select *, 
	ROW_NUMBER() over (partition BY ParcelID,
									PropertyAddress,
										SalePrice,
										SaleDate,
										LegalReference
										ORDER BY 
										UniqueID
										)row_num
	from [Portfolio project].dbo.NashvilleHousing
	--order by ParcelID
	)
	SELECT * FROM RowNumCTE
	where row_num > 1
	order by PropertyAddress;

	select * from [Portfolio project].dbo.NashvilleHousing;



	--Remove unused columns
	ALTER TABLE [Portfolio project].dbo.NashvilleHousing
	drop column PropertyAddress, OwnerAddress,TaxDistrict; 
	ALTER TABLE [Portfolio project].dbo.NashvilleHousing
	drop column SaleDate; 
	select * from [Portfolio project].dbo.NashvilleHousing;