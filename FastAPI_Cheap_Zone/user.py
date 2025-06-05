"""
author : smitepaladin 전종익
description : Firebase Authentication를 이용한 티끌맵 회원가입, 로그인, 이메일 중복 검증
date : 2025.06.05
version : 1.0

추가된 firebase_key.json는 firebase키 입니다. 안에 개인 키내용은 빼 놓았습니다.
"""

from fastapi import FastAPI, APIRouter, Form, HTTPException, Request
import pymysql
from pydantic import BaseModel
import os
import firebase_admin
from firebase_admin import credentials, auth as firebase_auth


BASE_DIR = os.path.dirname(os.path.abspath(__file__))  # 현재 파일 기준 디렉토리
KEY_PATH = os.path.join(BASE_DIR, "firebase_key.json")  # 같은 디렉토리에 키 파일이 있는 경우
# 제(종익)가 firebase_key.json 넣어놨습니다.


# 1. Flutter 프론트엔드예시 : Firebase로 회원가입/로그인 → ID 토큰 획득
"""
final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: emailController.text,
  password: passwordController.text,
);
final idToken = await credential.user!.getIdToken(); // 이 토큰을 FastAPI로 보냄
"""
# 2. Flutter → FastAPI 프론트엔드: ID 토큰 + 사용자 정보 전송
"""
final response = await http.post(
  Uri.parse("http://localhost:8000/user/joinuser"),
  headers: {"Content-Type": "application/json"},
  body: json.encode({
    "idToken": idToken,
    "name": nameController.text,
    "phone": phoneController.text,
    "date": birthDate,
    "identification": identificationNumber,
  }),
);
"""
# 3. FastAPI 백엔드 : Firebase 토큰 검증 → DB에 추가 정보 저장
"""
pip install firebase-admin 터미널 실행 필요

"""

# 4. 데이터 흐름도
"""
👤 사용자
   │
   ▼
Flutter 프론트 앱 (프론트를 안 만들었기 때문에 Postman이라는 프로그램으로 검증했습니다.)
   │
   ├─ 회원가입 요청 → Firebase Auth
   │     - 이메일 + 비밀번호
   │     - Firebase가 사용자 생성
   │
   └─ 로그인 요청 → Firebase Auth
         │
         └─ ✔️ 성공 시 ID 토큰(idToken) 발급
                   │
                   ▼
       FastAPI `/user/joinuser`
         - idToken 검증
         - 사용자 정보(name, phone, etc) MySQL에 저장
         ▼
      MySQL: `user` 테이블 저장
"""



# @router.post("/joinuser") # 회원가입 정보 MySQL DB에 insert
# async def joinuser(email: str=Form(...), name: str=Form(...), phone: str=Form(...), date: str=Form(...), identification: int=Form(...)):
#     try:
#         conn = connect()
#         curs = conn.cursor()
#         sql="INSERT INTO user (email, name, phone, date, identification) VALUES (%s, %s, %s, %s, %s)"
#         curs.execute(sql, (email, name, phone, date, identification))
#         conn.commit()
#         conn.close()
#         return {"result":"OK"}
#     except Exception as e:
#         print("Error: ", e)
#         return {"result":"Error"}



# Firebase 초기화 (중복 방지) 만약 이 파일이 다른 모듈에서도 여러 번 import된다면 중복 실행 오류 날 수 있으므로, 초기화 전 체크

if not firebase_admin._apps:
    cred = credentials.Certificate(KEY_PATH)
    firebase_admin.initialize_app(cred)

# FastAPI Router
router = APIRouter()

# MySQL 연결 함수
def connect():
    return pymysql.connect(
        host="127.0.0.1",
        user="root",
        password="qwer1234",
        db="cheapzone",
        charset="utf8"
    )

# 데이터 모델
class JoinUserRequest(BaseModel):
    idToken: str
    name: str
    phone: str
    date: str
    identification: int

# 회원가입 API
@router.post("/joinuser")
async def joinuser(data: JoinUserRequest):
    try:
        # Firebase 토큰 검증
        decoded_token = firebase_auth.verify_id_token(data.idToken)
        email = decoded_token["email"]
        uid = decoded_token["uid"]

        # DB 연결
        conn = connect()
        curs = conn.cursor()

        # 이메일 중복 검사
        curs.execute("SELECT * FROM user WHERE email = %s", (email,))
        if curs.fetchone():
            raise HTTPException(status_code=409, detail="이미 가입된 이메일입니다.")

        # MySQL DB(cheapzone user table)에 사용자 정보 삽입
        sql = """
            INSERT INTO user (email, name, phone, date, identification)
            VALUES (%s, %s, %s, %s, %s)
        """
        curs.execute(sql, (email, data.name, data.phone, data.date, data.identification))
        conn.commit()
        conn.close()

        return {"result": "OK", "uid": uid, "email": email}

    except Exception as e:
        print("Error:", e)
        raise HTTPException(status_code=400, detail="회원가입 실패")
    


# 로그인하기
class LoginRequest(BaseModel):
    idToken: str

@router.post("/login")
async def login(data: LoginRequest):
    try:
        # Firebase ID 토큰 검증
        decoded_token = firebase_auth.verify_id_token(data.idToken)
        uid = decoded_token["uid"]
        email = decoded_token["email"]

        return {
            "result": "OK",
            "uid": uid,
            "email": email
        }

    except firebase_auth.InvalidIdTokenError:
        raise HTTPException(status_code=401, detail="유효하지 않은 토큰입니다.")
    except Exception as e:
        print("Login Error:", e)
        raise HTTPException(status_code=400, detail="로그인 실패")
