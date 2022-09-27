WITH A AS (
SELECT
	"WERKS",
	"MATNR",
	"MATNR_DESC",
	"CA_CALWEEK",
	"BERW1"
	
FROM "_SYS_BIC"."mm/CV_SMM_ACTUAL_COVERAGE_MD04_QUERY"
	(PLACEHOLDER."$$ip_period_indicator$$" => 'W')
	
	WHERE "WERKS" IN ('SL41') 
	--AND "MATNR" IN ('71389')
	AND "CA_CALWEEK" <= to_nvarchar(ADD_MONTHS(CURRENT_DATE,7), 'YYYYWW')
	
GROUP BY
	"WERKS",
	"MATNR",
	"MATNR_DESC",
	"CA_CALWEEK",
	"BERW1"
	
ORDER BY
	"MATNR",
	"CA_CALWEEK"
)

SELECT
	B."SNAPSHOT_DATE" AS "Snapshot Date",
	CASE WHEN B."CALWEEK" IS NULL THEN 'Initial'
		 ELSE 'Projection' END AS "APO Status",
	B."CA_LOCATION" AS "DC",
	B."MATNR" AS "Material",
	B."MATNR_DESC" AS "Material Desc",
	B."MTART" AS "Material Type",
	B."LABOR" AS "Material ABC Strat",
	B."LVORM" AS "Material Del Flag",
	B."BRAND_DESC" AS "Material Brand",
	B."PRODH1_DESC" AS "Material ProdH1",
	B."ZPRODH2_DESC" AS "Material ProdH2",
	B."CALWEEK" AS "Calweek",
	A."BERW1" AS "Actual Days of Coverage",
	ROUND(SUM(B."CM_UNREST_STOCK_QTY"),2) AS "APO Unrestrd Stock Qty",
	ROUND(SUM(B."CM_STOCK_ON_HAND_PROJ"),2) AS "Stock on Hand (Proj) Qty",
	SUM(NULL) AS "Total Inventory Qty",
	SUM(NULL) AS "Unrestricted Stock Qty",		
	ROUND(SUM(B."CM_FORECAST"),2) AS "Forecast Qty",
	ROUND(SUM(B."CM_FORECAST_ADTNL"),2) AS "Additional Forecast Qty",
	ROUND(SUM(B."CM_DEMAND_FCST_SALES_ORDER"),2) AS "Demand (Fcst/SO) Qty",
	ROUND(SUM(B."CM_SALES_ORDER"),2) AS "Sales Order Qty",
	ROUND(SUM(B."CM_DIST_DEMAND_PLANNED"),2) AS "Dist Demand (Planned) Qty",
	ROUND(SUM(B."CM_DIST_DEMAND_CONFIRMED"),2) AS "Dist Demand (Confirmed) Qty",
	ROUND(SUM(B."CM_DIST_DEMAND_TLB_CONFIRMED"),2) AS "Dist Demand (TLB-Conf) Qty",
	ROUND(SUM(B."CM_SUB_DEMAND_PLANNED"),2) AS "Sub Demand (Planned) Qty",
	ROUND(SUM(B."CM_DEPENDENT_DEMAND"),2) AS "Dependent Demand Qty",
	ROUND(SUM(B."CM_TOTAL_DEMAND"),2) AS "Total Demand Qty",
	ROUND(SUM(B."CM_DIST_RECEIPT_PLANNED"),2) AS "Dist Receipt (Planned) Qty",
	ROUND(SUM(B."CM_DIST_RECEIPT_CONFIRMED"),2) AS "Dist Receipt (Confirmed) Qty",
	ROUND(SUM(B."CM_DIST_RECEIPT_TLB_CONFIRMED"),2) AS "Dist Receipt (TLB-Conf) Qty",
	ROUND(SUM(B."CM_IN_TRANSIT"),2) AS "In Transit Qty",
	ROUND(SUM(B."CM_PRODUCTION_PLANNED"),2) AS "Production (Planned) Qty",
	ROUND(SUM(B."CM_PRODUCTION_CONFIRMED"),2) AS "Production (Confirmed) Qty",
	ROUND(SUM(B."CM_MANUFACTURE_CO_PRODUCTS"),2) AS "Manufacture of Co-Products Qty",
	ROUND(SUM(B."CM_TOTAL_RECEIPTS"),2) AS "Total Receipts Qty",
	ROUND(SUM(B."CM_SUPPLY_SHORTAGE"),2) AS "Supply Shortage Qty",
	ROUND(SUM(B."SAFETY_DAYS_PLANNED"),2) AS "Safety Days (Planned)",
	ROUND(SUM(B."CM_SAFETY_STOCK_PLANNED"),2) AS "Safety Stock (Planned) Qty"

