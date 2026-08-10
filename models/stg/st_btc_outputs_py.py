import pandas
import simplejson

def model(dbt, session):

    dbt.config(materialized="table", packages=["pandas","pyarrow" ,"simplejson"])

    df = dbt.ref("stg_btc").to_pandas()  #converts Snowpark DataFrame to pandas DataFrame

    df["OUTPUTS"] = df["OUTPUTS"].apply(simplejson.loads) #df['output'] is json format. Parses JSON text in each OUTPUTS cell into real Python objects (usually list of dicts).

    df_exploded = df.explode("OUTPUTS").reset_index(drop=True) # turns each item in OUTPUTS list into its own row

    df_outputs = pandas.json_normalize(df_exploded["OUTPUTS"])[["address", "value"]] #Takes nested dicts and flattens them into columns.

    df_final = pandas.concat([df_exploded.drop(columns="OUTPUTS"), df_outputs],axis=1)

    df_final = df_final[df_final["address"].notnull()]

    df_final.columns = [col.upper() for col in df_final.columns]

    return df_final

     
