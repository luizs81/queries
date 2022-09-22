■受注ヘッダ
[①主となるテーブルより取得]--------------------------------
■ Order header
[(1) Obtained from the main table]--------------------------------
SELECT 	
 a.SALESID,	
 a.CREATEDDATETIME,	
 c.PATFINCHANNEL,	
 a.SALESTYPE,	
 a.SALESSTATUS,	
 a.CUSTACCOUNT	
FROM SALESTABLE AS a	
INNER JOIN 	
	(SELECT SALESID
	FROM SALESTABLE
	WHERE DATAAREAID = '4000'
	AND MODIFIEDDATETIME > '${input1}'
	AND MODIFIEDDATETIME <= '${input2}'
	UNION
	SELECT SALESID
	FROM SALESLINE
	WHERE DATAAREAID = '4000'
	AND MODIFIEDDATETIME > '${input1}'
	AND MODIFIEDDATETIME <= '${input2}'
	UNION
	SELECT SALESID
	FROM CUSTINVOICEJOUR
	WHERE DATAAREAID = '4000'
	AND MODIFIEDDATETIME > '${input1}'
	AND MODIFIEDDATETIME <= '${input2}'
	UNION
	SELECT SALESID
	FROM CUSTINVOICETRANS
	WHERE DATAAREAID = '4000'
	AND MODIFIEDDATETIME > '${input1}'
	AND MODIFIEDDATETIME <= '${input2}') AS b
ON a.SALESID = b.SALESID	
INNER JOIN	
	(SELECT DISTINCT SALESID,PATFINCHANNEL
         FROM SALESLINE	
	 WHERE DATAAREAID = '4000') AS c
ON a.SALESID = c.SALESID	
WHERE a.DATAAREAID = '4000'	
AND a.CUSTGROUP = 'JPNDTC'	
ORDER BY a.SALESID	


[↓②CSV出力時、レコード毎に取得]-------------------
[②-1SFCC顧客番号(No.14)]---------------------------
[↓②When outputting CSV, get each record]-------------------
[②-1SFCC customer number (No.14)]--------------------------
SELECT PATEXTERNALID 
  FROM CUSTTABLE 
 WHERE ACCOUNTNUM = ?input1?
 AND DATAAREAID = '4000'


[②-2売上数(No.21)、売上合計(No.22)]----------------
[②-2 Number of sales (No.21), total sales (No.22)]----------------
SELECT SUM(LINEAMOUNT) AS SUM_LINEAMOUNT,
       SUM(QTY) AS SUM_QTY 
  FROM CUSTINVOICETRANS 
 WHERE SALESID = ?input1?
 AND DATAAREAID = '4000'


[②-3受注合計数(No.24)、受注合計金額(No.25)]--------
[②-3 Total number of orders (No.24), Total amount of orders (No.25)]--------
SELECT SUM(LINEAMOUNT) AS SUM_LINEAMOUNT,
       SUM(SALESQTY) AS SUM_SALESQTY 
  FROM SALESLINE 
 WHERE SALESID = ?input1?
   AND SALESSTATUS <> 4
   AND DATAAREAID = '4000'


■受注明細
[①主となるテーブルより取得]--------------------------------------------------
■Order details
[(1) Obtained from the main table] ----------------------------------------- ---------
SELECT 	
 a.SALESID,	
 a.LINENUM,	
 c.CREATEDDATETIME,	
 a.MODIFIEDDATETIME,	
 a.ITEMID,	
 a.NAME,	
 c.CUSTACCOUNT,	
 a.SALESTYPE,	
 a.SALESSTATUS,	
 a.SALESQTY,	
 a.LINEAMOUNT as SL_LINEAMOUNT,	
 a.SALESPRICE	
FROM SALESLINE AS a	
INNER JOIN 	
	(SELECT SALESID
	FROM SALESTABLE
	WHERE DATAAREAID = '4000'
	AND MODIFIEDDATETIME > '${input1}'
	AND MODIFIEDDATETIME <= '${input2}'
	UNION
	SELECT SALESID
	FROM SALESLINE
	WHERE DATAAREAID = '4000'
	AND MODIFIEDDATETIME > '${input1}'
	AND MODIFIEDDATETIME <= '${input2}'
	UNION
	SELECT SALESID
	FROM CUSTINVOICEJOUR
	WHERE DATAAREAID = '4000'
	AND MODIFIEDDATETIME > '${input1}'
	AND MODIFIEDDATETIME <= '${input2}'
	UNION
	SELECT SALESID
	FROM CUSTINVOICETRANS
	WHERE DATAAREAID = '4000'
	AND MODIFIEDDATETIME > '${input1}'
	AND MODIFIEDDATETIME <= '${input2}') AS b
ON a.SALESID = b.SALESID	
INNER JOIN	
	(SELECT SALESID,CREATEDDATETIME,CUSTACCOUNT,MODIFIEDDATETIME
	FROM SALESTABLE
	WHERE DATAAREAID = '4000'
        AND CUSTGROUP = 'JPNDTC') AS c	
ON a.SALESID = c.SALESID	
WHERE a.DATAAREAID = '4000'	
ORDER BY a.SALESID,a.LINENUM


[↓②CSV出力時、レコード毎に取得]-----------------------------------------------
[②-1JANコード(No.17),サイズ(No.20),カラーコード(No.21),カラー名(No.22)]--------
[↓②When outputting CSV, get each record]--------------------------------------- --------
[②-1JAN code (No.17), size (No.20), color code (No.21), color name (No.22)]--------
SELECT	
 GTIN.GLOBALTRADEITEMNUMBER, 	
 INVE_DIM.INVENTSIZEID, 	
 INVE_DIM.INVENTCOLORID	