FROM "_SYS_BIC"."snp/CV_SNP_PLAN_QUERY"
	 (PLACEHOLDER."$$ip_yyyymm_from$$" => to_nvarchar(CURRENT_DATE, 'YYYYMM'),
	  PLACEHOLDER."$$ip_yyyymm_to$$" => to_nvarchar(ADD_MONTHS(CURRENT_DATE,6),'YYYYMM'),
	  PLACEHOLDER."$$ip_snapshot_date$$" => to_nvarchar(CASE WHEN WEEKDAY(CURRENT_DATE) = 0 THEN ADD_DAYS(CURRENT_DATE,-17)
	  														 WHEN WEEKDAY(CURRENT_DATE) = 1 THEN ADD_DAYS(CURRENT_DATE,-18)
	  														 WHEN WEEKDAY(CURRENT_DATE) = 2 THEN ADD_DAYS(CURRENT_DATE,-19)
	  														 WHEN WEEKDAY(CURRENT_DATE) = 3 THEN ADD_DAYS(CURRENT_DATE,-20) 
	  														 WHEN WEEKDAY(CURRENT_DATE) = 4 THEN ADD_DAYS(CURRENT_DATE,-14)
	  														 WHEN WEEKDAY(CURRENT_DATE) = 5 THEN ADD_DAYS(CURRENT_DATE,-15)
	  														 WHEN WEEKDAY(CURRENT_DATE) = 6 THEN ADD_DAYS(CURRENT_DATE,-16) END,'YYYYMMDD'),
	  PLACEHOLDER."$$ip_initial_ind$$" => 'Yes',
	  PLACEHOLDER."$$ip_version$$" => '000',
	  PLACEHOLDER."$$ip_schedule$$" => 'User Input',
	  PLACEHOLDER."$$ip_qty_uom$$" => 'PAL',
	  PLACEHOLDER."$$ip_time_dimension$$" => 'Weekly') AS B
	  
	 LEFT OUTER JOIN A ON B."MATNR" = A."MATNR"
	 AND B."CALWEEK" = A."CA_CALWEEK"
	 
	 WHERE B."CA_LOCATION" IN ('SL41')
	 --AND B."MATNR" IN ('01256')
	 AND B."LABOR" NOT IN ('S','N','S15','S1','M','S2','S5','S7','S10','D','S4','S8','S6','S3','S12')
	 AND B."LVORM" NOT IN ('X')
	 AND B."MTART" IN ('FG')
	 
GROUP BY
	B."SNAPSHOT_DATE",
	B."CA_LOCATION",
	B."MATNR",
	B."MATNR_DESC",
	B."MTART",
	B."LABOR",
	B."LVORM",
	B."BRAND_DESC",
	B."PRODH1_DESC",
	B."ZPRODH2_DESC",
	B."CALWEEK",
    A."BERW1"
	
UNION

