from pathlib import Path
import pandas as pd
import geopandas as gpd
from sqlalchemy import create_engine, text


engine = create_engine("postgresql+psycopg://mike@edw:5432/ipds")


def upload_study_areas():
    BASE_DIR = Path("/mnt/q/3_Projects/ROCKETRUST/Y2 Activity 2 - Alpine-Joy Place-Based Investment Area Analysis/Shapefiles")
    assert BASE_DIR.exists()
    
    files = [
        "Alpine_Joy_boundary_20260511_v2.shp",
        "Alpine_Joy_boundary_mi_20260521.shp",
        "Alpine_Joy_boundary_quartmi_20260520.shp",
    ]
    
    result = []
    for file in files:
        frame = gpd.read_file(BASE_DIR / file)
        frame = frame.rename(columns={c: c.lower() for c in frame.columns})

        result.append(frame)
    

    frame = pd.concat(result) 

    frame.to_postgis(
        "alpine_joy_study_areas",
        engine,
        schema="rocket",
        index=False,
        if_exists="append"
    )


def main():
    upload_study_areas()

if __name__ == "__main__":
    main()
