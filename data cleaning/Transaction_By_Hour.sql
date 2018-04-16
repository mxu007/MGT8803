## 03/31/18
## ----------------------- ##
## Remove duplicate entries for stable tables
delete   from SNAP_Discount
where   rowid not in
         (
         select  min(rowid)
         from    SNAP_Discount
         group by
                 DiscountCode,
                 DiscountName,
                 DiscountTypeId
         )



## ----------------------- ##
## Full Joint Table By Hour
SELECT trans.RestaurantLocationID, trans.zipcode, trans.[Date], trans.[Hour],
    trans.PatronSum, trans.TaxSum, trans.TransactionSum, trans.NetSales, trans.TransactionCount,
    IFNULL(disct.DiscountCount, 0) As DiscountCount,  IFNULL(disct.DiscountCount, 0)*1.0/trans.TransactionCount AS DiscountCountPct,
    weather.PRCP, weather.SNOW, weather.TMAX, weather.TMIN,
    IFNULL(holidays.IsHoliday,0) as IsHoliday,
    SUM (CASE WHEN strftime('%H:00', ept.ClockIn) <= trans.[Hour]
        AND strftime('%H:00', ept.ClockOut) >= trans.[Hour] THEN 1
        ELSE 0 END) As NoEmployee
FROM

(SELECT "100658" as RestaurantLocationID,  "63005" as zipcode, BusinessDate as [Date],
    strftime('%H:00', CloseDateTime) as [Hour],
    SUM(PatronCount) as PatronSum, SUM(TaxSum) as TaxSum,
    SUM(TransactionTotal) as TransactionSum ,
    SUM(TransactionTotal) -SUM(TaxSum) as NetSales,
    COUNT(TransactionId) as TransactionCount
FROM SNAP_Transaction
GROUP BY
BusinessDate, strftime('%Y-%m-%d-%H:00', CloseDateTime)) AS trans

LEFT JOIN

(SELECT strftime('%Y-%m-%d', TransactionDetailDate) as [Date], strftime('%H:00',
    TransactionDetailDate) as [Hour], COUNT (DISTINCT TransactionID) as DiscountCount
FROM SNAP_TransactionDetail
WHERE TransactionDetailTypeId = "2"
GROUP BY strftime('%Y-%m-%d-%H:00', TransactionDetailDate)) AS disct

ON trans.[Date] = disct.[Date] AND trans.[Hour]=disct.[Hour]

LEFT JOIN

weather

ON trans.zipcode = weather.zipcode AND trans.[Date] = weather.[Date]

LEFT JOIN

(SELECT [Date], COUNT (DISTINCT [Date]) AS IsHoliday
    FROM holidays
    WHERE HolidayType = "Federal Holiday" OR HolidayType = "State holiday" OR HolidayType = "Observance"
    GROUP BY [Date]
) as holidays

ON trans.[Date] = holidays.[Date]

LEFT JOIN SNAP_EmployeeTime ept
ON trans.[Date] = ept.BusinessDate
WHERE ept.PayRateRegular != 0
GROUP BY trans.[Date], trans.[Hour]



## ----------------------- ##
## Transaction Table By Hour
SELECT "100658" as RestaurantLocationID,  "63005" as zipcode, BusinessDate,
    strftime('%H:00', CloseDateTime) as [Hour],
    SUM(PatronCount) as PatronSum, SUM(TaxSum) as TaxSum,
    SUM(TransactionTotal) as TransactionSum ,
    SUM(TransactionTotal) -SUM(TaxSum) as NetSales,
    COUNT(TransactionId) as TransactionCount
FROM SNAP_Transaction
GROUP BY
BusinessDate, strftime('%Y-%m-%d-%H:00', CloseDateTime)


## ----------------------- ##
## No.of employee By hour
SELECT trans.RestaurantLocationID, trans.zipcode, trans.BusinessDate, trans.[Hour],
    trans.PatronSum, trans.TaxSum, trans.TransactionSum, trans.NetSales, trans.TransactionCount,
    SUM (CASE WHEN strftime('%H:00', ept.ClockIn) <= trans.[Hour]
        AND strftime('%H:00', ept.ClockOut) >= trans.[Hour] THEN 1
        ELSE 0 END) As NoEmployee

FROM

(SELECT "100658" as RestaurantLocationID,  "63005" as zipcode, BusinessDate,
    strftime('%H:00', CloseDateTime) as [Hour],
    SUM(PatronCount) as PatronSum, SUM(TaxSum) as TaxSum,
    SUM(TransactionTotal) as TransactionSum ,
    SUM(TransactionTotal) -SUM(TaxSum) as NetSales,
    COUNT(TransactionId) as TransactionCount
FROM SNAP_Transaction
GROUP BY
BusinessDate, strftime('%Y-%m-%d-%H:00', CloseDateTime)) as trans

