"""
author : 위성배
description : employee table for Tikkle Map Project
date : 2025.06.05
version : 1.0
"""

from fastapi import FastAPI, APIRouter, Form
from pydantic import BaseModel
import pymysql

router = APIRouter()

def connect():
    return pymysql.connect(
        host="192.168.20.10",
        user="root",
        password="qwer1234",
        db="cheapzone",
        charset="utf8"
    )

class Employee(BaseModel):
    id : str
    password : str
    phone : str
    name : str


@router.get("/employee")
async def selectAll(id : str):
    conn = connect()
    curs = conn.cursor()
    curs.execute("select * from employee where id = %s", (id))
    rows = curs.fetchall()
    conn.close

    result = [{"id" : row[0], "password" : row[1], "phone": row[2], "name": row[3]}for row in rows] 
    return {'results':result}

@router.post("/insert_emp") 
async def insertEmp(id : str = Form(...), password : str = Form(...), phone : str = Form(...), name : str = Form(...)):
    conn = connect()
    curs = conn.cursor()

    try : 
        sql = "insert into employee(id, password, phone, name) values (%s,%s,%s,%s)"
        curs.execute(sql, (id,password,phone,name))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        conn.close()
        print("Error : ", e)
        return {'result' : 'Error'}