SELECT
	C."SNAPSHOT_DATE" AS "Snapshot Date",
	CASE WHEN C."CALWEEK" IS NULL THEN 'Initial'
		 ELSE 'Projection' END AS "APO Status",
	C."CA_LOCATION" AS "DC",
	C."MATNR" AS "Material",
	C."MATNR_DESC" AS "Material Desc",
	C."MTART" AS "Material Type",
	C."LABOR" AS "Material ABC Strat",
	C."LVORM" AS "Material Del Flag",
	C."BRAND_DESC" AS "Material Brand",
	C."PRODH1_DESC" AS "Material ProdH1",
	C."ZPRODH2_DESC" AS "Material ProdH2",
	C."CALWEEK" AS "Calweek",
	A."BERW1" AS "Actual Days of Coverage",
	ROUND(SUM(C."CM_UNREST_STOCK_QTY"),2) AS "APO Unrestrd Stock Qty",
	ROUND(SUM(C."CM_STOCK_ON_HAND_PROJ"),2) AS "Stock on Hand (Proj) Qty",
	SUM(NULL) AS "Total Inventory Qty",
	SUM(NULL) AS "Unrestricted Stock Qty",		
	ROUND(SUM(C."CM_FORECAST"),2) AS "Forecast Qty",
	ROUND(SUM(C."CM_FORECAST_ADTNL"),2) AS "Additional Forecast Qty",
	ROUND(SUM(C."CM_DEMAND_FCST_SALES_ORDER"),2) AS "Demand (Fcst/SO) Qty",
	ROUND(SUM(C."CM_SALES_ORDER"),2) AS "Sales Order Qty",
	ROUND(SUM(C."CM_DIST_DEMAND_PLANNED"),2) AS "Dist Demand (Planned) Qty",
	ROUND(SUM(C."CM_DIST_DEMAND_CONFIRMED"),2) AS "Dist Demand (Confirmed) Qty",
	ROUND(SUM(C."CM_DIST_DEMAND_TLB_CONFIRMED"),2) AS "Dist Demand (TLB-Conf) Qty",
	ROUND(SUM(C."CM_SUB_DEMAND_PLANNED"),2) AS "Sub Demand (Planned) Qty",
	ROUND(SUM(C."CM_DEPENDENT_DEMAND"),2) AS "Dependent Demand Qty",
	ROUND(SUM(C."CM_TOTAL_DEMAND"),2) AS "Total Demand Qty",
	ROUND(SUM(C."CM_DIST_RECEIPT_PLANNED"),2) AS "Dist Receipt (Planned) Qty",
	ROUND(SUM(C."CM_DIST_RECEIPT_CONFIRMED"),2) AS "Dist Receipt (Confirmed) Qty",
	ROUND(SUM(C."CM_DIST_RECEIPT_TLB_CONFIRMED"),2) AS "Dist Receipt (TLB-Conf) Qty",
	ROUND(SUM(C."CM_IN_TRANSIT"),2) AS "In Transit Qty",
	ROUND(SUM(C."CM_PRODUCTION_PLANNED"),2) AS "Production (Planned) Qty",
	ROUND(SUM(C."CM_PRODUCTION_CONFIRMED"),2) AS "Production (Confirmed) Qty",
	ROUND(SUM(C."CM_MANUFACTURE_CO_PRODUCTS"),2) AS "Manufacture of Co-Products Qty",
	ROUND(SUM(C."CM_TOTAL_RECEIPTS"),2) AS "Total Receipts Qty",
	ROUND(SUM(C."CM_SUPPLY_SHORTAGE"),2) AS "Supply Shortage Qty",
	ROUND(SUM(C."SAFETY_DAYS_PLANNED"),2) AS "Safety Days (Planned)",
	ROUND(SUM(C."CM_SAFETY_STOCK_PLANNED"),2) AS "Safety Stock (Planned) Qty"

