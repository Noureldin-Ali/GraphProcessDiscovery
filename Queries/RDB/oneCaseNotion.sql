
SET STATISTICS TIME ON
go
SELECT distinct a.ActivityName, b.ActivityName
FROM bpi2012 a, bpi2012 b WHERE a.[Case] = b.[Case] AND
a.Timestamp < b.Timestamp AND
NOT EXISTS(SELECT * FROM bpi2012 c WHERE c.[Case] = a.[Case]
AND
a.Timestamp < c.Timestamp AND c.Timestamp < b.Timestamp);
go
SET STATISTICS TIME OFF