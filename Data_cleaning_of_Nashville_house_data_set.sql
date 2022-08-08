select * from house_data.house;
select count(*) from house_data.house;

-- After seeing description, we can see our sales date is in text, need to convert it to date data type 
describe house_data.house;

-- converting text to date 
select str_to_date(SaleDate, "%M %d, %Y") from house_data.house;
update house_data.house set SaleDate = str_to_date(SaleDate, "%M %d, %Y");
alter table house_data.house modify column SaleDate date;

-- finding null in PropertyAddress
select count(PropertyAddress) from house_data.house where PropertyAddress = '' or PropertyAddress is null;

-- Observing the data set by sorting ParcelId
select * from house_data.house order by ParcelID asc;
select ParcelID, PropertyAddress from house_data.house where PropertyAddress = '' order by ParcelID asc;

-- After observing we found that there are duplicate parcel id, with property address as null, so we can replace them with
-- the id provided for any other duplicate parcel id 
select a.ParcelID, b.ParcelID, a.UniqueID, b.UniqueID, a.PropertyAddress, b.PropertyAddress from house_data.house a join house_data.house b on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID 
where a.PropertyAddress = '';

-- Now, updating a.PropertyAddress with b.PropertyAddress 
update house_data.house a join house_data.house b 
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
set a.PropertyAddress = b.PropertyAddress 
where a.PropertyAddress = '';

-- After observing the data you saw that PropertyAddress should be divided into 
select substring_index(PropertyAddress, ',', 1) as Address,
substring_index(PropertyAddress, ',', -1)
from  house_data.house;

-- another way of writing the above sql 
select substring(PropertyAddress, 1, position("," in PropertyAddress) - 1),
substring(PropertyAddress, position("," in PropertyAddress) + 1, length(PropertyAddress)) 
from house_data.house;

-- Now, we need to add above selected two columns as new columns in the table 
alter table house_data.house
add column PropertySplitAddress varchar(255);

update house_data.house
set PropertySplitAddress = substring(PropertyAddress, 1, position("," in PropertyAddress) - 1);

alter table house_data.house
add column PropertySplitCity varchar(255);

update house_data.house
set PropertySplitCity = substring(PropertyAddress, position("," in PropertyAddress) + 1, length(PropertyAddress));

-- observing Ownwer Address 
select OwnerAddress from house_data.house;
select count(OwnerAddress) from house_data.house where OwnerAddress = '' ;

-- seperate them with delimiter ","
select
substring_index(OwnerAddress, ',', 1),
substring_index(substring_index(OwnerAddress, ',', 2), ',', -1),
substring_index(OwnerAddress, ',', -1)
from house_data.house;

-- Now, adding all the three selected columns into the table 
alter table house_data.house 
add column OwnerSplitAddress varchar(255);

update house_data.house
set OwnerSplitAddress = substring_index(OwnerAddress, ',', 1);

alter table house_data.house
add column OwnerSplitCity varchar(255);

update house_data.house
set OwnerSplitCity = substring_index(substring_index(OwnerAddress, ',', 2), ',', -1);

alter table house_data.house 
add column OwnerSplitState varchar(255);

update house_data.house
set OwnerSplitState = substring_index(OwnerAddress, ',', -1);

-- Observing the SoldAsVacant column
-- Observing that value contains Yes, Y, N, No
select distinct(SoldAsVacant) from house_data.house;

select distinct(SoldAsVacant), count(SoldAsVacant) as newCount
from house_data.house
group by SoldAsVacant
order by newCount asc;

-- Our task is to update No -> N and Yes -> Y. 
update house_data.house
set SoldAsVacant = 'No'
where SoldAsVacant = 'N';

update house_data.house
set SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y';

-- or you can also use 
select SoldAsVacant 
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
       else SoldAsVacant 
       end 
from house_data.house;

update house_data.house
set SoldAsVacant = 
  case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
       else SoldAsVacant 
       end;
    
-- Finding the duplicate records. there can be multiple ways to do it. 
select ParcelID, count(ParcelID), PropertyAddress, SalePrice, SaleDate, LegalReference
from house_data.house
group by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
having count(ParcelID) > 1;

-- There are multiple ways to delete the duplicate records in the table 
create table dummy like house_data.house;

describe house_data.dummy;

select * from house_data.dummy;

insert into house_data.dummy 
select * from house_data.house
group by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference;

select ParcelID, count(ParcelID), PropertyAddress, SalePrice, SaleDate, LegalReference
from house_data.dummy
group by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
having count(ParcelID) > 1;

