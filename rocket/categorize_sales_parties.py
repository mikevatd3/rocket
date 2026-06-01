import pandas as pd
from sqlalchemy import create_engine, text
from owner_classification.predict import OwnerClassifier


CHUNK_SIZE = 5000

db = create_engine("postgresql+psycopg://mike@edw:5432/ipds")

def label_grantors_grantees():
    
    predictor = OwnerClassifier()
    
    row_q = text("""
    SELECT sale_id, grantor, grantee
    FROM rocket.detroit_assessors_sales
    WHERE sale_id > :max_sale_id
    ORDER BY sale_id
    LIMIT :limit;
    """)

    mode="w"
    i = 1
    max_sale_id = 0
    while True:
        print(f"Predicting chunk {i}")
        with db.connect() as conn:
            frame = pd.read_sql(
                row_q,
                conn,
                params={"max_sale_id": max_sale_id, "limit": CHUNK_SIZE}
            )
        if len(frame) == 0: break

        max_sale_id = frame["sale_id"].max()
        
        print(f"Predicting grantors for chunk {i}")
        frame["grantor_category"] = predictor.predict(frame["grantor"].to_list())
        print(f"Predicting grantees for chunk {i}")
        frame["grantee_category"] = predictor.predict(frame["grantee"].to_list())
        
        frame.to_csv("party_categories.csv", index=False, mode=mode)
        mode="a"


def insert_grantors_grantees():
    if_exists = "replace"
    for i, chunk in enumerate(pd.read_csv("party_categories.csv", chunksize=1000), start=1):
        print(f"Pushing chunk {i} to ipds.")
        chunk.to_sql("sales_parties_predicted", db, schema="rocket", if_exists=if_exists)
        if_exists = "append"


