FROM prefecthq/prefect:2-python3.10-conda

COPY environment.yml .
COPY requirements.txt .
COPY setup.cfg .
COPY setup.py .
COPY xmatics .

RUN apt-get update && apt-get install -y libarchive13

# RUN conda install gdal fiona rasterio && conda install tiledb -c conda-forge
RUN conda install -c conda-forge mamba
RUN mamba env update --prefix /opt/conda/envs/prefect -f environment.yml
RUN pip install --upgrade pip setuptools --no-cache-dir
RUN pip install --trusted-host pypi.python.org --no-cache-dir .

ARG PREFECT_API_KEY
ENV PREFECT_API_KEY=$PREFECT_API_KEY

ARG PREFECT_API_URL
ENV PREFECT_API_URL=$PREFECT_API_URL

ENV PYTHONUNBUFFERED True

COPY xmatics/flows/ /opt/prefect/flows/

ENTRYPOINT ["/bin/bash", "--login", "-c", "prefect agent start -q cloudrun"]