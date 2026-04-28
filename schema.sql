DROP TABLE IF EXISTS corn_production;
DROP TABLE IF EXISTS usda_corn_benchmark;
DROP TABLE IF EXISTS farms;

CREATE TABLE farms (
    farm_id INTEGER PRIMARY KEY,
    farm_name TEXT NOT NULL,
    state TEXT NOT NULL,
    farm_size_acres INTEGER NOT NULL
);

CREATE TABLE usda_corn_benchmark (
    year INTEGER PRIMARY KEY,
    us_corn_yield_bu_per_acre REAL NOT NULL,
    source TEXT NOT NULL
);

CREATE TABLE corn_production (
    production_id INTEGER PRIMARY KEY,
    farm_id INTEGER NOT NULL,
    year INTEGER NOT NULL,
    yield_per_acre REAL NOT NULL,
    fertilizer_kg_per_acre REAL NOT NULL,
    rainfall_mm REAL NOT NULL,
    FOREIGN KEY (farm_id) REFERENCES farms(farm_id),
    FOREIGN KEY (year) REFERENCES usda_corn_benchmark(year)
);