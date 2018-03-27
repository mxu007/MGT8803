SELECT BusinessDate, strftime('%Y-%m-%d-%H:00', CloseDateTime) as [Hour], SUM(PatronCount), SUM(ItemCount), SUM(ItemSum), SUM(TaxSum), 
SUM(ServiceChargeSum), SUM(VoidSum), SUM(PaymentSum), SUM(DiscountSUM), SUM(TransactionTotal) 
FROM SNAP_Transaction
GROUP BY
BusinessDate, strftime('%Y-%m-%d-%H:00', CloseDateTime);