{
  pkgs,
  lib,
  stdenv,
  python3,
  fetchFromGitHub,
  makeWrapper,
}:
let
  version = "v0.1.123"; # version tag
  pname = "open-webui";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    hash = "sha256-GWNh6PAFhFVJEEnbE+XtxKUnDhBdAA1OtEW4SeJPbfA=";
  };

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

      # fpdf2 # currently breaking build
      rank-bm25

      faster-whisper

      pyjwt

      black
      # langfuse
      youtube-transcript-api

      # torch
      # torchvision
      # torchaudio

      # missing?
      beautifulsoup4
    ]
    ++ uvicorn.optional-dependencies.standard
    ++ pyjwt.optional-dependencies.crypto
  );

  # backend acts as reverse proxy, sending requests to ollama
  backend = pkgs.callPackage ./backend.nix { inherit src version; };

  # frontend is the static files
  frontend = pkgs.callPackage ./frontend.nix { inherit src version; };
in
stdenv.mkDerivation {
  inherit pname src version;

  nativeBuildInputs = [ makeWrapper ];

  # dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin

    ln -s ${backend}/lib/* $out/lib

    ln -s ${frontend}/lib/* $out/lib

    # install launcher for backend
    makeWrapper ${python_env}/bin/uvicorn $out/bin/openwebui-backend \
      --append-flags "main:app --app-dir $out/lib/backend" \
      --set-default "FRONTEND_BUILD_DIR" "$out/lib/build" \
      --chdir "$out/lib/backend"

    runHook postInstall
  '';
}
