"""
author : 재원
description : inquiry table for Tikkle Map Project
date : 2025.06.05
version : 1.0
"""
from fastapi import APIRouter
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
import pymysql

router = APIRouter()

class Inquiry(BaseModel):
    id : int
    date : str
    type : int
    content : str
    category : str
    status : bool = False
    user_email : str

def connect():
    return pymysql.connect(
        host="127.0.0.1",
        user="root",
        password="qwer1234",
        db="cheapzone",
        charset="utf8"
    )

@router.get('/select')
def select():
    conn = connect()
    curs = conn.cursor()

    sql = "SELECT * FROM inquiry"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)

    return {'results': rows}

@router.get('/select/user_email/{user_email}')
def selectUser(user_email : str):
    conn = connect()
    curs = conn.cursor()

    sql = "SELECT * FROM inquiry WHERE user_email = %s"
    curs.execute(sql, (user_email,))
    rows = curs.fetchall()
    conn.close()
    print(rows)

    return {'results': rows}

@router.get('/select/status/{status}')
def selectStatus(status : bool):
    conn = connect()
    curs = conn.cursor()

    sql = "SELECT * FROM inquiry WHERE status = %s"
    curs.execute(sql, (status,))
    rows = curs.fetchall()
    conn.close()
    print(rows)

    return {'results': rows}

@router.post('/insert')
def insert(inquiry : Inquiry) :
    conn = connect()
    curs = conn.cursor()
    try : 
        sql = "insert into inquiry(date, type, content, category, status, user_email) values (now(), %s, %s, %s, %s, %s)"
        curs.execute(sql,(inquiry.type, inquiry.content, inquiry.category,inquiry.status, inquiry.user_email))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as ex:
        conn.close()
        print("Error:", ex)
        return{'result' : 'Error'}

@router.put('/update/{status}')
def update(id : int, inquiryStatus : bool) :
    conn = connect()
    curs = conn.cursor()
    try : 
        sql = "update inquiry set status = %s where id = %s"
        curs.execute(sql,(inquiryStatus, id))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as ex:
        conn.close()
        print("Error:", ex)
        return{'result' : 'Error'}