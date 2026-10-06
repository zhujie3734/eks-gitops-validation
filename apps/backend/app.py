"""Adapted from zhujie3734/kubernetes-example/backend/app.py."""
import os
from flask import Flask, request
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import URL, text as sql_text

app = Flask(__name__)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_DATABASE_URI'] = URL.create(
    'postgresql+psycopg2',
    username=os.environ.get('DATABASE_USERNAME', 'postgres'),
    password=os.environ['DATABASE_PASSWORD'],
    host=os.environ.get('DATABASE_URI', 'pg-service'),
    database=os.environ.get('DATABASE_NAME', 'postgres'),
)
db = SQLAlchemy(app)


class Text(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    text = db.Column(db.String(120), nullable=False)


@app.get('/healthy')
def healthy():
    return {'healthy': True, 'version': os.environ.get('APP_VERSION', 'dev')}


@app.get('/ready')
def ready():
    db.session.execute(sql_text('SELECT 1'))
    return {'ready': True}


@app.get('/host_name')
def host_name():
    return {'host_name': os.environ.get('HOSTNAME')}


@app.get('/fetch')
def fetch():
    return {'texts': [{'text': row.text} for row in db.session.scalars(db.select(Text).order_by(Text.id))]}


@app.post('/add')
def add():
    value = (request.get_json(silent=True) or {}).get('text')
    if not isinstance(value, str) or not value.strip() or len(value) > 120:
        return {'error': 'text must contain 1–120 characters'}, 400
    db.session.add(Text(text=value))
    db.session.commit()
    return 'Done', 201


@app.delete('/delete')
def delete():
    db.session.execute(db.delete(Text))
    db.session.commit()
    return 'Done', 200


# A lab schema; production schema changes should use a migration job.
with app.app_context():
    db.create_all()