FROM "_SYS_BIC"."snp/CV_SNP_PLAN_QUERY"
	 (PLACEHOLDER."$$ip_yyyymm_from$$" => to_nvarchar(CURRENT_DATE, 'YYYYMM'),
	  PLACEHOLDER."$$ip_yyyymm_to$$" => to_nvarchar(ADD_MONTHS(CURRENT_DATE,6),'YYYYMM'),
	  PLACEHOLDER."$$ip_snapshot_date$$" => to_nvarchar(CASE WHEN WEEKDAY(CURRENT_DATE) = 0 THEN ADD_DAYS(CURRENT_DATE,-10)
	  														 WHEN WEEKDAY(CURRENT_DATE) = 1 THEN ADD_DAYS(CURRENT_DATE,-11)
	  														 WHEN WEEKDAY(CURRENT_DATE) = 2 THEN ADD_DAYS(CURRENT_DATE,-12)
	  														 WHEN WEEKDAY(CURRENT_DATE) = 3 THEN ADD_DAYS(CURRENT_DATE,-13) 
	  														 WHEN WEEKDAY(CURRENT_DATE) = 4 THEN ADD_DAYS(CURRENT_DATE,-7)
	  														 WHEN WEEKDAY(CURRENT_DATE) = 5 THEN ADD_DAYS(CURRENT_DATE,-8)
	  														 WHEN WEEKDAY(CURRENT_DATE) = 6 THEN ADD_DAYS(CURRENT_DATE,-9) END,'YYYYMMDD'),
	  PLACEHOLDER."$$ip_initial_ind$$" => 'Yes',
	  PLACEHOLDER."$$ip_version$$" => '000',
	  PLACEHOLDER."$$ip_schedule$$" => 'User Input',
	  PLACEHOLDER."$$ip_qty_uom$$" => 'PAL',
	  PLACEHOLDER."$$ip_time_dimension$$" => 'Weekly') AS C
	 
	 LEFT OUTER JOIN A ON C."MATNR" = A."MATNR"
	 AND C."CALWEEK" = A."CA_CALWEEK"
	 
	 WHERE C."CA_LOCATION" IN ('SL41')
	 --AND C."MATNR" IN ('01256')
	 AND C."LABOR" NOT IN ('S','N','S15','S1','M','S2','S5','S7','S10','D','S4','S8','S6','S3','S12')
	 AND C."LVORM" NOT IN ('X')
	 AND C."MTART" IN ('FG')
	 
GROUP BY
	C."SNAPSHOT_DATE",
	C."CA_LOCATION",
	C."MATNR",
	C."MATNR_DESC",
	C."MTART",
	C."LABOR",
	C."LVORM",
	C."BRAND_DESC",
	C."PRODH1_DESC",
	C."ZPRODH2_DESC",
	C."CALWEEK",
    A."BERW1"

UNION

