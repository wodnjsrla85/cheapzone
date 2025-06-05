"""
author : 재원
description : response table for Tikkle Map Project
date : 2025.06.05
version : 1.0
"""

from fastapi import APIRouter
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
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

class Response(BaseModel):
    content : str
    date : str
    inquiry_id : int
    employee_id : str

@router.post('/insert')
def insert(response : Response):
    conn = connect()
    curs = conn.cursor()
    try : 
        sql = "insert into response(content, date, inquiry_id, employee_id) values (%s, now(), %s, %s)"
        curs.execute(sql,(response.content,response.inquiry_id, response.employee_id))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as ex:
        conn.close()
        print("Eroor:", ex)
        return{'result' : 'Error'}
    
@router.get('/select/{inquiry_id}')
def select(inquiry_id : int):
    conn = connect()
    curs = conn.cursor()

    sql = "SELECT * FROM response WHERE inquiry_id = %s"
    curs.execute(sql,(inquiry_id,))
    rows = curs.fetchall()
    conn.close()
    print(rows)

    return {'results': rows}

