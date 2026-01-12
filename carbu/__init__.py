import json
import subprocess
import threading
import uuid
from pathlib import Path

from flask import Flask, render_template, request, send_from_directory

app = Flask(__name__)

ROOT_DIR = Path(__file__).parent.parent

TEMPLATES_DIR = "typst-templates"
DOCUMENTS_DIR = ROOT_DIR / "documents"
BUILD_DIR = ROOT_DIR / "build"


@app.after_request
def disable_cache(response):
    """Disable caching for all responses to prevent Cloudflare and browser caching"""
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
    response.headers["ETag"] = None
    return response


def compile_typst_to_pdf(doc_id, data):
    """Background task to compile Typst template to PDF"""
    try:
        # Ensure documents directory exists
        BUILD_DIR.mkdir(parents=True, exist_ok=True)
        DOCUMENTS_DIR.mkdir(parents=True, exist_ok=True)
        data_file = BUILD_DIR / f"data-{doc_id}.json"

        with open(data_file, "w") as f:
            json.dump(data, f, indent=2)

        # Compile document
        output_pdf = DOCUMENTS_DIR / f"{doc_id}.pdf"
        result = subprocess.run(
            [
                "typst",
                "compile",
                "--root",
                str(ROOT_DIR),
                "--font-path",
                str(ROOT_DIR / "fonts"),
                "--input",
                f"data={str(data_file.relative_to(ROOT_DIR / TEMPLATES_DIR, walk_up=True))}",
                str(Path(TEMPLATES_DIR) / "facture.typ"),
                str(output_pdf),
            ],
            capture_output=True,
            text=True,
        )

        if result.returncode != 0:
            app.logger.error(f"Error compiling Typst: {result.stderr}")
        else:
            app.logger.info(f"Successfully generated PDF: {output_pdf}")
            data_file.unlink()  # Clean up data file after successful compilation

    except Exception as e:
        app.logger.exception(f"Error in background task: {e}")


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/build", methods=["POST"])
def build():
    doc_id = uuid.uuid1()

    # Start background task to compile PDF
    thread = threading.Thread(target=compile_typst_to_pdf, args=(doc_id, request.form))
    thread.daemon = True
    thread.start()

    return render_template("wait.html", id=doc_id)


@app.route("/download/")
def download():
    return render_template("download.html", id=request.args.get("id"))


@app.route("/doc/<path:filename>")
def custom_static(filename):
    return send_from_directory(str(DOCUMENTS_DIR), filename)