SELECT
	D."SNAPSHOT_DATE" AS "Snapshot Date",
	CASE WHEN D."CALWEEK" IS NULL THEN 'Initial'
		 ELSE 'Projection' END AS "APO Status",
	D."CA_LOCATION" AS "DC",
	D."MATNR" AS "Material",
	D."MATNR_DESC" AS "Material Desc",
	D."MTART" AS "Material Type",
	D."LABOR" AS "Material ABC Strat",
	D."LVORM" AS "Material Del Flag",
	D."BRAND_DESC" AS "Material Brand",
	D."PRODH1_DESC" AS "Material ProdH1",
	D."ZPRODH2_DESC" AS "Material ProdH2",
	D."CALWEEK" AS "Calweek",
	A."BERW1" AS "Actual Days of Coverage",
	ROUND(SUM(D."CM_UNREST_STOCK_QTY"),2) AS "APO Unrestrd Stock Qty",
	ROUND(SUM(D."CM_STOCK_ON_HAND_PROJ"),2) AS "Stock on Hand (Proj) Qty",
	SUM(NULL) AS "Total Inventory Qty",
	SUM(NULL) AS "Unrestricted Stock Qty",		
	ROUND(SUM(D."CM_FORECAST"),2) AS "Forecast Qty",
	ROUND(SUM(D."CM_FORECAST_ADTNL"),2) AS "Additional Forecast Qty",
	ROUND(SUM(D."CM_DEMAND_FCST_SALES_ORDER"),2) AS "Demand (Fcst/SO) Qty",
	ROUND(SUM(D."CM_SALES_ORDER"),2) AS "Sales Order Qty",
	ROUND(SUM(D."CM_DIST_DEMAND_PLANNED"),2) AS "Dist Demand (Planned) Qty",
	ROUND(SUM(D."CM_DIST_DEMAND_CONFIRMED"),2) AS "Dist Demand (Confirmed) Qty",
	ROUND(SUM(D."CM_DIST_DEMAND_TLB_CONFIRMED"),2) AS "Dist Demand (TLB-Conf) Qty",
	ROUND(SUM(D."CM_SUB_DEMAND_PLANNED"),2) AS "Sub Demand (Planned) Qty",
	ROUND(SUM(D."CM_DEPENDENT_DEMAND"),2) AS "Dependent Demand Qty",
	ROUND(SUM(D."CM_TOTAL_DEMAND"),2) AS "Total Demand Qty",
	ROUND(SUM(D."CM_DIST_RECEIPT_PLANNED"),2) AS "Dist Receipt (Planned) Qty",
	ROUND(SUM(D."CM_DIST_RECEIPT_CONFIRMED"),2) AS "Dist Receipt (Confirmed) Qty",
	ROUND(SUM(D."CM_DIST_RECEIPT_TLB_CONFIRMED"),2) AS "Dist Receipt (TLB-Conf) Qty",
	ROUND(SUM(D."CM_IN_TRANSIT"),2) AS "In Transit Qty",
	ROUND(SUM(D."CM_PRODUCTION_PLANNED"),2) AS "Production (Planned) Qty",
	ROUND(SUM(D."CM_PRODUCTION_CONFIRMED"),2) AS "Production (Confirmed) Qty",
	ROUND(SUM(D."CM_MANUFACTURE_CO_PRODUCTS"),2) AS "Manufacture of Co-Products Qty",
	ROUND(SUM(D."CM_TOTAL_RECEIPTS"),2) AS "Total Receipts Qty",
	ROUND(SUM(D."CM_SUPPLY_SHORTAGE"),2) AS "Supply Shortage Qty",
	ROUND(SUM(D."SAFETY_DAYS_PLANNED"),2) AS "Safety Days (Planned)",
	ROUND(SUM(D."CM_SAFETY_STOCK_PLANNED"),2) AS "Safety Stock (Planned) Qty"

FROM "_SYS_BIC"."snp/CV_SNP_PLAN_QUERY"
	 (PLACEHOLDER."$$ip_yyyymm_from$$" => to_nvarchar(CURRENT_DATE, 'YYYYMM'),
	  PLACEHOLDER."$$ip_yyyymm_to$$" => to_nvarchar(ADD_MONTHS(CURRENT_DATE,6),'YYYYMM'),
	  PLACEHOLDER."$$ip_snapshot_date$$" => to_nvarchar(CASE WHEN WEEKDAY(CURRENT_DATE) = 0 THEN ADD_DAYS(CURRENT_DATE,-3)
	  														 WHEN WEEKDAY(CURRENT_DATE) = 1 THEN ADD_DAYS(CURRENT_DATE,-4)
	  														 WHEN WEEKDAY(CURRENT_DATE) = 2 THEN ADD_DAYS(CURRENT_DATE,-5)
	  														 WHEN WEEKDAY(CURRENT_DATE) = 3 THEN ADD_DAYS(CURRENT_DATE,-6) 
	  														 WHEN WEEKDAY(CURRENT_DATE) = 4 THEN CURRENT_DATE
	  														 WHEN WEEKDAY(CURRENT_DATE) = 5 THEN ADD_DAYS(CURRENT_DATE,-1)
	  														 WHEN WEEKDAY(CURRENT_DATE) = 6 THEN ADD_DAYS(CURRENT_DATE,-2) END,'YYYYMMDD'),
	  PLACEHOLDER."$$ip_initial_ind$$" => 'Yes',
	  PLACEHOLDER."$$ip_version$$" => '000',
	  PLACEHOLDER."$$ip_schedule$$" => 'User Input',
	  PLACEHOLDER."$$ip_qty_uom$$" => 'PAL',
	  PLACEHOLDER."$$ip_time_dimension$$" => 'Weekly') AS D
	 
	 LEFT OUTER JOIN A ON D."MATNR" = A."MATNR"
	 AND D."CALWEEK" = A."CA_CALWEEK"
	 
	 WHERE D."CA_LOCATION" IN ('SL41')
	 --AND D."MATNR" IN ('01256')
	 AND D."LABOR" NOT IN ('S','N','S15','S1','M','S2','S5','S7','S10','D','S4','S8','S6','S3','S12')
	 AND D."LVORM" NOT IN ('X')
	 AND D."MTART" IN ('FG')
	 
