SELECT *
FROM housing..data;





-- Ubah date format
ALTER TABLE data
Add Date Date;

Update data
SET Date = CONVERT(Date,SaleDate);

ALTER TABLE data
DROP COLUMN SaleDate;






-- Isi address yang kosong dengan address dengan parcell id yang sama.
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing..data a
JOIN housing..data b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing..data a
JOIN housing..data b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null;






-- Pisahkan adress menjadi (address, city, state)
-- SUBSTRING(string, start, length)
SELECT PropertyAddress,
		SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM housing..data;


ALTER TABLE housing..data
Add PropertySplitAddress NVARCHAR(255);
Update housing..data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE housing..data
Add PropertySplitCity NVARCHAR(255);
Update housing..data
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));



SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM housing..data;

ALTER TABLE housing..data
Add OwnerSplitAddress NVARCHAR(255);
Update housing..data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE housing..data
Add OwnerSplitCity NVARCHAR(255);
Update housing..data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE housing..data
Add OwnerSplitState NVARCHAR(255);
Update housing..data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);





-- Ubah Y dan N menjadi Yes dan NO column Sold As Vacant
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM housing..data
GROUP BY SoldAsVacant;


SELECT SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM housing..data
WHERE SoldAsVacant IN ('N','Y');

UPDATE housing..data
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END






-- Menghapus data duplikat
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 Date,
					 LegalReference
		ORDER BY UniqueID) row_num
FROM housing..data
)
SELECT *
FROM RowNumCTE
Where row_num > 1
ORDER BY PropertyAddress;






-- Hapus kolom yang tidak digunakan
ALTER TABLE housing..data
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

SELECT *
FROM housing..data