FROM prefecthq/prefect:2-python3.10-conda

COPY environment.yml .
COPY pyproject.toml .
COPY poetry.lock .
COPY prefect_utils .

RUN apt-get update && apt-get install -y libarchive13

# RUN conda install gdal fiona rasterio && conda install tiledb -c conda-forge
RUN conda install -c conda-forge mamba
RUN mamba env update --prefix /opt/conda/envs/prefect -f environment.yml
RUN pip install --upgrade pip setuptools poetry --no-cache-dir
RUN conda activate /opt/conda/envs/prefect
#RUN pip install --trusted-host pypi.python.org --no-cache-dir .
RUN poetry install

ARG PREFECT_API_KEY
ENV PREFECT_API_KEY=$PREFECT_API_KEY

ARG PREFECT_API_URL
ENV PREFECT_API_URL=$PREFECT_API_URL

ENV PYTHONUNBUFFERED True

COPY xmatics/flows/ /opt/prefect/flows/

ENTRYPOINT ["/bin/bash", "--login", "-c", "prefect agent start -q cloudrun"]