-- Question 1
SELECT
    DA.platform,
    SUM(unit_price*quantity) AS TotalRevenue,                  
    COUNT(order_number) AS TotalOrders,                   
    SUM(quantity) AS TotalItemsSold,                 
    AVG(unit_price*quantity) AS AOV,                          
    SUM(unit_price*quantity) / SUM(quantity) AS ASP              
FROM
    Dataset$ as DA
WHERE
    order_created_date >= '2024-05-01' AND order_created_date < '2024-06-01' 
    AND Order_status NOT IN ('cancelled', 'returned', 'failed')
GROUP BY
    DA.platform;

-- Question 2
SELECT
    TOP 5
    DA.[Product SKU],
	CT.Category as Category,
    SUM(quantity * unit_price) AS TotalRevenue
FROM
    Dataset$ as DA
JOIN
	Category$ as CT ON DA.[Product SKU] = CT.[Product SKU]
WHERE
    order_created_date >= '2024-05-01' AND order_created_date < '2024-06-01' 
    AND Order_status NOT IN ('cancelled', 'returned', 'failed')
GROUP BY
    DA.[Product SKU], 
	CT.Category
ORDER BY
    TotalRevenue DESC;

-- Question 3
SELECT
    DA.[Product SKU],
    MIN(order_created_date) AS FirstSaleDate
FROM
    Dataset$ as DA
GROUP BY
    DA.[Product SKU]
ORDER BY
    DA.[Product SKU]

-- Question 4
SELECT
    CT.Category,
    SUM(DA.[seller_promo]) AS TotalSellerPromotion,
    SUM(DA.quantity * DA.unit_price) AS TotalRevenue,
    CASE
        WHEN SUM(DA.quantity * DA.unit_price) > 0 THEN SUM(DA.[seller_promo]) / SUM(DA.quantity * DA.unit_price)
        ELSE 0
    END AS SellerPromotionRatio
FROM
    Dataset$ AS DA
JOIN 
	Category$ as CT ON DA.[Product SKU] = CT.[Product SKU]
WHERE
    DA.order_created_date >= '2024-05-01' AND DA.order_created_date < '2024-06-01' 
    AND DA.Order_status NOT IN ('cancelled', 'returned', 'failed')
GROUP BY
    CT.Category
ORDER BY
    SellerPromotionRatio DESC; 

-- Question 5
WITH OrderCounts AS (
    SELECT
        DA.[Product SKU],
        COUNT(*) AS TotalOrders,
        SUM(CASE WHEN Order_status = 'cancelled' THEN 1 ELSE 0 END) AS CancelledOrders
    FROM
        Dataset$ AS DA
    WHERE
        order_created_date >= '2024-06-01' AND order_created_date < '2024-07-01' -- June 2024
    GROUP BY
        DA.[Product SKU]
),
CancellationRatios AS (
    SELECT
        [Product SKU],
		TotalOrders,
        CancelledOrders,  
        CASE
            WHEN TotalOrders > 0 THEN CAST(CancelledOrders AS FLOAT) / TotalOrders
            ELSE 0
        END AS CancellationRatio
    FROM
        OrderCounts
)
SELECT TOP 1
    [Product SKU],
    CancellationRatio
FROM
    CancellationRatios
ORDER BY
    CancellationRatio DESC
-- -- Question 5
WITH CancellationReasons AS (
    SELECT
        DA.cancelled_reason,
        COUNT(*) AS ReasonCount
    FROM
        Dataset$ AS DA
    WHERE
        DA.[Product SKU] = 'INT-ERGREEN' 
        AND order_created_date >= '2024-06-01' AND order_created_date < '2024-07-01' -- June 2024
        AND Order_status = 'cancelled'
    GROUP BY
        DA.cancelled_reason
)
SELECT TOP 1
    cancelled_reason,
    ReasonCount
FROM
    CancellationReasons
ORDER BY
    ReasonCount DESC

-- Question 6
WITH OrderDetails AS (
    SELECT
        DA.platform,
        order_number,
        DATEDIFF(day, [order_created_date], [delivery_date]) AS DeliveryLeadTime
    FROM
        Dataset$ AS DA
    WHERE
        [order_created_date] >= '2024-06-01' AND [order_created_date] < '2024-07-01' 
),
OrderCounts AS (
    SELECT
        platform,
        COUNT(*) AS TotalOrders,
        SUM(CASE WHEN DeliveryLeadTime >= 3 THEN 1 ELSE 0 END) AS LateOrders
    FROM
        OrderDetails
    GROUP BY
        platform
)
SELECT
    platform,
    TotalOrders,
    LateOrders,
    CASE
        WHEN TotalOrders > 0 THEN CAST(LateOrders AS FLOAT) / TotalOrders * 100
        ELSE 0
    END AS LateOrderPercentage
FROM
    OrderCounts
WHERE
    platform IN ('shopee', 'lazada') -- Specify the platforms
ORDER BY
    platform;



--

SELECT TOP 100 * FROM Dataset$