GROUP BY
	D."SNAPSHOT_DATE",
	D."CA_LOCATION",
	D."MATNR",
	D."MATNR_DESC",
	D."MTART",
	D."LABOR",
	D."LVORM",
	D."BRAND_DESC",
	D."PRODH1_DESC",
	D."ZPRODH2_DESC",
	D."CALWEEK",
    A."BERW1"
    
UNION

SELECT
	CASE WHEN WEEKDAY(CURRENT_DATE) = 4 THEN to_nvarchar(ADD_DAYS(CURRENT_DATE,1), 'YYYYMMDD')
	 	 ELSE to_nvarchar(CURRENT_DATE,'YYYYMMDD') END AS "Snapshot Date",
	CASE WHEN E."CALWEEK" IS NULL THEN 'Initial'
		 ELSE 'Projection' END AS "APO Status",
	E."CA_LOCATION" AS "DC",
	E."MATNR" AS "Material",
	E."MATNR_DESC" AS "Material Desc",
	E."MTART" AS "Material Type",
	E."LABOR" AS "Material ABC Strat",
	E."LVORM" AS "Material Del Flag",
	E."BRAND_DESC" AS "Material Brand",
	E."PRODH1_DESC" AS "Material ProdH1",
	E."ZPRODH2_DESC" AS "Material ProdH2",
	E."CALWEEK" AS "Calweek",
	A."BERW1" AS "Actual Days of Coverage",
	ROUND(SUM(E."CM_UNREST_STOCK_QTY"),2) AS "APO Unrestrd Stock Qty",
	ROUND(SUM(E."CM_STOCK_ON_HAND_PROJ"),2) AS "Stock on Hand (Proj) Qty",
	SUM(NULL) AS "Total Inventory Qty",
	SUM(NULL) AS "Unrestricted Stock Qty",	
	ROUND(SUM(E."CM_FORECAST"),2) AS "Forecast Qty",
	ROUND(SUM(E."CM_FORECAST_ADTNL"),2) AS "Additional Forecast Qty",
	ROUND(SUM(E."CM_DEMAND_FCST_SALES_ORDER"),2) AS "Demand (Fcst/SO) Qty",
	ROUND(SUM(E."CM_SALES_ORDER"),2) AS "Sales Order Qty",
	ROUND(SUM(E."CM_DIST_DEMAND_PLANNED"),2) AS "Dist Demand (Planned) Qty",
	ROUND(SUM(E."CM_DIST_DEMAND_CONFIRMED"),2) AS "Dist Demand (Confirmed) Qty",
	ROUND(SUM(E."CM_DIST_DEMAND_TLB_CONFIRMED"),2) AS "Dist Demand (TLB-Conf) Qty",
	ROUND(SUM(E."CM_SUB_DEMAND_PLANNED"),2) AS "Sub Demand (Planned) Qty",
	ROUND(SUM(E."CM_DEPENDENT_DEMAND"),2) AS "Dependent Demand Qty",
	ROUND(SUM(E."CM_TOTAL_DEMAND"),2) AS "Total Demand Qty",
	ROUND(SUM(E."CM_DIST_RECEIPT_PLANNED"),2) AS "Dist Receipt (Planned) Qty",
	ROUND(SUM(E."CM_DIST_RECEIPT_CONFIRMED"),2) AS "Dist Receipt (Confirmed) Qty",
	ROUND(SUM(E."CM_DIST_RECEIPT_TLB_CONFIRMED"),2) AS "Dist Receipt (TLB-Conf) Qty",
	ROUND(SUM(E."CM_IN_TRANSIT"),2) AS "In Transit Qty",
	ROUND(SUM(E."CM_PRODUCTION_PLANNED"),2) AS "Production (Planned) Qty",
	ROUND(SUM(E."CM_PRODUCTION_CONFIRMED"),2) AS "Production (Confirmed) Qty",
	ROUND(SUM(E."CM_MANUFACTURE_CO_PRODUCTS"),2) AS "Manufacture of Co-Products Qty",
	ROUND(SUM(E."CM_TOTAL_RECEIPTS"),2) AS "Total Receipts Qty",
	ROUND(SUM(E."CM_SUPPLY_SHORTAGE"),2) AS "Supply Shortage Qty",
	ROUND(SUM(E."SAFETY_DAYS_PLANNED"),2) AS "Safety Days (Planned)",
	ROUND(SUM(E."CM_SAFETY_STOCK_PLANNED"),2) AS "Safety Stock (Planned) Qty"

