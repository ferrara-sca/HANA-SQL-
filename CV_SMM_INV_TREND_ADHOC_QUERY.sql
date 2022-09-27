SELECT
	"BWKEY" AS "DC",
	"MATNR" AS "Material",
	"MATNR_DESC" AS "Material Desc",
	"LABOR" AS "Material ABC Strat",
	"LVORM" AS "Material Del Flag",
	"MVGR1_DESC" AS "Material Brand",
	"PRODH1_DESC" AS "Material ProdH1",
	"ZPRODH2_DESC" AS "Material ProdH2",
	"CALWEEK" AS "Calweek",
	SUM("CM_SNAPSHOT_QTY") AS "Total Inventory Qty",
	SUM("CM_UNRESTRICTED_STOCK_QTY") AS "Unrestricted Stock Qty"
 
FROM "_SYS_BIC"."mm/CV_SMM_INVT_TREND_AD_HOC_QUERY"
	(PLACEHOLDER."$$ip_yyyymm_to$$" => to_nvarchar(CURRENT_DATE, 'YYYYMM'),
	 PLACEHOLDER."$$ip_qty_uom$$" => 'PAL',
	 PLACEHOLDER."$$ip_yyyymm_from$$" => to_nvarchar(ADD_MONTHS(CURRENT_DATE,-1), 'YYYYMM'))
	 
	 WHERE --"BWKEY" IN ('SL41')
	 "MATNR" IN ('00134')
	 AND "CALWEEK" IS NOT NULL
	 
GROUP BY
	"BWKEY",
	"MATNR",
	"MATNR_DESC",
	"LABOR",
	"LVORM",
	"MVGR1_DESC",
	"PRODH1_DESC",
	"ZPRODH2_DESC",
	"CALWEEK"
	
ORDER BY
	"BWKEY",
	"MATNR",
	"CALWEEK"
