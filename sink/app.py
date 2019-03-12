import logging
import os

import asyncio
import uvicorn
from starlette.applications import Starlette
from starlette.middleware.gzip import GZipMiddleware
from starlette.responses import HTMLResponse, PlainTextResponse, RedirectResponse, UJSONResponse
from starlette.schemas import SchemaGenerator, OpenAPIResponse
from starlette.staticfiles import StaticFiles
from starlette_prometheus import metrics, PrometheusMiddleware

logger = logging.getLogger()
logger.setLevel(logging.INFO)

loop = asyncio.get_event_loop()

app = Starlette(debug=('DEV' in os.environ), template_directory='templates')

app.schema_generator = SchemaGenerator(
    {"openapi": "3.0.0", "info": {"title": "Leaderboard", "version": "1.0"}}
)

app.add_middleware(PrometheusMiddleware)
app.add_route("/metrics/", metrics)

default_response = open('/code/static/index.html', 'r').read()

@app.route('/')
async def index(request):
  return HTMLResponse(default_response)

# Swagger spec

@app.route("/schema", methods=["GET"], include_in_schema=False)
def schema(request):
    return OpenAPIResponse(app.schema)
