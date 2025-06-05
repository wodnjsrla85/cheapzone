"""
author : Jack Jung
description : FastAPI for Tikkle Map Project
date : 2025.06.05
version : 1.0
"""

from fastapi import FastAPI
from user import router as user_router
from employee import router as employee_router
from inquiry import router as inquiry_router
from bookmark import router as bookmark_router
from response import router as response_router
import pymysql


app = FastAPI()
app.include_router(user_router, prefix="/user", tags=['user'])
app.include_router(employee_router, prefix="/employee", tags=['employee'])
app.include_router(inquiry_router, prefix="/inquiry", tags=['inquiry'])
app.include_router(bookmark_router, prefix="/bookmark", tags=['bookmark'])
app.include_router(response_router, prefix="/response", tags=['response'])


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)