-- cau1
select MATHANG.MaMH, TenMH, MATHANG.DonGia, avg(CHITIETDDH.DonGia) as 'Don gia dat hang trung binh', sum(CHITIETDDH.SoLuong)
as 'Tong so luong mat hang'
from (MATHANG join CHITIETDDH on MATHANG.MaMH=CHITIETDDH.MaMH) 
join DONDATHANG on CHITIETDDH.MaDDH=DONDATHANG.MaDDH
where DONDATHANG.NgayDatHang between '7/1/2012' and '7/31/2012'
group by MATHANG.MaMH,TenMH, MATHANG.DonGia

-- cau2
select KHACHHANG.MaKH, KHACHHANG.HoTen, KHACHHANG.DiaChi,KHACHHANG.ThanhPho, KHACHHANG.QuocGia ,KHACHHANG.SoDT, sum(TriGia) as 'Tong tri gia cac don dat hang'
from KHACHHANG join DONDATHANG on KHACHHANG.MaKH=DONDATHANG.MaKH 
group by KHACHHANG.MaKH, KHACHHANG.HoTen, KHACHHANG.DiaChi,KHACHHANG.ThanhPho, KHACHHANG.QuocGia ,KHACHHANG.SoDT
having sum(TriGia) > 3000

-- cau3
select KHACHHANG.MaKH, KHACHHANG.HoTen, count(DONDATHANG.MaDDH) as 'Tong so don dat hang'
from KHACHHANG join DONDATHANG on KHACHHANG.MaKH=DONDATHANG.MaKH
group by  KHACHHANG.MaKH,KHACHHANG.HoTen

-- cau4
select MATHANG.MaMH, MATHANG.TenMH, MATHANG.MaNCC, MATHANG.DonGia, MATHANG.TinhTrang
from MATHANG
where (MATHANG.TinhTrang = 1) and MATHANG.MaMH NOT IN (
select CHITIETDDH.MaMH
 from CHITIETDDH)

 -- cau5
select NHACUNGCAP.MaNCC, NHACUNGCAP.TenNCC, COUNT(MATHANG.MaNCC) as 'So luong mat hang nhieu nhat'
from NHACUNGCAP join MATHANG on NHACUNGCAP.MaNCC = MATHANG.MaNCC
group by NHACUNGCAP.MaNCC, NHACUNGCAP.TenNCC
having COUNT(MATHANG.MaNCC) >= all (
select COUNT(MATHANG.MaNCC)
from NHACUNGCAP join MATHANG on NHACUNGCAP.MaNCC = MATHANG.MaNCC
group by NHACUNGCAP.MaNCC, NHACUNGCAP.TenNCC )

-- cau6
select KHACHHANG.MaKH, KHACHHANG.HoTen, KHACHHANG.DiaChi, KHACHHANG.ThanhPho, KHACHHANG.QuocGia ,KHACHHANG.SoDT
from KHACHHANG, DONDATHANG
where KHACHHANG.MaKH=DONDATHANG.MaKH and KHACHHANG.QuocGia = 'Brazil' 
group by KHACHHANG.MaKH, KHACHHANG.HoTen, KHACHHANG.DiaChi,KHACHHANG.ThanhPho, KHACHHANG.QuocGia ,KHACHHANG.SoDT
having max(DONDATHANG.TriGia) >= all (
select DONDATHANG.TriGia
from DONDATHANG, KHACHHANG
where KHACHHANG.MaKH=DONDATHANG.MaKH and KHACHHANG.QuocGia = 'Brazil' )



---------------
--1
select MH.MaMH, MH.TenMH, MH.DonGia, AVG(CTDDH.DonGia) as 'Don gia dat hang trung binh', count(CTDDH.SoLuong) as 'Tong so luong mat hang trong thang 7'
from MATHANG as MH join CHITIETDDH as CTDDH on MH.MaMH=CTDDH.MAMH
group by MH.MaMH, MH.TenMH, MH.DonGia

--2
select *
from KHACHHANG
where MaKH in ( select MaKH
 from DONDATHANG
 group by MaKH
 having sum(TriGia) > 3000 )

--3
select KH.MaKH, KH.HoTen, count(DDH.MaKH) as 'So don dat hang' 
from KHACHHANG as KH left join DONDATHANG as DDH on KH.MaKH = DDH.MaKH
group by KH.MaKH, KH.HoTen

--4
select *
from MATHANG as MH
where MH.TinhTrang = 1 and MH.MaMH not in 
( select MaMH 
from CHITIETDDH) 

--5
select NCC.MaNCC, NCC.TenNCC
from NHACUNGCAP as NCC join MATHANG as MH on MH.MaNCC = NCC.MaNCC
group by  NCC.MaNCC, NCC.TenNCC
having count(*) >= all( select count(*)
from MATHANG
group by MaNCC)

--6
SELECT *
from KHACHHANG as KH join DONDATHANG as DDH on KH.MaKH = DDH.MaKH
where KH.QuocGia = 'Brazil' and DDH.TriGia = ( select max(DDH.TriGia)
from DONDATHANG as DDH, KHACHHANG as KH
where KH.QuocGia = 'Brazil' and KH.MaKH = DDH.MaKH )

