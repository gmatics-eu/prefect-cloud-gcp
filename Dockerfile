FROM prefecthq/prefect:2-python3.10

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    bzip2 \
    && rm -rf /var/lib/apt/lists/*

# Set the environment variables needed for Miniconda
ENV PATH /opt/conda/bin:$PATH

# Download and install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tp && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

COPY requirements.txt .
COPY setup.py .
COPY prefect_utils .
COPY pyproject.toml .

# Use the prefect environment by default
RUN conda install gdal
RUN pip install --upgrade pip setuptools poetry --no-cache-dir
RUN poetry install



ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

ARG PREFECT_API_KEY
ENV PREFECT_API_KEY=$PREFECT_API_KEY

ARG PREFECT_API_URL
ENV PREFECT_API_URL=$PREFECT_API_URL

ENV PYTHONUNBUFFERED True

COPY flows/ /opt/prefect/flows/
COPY start_prefect.sh opt/conda/bin/start_prefect.sh


ENTRYPOINT ["prefect", "agent", "start", "-q", "default"]
#ENTRYPOINT ["conda", "run", "--no-capture-output", "-v", "-n", "prefect", "/bin/bash", "--login", "-c"]