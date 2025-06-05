"""
author : Jack Jung
description : response table for Tikkle Map Project
date : 2025.06.05
version : 1.0
"""

from fastapi import FastAPI, APIRouter, Form
import pymysql

router = APIRouter()

def connect():
    return pymysql.connect(
        host="127.0.0.1",
        user="root",
        password="qwer1234",
        db="cheapzone",
        charset="utf8"
    )