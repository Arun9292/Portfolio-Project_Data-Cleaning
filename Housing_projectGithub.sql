

SELECT *
FROM `housing_data`

update `housing_data` set PropertyAddress=NULL where PropertyAddress='';
update `housing_data` set TaxDistrict =NULL where TaxDistrict='';


--            Populate Property Address ( Replaced Null values with similar Address)



SELECT  a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ifnull(a.PropertyAddress,b.PropertyAddress), a.uniqueID
FROM `housing_data` a
join `housing_data` b
   on  a.ParcelID = b.ParcelID
   and a.uniqueID <> b.uniqueID 
where a.propertyaddress is null

UPDATE `housing_data` a
join `housing_data` b
   on a.ParcelID = b.ParcelID
   and a.uniqueID <> b.uniqueID 
set a.propertyaddress = b.propertyaddress  
where a.propertyaddress is null

--           Property Address into individual columns


SELECT 
SUBSTRING_INDEX(PropertyAddress, ',' , 1) as Address ,
SUBSTRING_INDEX(PropertyAddress, ',' , -1) as Address2
FROM `housing_data`

ALTER table housing_data
add column Property_address Nvarchar(255);

update `housing_data`
set Property_address = SUBSTRING_INDEX(PropertyAddress, ',' , 1)

ALTER table `housing_data`
add column Property_City Nvarchar(255);

update `housing_data`
set Property_City = SUBSTRING_INDEX(PropertyAddress, ',' , -1)


--           OwnerAddress into individual columns


SELECT 
SUBSTRING_INDEX(OwnerAddress, ',' , 1) as Owner_Address ,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',' , -2),',' , 1 ) as Owner_City,
SUBSTRING_INDEX(OwnerAddress, ',' , -1) as Owner_State
FROM `housing_data`

alter table `housing_data`
add column Owner_Address Nvarchar(255);

update `housing_data`
set Owner_Address = SUBSTRING_INDEX(OwnerAddress, ',' , 1)

alter table `housing_data`
add column Owner_City Nvarchar(255);

update `housing_data`
set Owner_City = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',' , -2),',' , 1 )

alter table `housing_data`
add column Owner_State Nvarchar(255);

update `housing_data`
set Owner_State = SUBSTRING_INDEX(OwnerAddress, ',' , -1)


-- Change Y & N to YES NO in SoldAsVacant column

SELECT SoldAsVacant,
Case When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
     Else SoldAsVacant
     End
FROM portfolio_datacleaning.housing_data

update housing_data
set SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
     Else SoldAsVacant
     End
     
     
     
     --                  Deleting duplicates


With RownumCTE as 
(
SELECT *, row_number() over(partition by ParcelID,PropertyAddress,SalePrice,LegalReference order by UniqueID) row_num
 FROM housing_data 
  ) 
 delete hd
 from housing_data hd
 JOIN RownumCTE r 
 ON hd.UniqueID = r.uniqueID
 where row_num > 1
 
   --                  Deleting Columns
   
   ALter table housing_data
   Drop PropertyAddress, 
   
   Drop OwnerAddress,

   Drop TaxDistrict
