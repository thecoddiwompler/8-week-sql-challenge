import psycopg2
import os
import time
from dotenv import load_dotenv


load_dotenv() 

user = os.getenv("user")
password = os.getenv("password")
database = os.getenv("database")

# Sleep for 30s for DB Server to start properly

time.sleep(30)

# Function to establish the connection to the DB

def connect(host, user, password, database):

    try:
        conn = psycopg2.connect(
            host = host,
            user = user,
            password = password,
            dbname = database
        )
    except psycopg2.Error as e:
        print("Could not connect to the Database")
        print(e)

    return conn


# Establish the DB Connection

try:
    conn = connect("postgres", user, password, database)    # Connecting to Postgres host inside container.
except psycopg2.Error as e:
    print("Cannot establish connection to the Database.")
    print(e)

# Set Auto commit for this connection so that we do not have to do conn.commit() everytime after a DML Operation

conn.set_session(autocommit=True)

# Create a cursor to this connection

try:
    curr = conn.cursor()
except psycopg2.Error as e:
    print("Unable to get a cursor for this connection.")
    print(e)

# Create the Schema and Tables and Views. And then, populate those tables.

with open("sample_db/script.sql") as script:
    script = script.read()
    curr.execute(script)
    print("Execution Successful")