FROM SALESTABLE AS SALES_T	
INNER JOIN SALESLINE AS SALES_L	
  ON SALES_T.SALESID = SALES_L.SALESID 	
  AND SALES_T.DATAAREAID = SALES_L.DATAAREAID	
INNER JOIN INVENTDIM AS INVE_DIM	
  ON SALES_L.INVENTDIMID = INVE_DIM.INVENTDIMID	
  AND SALES_L.DATAAREAID = INVE_DIM.DATAAREAID	
INNER JOIN INVENTDIM AS INVE_DIM2	
  ON INVE_DIM.INVENTCOLORID = INVE_DIM2.INVENTCOLORID	
  AND INVE_DIM.INVENTSIZEID = INVE_DIM2.INVENTSIZEID	
  AND INVE_DIM.CONFIGID = INVE_DIM2.CONFIGID	
  AND INVE_DIM.DATAAREAID = INVE_DIM2.DATAAREAID	
 INNER JOIN INVENTITEMGTIN AS GTIN	
  ON SALES_L.ITEMID = GTIN.ITEMID	
  AND INVE_DIM2.INVENTDIMID = GTIN.INVENTDIMID	
  AND INVE_DIM2.DATAAREAID = GTIN.DATAAREAID	
 WHERE SALES_T.DATAAREAID = '4000'	
   AND SALES_L.SALESID = ?input1?	
   AND SALES_L.LINENUM = ?input2?	


[②-2売上合計(No.33),受注数(No.23),受注合計(No.27)]-----------------------
[②-2 Sales total (No.33), number of orders received (No.23), total orders received (No.27)]---------------------- -
SELECT SUM(LINEAMOUNT) AS SUM_LINEAMOUNT,
       SUM(QTY) AS SUM_QTY 
  FROM CUSTINVOICETRANS A 
 WHERE SALESID = ?input1?
   AND LINENUM = ?input2?
   AND DATAAREAID = '4000'


[②-3売上伝票番号(No.37)]-------------------------------------------------
[②-3 Sales slip number (No.37)]------------------------------------- ------------
SELECT INVOICEID 
  FROM CUSTINVOICEJOUR 
 WHERE SALESID = ?input1?
 AND DATAAREAID = '4000'


■顧客
■ Customers

[①主となるテーブルより取得]--------------------------------
[(1) Obtained from the main table]--------------------------------
SELECT
    A.ACCOUNTNUM
    , A.CREATEDDATETIME
    , A.PATEXTERNALID
    , B.NAME
    , B.BIRTHDAY
    , B.BIRTHMONTH
    , B.BIRTHYEAR
    , B.GENDER
    , B.PHONETICFIRSTNAME
    , B.PHONETICLASTNAME
    , A.PATCLASSCODE
    , A.PATSOURCEID
    , C.LOCATOR
    , D.LOCATOR 
FROM
    CUSTTABLE A 
    LEFT OUTER JOIN DIRPARTYTABLE B 
        ON A.PARTY = B.RECID 
    INNER JOIN LOGISTICSELECTRONICADDRESS C 
        ON B.PRIMARYCONTACTEMAIL = C.RECID 
    INNER JOIN LOGISTICSELECTRONICADDRESS D 
        ON B.PRIMARYCONTACTPHONE = D.RECID 
WHERE
    ( 
        ( 
            A.MODIFIEDDATETIME > '{前回実行日時}' 
            AND A.MODIFIEDDATETIME <= '{今回実行日時}'
        ) 
        OR ( 
            B.MODIFIEDDATETIME > '{前回実行日時}'
            AND B.MODIFIEDDATETIME <= '{今回実行日時}'
        )
    )
    AND A.DATAAREAID='4000'
ORDER BY A.CREATEDDATETIME


[↓②レコード毎に取得]-----------------------------------------------
[↓② Acquire for each record]--------------------------------------------- -----
SELECT
    C.DESCRIPTION
    , D.CITY
    , D.STATE
    , D.STREET
    , D.ZIPCODE
    , E.LOCATOR
    , C.CREATEDDATETIME
FROM
    CUSTTABLE A 
    LEFT OUTER JOIN DIRPARTYTABLE B 
        ON A.PARTY = B.RECID 
    LEFT OUTER JOIN LOGISTICSLOCATION C 
        ON C.RECID = B.PRIMARYADDRESSLOCATION 
    LEFT OUTER JOIN LOGISTICSPOSTALADDRESS D 
        ON C.RECID = D.LOCATION 
    INNER JOIN LOGISTICSELECTRONICADDRESS E 
        ON B.PRIMARYCONTACTPHONE = E.RECID 
WHERE
    A.ACCOUNTNUM = '{顧客番号}' 
    AND A.DATAAREAID='4000'
    AND D.VALIDFROM = (SELECT MAX(VALIDFROM) FROM LOGISTICSPOSTALADDRESS D2 WHERE D2.LOCATION = C.RECID)
    AND ( 
        ( 
            A.MODIFIEDDATETIME > '{前回実行日時}' 
            AND A.MODIFIEDDATETIME <= '{今回実行日時}'
        ) 
        OR ( 
            D.MODIFIEDDATETIME > '{前回実行日時}' 
            AND D.MODIFIEDDATETIME <= '{今回実行日時}'
        )
    )