LEFT JOIN SNAP_EmployeeTime ept
ON trans.BusinessDate = ept.BusinessDate
WHERE ept.PayRateRegular != 0
GROUP BY trans.BusinessDate, trans.[Hour]



## ----------------------- ##
## Discount Table
SELECT "100658" as RestaurantLocationID, strftime('%Y-%m-%d', TransactionDetailDate) as [Date], trans.TransactionDetailId, trans.TransactionId, trans.TransactionDetailTypeId, trans.DiscountCode, disc.DiscountTypeId, CAST(disc.DiscountTypeId as INTEGER) - 1 AS Promotion
FROM SNAP_TransactionDetail trans INNER JOIN SNAP_Discount disc
ON trans.DiscountCode = disc.DiscountCode
WHERE trans.TransactionDetailTypeId = "2"


## ----------------------- ##
## No.of Transaction with Discount By Hour
SELECT RestaurantLocationID, [DATE], TransactionID, MIN(cast(DiscountCode as integer)), MIN(cast(DiscountCode as integer)), MIN(cast(DiscountTypeID as integer)), MIN(cast(Promotion as integer))
FROM
(SELECT "100658" as RestaurantLocationID, strftime('%Y-%m-%d', TransactionDetailDate) as [Date], trans.TransactionDetailId, trans.TransactionId, trans.DiscountCode, disc.DiscountTypeId, CAST(disc.DiscountTypeId as INTEGER) - 1 AS Promotion
FROM SNAP_TransactionDetail trans INNER JOIN SNAP_Discount disc
ON trans.DiscountCode = disc.DiscountCode
WHERE trans.TransactionDetailTypeId = "2" )

GROUP BY [DATE], TransactionID
ORDER BY [DATE], cast(TransactionID as integer)



## ----------------------- ##
SELECT BusinessDate, strftime('%Y-%m-%d-%H:00', CloseDateTime) as [Hour], SUM(PatronCount), SUM(ItemCount), SUM(ItemSum), SUM(TaxSum),
SUM(ServiceChargeSum), SUM(VoidSum), SUM(PaymentSum), SUM(DiscountSUM), SUM(TransactionTotal)
FROM SNAP_Transaction
GROUP BY
BusinessDate, strftime('%Y-%m-%d-%H:00', CloseDateTime);


## ----------------------- ##
## Full Joint Table By Day
## Remove #employee as it is not relavent for daily aggregated level of data

SELECT trans.RestaurantLocationID, trans.zipcode, trans.[Date],
    trans.PatronSum, trans.TaxSum, trans.TransactionSum, trans.NetSales, trans.TransactionCount,
    IFNULL(disct.DiscountCount, 0) As DiscountCount,  IFNULL(disct.DiscountCount, 0)*1.0/trans.TransactionCount AS DiscountCountPct,
    weather.PRCP, weather.SNOW, weather.TMAX, weather.TMIN,
    IFNULL(holidays.IsHoliday,0) as IsHoliday
FROM

(SELECT "100658" as RestaurantLocationID,  "63005" as zipcode, BusinessDate as [Date],
    SUM(PatronCount) as PatronSum, SUM(TaxSum) as TaxSum,
    SUM(TransactionTotal) as TransactionSum ,
    SUM(TransactionTotal) -SUM(TaxSum) as NetSales,
    COUNT(TransactionId) as TransactionCount
FROM SNAP_Transaction
GROUP BY
BusinessDate) AS trans

LEFT JOIN

(SELECT strftime('%Y-%m-%d', TransactionDetailDate) as [Date], COUNT (DISTINCT TransactionID) as DiscountCount
FROM SNAP_TransactionDetail
WHERE TransactionDetailTypeId = "2"
GROUP BY [Date]) AS disct

ON trans.[Date] = disct.[Date]

LEFT JOIN

weather

ON trans.zipcode = weather.zipcode AND trans.[Date] = weather.[Date]

LEFT JOIN

(SELECT [Date], COUNT (DISTINCT [Date]) AS IsHoliday
    FROM holidays
    WHERE HolidayType = "Federal Holiday" OR HolidayType = "State holiday" OR HolidayType = "Observance"
    GROUP BY [Date]
) as holidays

ON trans.[Date] = holidays.[Date]

LEFT JOIN SNAP_EmployeeTime ept
ON trans.[Date] = ept.BusinessDate
WHERE ept.PayRateRegular != 0
GROUP BY trans.[Date]


## ----------------------- ##
## Transaction Table By Day
SELECT "100658" as RestaurantLocationID,  "63005" as zipcode, BusinessDate,
    SUM(PatronCount) as PatronSum, SUM(TaxSum) as TaxSum,
    SUM(TransactionTotal) as TransactionSum ,
    SUM(TransactionTotal) -SUM(TaxSum) as NetSales,
    COUNT(TransactionId) as TransactionCount
FROM SNAP_Transaction
GROUP BY
BusinessDate



