FROM prefecthq/prefect:2-python3.10-conda


COPY requirements.txt .
COPY setup.py .
COPY prefect_utils .

# Use the prefect environment by default
RUN echo "conda activate prefect" >> ~/.bashrc
RUN pip install --upgrade pip setuptools --no-cache-dir
RUN pip install --trusted-host pypi.python.org --no-cache-dir .

ARG PREFECT_API_KEY
ENV PREFECT_API_KEY=$PREFECT_API_KEY

ARG PREFECT_API_URL
ENV PREFECT_API_URL=$PREFECT_API_URL

ENV PYTHONUNBUFFERED True

COPY flows/ /opt/prefect/flows/
COPY start_prefect.sh opt/conda/bin/start_prefect.sh
ENTRYPOINT ["conda", "run", "--no-capture-output", "-v", "-n", "prefect", "/bin/bash", "--login", "-c"]
CMD ["prefect agent start -q test"]