FROM "_SYS_BIC"."snp/CV_SNP_PLAN_QUERY"
	 (PLACEHOLDER."$$ip_yyyymm_from$$" => to_nvarchar(CURRENT_DATE, 'YYYYMM'),
	  PLACEHOLDER."$$ip_yyyymm_to$$" => to_nvarchar(ADD_MONTHS(CURRENT_DATE,6),'YYYYMM'),
	  PLACEHOLDER."$$ip_snapshot_date$$" => '',
	  PLACEHOLDER."$$ip_initial_ind$$" => 'Yes',
	  PLACEHOLDER."$$ip_version$$" => '000',
	  PLACEHOLDER."$$ip_schedule$$" => 'User Input',
	  PLACEHOLDER."$$ip_qty_uom$$" => 'PAL',
	  PLACEHOLDER."$$ip_time_dimension$$" => 'Weekly') AS E
	 
	 LEFT OUTER JOIN A ON E."MATNR" = A."MATNR"
	 AND E."CALWEEK" = A."CA_CALWEEK"
	 
	 WHERE E."CA_LOCATION" IN ('SL41')
	 --AND E."MATNR" IN ('01256')
	 AND E."LABOR" NOT IN ('S','N','S15','S1','M','S2','S5','S7','S10','D','S4','S8','S6','S3','S12')
	 AND E."LVORM" NOT IN ('X')
	 AND E."MTART" IN ('FG')
	 
GROUP BY
	E."SNAPSHOT_DATE",
	E."CA_LOCATION",
	E."MATNR",
	E."MATNR_DESC",
	E."MTART",
	E."LABOR",
	E."LVORM",
	E."BRAND_DESC",
	E."PRODH1_DESC",
	E."ZPRODH2_DESC",
	E."CALWEEK",
    A."BERW1"

UNION

