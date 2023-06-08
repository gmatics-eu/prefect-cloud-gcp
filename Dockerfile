FROM prefecthq/prefect:2-python3.10-conda

COPY requirements.txt .
COPY setup.py .
COPY prefect_utils .

# Use the prefect environment by default
RUN echo "conda activate prefect" >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]
RUN pip install --upgrade pip setuptools --no-cache-dir
RUN pip install --trusted-host pypi.python.org --no-cache-dir .

ARG PREFECT_API_KEY
ENV PREFECT_API_KEY=$PREFECT_API_KEY

ARG PREFECT_API_URL
ENV PREFECT_API_URL=$PREFECT_API_URL

ENV PYTHONUNBUFFERED True

COPY flows/ /opt/prefect/flows/

ENTRYPOINT ["/bin/bash", "--login", "-c", "conda activate prefect && prefect agent start -q default"]
