"""
author : Jack Jung - It is mine. 
description : bookmark table for Tikkle Map Project
date : 2025.06.05
version : 1.0
"""

from fastapi import FastAPI, APIRouter, Form
from typing import Optional
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

class BookMark(BaseModel):
    name: str
    type: int
    date: str
    address: str
    status: int
    user_email: str

class BookMarkSimpleUpdate(BaseModel):
    name: str
    status: int
    user_email: str

@router.get("/select")
async def select():
    conn = connect()
    curs = conn.cursor()

    sql = "SELECT * FROM bookmark"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()

    result = [{'name':row[0], 'type':row[1], 'date':row[2], 'address':row[3], 'status':row[4], 'user_email':row[5]}for row in rows]
    return {'results':result}


@router.get("/select/{user_email}")
async def select(user_email: str):
    conn = connect()
    curs = conn.cursor()

    sql = "SELECT * FROM bookmark WHERE user_email = %s"
    curs.execute(sql, (user_email))
    rows = curs.fetchall()
    conn.close()

    result = [{'name':row[0], 'type':row[1], 'date':row[2], 'address':row[3], 'status':row[4], 'user_email':row[5]}for row in rows]
    return {'results':result}


@router.get("/select/{user_email}/{status}")
async def select(user_email: str, status: int):
    conn = connect()
    curs = conn.cursor()

    sql = "SELECT * FROM bookmark WHERE user_email = %s AND status = %s"
    curs.execute(sql, (user_email, status))
    rows = curs.fetchall()
    conn.close()

    result = [{'name':row[0], 'type':row[1], 'date':row[2], 'address':row[3], 'status':row[4], 'user_email':row[5]}for row in rows]
    return {'results':result}



@router.post("/insert")
async def insert(bookMark: BookMark):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = "INSERT INTO bookmark(name, type, date, address, status, user_email) VALUES (%s,%s,%s,%s,%s,%s)"
        curs.execute(sql, (bookMark.name, bookMark.type, bookMark.date, bookMark.address, bookMark.status, bookMark.user_email))
        conn.commit()
        conn.close()
        return {'result': 'OK'}
    except Exception as ex:
        conn.cloese()
        print("Error :", ex)
        return {'result': 'Error'}

@router.post("/update")
async def update(bookMark: BookMark):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = "UPDATE bookmark SET name = %s, type = %s, date= %s, address = %s, status = %s WHERE user_email = %s"
        curs.execute(sql, (bookMark.name, bookMark.type, bookMark.date, bookMark.address, bookMark.status, bookMark.user_email))
        conn.commit()
        conn.close()
        return {'result': 'OK'}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result': 'Error'}
    
@router.post("/simpleupdate")
async def update(bookMarkSimpleUpdate: BookMarkSimpleUpdate):
    conn = connect()
    curs = conn.cursor()

    try:
        sql = "UPDATE bookmark SET status = %s WHERE name = %s and user_email = %s"
        curs.execute(sql, (bookMarkSimpleUpdate.status, bookMarkSimpleUpdate.name, bookMarkSimpleUpdate.user_email))
        conn.commit()
        conn.close()
        return {'result': 'OK'}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result': 'Error'}