SELECT
	CASE WHEN WEEKDAY(CURRENT_DATE) = 4 THEN to_nvarchar(ADD_DAYS(CURRENT_DATE,1), 'YYYYMMDD')
	 	 ELSE to_nvarchar(CURRENT_DATE,'YYYYMMDD') END AS "Snapshot Date",
	CASE WHEN F."CALWEEK" IS NULL THEN 'Initial'
		 ELSE 'Projection' END AS "APO Status",
	F."BWKEY" AS "DC",
	F."MATNR" AS "Material",
	F."MATNR_DESC" AS "Material Desc",
	F."MTART" AS "Material Type",
	F."LABOR" AS "Material ABC Strat",
	F."LVORM" AS "Material Del Flag",
	F."MVGR1_DESC" AS "Material Brand",
	F."PRODH1_DESC" AS "Material ProdH1",
	F."ZPRODH2_DESC" AS "Material ProdH2",
	F."CALWEEK" AS "Calweek",
	SUM(NULL) AS "Actual Days of Coverage",
	SUM(NULL) AS "APO Unrestrd Stock Qty",
	SUM(NULL) AS "Stock on Hand (Proj) Qty",
	SUM(F."CM_SNAPSHOT_QTY") AS "Total Inventory Qty",
	SUM(F."CM_UNRESTRICTED_STOCK_QTY") AS "Unrestricted Stock Qty",
	SUM(NULL) AS "Forecast Qty",
	SUM(NULL) AS "Additional Forecast Qty",
	SUM(NULL) AS "Demand (Fcst/SO) Qty",
	SUM(NULL) AS "Sales Order Qty",
	SUM(NULL) AS "Dist Demand (Planned) Qty",
	SUM(NULL) AS "Dist Demand (Confirmed) Qty",
	SUM(NULL) AS "Dist Demand (TLB-Conf) Qty",
	SUM(NULL) AS "Sub Demand (Planned) Qty",
	SUM(NULL) AS "Dependent Demand Qty",
	SUM(NULL) AS "Total Demand Qty",
	SUM(NULL) AS "Dist Receipt (Planned) Qty",
	SUM(NULL) AS "Dist Receipt (Confirmed) Qty",
	SUM(NULL) AS "Dist Receipt (TLB-Conf) Qty",
	SUM(NULL) AS "In Transit Qty",
	SUM(NULL) AS "Production (Planned) Qty",
	SUM(NULL) AS "Production (Confirmed) Qty",
	SUM(NULL) AS "Manufacture of Co-Products Qty",
	SUM(NULL) AS "Total Receipts Qty",
	SUM(NULL) AS "Supply Shortage Qty",
	SUM(NULL) AS "Safety Days (Planned)",
	SUM(NULL) AS "Safety Stock (Planned) Qty"
 
FROM "_SYS_BIC"."mm/CV_SMM_INVT_TREND_AD_HOC_QUERY"
	(PLACEHOLDER."$$ip_yyyymm_to$$" => to_nvarchar(CURRENT_DATE, 'YYYYMM'),
	 PLACEHOLDER."$$ip_qty_uom$$" => 'PAL',
	 PLACEHOLDER."$$ip_yyyymm_from$$" => '202101') AS F
	 
	 --LEFT OUTER JOIN A ON F."MATNR" = A."MATNR"
	 --AND F."CALWEEK" = A."CA_CALWEEK"	 
	 
	 WHERE F."BWKEY" IN ('SL41')
	 --AND F."MATNR" IN ('01256')
	 AND F."CALWEEK" IS NOT NULL
	 AND F."LABOR" NOT IN ('S','N','S15','S1','M','S2','S5','S7','S10','D','S4','S8','S6','S3','S12')
	 AND F."MTART" IN ('FG')
	 
GROUP BY
	F."BWKEY",
	F."MATNR",
	F."MATNR_DESC",
	F."MTART",
	F."LABOR",
	F."LVORM",
	F."MVGR1_DESC",
	F."PRODH1_DESC",
	F."ZPRODH2_DESC",
	F."CALWEEK"
	--A."BERW1"
	
ORDER BY
	"Snapshot Date" DESC,
	"Material",
	"Calweek"
