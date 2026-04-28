-- Real-Data Hybrid Agriculture SQL Project
-- Focus: compare farm-level corn performance against real USDA national yield benchmarks.

-- 1. Farm-year yield compared with the USDA national benchmark
SELECT
    f.farm_name,
    p.year,
    p.yield_per_acre,
    b.us_corn_yield_bu_per_acre AS us_benchmark,
    ROUND(p.yield_per_acre - b.us_corn_yield_bu_per_acre, 1) AS yield_gap
FROM corn_production p
JOIN farms f ON p.farm_id = f.farm_id
JOIN usda_corn_benchmark b ON p.year = b.year
ORDER BY p.year, yield_gap DESC;

-- 2. Average farm performance across the full period
SELECT
    f.farm_name,
    f.state,
    ROUND(AVG(p.yield_per_acre), 1) AS avg_yield,
    ROUND(AVG(p.fertilizer_kg_per_acre), 1) AS avg_fertilizer,
    ROUND(AVG(p.rainfall_mm), 1) AS avg_rainfall
FROM corn_production p
JOIN farms f ON p.farm_id = f.farm_id
GROUP BY f.farm_name, f.state
ORDER BY avg_yield DESC;

-- 3. State average versus USDA benchmark average
SELECT
    f.state,
    ROUND(AVG(p.yield_per_acre), 1) AS state_avg_yield,
    ROUND(AVG(b.us_corn_yield_bu_per_acre), 1) AS avg_us_benchmark,
    ROUND(AVG(p.yield_per_acre) - AVG(b.us_corn_yield_bu_per_acre), 1) AS benchmark_gap
FROM corn_production p
JOIN farms f ON p.farm_id = f.farm_id
JOIN usda_corn_benchmark b ON p.year = b.year
GROUP BY f.state
ORDER BY benchmark_gap DESC;

-- 4. Input efficiency by farm
SELECT
    f.farm_name,
    ROUND(AVG(p.yield_per_acre / p.fertilizer_kg_per_acre), 3) AS yield_per_kg_fertilizer
FROM corn_production p
JOIN farms f ON p.farm_id = f.farm_id
GROUP BY f.farm_name
ORDER BY yield_per_kg_fertilizer DESC;

-- 5. Yearly project average versus the real national benchmark
SELECT
    p.year,
    ROUND(AVG(p.yield_per_acre), 1) AS project_avg_yield,
    b.us_corn_yield_bu_per_acre AS us_benchmark,
    ROUND(AVG(p.yield_per_acre) - b.us_corn_yield_bu_per_acre, 1) AS project_gap
FROM corn_production p
JOIN usda_corn_benchmark b ON p.year = b.year
GROUP BY p.year, b.us_corn_yield_bu_per_acre
ORDER BY p.year;

-- 6. Flag farm-years that materially underperform or outperform the benchmark
SELECT
    f.farm_name,
    p.year,
    p.yield_per_acre,
    b.us_corn_yield_bu_per_acre,
    ROUND(p.yield_per_acre - b.us_corn_yield_bu_per_acre, 1) AS yield_gap,
    CASE
        WHEN p.yield_per_acre - b.us_corn_yield_bu_per_acre >= 8 THEN 'Strong Outperformance'
        WHEN p.yield_per_acre - b.us_corn_yield_bu_per_acre <= -8 THEN 'Meaningful Underperformance'
        ELSE 'Near Benchmark'
    END AS performance_flag
FROM corn_production p
JOIN farms f ON p.farm_id = f.farm_id
JOIN usda_corn_benchmark b ON p.year = b.year
ORDER BY p.year, yield_gap DESC;

-- 7. Simple decision-support output
SELECT
    f.farm_name,
    p.year,
    p.yield_per_acre,
    p.fertilizer_kg_per_acre,
    p.rainfall_mm,
    ROUND(p.yield_per_acre - b.us_corn_yield_bu_per_acre, 1) AS benchmark_gap,
    CASE
        WHEN p.yield_per_acre < b.us_corn_yield_bu_per_acre - 8 AND p.fertilizer_kg_per_acre >= 195 THEN 'Review input mix and field conditions'
        WHEN p.yield_per_acre < b.us_corn_yield_bu_per_acre - 8 AND p.rainfall_mm < 700 THEN 'Review water stress / irrigation exposure'
        WHEN p.yield_per_acre > b.us_corn_yield_bu_per_acre + 8 THEN 'Document best practices'
        ELSE 'Monitor'
    END AS recommendation
FROM corn_production p
JOIN farms f ON p.farm_id = f.farm_id
JOIN usda_corn_benchmark b ON p.year = b.year
ORDER BY p.year, f.farm_name;