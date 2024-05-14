{
  src,
  version,
  stdenv,
  makeWrapper,
  python3,
  ...
}:
let
  python_env = python3.withPackages (
    p:
    with p;
    [
      fastapi
      uvicorn
      pydantic
      python-multipart

      flask
      flask-cors

      python-socketio
      python-jose
      passlib
      # uuid # this is a standard python module

      requests
      aiohttp
      peewee
      peewee-migrate
      psycopg2
      pymysql
      bcrypt

      litellm

      boto3

      argon2-cffi
      APScheduler
      google-generativeai

      langchain
      langchain-community
      # langchain-chroma

      fake-useragent
      chromadb
      sentence-transformers
      pypdf
      docx2txt
      unstructured
      markdown
      pypandoc
      pandas
      openpyxl
      pyxlsb
      xlrd
      validators

      # opencv-python-headless
      # rapidocr-onnxruntime

      (fpdf2.overridePythonAttrs (old: {
        disabledTests = old.disabledTests ++ [
          "test_bidi_character" # tries to download file
          "test_bidi_conformance" # tries to download file
          "test_insert_jpg_jpxdecode" # JPEG2000 files are a PITA
        ];
      }))
      rank-bm25

      faster-whisper

      pyjwt

      # black
      # langfuse
      youtube-transcript-api
      pytube

      # missing?
      beautifulsoup4
    ]
    ++ uvicorn.optional-dependencies.standard
    ++ pyjwt.optional-dependencies.crypto
    ++ passlib.optional-dependencies.bcrypt
    ++ litellm.optional-dependencies.proxy
  );
in
stdenv.mkDerivation {
  pname = "open-webui-backend";
  inherit src version;

  dontBuild = true; # just need to copy python files

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    mkdir -p $out/bin
    cp -R ./backend $out/lib
    cp ./CHANGELOG.md $out/lib

    # install launcher for backend
    makeWrapper ${python_env}/bin/uvicorn $out/bin/open-webui \
      --append-flags "main:app --app-dir $out/lib/backend" \
      --suffix PATH : "${python_env}/bin/" \
      --chdir "$out/lib/backend"

    runHook postInstall
  '';

  # tries to copy favicon file, but Nix store is read-only so skip this step
  postInstall = ''
    substituteInPlace $out/lib/backend/config.py \
      --replace-warn "shutil.copyfile(frontend_favicon, f\"{STATIC_DIR}/favicon.png\")" \
        "pass"
  '';
}
